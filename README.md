# azurebaseline
Eksempler på konfigurasjon av Azure tjenester for å gi fornuftig sikkerhet. 

## SQL Server og databaser 

Hvordan sørge for å bruke Entra ID til authentisering og autorisasjon mot SQL Server og SQL databaser. Dette kan automatiseres ved hjelp av [Terraform og PowerShell](/sqlserver.md)

## Azure Storage 

Hvordan sørge for å bruke Entra ID og RBAC til authentisering og autorisasjon av Storage Accounts og filer i Storage Containere, både fra Terraform og fra applikasjoner. Målet er å hindre bruk av nøkler og SAS-tokens, samt unngå feilkonfigurering som kan lede til f.eks. anonym tilgang til filer. [Les videre her](/storage.md)

## Virtual machine (VM) & virtual machine scale sets

Hvordan skru på kryptering av VMer for å få tilsvarende kryptering som PaaS tjenester har som standard. I tillegg hvordan konfigurere VMer til å automatisk sjekke etter systemoppdateringer slik at de ikke blir stående med sårbarheter og utdatert programvare. [Les videre her](/vm.md)

