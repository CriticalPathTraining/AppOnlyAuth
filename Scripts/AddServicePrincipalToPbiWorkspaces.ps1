cls

$userName = "tedp@pbie2019.onMicrosoft.com"
$password = "Pa`$`$word!"
$securePassword = ConvertTo-SecureString –String $password –AsPlainText -Force
$credential = New-Object –TypeName System.Management.Automation.PSCredential `
                         –ArgumentList $userName, $securePassword

#Connect-AzureAD -Credential $credential
#Login-PowerBI -Credential $credential

$adSecurityGroupName = "Power BI Apps"
$adSecurityGroup = Get-AzureADGroup -Filter "DisplayName eq '$adSecurityGroupName'"
$adSecurityGroupId = $adSecurityGroup.ObjectId

$adApplicationName = "App-only Demo App"
$servicePrincipal = Get-AzureADServicePrincipal -Filter "DisplayName eq '$adApplicationName'"
$servicePrincipalId = $servicePrincipal.ObjectId

Write-Host "SP Object ID:" $servicePrincipalId

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


# Add-ServicePrincipalToPowerBiWorkspace -workspaceId $workspaceId -servicePrincipalId $servicePrincipalId
# Remove-ServicePrincipalFromPowerBiWorkspace -workspaceId $workspaceId -servicePrincipalId $servicePrincipalId


Get-PowerBiWorkspaceMembers $workspaceId | Format-Table displayName, identifier, principalType
