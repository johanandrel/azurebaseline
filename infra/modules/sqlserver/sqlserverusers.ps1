
# Generate SID (security identifier) based on given identity to be able to add external user to SQL database
[guid]$guid = [System.Guid]::Parse($env:identityId)

foreach ($byte in $guid.ToByteArray()) {
    $byteGuid += [System.String]::Format("{0:X2}", $byte)
}

$sid = "0x" + $byteGuid
Write-Output "Generated SID: $sid"

$token = az account get-access-token --resource "https://database.windows.net/" | ConvertFrom-Json
$connectionString = "Server=tcp:$env:serverName,1433;Initial Catalog=$env:databaseName;Encrypt=True;"

Write-Output "Using ConnectionString: $connectionString"

$sqlConnection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
$sqlConnection.AccessToken = $token.accessToken
$sqlConnection.Open()

# TYPE=X is used for inserting an AD group. Use TYPE=E if we want to insert a user instead.
if($env:identityIsGroup -eq $true){
    $sqlUserType = "TYPE=X"
}
else {
    $sqlUserType = "TYPE=E"
}

Write-Output "Using SQL-user: $sqlUserType..."

# Create external user with SID if it does not already exist
$userQuery = @"      
IF (SELECT DATABASE_PRINCIPAL_ID('$env:identityDisplayName')) IS NULL
    BEGIN
        CREATE USER [$env:identityDisplayName] WITH SID=$sid, $sqlUserType
        SELECT 'User $env:identityDisplayName created.'
    END
ELSE
    SELECT 'User $env:identityDisplayName already existed...'
"@

$userCommand = New-Object -Type System.Data.SqlClient.SqlCommand($userQuery, $sqlConnection)
$userResult = $userCommand.ExecuteScalar()
Write-Output("Result: $userResult")

$array = $env:databaseRoles -split ','

# Add external user to specific role(s) if not already member
foreach($item in $array){

$roleQuery = @" 
IF (IS_ROLEMEMBER('$item','$env:identityDisplayName')) = 0
    BEGIN
        ALTER ROLE $item ADD MEMBER [$env:identityDisplayName]
        SELECT 'Added $env:identityDisplayName to role $item.'
    END
ELSE
    SELECT '$env:identityDisplayName is already member of $item...'
"@

$roleCommand = New-Object -Type System.Data.SqlClient.SqlCommand($roleQuery, $sqlConnection)
$roleResult = $roleCommand.ExecuteScalar()
Write-Output("Result: $roleResult")
}

$sqlConnection.Close() 
