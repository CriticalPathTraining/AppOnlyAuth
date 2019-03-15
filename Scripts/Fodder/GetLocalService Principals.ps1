cls
# sign-in info for script runner
$userName = "ted@tedworld.onMicrosoft.com"
$password = "Pa`$`$word!"
$securePassword = ConvertTo-SecureString –String $password –AsPlainText -Force
$credential = New-Object –TypeName System.Management.Automation.PSCredential `
                         –ArgumentList $userName, $securePassword

# connect to Azure AD
$authResult = Connect-AzureAD -Credential $credential
$tenantId = $authResult.TenantId

ForEach($adApp in Get-AzureADApplication) {
 Write-Host $adApp.DisplayName
 $appId = $adApp.AppId
 $adServicePrincipal = Get-AzureADServicePrincipal -Filter "AppId eq '$appId'"
 Write-Host " Service Principal: " $adServicePrincipal.ObjectId
 Write-Host
}