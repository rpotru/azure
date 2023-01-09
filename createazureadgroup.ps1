<#
 # The following script will take the inputs of azure ad group name as a string and will create a "Security Group"}
 # Connect-AzAccount is a prerequisite to connect to subscription and authenticate.
 # 
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [String] $adgroupname = "testraj876"

)
# $adgroupname = "testraj876"
New-AzADGroup -DisplayName $adgroupname -Description "Testing purpose" -MailNickname "NotSet" -MailEnabled $false -SecurityEnabled $true
