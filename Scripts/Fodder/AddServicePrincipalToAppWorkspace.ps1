cls

$appDisplayName = "App1"
$replyUrl = "https://localhost:44300"

$userName = "tedp@pbie2019.onMicrosoft.com"
$password = "Pa`$`$word!"
$securePassword = ConvertTo-SecureString –String $password –AsPlainText -Force
$credential = New-Object –TypeName PSCredential `
                         –ArgumentList $userName, $securePassword

$credential
$authResult = Connect-AzureAD -Credential $credential

Login-PowerBI -Credential $credential


$tenantId = $authResult.TenantId.ToString()
$tenantDomain = $authResult.TenantDomain
$tenantDisplayName = (Get-AzureADTenantDetail).DisplayName



$userAccountId = $authResult.Account.Id
$user = Get-AzureADUser -ObjectId $userAccountId
$userDisplayName = $user.DisplayName

# create app secret
$newGuid = New-Guid
$appSecret = ([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(($newGuid))))+"="
$startDate = Get-Date	
$passwordCredential = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordCredential
$passwordCredential.StartDate = $startDate
$passwordCredential.EndDate = $startDate.AddYears(1)
$passwordCredential.KeyId = $newGuid
$passwordCredential.Value = $appSecret 

Write-Host "Registering new app $appDisplayName in $tenantDomain"

# create Azure AD Application
$aadApplication = New-AzureADApplication `
                        -DisplayName $appDisplayName `
                        -PublicClient $false `
                        -AvailableToOtherTenants $false `
                        -ReplyUrls @($replyUrl) `
                        -Homepage $replyUrl `
                        -PasswordCredentials $passwordCredential

# create applicaiton's service principal 
$appId = $aadApplication.AppId
$appObjectId = $aadApplication.ObjectId
$servicePrincipal = New-AzureADServicePrincipal -AppId $appId
$servicePrincipalId = $servicePrincipal.ObjectId

# assign current user as owner
Add-AzureADApplicationOwner -ObjectId $aadApplication.ObjectId -RefObjectId $user.ObjectId

# add new app to Power BI Apps group
$adSecurityGroupName = "Power BI Apps"
$adSecurityGroup = Get-AzureADGroup -Filter "DisplayName eq '$adSecurityGroupName'"
$adSecurityGroupId = $adSecurityGroup.ObjectId

Add-AzureADGroupMember -ObjectId $($adSecurityGroup.ObjectId) -RefObjectId $($servicePrincipal.ObjectId)

Write-Host "Pausing for 15 seconds for Azure AD to create the service principal"
Start-Sleep -Seconds 15

Write-Host
$workspaceName = "My First App Workspace"
$workspace = Get-PowerBIWorkspace -Filter "name eq '$workspaceName'" # | where { $_.Name -eq $workspaceName }
$workspaceId = $workspace.Id
Write-Host "Workspace ID:"$workspaceId

function Get-PbiWorkspaceMembers([guid] $workspaceId){
    $headers = Get-PowerBIAccessToken
    $restUrl = "https://api.powerbi.com/v1.0/myorg/groups/" + $workspaceId + "/users/"
    $response = Invoke-RestMethod -Method Get -Headers $headers -Uri $restUrl
    return $response.value
}

function Add-ServicePrincipalToPowerBiWorkspace ([guid] $workspaceId, [guid] $servicePrincipalId) {
    $headers = Get-PowerBIAccessToken
    $restUrl = "https://api.powerbi.com/v1.0/myorg/groups/" + $workspaceId + "/users/"
    $postBody = '{ "groupUserAccessRight": "Admin", "identifier":"' + $servicePrincipalId + '", "principalType":"App"}'    
    Write-Host $postBody 
    Invoke-RestMethod -Method Post -Headers $headers -Uri $restUrl -ContentType "application/json" -Body $postBody
}

function Remove-ServicePrincipalFromPowerBiWorkspace ([guid] $workspaceId, [guid] $servicePrincipalId){
    Remove-PowerBIGroupUser -Id $workspaceId -UserPrincipalName $servicePrincipalId
}

function RemoveAll-ServicePrincipalsFromPowerBiWorkspace ([guid] $workspaceId){
    $appMembers = Get-PowerBiWorkspaceMembers -workspaceId $workspaceId | where { $_.principalType -eq "App"}    
    foreach($member in $appMembers) { 
        Remove-PowerBIGroupUser -Id $workspaceId -UserPrincipalName $member.identifier 
    }
}


Add-ServicePrincipalToPowerBiWorkspace -workspaceId $workspaceId -servicePrincipalId $servicePrincipalId
# Remove-ServicePrincipalFromPowerBiWorkspace -workspaceId $workspaceId -servicePrincipalId $servicePrincipalId


Get-PowerBiWorkspaceMembers $workspaceId | Format-Table displayName, identifier, principalType

$outputFile = "$PSScriptRoot\appinfo.txt"
Out-File -FilePath $outputFile -InputObject "--- Info for $appDisplayName ---"
Out-File -FilePath $outputFile -Append -InputObject "TenantId: $tenantId"
Out-File -FilePath $outputFile -Append -InputObject "AppId: $appId"
Out-File -FilePath $outputFile -Append -InputObject "AppSecret: $appSecret"
Out-File -FilePath $outputFile -Append -InputObject "Service Principal ID: $servicePrincipalId"
Out-File -FilePath $outputFile -Append -InputObject "ReplyUrl: $replyUrl"

Notepad $outputFile
