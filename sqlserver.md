## SQL Server 

### Bakgrunn

SQL-Server bør administreres ved å sette **Microsoft Entra admin** istedenfor å bruke admin brukernavn og passord. 
Videre bør man skru på **Microsoft Entra authentication only** for å deaktivere SQL authentisering på både server og databaser. 

På denne måten kan man knytte SQL-Server administrasjon til Entra grupper uten bruk av administrator brukere. Tilgang fra applikasjoner kan også styres via Entra grupper eller via en spesifikk identitet (managed identity) slik at man unngår bruk av passord ved tilkoblinger til databaser.

### Løsning

Se hvordan dette kan settes opp og automatiseres ved hjelp av eksempel/POC med [Terraform og PowerShell](/infra/modules/sqlserver)

### Azure policy 

> #### Azure SQL Database should have Microsoft Entra-only authentication
> - PolicySet: a55e4a7e-1b9c-43ef-b4b3-642f303804d6
> - Ref: https://www.azadvertizer.net/azpolicyinitiativesadvertizer/a55e4a7e-1b9c-43ef-b4b3-642f303804d6.html
>> - Policy ID: abda6d70-9778-44e7-84a8-06713e6db027
>> - Ref: https://www.azadvertizer.net/azpolicyadvertizer/abda6d70-9778-44e7-84a8-06713e6db027.html
>> - Policy ID: b3a22bc9-66de-45fb-98fa-00f5df42f41a
>> - Ref: https://www.azadvertizer.net/azpolicyadvertizer/b3a22bc9-66de-45fb-98fa-00f5df42f41a.html

### Compliance

> #### Azure Security Benchmark v_3.0 
> - Control IM-1 - *Use centralized identity and authentication system*
> - Ref: https://learn.microsoft.com/en-us/security/benchmark/azure/mcsb-identity-management#im-1-use-centralized-identity-and-authentication-system 

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