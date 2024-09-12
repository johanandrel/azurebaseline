## Azure Storage (account + containers)

### Bakgrunn

Azure Storage bør bruke Entra ID for all authentisering og autorisering. Dette gjelder både administrasjon av Storage Account via f.eks. Terraform og tilgangsstyring til Storage Containers fra applikasjoner. 

### Løsning

#### Storage Account

Hovedinnstillingen for å skru av nøkler er å sette `shared_access_key_enabled = false` på en **Storage Account** via Terraform (i portalen står det under **Allow storage account key access** som skal være **disabled**). 

Vær oppmerksom på at når man setter denne til **false** på en Storage Account må man også sette `storage_use_azuread = true` i provider config (`provider.tf`) til `azurerm` provideren for at Terraform også skal bruke Entra ID for å gjøre operasjoner via Storage APIet. Hvis du ikke gjør dette så vil neste kjøring av Terraform feile fordi Terraform ikke lenger klarer å authentisere seg mot Storage APIet. 

Videre bør man sette følgende innstillinger på en **Storage Account** for å sørge for at authentisering og autorisering faktisk blir fulgt:

>`allow_nested_items_to_be_public = false`

Denne er spesielt viktig da den hindrer anonym tilgang til filer i **Storage Containers** under din **Storage Account**. Containere kan nemlig konfigureres med anonym tilgang til alle filene i en container hvis man setter `container_access_type = "blob"` på en **Storage Container** istedenfor `container_access_type = "private"` 

`allow_nested_items_to_be_public` setter i praksis `allowBlobPublicAccess` egenskapen i Azure og overstyrer innstillinger til **Containere** som er knyttet til gjeldende **Storage Account**. Ved opprettelse av ressurser via *portalen* er denne satt til `false` som standard for å låse muigheten til å konfigurere anonym tilgang, men i Terraform er denne **IKKE** satt til **false** som standard. Containere kan nemlig konfigureres med anonym tilgang til alle filene i en container hvis man setter `container_access_type = "blob"` eller `container_access_type = "container"` på en **Storage Container** istedenfor `container_access_type = "private"` 

Dette som gjør det lett å konfigurere en container feil og få uønskede konsekvenser. 

>`default_to_oauth_authentication = true`

Denne gjør at tilgang via portalen bruker Entra ID som standard hvis man skal inn på en Storage Account. Hvis denne ikke er på vil portalen prøve å bruke **access keys** også må brukeren klikke ("Switch to Microsoft Entra user account") for å bytte til Entra ID for sin sesjon noe som kan være forvirrende for brukere. 

>`local_user_enabled = false`

Denne skrur av lokale brukere som noen ganger blir brukt til f.eks. FTP-tilgang. I praksis setter den `isLocalUserEnabled` egenskapen i Azure. Ved opprettelse av ressurser via portalen er denne satt til `null` som standard, men i Terraform er denne satt til **true**, noe som kan få uønskede konsekvenser. 

#### Storage Container

>`container_access_type = "private"`

Dette er standard innstilling på en Storage Container og den eneste riktige innstillingen hvis man skal ha authentisering og autorisering på blobs i en container. Som nevnt under Storage Account så vil denne overstyres av `allow_nested_items_to_be_public = false`, hvis denne likevel settes til noe annet enn `container_access_type = "private"` 

Vær oppmerksom på at når man har skrudd av nøklene til en Storage Account kan ikke Terraform lenger endre `container_access_type` egenskapen på en container fordi denne egenskapen styres av en API som ikke støtter Entra ID. Dette er sjelden et problem i praksis da denne egenskapen sjelden endres. 

#### RBAC (tilgangsstyring/autorisasjon)

For å gi riktige rettigheter bruker man RBAC-roller for tilgangsstyring. Her bør man sette *scope* på rollene så spesifikt som mulig og med så lite rettigheter som mulig (principle of least privilege). Det vil si at man bør sette *scope* til én spesifikk Storage **Container** og ikke til en Storage **Account** hvis man skal gi tilgang fra en applikasjon til en samling med filer. Settes en RBAC-rolle på en Storage Account vil identiteten med rollen få implisitt tilgang til alle fremtidige Storage Containere under kontoen, noe som kan lede til access/privilege creep. 

De vanligste RBAC-rollene for Storage er:

- Storage Blob Data Reader (lese blobs)
- Storage Blob Data Contributor (lese/skrive/slette blobs)

Komplett liste over RBAC-roller for Storage finnes hos [Microsoft](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#storage) 

### Azure policy 

> #### Storage accounts should prevent shared key access
> - PolicyID: 8c6a50c6-9ffd-4ae7-986f-5fa6111f9a54
> - Ref: https://www.azadvertizer.net/azpolicyadvertizer/8c6a50c6-9ffd-4ae7-986f-5fa6111f9a54.html

**Vær oppmerksom på at denne policyen er *generelt* klassifisert som MEDIUM RISK i Advisor, men hvis innholdet i Storage Account er sensitivt kan denne bli klassifisert som CRITICAL av Defender (Defender policy er i preview pr. 10. september 2024).**

### Compliance

> #### Azure Security Benchmark v_3.0 
> - Control IM-1 - *Use centralized identity and authentication system*
> - Ref: https://learn.microsoft.com/en-us/security/benchmark/azure/mcsb-identity-management#im-1-use-centralized-identity-and-authentication-system 

> #### Azure Landing Zones (ALZ) Policy Initiative
> - Enforce recommended guardrails for Storage Account
> - Ref: https://www.azadvertizer.net/azpolicyinitiativesadvertizer/Enforce-Guardrails-Storage.html  

> #### CIS Controls v8 
> - 6.7
> - 12.5 	 	

> #### NIST SP 800-53 r4
> - AC-2 
> - AC-3 
> - IA-2 
> - IA-8

> #### PCI-DSS v3.2.1
> - 7.2 
> - 8.3