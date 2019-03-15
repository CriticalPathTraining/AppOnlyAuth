cls

$userName = "student@bbspa2019.onMicrosoft.com"
$password = "Pa`$`$word!"


$outputFile = "$PSScriptRoot\AppOwnsDataAppOnly.txt"
$newline = "`r`n"
Write-Host "Getting Power BI App-only Objects"
Write-Host 
$securePassword = ConvertTo-SecureString –String $password –AsPlainText -Force
$credential = New-Object –TypeName System.Management.Automation.PSCredential `
                         –ArgumentList $userName, $securePassword

$authResult = Connect-AzureAD -Credential $credential

# create Azure AD App
$appDisplayName = "Test1 Application"
$replyUrl = "https://localhost:44300"

$adApp = New-AzureADApplication -DisplayName $appDisplayName `
                                -Homepage $replyUrl `
                                -ReplyUrls $replyUrl

$adServicePrincipal = New-AzureADServicePrincipal -AppId $adApp.AppId

# Get the service principal key.
$key = New-AzureADServicePrincipalPasswordCredential -ObjectId $adServicePrincipal.ObjectId `
                                                     -CustomKeyIdentifier "Key1"

$key

Write-Host 

$adAppDisplayName = $adApp.DisplayName
$adAppObjectId = $adApp.ObjectId
$adAppAppId = $adApp.AppId
Write-Host "Azure AD Application: $adAppDisplayName (ObjectId=$adAppObjectId, AppId=$adAppAppId)" 

$adServicePrincipalObjectId = $adServicePrincipal.ObjectId
Write-Host "Azure AD Service Principal: (ObjectId=$$adServicePrincipalObjectId)" 

# Create an AAD security group
$appGroupName =  "Test1 Group"
$adGroup = New-AzureADGroup -DisplayName $appGroupName -SecurityEnabled $true -MailEnabled $false -MailNickName notSet

# Add the service principal to the group
Add-AzureADGroupMember -ObjectId $($adGroup.ObjectId) -RefObjectId $($adServicePrincipal.ObjectId)

$adGroupDisplayName = $adGroup.DisplayName
$adGroupObjectId = $adGroup.ObjectId
Write-Host "Azure AD Group: $adGroupDisplayName (ObjectId=$adGroupObjectId)" 

Write-Host 
Write-Host "Group membership:"
Get-AzureADGroupMember -ObjectId $adgroup.ObjectId | Format-Table ObjectType, DisplayName, AppId, ObjectId