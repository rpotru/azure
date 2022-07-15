# Get the expiring service principals after querying the Azure Active Directory applications.

$applications = Get-AzADApplication
$servicePrincipals = Get-AzADServicePrincipal

$appWithCredentials = @()
$appWithCredentials += $applications | Sort-Object -Property DisplayName | % {
    $application = $_
    $sp = $servicePrincipals | ? ApplicationId -eq $application.ApplicationId
    Write-Verbose ('Fetching information for application {0}' -f $application.DisplayName)
    $application | Get-AzADAppCredential -ErrorAction SilentlyContinue | Select-Object -Property @{Name = 'DisplayName'; Expression = { $application.DisplayName } }, @{Name = 'ObjectId'; Expression = { $application.Id } }, @{Name = 'ApplicationId'; Expression = { $application.ApplicationId } }, @{Name = 'KeyId'; Expression = { $_.KeyId } }, @{Name = 'Type'; Expression = { $_.Type } }, @{Name = 'StartDate'; Expression = { $_.StartDate -as [datetime] } }, @{Name = 'EndDate'; Expression = { $_.EndDate -as [datetime] } }
}

Write-Host 'Validating expiration data...'
$today = (Get-Date).ToUniversalTime()
$limitDate = $today.AddDays($ExpiresInDays)
$appWithCredentials | Sort-Object EndDate | % {
    if ($_.EndDate -lt $today) {
        $_ | Add-Member -MemberType NoteProperty -Name 'Status' -Value 'Expired'
    }
    elseif ($_.EndDate -le $limitDate) {
        $_ | Add-Member -MemberType NoteProperty -Name 'Status' -Value 'ExpiringSoon'
    }
    else {
        $_ | Add-Member -MemberType NoteProperty -Name 'Status' -Value 'Valid'
    }
}

$ExpiringAppCredentials = $appWithCredentials | ? { $_.Status -eq 'Expired' -or $_.Status -eq 'ExpiringSoon' } | Sort-Object -Property DisplayName
$ExpiringAppCredentialsString = $ExpiringAppCredentials | Out-String
Write-Host $ExpiringAppCredentials7
