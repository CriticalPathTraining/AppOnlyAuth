cls


$appDisplayName = "Mila App"
$replyUrl = "https://localhost:44300"

$userName = "tedp@pbierox.onMicrosoft.com"
$password = "Pa`$`$word!"
$securePassword = ConvertTo-SecureString –String $password –AsPlainText -Force
$credential = New-Object –TypeName System.Management.Automation.PSCredential `
                         –ArgumentList $userName, $securePassword

$credential
$authResult = Connect-AzureAD -Credential $credential

$tenantId = $authResult.TenantId.ToString()
$tenantDomain = $authResult.TenantDomain
$tenantDisplayName = (Get-AzureADTenantDetail).DisplayName



$userAccountId = $authResult.Account.Id
$user = Get-AzureADUser -ObjectId $userAccountId
$userDisplayName = $user.DisplayName
