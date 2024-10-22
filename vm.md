## Virtual machine (VM) & virtual machine scale sets

### Bakgrunn

Virtuelle maskiner (VMer) i Azure bør skru på *encryption at host* for å få ende-til-ende kryptering av dataene sine. I motsetning til PaaS-ressurser (SQL, Storage etc.) er dette **ikke** standard på VMer. 

VMer bør også konfigureres til å automatisk sjekke etter systemoppdateringer slik at de ikke blir stående med sårbarheter og utdatert programvare 

### Løsning

#### Encryption at host

Hovedinnstillingen for å skru på kryptering er å sette `encryption_at_host_enabled = true` på en **Virtual machine** ressurs via Terraform. 

I portalen står det under **Properties -> Disk - > Encryption at host** som skal være **enabled**. Merk at man må ha en VM som støtter kryptering. De rimeligste VMene støtter typisk ikke dette. 

Vær oppmerksom på at når man setter denne til **true** på en VM så kan det hende man får feil i Terraform fordi den underliggende featuren som kreves ikke er aktivert i din aktuelle subscription. Hvis man har andre VMer i samme subscription med kryptering er dette trolig allerede på plass. Terraform *skal* aktivere de nødvendige features automatisk, men vi har sett mange eksempler på at `Microsoft.Compute` er registrert, men ikke den påkrevde `EncryptionAtHost` som er en sub-dependency til `Microsoft.Compute`

For å bøte på dette kan man bruke `az cli` for å registrere featuren riktig. Følgende workaround kan brukes ved hjelp av en *null_resource* i Terraform som vil registrere `EncryptionAtHost`featuren:  

```
resource "null_resource" "encryptionathost" {
  provisioner "local-exec" {
    command = "az feature register --namespace Microsoft.Compute --name EncryptionAtHost"
  }
}
```

#### Machines should be configured to periodically check for missing system updates

Hovedinnstillingen for å skru på periodisk sjekk for systemoppdateringer er å sette `patch_assessment_mode = "AutomaticByPlatform"` på en **Virtual machine** ressurs via Terraform. 

I portalen står det under **Operations -> Updates - > Periodic assessment** som skal være **Yes**. Dette gjør at VMen scannes automatisk hvert døgn. 

### Azure policy & compliance

> #### Virtual machines and virtual machine scale sets should have encryption at host enabled
> - PolicyID: fc4d8e41-e223-45ea-9bf5-eada37891d87
> - Ref: https://www.azadvertizer.net/azpolicyadvertizer/fc4d8e41-e223-45ea-9bf5-eada37891d87.html
> - Microsoft cloud security benchmark: PV-6
> - CIS Microsoft Azure Foundations Benchmark: 2.1


> #### Machines should be configured to periodically check for missing system updates
> - PolicyID: bd876905-5b84-4f73-ab2d-2e7a7c4568d9
> - Ref: https://www.azadvertizer.net/azpolicyadvertizer/bd876905-5b84-4f73-ab2d-2e7a7c4568d9.html
> - Microsoft cloud security benchmark: DP-4

