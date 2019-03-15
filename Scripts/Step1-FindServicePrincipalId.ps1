$userName = "tedp@pbie2019.onMicrosoft.com"
$password = "Pa`$`$word!"
$securePassword = ConvertTo-SecureString –String $password –AsPlainText -Force
$credential = New-Object –TypeName System.Management.Automation.PSCredential `
                         –ArgumentList $userName, $securePassword

# connect to Azure AD
$authResult = Connect-AzureAD -Credential $credential

$adApplicationName = "App-only Demo App"

$servicePrincipal = Get-AzureADServicePrincipal -Filter "DisplayName eq '$adApplicationName'"

$servicePrincipal | Format-List DisplayName, AppId, ObjectId