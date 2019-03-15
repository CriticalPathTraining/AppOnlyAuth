cls

$userName = "student@bbspa2019.onMicrosoft.com"
$password = "Pa`$`$word!"
$securePassword = ConvertTo-SecureString –String $password –AsPlainText -Force
$credential = New-Object –TypeName System.Management.Automation.PSCredential `
                         –ArgumentList $userName, $securePassword

$authResult = Connect-AzureAD -Credential $credential

# get more info about the logged in user
$user = Get-AzureADUser -ObjectId $authResult.Account.Id

# create Azure AD application
$adAppDisplayName = "Test Application 3" 

# create Azure AD Application
$adApp = New-AzureADApplication -DisplayName $adAppDisplayName `
                                -Homepage "https://localhost:44300" `
                                -ReplyUrls "https://localhost:44300"

                                
# assign current user as application owner
Add-AzureADApplicationOwner -ObjectId $adApp.ObjectId -RefObjectId $user.ObjectId


# create AD service principal for AD application
$adServicePrincipal = New-AzureADServicePrincipal -AppId $adApp.AppId

$key = New-AzureADServicePrincipalPasswordCredential -ObjectId $adServicePrincipal.ObjectId 

Write-Host "App ID:"$adApp.AppId

Write-Host "App Secret:"$key.Value

Write-Host
