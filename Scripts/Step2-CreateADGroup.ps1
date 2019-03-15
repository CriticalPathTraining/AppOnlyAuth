$userName = "tedp@pbie2019.onMicrosoft.com"
$password = "Pa`$`$word!"
$securePassword = ConvertTo-SecureString –String $password –AsPlainText -Force
$credential = New-Object –TypeName System.Management.Automation.PSCredential `
                         –ArgumentList $userName, $securePassword

# connect to Azure AD
$authResult = Connect-AzureAD -Credential $credential

$adSecurityGroupName = "Power BI Apps"

$adSecurityGroup = 
`New-AzureADGroup `
    -DisplayName $adSecurityGroupName `
    -SecurityEnabled $true `
    -MailEnabled $false `
    -MailNickName notSet

$adSecurityGroup | Format-Table DisplayName, ObjectId