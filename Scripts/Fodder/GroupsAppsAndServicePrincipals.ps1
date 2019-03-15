cls

$userName = "student@bbspa2019.onMicrosoft.com"
$password = "Pa`$`$word!"

$adGroupName = "AOD Group"
$adApplicationName = "AOD Application"
$replyUrl = "https://localhost:44300"

$outputFile = "$PSScriptRoot\AppOwnsDataAppOnly.txt"
$newline = "`r`n"
Write-Host "Getting Power BI App-only Objects"
Write-Host 
$securePassword = ConvertTo-SecureString –String $password –AsPlainText -Force
$credential = New-Object –TypeName System.Management.Automation.PSCredential `
                         –ArgumentList $userName, $securePassword

$authResult = Connect-AzureAD -Credential $credential

$adGroup = Get-AzureADGroup -Filter "DisplayName eq 'AppOwnsDataAppOnly'"
$adGroupDisplayName = $adGroup.DisplayName
$adGroupObjectId = $adGroup.ObjectId
Write-Host "Azure AD Group: $adGroupDisplayName (ObjectId=$adGroupObjectId)" 

Write-Host 
$adApp = Get-AzureADApplication -Filter "DisplayName eq 'AppOwnsDataAppOnly'"
$adAppDisplayName = $adApp.DisplayName
$adAppObjectId = $adApp.ObjectId
$adAppAppId = $adApp.AppId
Write-Host "Azure AD Application: $adAppDisplayName (ObjectId=$adAppObjectId, AppId=$adAppAppId)" 

Write-Host 