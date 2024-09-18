# win-arm32
# PowerShell-7.3.12-win-arm32.zip

#region License ####################################################################
# Copyright (c) 2024 Frank Lesniak
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be included in all copies
# or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#endregion License ####################################################################

function Get-PSVersion {
    <#
    .SYNOPSIS
    Returns the version of PowerShell that is running

    .DESCRIPTION
    Returns the version of PowerShell that is running, including on the original
    release of Windows PowerShell (version 1.0)

    .EXAMPLE
    Get-PSVersion

    This example returns the version of PowerShell that is running. On versions of
    PowerShell greater than or equal to version 2.0, this function returns the
    equivalent of $PSVersionTable.PSVersion

    .OUTPUTS
    A [version] object representing the version of PowerShell that is running

    .NOTES
    PowerShell 1.0 does not have a $PSVersionTable variable, so this function returns
    [version]('1.0') on PowerShell 1.0
    #>

    [CmdletBinding()]
    [OutputType([version])]

    param ()

    #region License ################################################################
    # Copyright (c) 2023 Frank Lesniak
    #
    # Permission is hereby granted, free of charge, to any person obtaining a copy of
    # this software and associated documentation files (the "Software"), to deal in the
    # Software without restriction, including without limitation the rights to use,
    # copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
    # Software, and to permit persons to whom the Software is furnished to do so,
    # subject to the following conditions:
    #
    # The above copyright notice and this permission notice shall be included in all
    # copies or substantial portions of the Software.
    #
    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    # FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
    # COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
    # AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    # WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    #endregion License ################################################################

    $versionThisFunction = [version]('1.0.20230613.0')

    if (Test-Path variable:\PSVersionTable) {
        $PSVersionTable.PSVersion
    } else {
        [version]('1.0')
    }
}

function Test-Windows {
    # Returns a boolean ($true or $false) indicating whether the current PowerShell
    # session is running on Windows. This function is useful for writing scripts that
    # need to behave differently on Windows and non-Windows platforms (Linux, macOS,
    # etc.). Additionally, this function is useful because it works on Windows
    # PowerShell 1.0 through 5.1, which do not have the $IsWindows global variable.
    #
    # Example:
    # $boolIsWindows = Test-Windows
    #
    # This example returns $true if the current PowerShell session is running on
    # Windows, and $false if the current PowerShell session is running on a non-Windows
    # platform (Linux, macOS, etc.)
    #
    # Version 1.0.20240917.0

    #region License ################################################################
    # Copyright (c) 2024 Frank Lesniak
    #
    # Permission is hereby granted, free of charge, to any person obtaining a copy of
    # this software and associated documentation files (the "Software"), to deal in the
    # Software without restriction, including without limitation the rights to use,
    # copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
    # Software, and to permit persons to whom the Software is furnished to do so,
    # subject to the following conditions:
    #
    # The above copyright notice and this permission notice shall be included in all
    # copies or substantial portions of the Software.
    #
    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    # FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
    # COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
    # AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    # WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    #endregion License ################################################################

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

    $versionPS = Get-PSVersion
    if ($versionPS.Major -ge 6) {
        $IsWindows
    } else {
        $true
    }
}

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

$strNewestARM32Release = '7.3.12'
$versionARM64MSI = [version]('7.4.3') # First ARM64 MSI release

$versionPS = Get-PSVersion
$boolWindows = Test-Windows

