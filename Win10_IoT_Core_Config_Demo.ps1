#region Readme #####################################################################
# This demo script is intended to be run on against a Windows 10 IoT Core device.
#
# This can be achieved by first obtaining a Raspberry Pi 2 or Raspberry Pi 3B.
#
# Note that the Raspberry Pi 3A+ and 3B+ requires some low-level driver configuration
# due to limited support from Microsoft, so it's best to avoid them for quick testing.
#
# Finally, note that the Raspberry Pi 4 and Raspberry Pi 5 are not supported.
#
# The Raspberry Pi 1, Raspberry Pi Zero and Raspberry Pi Zero W are not supported with
# Windows 10 IoT Coreand they are incompatible with PowerShell Core 6 and PowerShell 7
# due to .NET Core lacking support for their CPUs.
#
# Status of other Raspberry Pi devices (compute module) is unknown
#
# With the correct device, use the "Windows 10 IoT Core Dashboard" to flash a microSD
# card with the Windows 10 IoT Core image.
#
# I tested this against Windows 10 1809 on a Raspberry Pi 2 (exact version was
# 10.0.17763.107)
#region Readme #####################################################################

#region License ################################################################
# Copyright 2024 Frank Lesniak

# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in the
# Software without restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
# Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
# AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#endregion License ################################################################

