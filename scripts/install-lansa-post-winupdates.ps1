﻿<#
.SYNOPSIS

Install the remaining parts of the base LANSA image one Windows Updates has been applied.

.DESCRIPTION

These tasks must all occur after Windows Updates. If they can be applied earlier, they should be applied earlier

.EXAMPLE


#>
function Log-Date 
{
    ((get-date).ToUniversalTime()).ToString("yyyy-MM-dd HH:mm:ssZ")
}

param (
    [Parameter(Mandatory=$true)]
    [string]
    $GitRepoPath,

    [Parameter(Mandatory=$true)]
    [string]
    $TempPath
    )

$DebugPreference = "Continue"
$VerbosePreference = "Continue"

$script:IncludeDir = "$GitRepoPath\scripts"

Write-Debug "script:IncludeDir = $script:IncludeDir"

# Includes
. "$Script:IncludeDir\dot-createlicense.ps1"
. "$Script:IncludeDir\dot-Add-DirectoryToEnvPathOnce.ps1"
. "$script:IncludeDir\dot-New-ErrorRecord.ps1"
. "$script:IncludeDir\dot-Get-AvailableExceptionsList.ps1"


try
{
    Write-Output "$(Log-Date) Synchronise clock"

    cmd /c sc triggerinfo w32time start/networkon stop/networkoff

    Write-Output "$(Log-Date) Ensure that Framework caching is completed"

    cmd /c "C:\Windows\Microsoft.NET\Framework\v4.0.30319\Ngen" executequeueditems
    cmd /c "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Ngen" executequeueditems

    Write-Output "$(Log-Date) Configure EC2 Settings"
    &"$Script:IncludeDir\Ec2ConfigSettings.ps1" "$TempPath"

    Write-Output "$(Log-Date) Tidy up"

    cmd /c rd /S/Q $TempPath
    cmd /c del /F "$ENV:ProgramFiles\Amazon\Ec2ConfigService\Logs\*.txt"
}
catch
{
    Write-Error $(Get-Date) ($_ | format-list | out-string)
    throw
}