cls

$userName = "tedp@pbierox.onMicrosoft.com"
$password = "Pa`$`$word!"
$securePassword = ConvertTo-SecureString –String $password –AsPlainText -Force
$credential = New-Object –TypeName System.Management.Automation.PSCredential `
                         –ArgumentList $userName, $securePassword

#Connect-AzureAD -Credential $credential
#Login-PowerBI -Credential $credential

$adSecurityGroupName = "Power BI Apps"
$adSecurityGroup = Get-AzureADGroup -Filter "DisplayName eq '$adSecurityGroupName'"

$adApplicationName = "App-only Demo App"
$servicePrincipal = Get-AzureADServicePrincipal -Filter "DisplayName eq '$adApplicationName'"
Write-Host "SP Object ID:" + $servicePrincipal.ObjectId

Write-Host
$workspaceName = "My First App Workspace"
$workspace = Get-PowerBIWorkspace -Filter "name eq '$workspaceName'" # | where { $_.Name -eq $workspaceName }
$workspaceId = $workspace.Id
Write-Host "Workspace ID:" + $workspaceId

$restUrl = "https://api.powerbi.com/v1.0/myorg/groups/" + $workspaceId + "/users/"
$headers = Get-PowerBIAccessToken

$postBody = '{ "groupUserAccessRight": "Admin", "identifier":"' + $servicePrincipal.ObjectId + '", "principalType":"App"}'
Invoke-RestMethod -Method Post -Headers $headers -Uri $restUrl -ContentType "application/json" -Body $postBody

$result = Invoke-RestMethod -Headers $headers -Uri $restUrl
$result.value | Format-Table displayName, principalType, identifier, groupUserAccessRight