#region Part 0: Load required functions ############################################
function Get-FolderPathContainingScript {
    # Returns the path to the folder containing the running script. If no script is
    # running, the function returns the current path
    #
    # Example:
    # Get-FolderPathContainingScript
    #
    # This example returns the folder that contains the currently running script. Or,
    # if no script is running, the function returns the current folder
    #
    # The function outputs a [string] object representing the path to the folder
    #
    # PowerShell v1 - v2 do not have a $PSScriptRoot variable, so this function uses
    # other methods to determine the script directory
    #
    # Version 1.0.20240930.1

    #region License ############################################################
    # Copyright (c) 2024 Frank Lesniak
    #
    # Permission is hereby granted, free of charge, to any person obtaining a copy
    # of this software and associated documentation files (the "Software"), to deal
    # in the Software without restriction, including without limitation the rights
    # to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    # copies of the Software, and to permit persons to whom the Software is
    # furnished to do so, subject to the following conditions:
    #
    # The above copyright notice and this permission notice shall be included in
    # all copies or substantial portions of the Software.
    #
    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    # AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    # SOFTWARE.
    #endregion License ############################################################

    #region DownloadLocationNotice #############################################
    # The most up-to-date version of this script can be found on the author's
    # GitHub repository at https://github.com/franklesniak/PowerShell_Resources
    #endregion DownloadLocationNotice #############################################

    function Get-PSVersion {
        # Returns the version of PowerShell that is running, including on the original
        # release of Windows PowerShell (version 1.0)
        #
        # Example:
        # Get-PSVersion
        #
        # This example returns the version of PowerShell that is running. On versions
        # of PowerShell greater than or equal to version 2.0, this function returns the
        # equivalent of $PSVersionTable.PSVersion
        #
        # The function outputs a [version] object representing the version of
        # PowerShell that is running
        #
        # PowerShell 1.0 does not have a $PSVersionTable variable, so this function
        # returns [version]('1.0') on PowerShell 1.0
        #
        # Version 1.0.20240917.0

        #region License ############################################################
        # Copyright (c) 2024 Frank Lesniak
        #
        # Permission is hereby granted, free of charge, to any person obtaining a copy
        # of this software and associated documentation files (the "Software"), to deal
        # in the Software without restriction, including without limitation the rights
        # to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
        # copies of the Software, and to permit persons to whom the Software is
        # furnished to do so, subject to the following conditions:
        #
        # The above copyright notice and this permission notice shall be included in
        # all copies or substantial portions of the Software.
        #
        # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        # AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
        # SOFTWARE.
        #endregion License ############################################################

        #region DownloadLocationNotice #############################################
        # The most up-to-date version of this script can be found on the author's
        # GitHub repository at https://github.com/franklesniak/PowerShell_Resources
        #endregion DownloadLocationNotice #############################################

        if (Test-Path variable:\PSVersionTable) {
            return ($PSVersionTable.PSVersion)
        } else {
            return ([version]('1.0'))
        }
    }

    $strFolderPathContainingScript = ''
    if (Test-Path variable:\PSScriptRoot) {
        # $PSScriptRoot exists
        if (-not [string]::IsNullOrEmpty($PSScriptRoot)) {
            $strFolderPathContainingScript = $PSScriptRoot
        }
    }

    if ([string]::IsNullOrEmpty($strFolderPathContainingScript)) {
        # $PSScriptRoot does not exist or is empty
        # Either PowerShell v1 or v2 is running, or there may not be a script running

        $strScriptPath = ''
        if (Test-Path variable:\HostInvocation) {
            # Edge case for Sapien PrimalScript/PowerShell Studio
            $strScriptPath = $HostInvocation.MyCommand.Path
        } elseif (Test-Path variable:script:MyInvocation) {
            $strScriptPath = (Get-Variable MyInvocation -Scope Script).Value.MyCommand.Definition
        }

        if (-not [string]::IsNullOrEmpty($strScriptPath)) {
            # $strScriptPath would be the path to a script file, if we are, in fact,
            # running inside a script.
            # Otherwise, $strScriptPath would be the last command that was run, in
            # which case Test-Path would fail.
            if (Test-Path $strScriptPath) {
                $strFolderPathContainingScript = (Split-Path $strScriptPath)
            }
        }

        if ([string]::IsNullOrEmpty($strFolderPathContainingScript)) {
            $strFolderPathContainingScript = (Get-Location).Path
            if ($Host.Name -eq 'ConsoleHost' -or $Host.Name -eq 'ServerRemoteHost' -or $Host.Name -eq 'Windows PowerShell ISE Host' -or $Host.Name -eq 'Visual Studio Code Host') {
                $versionPS = Get-PSVersion
                $strMessage = 'Get-FolderPathContainingScript: There does not appear to be a script running; the current directory <' + $strFolderPathContainingScript + '> will be used.'
                if ($versionPS.Major -ge 5) {
                    Write-Information $strMessage
                } else {
                    Write-Host $strMessage
                }
            } else {
                Write-Warning ('Get-FolderPathContainingScript: Powershell Host <' + $Host.Name + '> may not be compatible with this function, the current directory <' + $strFolderPathContainingScript + '> will be used.')
            }
        }
    }

    return $strFolderPathContainingScript
}
function Get-PSVersion {
    # Returns the version of PowerShell that is running, including on the original
    # release of Windows PowerShell (version 1.0)
    #
    # Example:
    # Get-PSVersion
    #
    # This example returns the version of PowerShell that is running. On versions
    # of PowerShell greater than or equal to version 2.0, this function returns the
    # equivalent of $PSVersionTable.PSVersion
    #
    # The function outputs a [version] object representing the version of
    # PowerShell that is running
    #
    # PowerShell 1.0 does not have a $PSVersionTable variable, so this function
    # returns [version]('1.0') on PowerShell 1.0
    #
    # Version 1.0.20240917.0

    #region License ############################################################
    # Copyright (c) 2024 Frank Lesniak
    #
    # Permission is hereby granted, free of charge, to any person obtaining a copy
    # of this software and associated documentation files (the "Software"), to deal
    # in the Software without restriction, including without limitation the rights
    # to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    # copies of the Software, and to permit persons to whom the Software is
    # furnished to do so, subject to the following conditions:
    #
    # The above copyright notice and this permission notice shall be included in
    # all copies or substantial portions of the Software.
    #
    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    # AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    # SOFTWARE.
    #endregion License ############################################################

    #region DownloadLocationNotice #############################################
    # The most up-to-date version of this script can be found on the author's
    # GitHub repository at https://github.com/franklesniak/PowerShell_Resources
    #endregion DownloadLocationNotice #############################################

    if (Test-Path variable:\PSVersionTable) {
        return ($PSVersionTable.PSVersion)
    } else {
        return ([version]('1.0'))
    }
}
#endregion Part 0: Load required functions ############################################

