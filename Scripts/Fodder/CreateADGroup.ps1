cls

$adSecurityGroupName = "Power BI Apps"

# sign-in info for script runner
$userName = "ted@tedworld.onMicrosoft.com"
$password = "Pa`$`$word!"
$securePassword = ConvertTo-SecureString –String $password –AsPlainText -Force
$credential = New-Object –TypeName System.Management.Automation.PSCredential `
                         –ArgumentList $userName, $securePassword

# connect to Azure AD
$authResult = Connect-AzureAD -Credential $credential


# Create an AAD security group
$adSecurityGroup = Get-AzureADGroup -Filter "DisplayName eq '$adSecurityGroupName'"

if(!$adSecurityGroup){
    Write-Host "Creating new AD security group $adSecurityGroupName"
    $adSecurityGroup = New-AzureADGroup `
        -DisplayName $adSecurityGroupName `
        -SecurityEnabled $true `
        -MailEnabled $false `
        -MailNickName notSet
}

$adSecurityGroup | Format-Table DisplayName, ObjectId

$appName = "Ted App 1"
$servicePrincipal = Get-AzureADServicePrincipal -Filter "DisplayName eq '$appName'"
$servicePrincipal.DisplayName
$servicePrincipal.ObjectId

Write-Host
Write-Host "Group Memebers"


# Add the service principal to the group
Add-AzureADGroupMember -ObjectId $($adSecurityGroup.ObjectId) -RefObjectId $($servicePrincipal.ObjectId)

Get-AzureADGroupMember -ObjectId $adSecurityGroup.ObjectId

