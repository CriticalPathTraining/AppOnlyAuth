cls
$userName = "tedp@pbie2019.onMicrosoft.com"
$password = "Pa`$`$word!"
$securePassword = ConvertTo-SecureString –String $password –AsPlainText -Force
$credential = New-Object –TypeName PSCredential `
                         –ArgumentList $userName, $securePassword


$authResult = Connect-AzureAD -Credential $credential

$pbiauth = Login-PowerBI -Credential $credential

$workspaceName = "Test 1"
$workspace = Get-PowerBIWorkspace -Filter "name eq 'Test 1'" # | where { $_.Name -eq $workspaceName }
$workspaceId = $workspace.Id
Write-Host "Workspace ID:"$workspaceId
