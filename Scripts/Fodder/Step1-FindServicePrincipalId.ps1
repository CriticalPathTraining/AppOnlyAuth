# connect to Azure AD
$authResponse = Connect-AzureAD

$adApplicationName = "App-only Demo App"

$servicePrincipal = Get-AzureADServicePrincipal -Filter "DisplayName eq '$adApplicationName'"

$servicePrincipal | Format-List DisplayName, AppId, ObjectId