#region Part 1: Copy scripts to the target system using remote PSSession ###########
# NOTE: Before starting, make sure your working directory is the root of this
# repository! Otherwise you will have a failure to copy files.

$strWin10IoTCoreDeviceIPOrHostname = "10.1.2.137"
$strWin10IoTCoreUsername = "Administrator"
$strCurrentFolder = Get-FolderPathContainingScript
$strPathToInvokeX86ExeScript = Join-Path $strCurrentFolder 'Win10_IoT_Core'
$strPathToInvokeX86ExeScript = Join-Path $strPathToInvokeX86ExeScript 'Invoke-x86Exe.ps1'
$strPathToTestPowerShellModuleInstalledScript = Join-Path $strCurrentFolder 'Win10_IoT_Core'
$strPathToTestPowerShellModuleInstalledScript = Join-Path $strPathToTestPowerShellModuleInstalledScript 'Test-PowerShellModuleInstalled.ps1'

$versionPS = Get-PSVersion

$credential = Get-Credential $strWin10IoTCoreUsername
$PSSession = New-PSSession -ComputerName $strWin10IoTCoreDeviceIPOrHostname -Credential $credential

$strWin10IoTCoreDownloadPathRoot = ("C:\Data\Users\" + $strWin10IoTCoreUsername + "\Downloads")

if ($versionPS.Major -ge 5) {
    Copy-Item $strPathToInvokeX86ExeScript -Destination $strWin10IoTCoreDownloadPathRoot -ToSession $PSSession -Force
    Copy-Item $strPathToTestPowerShellModuleInstalledScript -Destination $strWin10IoTCoreDownloadPathRoot -ToSession $PSSession -Force
} else {
    Write-Error "Cannot copy a file to a PSSession on PowerShell v4 and previous; need to identify and write workaround!"
}
#endregion Part 1: Copy scripts to the target system using remote PSSession ###########

#region Part 2: Connect to Windows 10 IoT Core and re-define functions #############
Enter-PSSession -Session $PSSession

function Get-DownloadFolder {
    if (Test-Path variable:\HOME) {
        $strBasePath = $HOME
    } elseif (Test-Path env:\USERPROFILE) {
        $strBasePath = $env:USERPROFILE
    } else {
        $strBasePath = $null
    }

    if ($null -ne $strBasePath) {
        $strDownloads = Join-Path $strBasePath "Downloads"
        if ((Test-Path $strDownloads) -eq $false) {
            New-Item -Path $strDownloads -ItemType Directory | Out-Null
        }
        $strDownloads
    } else {
        Write-Warning "Get-DownloadFolder was unable to locate suitable folder path for downloads. Returning `$null"
        $null
    }
}
#endregion Part 2: Connect to Windows 10 IoT Core and re-define functions #############

#region Part 3: Try some things on Windows 10 IoT Core #############################
$strDownloadFolder = Get-DownloadFolder
$strPathToInvokeX86ExeScript = Join-Path $strDownloadFolder 'Invoke-x86Exe.ps1'
$strPathToTestPowerShellModuleInstalledScript = Join-Path $strDownloadFolder 'Test-PowerShellModuleInstalled.ps1'

# This script downloads Streams for Sysinternals and attempts to run it:
& $strPathToInvokeX86ExeScript
# Did it work? Why or why not?

# Hint:
$env:PROCESSOR_ARCHITECTURE

##########################################

# This script checks if the PSCompression module is installed:
& $strPathToTestPowerShellModuleInstalledScript
# It's not! What happens if we try to install it (by following the suggested
# instructions)?

# Get more information about the installed version of PowerShell:
$PSVersionTable
# Note the PSVersion
# ... and note the PSEdition!

# Return to the host system
Exit-PSSession
#endregion Part 3: Try some things on Windows 10 IoT Core #############################

#region Part 4: Download PowerShell 7 for Windows 10 IoT Core and transfer it ######
# ...back on the host system, we can download PowerShell 7 for Windows 10 IoT Core
$strPathToInvokePowerShellDownloadScript = Join-Path $strCurrentFolder 'Invoke-PowerShellDownload.ps1'

$results = & $strPathToInvokePowerShellDownloadScript -PreferZIP -Windows -ARM

# Display the $results variable:
$results

# Transfer the downloaded file
if ($versionPS.Major -ge 5) {
    Copy-Item ($results.DownloadedFilePath) -Destination $strWin10IoTCoreDownloadPathRoot -ToSession $PSSession -Force
} else {
    Write-Error "Cannot copy a file to a PSSession on PowerShell v4 and previous; need to identify and write workaround!"
}

# The $results file has important information like the file name, etc., and this
# variable is on the host, not the target system. How can we transfer it?
# 🤔💭

# Before we transfer it, let's update the paths to reflect the correct ones on the
# remote host
$strHostFolderPath = $results.FolderPathContainingDownload
$results.FolderPathContainingDownload = $strWin10IoTCoreDownloadPathRoot
$results.DownloadedFilePath = Join-Path $strWin10IoTCoreDownloadPathRoot ($results.DownloadedFileName)

# Convert it to JSON:
$strPathToDownloadResultsJSONFile = Join-Path $strCurrentFolder 'PowerShellDownloadResults.json'
$results | ConvertTo-Json | Out-File -FilePath $strPathToDownloadResultsJSONFile -Force

# Transfer it
if ($versionPS.Major -ge 5) {
    Copy-Item $strPathToDownloadResultsJSONFile -Destination $strWin10IoTCoreDownloadPathRoot -ToSession $PSSession -Force
} else {
    Write-Error "Cannot copy a file to a PSSession on PowerShell v4 and previous; need to identify and write workaround!"
}

# Put the downloaded file info back on the host just in case
$results.FolderPathContainingDownload = $strHostFolderPath
$results.DownloadedFilePath = Join-Path $strHostFolderPath ($results.DownloadedFileName)
#endregion Part 4: Download PowerShell 7 for Windows 10 IoT Core and transfer it ######

#region Part 5: Extract PowerShell 7 and Enable Remoting ###########################
# Enter the PSSession for the IoT Core device
Enter-PSSession $PSSession

$strDownloadFolder = Get-DownloadFolder
Set-Location $strDownloadFolder

# Load the JSON file
$strJSONFileName = 'PowerShellDownloadResults.json'
$results = Get-Content (Join-Path $strDownloadFolder $strJSONFileName) | ConvertFrom-Json

# Look! We have our object!
$results

# Get the Program Files path - note: this technique is not fully backward compatible!
$strProgramFilesFolderPath = $env:ProgramW6432
if ([string]::IsNullOrEmpty($strProgramFilesFolderPath)) {
    $strProgramFilesFolderPath = $env:ProgramFiles
    if ([string]::IsNullOrEmpty($strProgramFilesFolderPath)) {
        Write-Warning 'Uh, we couldn''t find a Program Files folder?'
    }
}

# Determine the future folder for PowerShell 7
$strMajorVersion = [string](([version]$results.DownloadedVersion).Major)
$strPowerShell7Folder = Join-Path $strProgramFilesFolderPath 'PowerShell'
$strPowerShell7Folder = Join-Path $strPowerShell7Folder $strMajorVersion

Expand-Archive -Path $results.DownloadedFilePath -DestinationPath $strPowerShell7Folder
Set-Location $strPowerShell7Folder

# Dead man's switch the OS
shutdown -r -f -t 120

# Enable PowerShell 7 remoting:
.\Install-PowerShellRemoting.ps1 -PowerShellHome .
# You will get disconnected. This is expected!

# Windows may be unstable; if you can't remote back in, be patient and it should auto
# reboot thanks to our dead man switch

Exit-PSSession
#endregion Part 5: Extract PowerShell 7 and Enable Remoting ###########################

#region Part 6: Reconnect - This Time to PowerShell 7! #############################
# NOTE: If you haven't already, wait the two minutes for the dead man's switch to
# reboot Windows
$strMajorVersion = [string](([version]$results.DownloadedVersion).Major)
$strConfigurationName = 'PowerShell.' + $strMajorVersion
$PSSession = New-PSSession -ComputerName $strWin10IoTCoreDeviceIPOrHostname -Credential $credential -ConfigurationName $strConfigurationName

Enter-PSSession $PSSession

$PSVersionTable
#endregion Part 6: Reconnect - This Time to PowerShell 7! #############################

#region Part 7: Try Again to Install the PowerShell Module #########################
function Get-DownloadFolder {
    if (Test-Path variable:\HOME) {
        $strBasePath = $HOME
    } elseif (Test-Path env:\USERPROFILE) {
        $strBasePath = $env:USERPROFILE
    } else {
        $strBasePath = $null
    }

    if ($null -ne $strBasePath) {
        $strDownloads = Join-Path $strBasePath "Downloads"
        if ((Test-Path $strDownloads) -eq $false) {
            New-Item -Path $strDownloads -ItemType Directory | Out-Null
        }
        $strDownloads
    } else {
        Write-Warning "Get-DownloadFolder was unable to locate suitable folder path for downloads. Returning `$null"
        $null
    }
}

$strDownloadFolder = Get-DownloadFolder
$strPathToTestPowerShellModuleInstalledScript = Join-Path $strDownloadFolder 'Test-PowerShellModuleInstalled.ps1'

# This script checks if the PSCompression module is installed:
& $strPathToTestPowerShellModuleInstalledScript
# It's not! Will it work this time?:

Install-Module PSCompression;
#endregion Part 7: Try Again to Install the PowerShell Module #########################

#region Part 8: Review Information About the Computer ##############################
Get-ComputerInfo
#endregion Part 8: Review Information About the Computer ##############################

#region Part 9: Define Helper Functions for Registry Work ##########################
function Test-RegistryValue {
    # Returns $true if a registry value exists; $false otherwise
    $strPath = $args[0]
    $strValueName = $args[1]

    if (Test-Path -LiteralPath $strPath) {
        $registryKey = Get-Item -LiteralPath $strPath
        if ($null -ne $registryKey.GetValue($strValueName, $null)) {
            $true
        } else {
            $false
        }
    } else {
        $false
    }
}

# Create a helper function to set/update a registry value when needed
function Update-RegistryValue {
    $strRegistryPath = $args[0]
    $strValueName = $args[1]
    $registryTypeDesired = $args[2]
    $strPowerShellComparableTypeName = $args[3]
    $registryValueDesired = $args[4]
    if (Test-RegistryValue $strRegistryPath $strValueName) {
        # Value exists
        $registryvalue = Get-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName
        if ((($registryvalue.$strValueName).GetType().FullName) -notlike $strPowerShellComparableTypeName) {
            # Wrong type; delete and recreate
            Remove-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName | Out-Null
            New-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName -Value $registryValueDesired -Type $registryTypeDesired | Out-Null
        } else {
            # Correct type; check value
            if (($registryvalue.$strValueName) -ne $registryValueDesired) {
                # Incompatible value; update it
                Set-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName -Value $registryValueDesired | Out-Null
            }
        }
    } else {
        # Registry value does not exist; create it
        if (-not (Test-Path -LiteralPath $strRegistryPath)) {
            New-Item -Path $strRegistryPath | Out-Null
        }
        New-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName -Value $registryValueDesired -Type $registryTypeDesired | Out-Null
    }
}

# Create a helper function to set/update a registry value when needed
function Update-RegistryValueToAtLeast {
    $strRegistryPath = $args[0]
    $strValueName = $args[1]
    $registryTypeDesired = $args[2]
    $strPowerShellComparableTypeName = $args[3]
    $registryValueDesired = $args[4]
    if (Test-RegistryValue $strRegistryPath $strValueName) {
        # Value exists
        $registryvalue = Get-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName
        if ((($registryvalue.$strValueName).GetType().FullName) -notlike $strPowerShellComparableTypeName) {
            # Wrong type; delete and recreate
            Remove-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName | Out-Null
            New-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName -Value $registryValueDesired -Type $registryTypeDesired | Out-Null
        } else {
            # Correct type; check value
            if (($registryvalue.$strValueName) -lt $registryValueDesired) {
                # Incompatible value; update it
                Set-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName -Value $registryValueDesired | Out-Null
            }
        }
    } else {
        # Registry value does not exist; create it
        if (-not (Test-Path -LiteralPath $strRegistryPath)) {
            New-Item -Path $strRegistryPath | Out-Null
        }
        New-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName -Value $registryValueDesired -Type $registryTypeDesired | Out-Null
    }
}

function Test-Windows {
    if (Test-Path variable:\isWindows) {
        $isWindows
    } else {
        $true
    }
}
#endregion Part 9: Define Helper Functions for Registry Work ##########################

#region Part 10: Configure Windows Update ##########################################
# Prerequisite: check the telemetry setting to ensure it is at least set to 1 (1 or greater)
$strRegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
$strValueName = "AllowTelemetry"
$registryTypeDesired = [Microsoft.Win32.RegistryValueKind]::DWord
$strPowerShellComparableTypeName = "*Int32*"
$registryValueDesired = 1
Update-RegistryValueToAtLeast $strRegistryPath $strValueName $registryTypeDesired $strPowerShellComparableTypeName $registryValueDesired

#region CISBenchmarkWindowsUpdateSettings
# Configure Windows Update settings aligned with CIS Benchmark:

# Prep parameters used repeatedly
$registryTypeDesired = [Microsoft.Win32.RegistryValueKind]::DWord
$strPowerShellComparableTypeName = "*Int32*"

# Set registry key
$strRegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"

# Configure BranchReadinessLevel
$strValueName = "BranchReadinessLevel"
$registryValueDesired = 32
Update-RegistryValue $strRegistryPath $strValueName $registryTypeDesired $strPowerShellComparableTypeName $registryValueDesired

# Configure DeferFeatureUpdates
$strValueName = "DeferFeatureUpdates"
$registryValueDesired = 1
Update-RegistryValue $strRegistryPath $strValueName $registryTypeDesired $strPowerShellComparableTypeName $registryValueDesired

# Configure DeferFeatureUpdatesPeriodInDays
$strValueName = "DeferFeatureUpdatesPeriodInDays"
$registryValueDesired = 180
Update-RegistryValue $strRegistryPath $strValueName $registryTypeDesired $strPowerShellComparableTypeName $registryValueDesired

# Configure DeferQualityUpdates
$strValueName = "DeferQualityUpdates"
$registryValueDesired = 1
Update-RegistryValue $strRegistryPath $strValueName $registryTypeDesired $strPowerShellComparableTypeName $registryValueDesired

# Configure DeferQualityUpdatesPeriodInDays
$strValueName = "DeferQualityUpdatesPeriodInDays"
$registryValueDesired = 0
Update-RegistryValue $strRegistryPath $strValueName $registryTypeDesired $strPowerShellComparableTypeName $registryValueDesired

# Configure ManagePreviewBuilds
$strValueName = "ManagePreviewBuilds"
$registryValueDesired = 1
Update-RegistryValue $strRegistryPath $strValueName $registryTypeDesired $strPowerShellComparableTypeName $registryValueDesired

# Configure ManagePreviewBuildsPolicyValue
$strValueName = "ManagePreviewBuildsPolicyValue"
$registryValueDesired = 0
Update-RegistryValue $strRegistryPath $strValueName $registryTypeDesired $strPowerShellComparableTypeName $registryValueDesired

# Prep parameters used repeatedly
$registryTypeDesired = [Microsoft.Win32.RegistryValueKind]::String
$strPowerShellComparableTypeName = "*String*"

# Configure PauseFeatureUpdatesStartTime
$strValueName = "PauseFeatureUpdatesStartTime"
$registryValueDesired = ""
Update-RegistryValue $strRegistryPath $strValueName $registryTypeDesired $strPowerShellComparableTypeName $registryValueDesired

# Configure PauseQualityUpdatesStartTime
$strValueName = "PauseQualityUpdatesStartTime"
$registryValueDesired = ""
Update-RegistryValue $strRegistryPath $strValueName $registryTypeDesired $strPowerShellComparableTypeName $registryValueDesired

# Prep parameters used repeatedly
$registryTypeDesired = [Microsoft.Win32.RegistryValueKind]::DWord
$strPowerShellComparableTypeName = "*Int32*"

# Configure SetDisablePauseUXAccess
$strValueName = "SetDisablePauseUXAccess"
$registryValueDesired = 1
Update-RegistryValue $strRegistryPath $strValueName $registryTypeDesired $strPowerShellComparableTypeName $registryValueDesired

# Set registry key
$strRegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

# Check and update "Configure Automatic Updates" -> "Configure automatic updating" setting (AUOptions)
$strValueName = "AUOptions"
$registryValueDesired = 4
if (Test-RegistryValue $strRegistryPath $strValueName) {
    # Value exists
    $registryvalue = Get-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName
    if ((($registryvalue.$strValueName).GetType().FullName) -notlike $strPowerShellComparableTypeName) {
        # Wrong type; delete and recreate
        Remove-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName
        New-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName -Value $registryValueDesired -Type $registryTypeDesired | Out-Null
        $intAUOptionsValue = $registryValueDesired
    } else {
        # Correct type; check value
        if ((($registryvalue.$strValueName) -lt 2) -or (($registryvalue.$strValueName) -gt 5)) {
            # Non-compliant value; update it
            Set-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName -Value $registryValueDesired
            $intAUOptionsValue = $registryValueDesired
        } else {
            $intAUOptionsValue = ($registryvalue.$strValueName)
        }
    }
} else {
    # Registry value does not exist; create it
    if (-not (Test-Path -LiteralPath $strRegistryPath)) {
        New-Item -Path $strRegistryPath | Out-Null
    }
    New-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName -Value $registryValueDesired -Type $registryTypeDesired | Out-Null
    $intAUOptionsValue = $registryValueDesired
}

if ($intAUOptionsValue -eq 4) {
    # Need to configure "Configure Automatic Updates" -> "Scheduled install day" setting (ScheduledInstallDay)
    $strValueName = "ScheduledInstallDay"
    $registryValueDesired = 0
    Update-RegistryValue $strRegistryPath $strValueName $registryTypeDesired $strPowerShellComparableTypeName $registryValueDesired
}

# Ensure updates are enabled (corresponds to "Configure Automatic Updates" -> "Configure automatic updating" setting being 2, 3, 4, or 5) (NoAutoUpdate)
$strValueName = "NoAutoUpdate"
$registryValueDesired = 0
Update-RegistryValue $strRegistryPath $strValueName $registryTypeDesired $strPowerShellComparableTypeName $registryValueDesired

# Configure NoAutoRebootWithLoggedOnUsers
$strValueName = "NoAutoRebootWithLoggedOnUsers"
$registryValueDesired = 0
Update-RegistryValue $strRegistryPath $strValueName $registryTypeDesired $strPowerShellComparableTypeName $registryValueDesired
#endregion CISBenchmarkWindowsUpdateSettings

#region AdditionalPrudentWindowsUpdateSettings
# Configure prudent settings not in CIS Benchmark:

# Set registry key
$strRegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

# Configure prudent settings relevant to automatic installation
if ($intAUOptionsValue -eq 4) {	
    # Need to configure "Configure Automatic Updates" -> "Install during automatic maintenance" setting (AutomaticMaintenanceEnabled)
    $strValueName = "AutomaticMaintenanceEnabled"
    $registryValueDesired = 1
    Update-RegistryValue $strRegistryPath $strValueName $registryTypeDesired $strPowerShellComparableTypeName $registryValueDesired

    # Need to configure "Configure Automatic Updates" -> "Every week" setting (ScheduledInstallEveryWeek)
    $strValueName = "ScheduledInstallEveryWeek"
    $registryValueDesired = 1
    Update-RegistryValue $strRegistryPath $strValueName $registryTypeDesired $strPowerShellComparableTypeName $registryValueDesired

    # Need to remove "Configure Automatic Updates" -> "First week of the month" setting (ScheduledInstallFirstWeek)
    $strValueName = "ScheduledInstallFirstWeek"
    if (Test-RegistryValue $strRegistryPath $strValueName) {
        # Value exists
        Remove-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName
    }

    # Need to remove "Configure Automatic Updates" -> "Second week of the month" setting (ScheduledInstallSecondWeek)
    $strValueName = "ScheduledInstallSecondWeek"
    if (Test-RegistryValue $strRegistryPath $strValueName) {
        # Value exists
        Remove-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName
    }

    # Need to remove "Configure Automatic Updates" -> "Third week of the month" setting (ScheduledInstallThirdWeek)
    $strValueName = "ScheduledInstallThirdWeek"
    if (Test-RegistryValue $strRegistryPath $strValueName) {
        # Value exists
        Remove-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName
    }

    # Need to remove "Configure Automatic Updates" -> "Fourth week of the month" setting (ScheduledInstallFourthWeek)
    $strValueName = "ScheduledInstallFourthWeek"
    if (Test-RegistryValue $strRegistryPath $strValueName) {
        # Value exists
        Remove-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName
    }

    # Need to configure "Configure Automatic Updates" -> "Scheduled install time" setting (ScheduledInstallTime)
    $strValueName = "ScheduledInstallTime"
    $registryValueDesired = 24
    if (Test-RegistryValue $strRegistryPath $strValueName) {
        # Value exists
        $registryvalue = Get-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName
        if ((($registryvalue.$strValueName).GetType().FullName) -notlike $strPowerShellComparableTypeName) {
            # Wrong type; delete and recreate
            Remove-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName
            New-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName -Value $registryValueDesired -Type $registryTypeDesired | Out-Null
        } else {
            # Correct type; check value
            if ((($registryvalue.$strValueName) -lt 0) -or (($registryvalue.$strValueName) -gt 24)) {
                # Incompatible value; update it
                Set-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName -Value $registryValueDesired
            }
        }
    } else {
        # Registry value does not exist; create it
        New-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName -Value $registryValueDesired -Type $registryTypeDesired | Out-Null
    }
}

# Need to configure "Configure Automatic Updates" -> "Install updates for other Microsoft products" setting (AllowMUUpdateService)
$strValueName = "AllowMUUpdateService"
$registryValueDesired = 1
Update-RegistryValue $strRegistryPath $strValueName $registryTypeDesired $strPowerShellComparableTypeName $registryValueDesired

#endregion AdditionalPrudentWindowsUpdateSettings

# Update the telemetry setting to full, because this is a test device and I don't see any harm
# in helping Microsoft's devs
$strRegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
$strValueName = "AllowTelemetry"
$registryTypeDesired = [Microsoft.Win32.RegistryValueKind]::DWord
$strPowerShellComparableTypeName = "*Int32*"
$registryValueDesired = 3
Update-RegistryValue $strRegistryPath $strValueName $registryTypeDesired $strPowerShellComparableTypeName $registryValueDesired

# Restart the service
Stop-Service wuauserv
Start-Service wuauserv

# Force a check for updates
wuauclt.exe /detectnow
#endregion Part 10: Configure Windows Update ##########################################
