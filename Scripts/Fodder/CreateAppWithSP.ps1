# The app id - $app.appid
# The service principal object id - $sp.objectId
# The app key - $key.value


$userName = "student@bbspa2019.onMicrosoft.com"
$password = "Pa`$`$word!"

$appGroupName = "AppOwnsDataAppOnly"
$appDisplayName = "AppOwnsDataAppOnly"
$replyUrl = "https://localhost:44300"

$outputFile = "$PSScriptRoot\AppOwnsDataAppOnly.txt"
$newline = "`r`n"
Write-Host "Writing info to $outputFile"

$securePassword = ConvertTo-SecureString –String $password –AsPlainText -Force
$credential = New-Object –TypeName System.Management.Automation.PSCredential `
                         –ArgumentList $userName, $securePassword

$authResult = Connect-AzureAD -Credential $credential


# Create a new AAD web application
$app = New-AzureADApplication -DisplayName $appDisplayName -Homepage $replyUrl -ReplyUrls $replyUrl

# Creates a service principal
$sp = New-AzureADServicePrincipal -AppId $app.AppId

# Get the service principal key.
$key = New-AzureADServicePrincipalPasswordCredential -ObjectId $sp.ObjectId


# Create an AAD security group
$group = New-AzureADGroup -DisplayName $appGroupName -SecurityEnabled $true -MailEnabled $false -MailNickName notSet

# Add the service principal to the group
Add-AzureADGroupMember -ObjectId $($group.ObjectId) -RefObjectId $($sp.ObjectId)