if ($boolWindows) {
    if ($versionPS.Major -lt 6) {
        # Need to download PowerShell v7

        # Methodology adopted from sysadmin-accelerator project
        # See: GetOperatingSystemProcessorArchitectureUsingOperatingSystemVersion.vbs
        $objWSHShell = New-Object -ComObject WScript.Shell
        $objEnvironment = $objWSHShell.Environment('System')
        $strOSProcessorArchitecture = $objEnvironment.Item('PROCESSOR_ARCHITECTURE')

        switch ($strOSProcessorArchitecture) {
            'x86' {
                $strPowerShellProcessorArchitecture = 'win-x86'
                $strPowerShellReleaseMetadata = 'https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/metadata.json'
                $strPowerShellVersion = (Invoke-RestMethod -Uri $strPowerShellReleaseMetadata).StableReleaseTag -replace '^v'
                $boolUseMSI = $true
            }
            'AMD64' {
                $strPowerShellProcessorArchitecture = 'win-x64'
                $strPowerShellReleaseMetadata = 'https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/metadata.json'
                $strPowerShellVersion = (Invoke-RestMethod -Uri $strPowerShellReleaseMetadata).StableReleaseTag -replace '^v'
                $boolUseMSI = $true
            }
            'ARM64' {
                $strPowerShellProcessorArchitecture = 'win-arm64'
                $strPowerShellReleaseMetadata = 'https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/metadata.json'
                $strPowerShellVersion = (Invoke-RestMethod -Uri $strPowerShellReleaseMetadata).StableReleaseTag -replace '^v'
                if ([version]$strPowerShellReleaseMetadata -ge $versionARM64MSI) {
                    $boolUseMSI = $true
                } else {
                    $boolUseMSI = $false
                }
            }
            'ARM' {
                $strPowerShellProcessorArchitecture = 'win-arm32'
                $strPowerShellVersion = $strNewestARM32Release
                $boolUseMSI = $false
            }
            default {
                Write-Error ('Unknown processor architecture: ' + $strOSProcessorArchitecture)
                $strPowerShellProcessorArchitecture = ''
                $strPowerShellVersion = ''
            }
        }

        if ($strPowerShellProcessorArchitecture -ne '') {
            if ($boolUseMSI) {
                $strPowerShellRelease = "PowerShell-$strPowerShellVersion-$strPowerShellProcessorArchitecture.msi"
            } else {
                $strPowerShellRelease = "PowerShell-$strPowerShellVersion-$strPowerShellProcessorArchitecture.zip"
            }

            $strDownloadURL = 'https://github.com/PowerShell/PowerShell/releases/download/v' + $strPowerShellVersion + '/' + $strPowerShellRelease

            $strTargetFolder = Get-DownloadFolder
            if ($strTargetFolder -ne $null) {
                $strTargetPath = Join-Path $strTargetFolder $strPowerShellRelease
                if ((Test-Path $strTargetPath) -eq $false) {
                    if ($versionPS.Major -ge 5) {
                        Write-Information ('Downloading PowerShell ' + $strPowerShellVersion + ' for ' + $strPowerShellProcessorArchitecture + ' to ' + $strTargetPath)
                    } else {
                        Write-Host ('Downloading PowerShell ' + $strPowerShellVersion + ' for ' + $strPowerShellProcessorArchitecture + ' to ' + $strTargetPath)
                    }
                    $actionPreferencePreviousProgress = $ProgressPreference
                    $ProgressPreference = 'SilentlyContinue'
                    Invoke-WebRequest -Uri $strDownloadURL -OutFile $strTargetPath
                    $ProgressPreference = $actionPreferencePreviousProgress
                } else {
                    Write-Host ('PowerShell ' + $strPowerShellVersion + ' for ' + $strPowerShellProcessorArchitecture + ' already downloaded to ' + $strTargetPath)
                }
            } else {
                Write-Warning 'Unable to locate suitable folder path for downloads. PowerShell download aborted.'
            }
        }
    }
} else {
    # Not Windows
    $strDotNetOSArchitecture = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture
    if ($IsLinux) {
        switch ($strDotNetOSArchitecture) {
            'X64' {
                $strPowerShellProcessorArchitecture = 'linux-x64'
            }
            'X86' {
                $strPowerShellProcessorArchitecture = 'linux-x86'
            }
            'Arm' {
                $strPowerShellProcessorArchitecture = 'linux-arm32'
            }
            'Arm64' {
                $strPowerShellProcessorArchitecture = 'linux-arm64'
            }
        }
    } elseif ($IsMacOS) {
        switch ($strDotNetOSArchitecture) {
            'X64' {
                $strPowerShellProcessorArchitecture = 'osx-x64'
            }
            'Arm64' {
                $strPowerShellProcessorArchitecture = 'osx-arm64'
            }
        }
    }
}
