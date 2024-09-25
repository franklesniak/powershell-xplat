# Version 0.1.20240924.0

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

param(
    [switch]$PreferZIP
)

# TODO: Add capability to download to temp folder instead of downloads folder?

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

function Get-WScriptShellCOMObject {
    #region FunctionHeader #########################################################
    # Attempts to create a new COM object "WScript.Shell"; if successful, it returns it
    #
    # One positional arguments is required:
    #
    # The first argument is a reference to a ComObject that will be used to store the
    # WScript.Shell COM object, (if it is successfully created)
    #
    # The function returns $true if the process completed successfully; $false
    # otherwise
    #
    # # Example usage:
    # $objWScriptShell = $null
    # $boolResult = Get-WScriptShellCOMObject ([ref]$objWScriptShell)
    # # If $boolResult is $true, then $objWScriptShell is a WScript.Shell object
    #
    # Version: 1.0.20240925.0
    #endregion FunctionHeader #########################################################

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

    function Get-ReferenceToLastError {
        #region FunctionHeader #####################################################
        # Function returns $null if no errors on on the $error stack;
        # Otherwise, function returns a reference (memory pointer) to the last error
        # that occurred.
        #
        # Version: 1.0.20240127.0
        #endregion FunctionHeader #####################################################

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

        if ($error.Count -gt 0) {
            [ref]($error[0])
        } else {
            $null
        }
    }

    function Test-ErrorOccurred {
        #region FunctionHeader #####################################################
        # Function accepts two positional arguments:
        #
        # The first argument is a reference (memory pointer) to the last error that had
        # occurred prior to calling the command in question - that is, the command that
        # we want to test to see if an error occurred.
        #
        # The second argument is a reference to the last error that had occurred as-of
        # the completion of the command in question.
        #
        # Function returns $true if it appears that an error occurred; $false otherwise
        #
        # Version: 1.0.20240127.0
        #endregion FunctionHeader #####################################################

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

        # TO-DO: Validate input

        $boolErrorOccurred = $false
        if (($null -ne ($args[0])) -and ($null -ne ($args[1]))) {
            # Both not $null
            if ((($args[0]).Value) -ne (($args[1]).Value)) {
                $boolErrorOccurred = $true
            }
        } else {
            # One is $null, or both are $null
            # NOTE: ($args[0]) could be non-null, while ($args[1])
            # could be null if $error was cleared; this does not indicate an error.
            # So:
            # If both are null, no error
            # If ($args[0]) is null and ($args[1]) is non-null, error
            # If ($args[0]) is non-null and ($args[1]) is null, no error
            if (($null -eq ($args[0])) -and ($null -ne ($args[1]))) {
                $boolErrorOccurred
            }
        }

        $boolErrorOccurred
    }

    trap {
        # Intentionally left empty to prevent terminating errors from halting
        # processing
    }

    $refOutput = $args[0]

    # Retrieve the newest error on the stack prior to doing work
    $refLastKnownError = Get-ReferenceToLastError

    # Store current error preference; we will restore it after we do the work of this
    # function
    $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

    # Set ErrorActionPreference to SilentlyContinue; this will suppress error output.
    # Terminating errors will not output anything, kick to the empty trap statement and
    # then continue on. Likewise, non-terminating errors will also not output anything,
    # but they do not kick to the trap statement; they simply continue on.
    $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

    # Attempt to create the WScript.Shell object
    $output = New-Object -ComObject WScript.Shell

    # Restore the former error preference
    $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

    # Retrieve the newest error on the error stack
    $refNewestCurrentError = Get-ReferenceToLastError

    if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
        # Error occurred
        return $false
    } else {
        # No error occurred
        $refOutput.Value = $output
        return $true
    }
}

function Get-SystemProcessorArchitectureEnvironmentVariableFromWindowsRegistry {
    #region FunctionHeader #########################################################
    # Attempts to retrieve the system-context PROCESS_ARCHITECTURE environment variable
    # from the registry
    #
    # One positional arguments is required:
    #
    # The first argument is a reference to a string that will be used to store the
    # value of the system-context PROCESSOR_ARCHITECTURE environment variable
    #
    # The function returns $true if the process completed successfully; $false
    # otherwise
    #
    # # Example usage:
    # $strSystemPROCESSORARCHITECTURE = $null
    # $boolResult = Get-SystemProcessorArchitectureEnvironmentVariableFromWindowsRegistry ([ref]$strSystemPROCESSORARCHITECTURE)
    # # If $boolResult is $true, then $strSystemPROCESSORARCHITECTURE is a string
    # # containing the value of the system-context PROCESSOR_ARCHITECTURE environment
    # # variable.
    #
    # Version: 1.0.20240924.0
    #endregion FunctionHeader #########################################################

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

    function Get-ReferenceToLastError {
        #region FunctionHeader #####################################################
        # Function returns $null if no errors on on the $error stack;
        # Otherwise, function returns a reference (memory pointer) to the last error
        # that occurred.
        #
        # Version: 1.0.20240127.0
        #endregion FunctionHeader #####################################################

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

        if ($error.Count -gt 0) {
            [ref]($error[0])
        } else {
            $null
        }
    }

    function Test-ErrorOccurred {
        #region FunctionHeader #####################################################
        # Function accepts two positional arguments:
        #
        # The first argument is a reference (memory pointer) to the last error that had
        # occurred prior to calling the command in question - that is, the command that
        # we want to test to see if an error occurred.
        #
        # The second argument is a reference to the last error that had occurred as-of
        # the completion of the command in question.
        #
        # Function returns $true if it appears that an error occurred; $false otherwise
        #
        # Version: 1.0.20240127.0
        #endregion FunctionHeader #####################################################

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

        # TO-DO: Validate input

        $boolErrorOccurred = $false
        if (($null -ne ($args[0])) -and ($null -ne ($args[1]))) {
            # Both not $null
            if ((($args[0]).Value) -ne (($args[1]).Value)) {
                $boolErrorOccurred = $true
            }
        } else {
            # One is $null, or both are $null
            # NOTE: ($args[0]) could be non-null, while ($args[1])
            # could be null if $error was cleared; this does not indicate an error.
            # So:
            # If both are null, no error
            # If ($args[0]) is null and ($args[1]) is non-null, error
            # If ($args[0]) is non-null and ($args[1]) is null, no error
            if (($null -eq ($args[0])) -and ($null -ne ($args[1]))) {
                $boolErrorOccurred
            }
        }

        $boolErrorOccurred
    }

    trap {
        # Intentionally left empty to prevent terminating errors from halting
        # processing
    }

    $refOutput = $args[0]

    # Retrieve the newest error on the stack prior to doing work
    $refLastKnownError = Get-ReferenceToLastError

    # Store current error preference; we will restore it after we do the work of this
    # function
    $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

    # Set ErrorActionPreference to SilentlyContinue; this will suppress error output.
    # Terminating errors will not output anything, kick to the empty trap statement and
    # then continue on. Likewise, non-terminating errors will also not output anything,
    # but they do not kick to the trap statement; they simply continue on.
    $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

    $regKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'

    # Attempt to retrieve the system-context PROCESSOR_ARCHITECTURE environment
    # variable from the registry. This has to be done in one line for effective error
    # handling
    $output = (Get-ItemProperty $regKey).PROCESSOR_ARCHITECTURE

    # Restore the former error preference
    $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

    # Retrieve the newest error on the error stack
    $refNewestCurrentError = Get-ReferenceToLastError

    if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
        # Error occurred
        return $false
    } else {
        # No error occurred
        $refOutput.Value = $output
        return $true
    }
}

$strNewestARM32Release = '7.3.12'
$versionARM64MSI = [version]('7.4.3') # First ARM64 MSI release

$boolPreferZIP = $false
if ($null -ne $PreferZIP) {
    if ($PreferZIP.IsPresent) {
        $boolPreferZIP = $true
    }
}

$versionPS = Get-PSVersion
$boolWindows = Test-Windows

# TODO: Change script logic to download whenever the current version is not up to date?

if ($boolWindows) {
    if ($versionPS.Major -lt 6) {
        # Need to download PowerShell v7

        # Methodology adopted from sysadmin-accelerator project
        # See: GetOperatingSystemProcessorArchitectureUsingOperatingSystemVersion.vbs
        $objWScriptShell = $null
        $boolResult = Get-WScriptShellCOMObject ([ref]$objWScriptShell)
        if ($boolResult) {
            # Success! Use the WScript.Shell object
            $objEnvironment = $objWSHShell.Environment('System')
            $strOSProcessorArchitecture = $objEnvironment.Item('PROCESSOR_ARCHITECTURE')
        } else {
            # Could not create a WScript.Shell object; fall back to other method(s)
            $strOSProcessorArchitecture = $null
            $boolResult = Get-SystemProcessorArchitectureEnvironmentVariableFromWindowsRegistry ([ref]$strOSProcessorArchitecture)
            if (-not $boolResult) {
                # TODO: Code more alternatives
                Write-Warning 'Could not retrieve the OS processor architecture!'
            }
        }

        switch ($strOSProcessorArchitecture) {
            'x86' {
                $strPowerShellProcessorArchitecture = 'win-x86'
                $strPowerShellReleaseMetadata = 'https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/metadata.json'
                $strPowerShellVersion = (Invoke-RestMethod -Uri $strPowerShellReleaseMetadata).StableReleaseTag -replace '^v'
                if ($boolPreferZIP) {
                    $boolUseMSI = $false
                } else {
                    $boolUseMSI = $true
                }
            }
            'AMD64' {
                $strPowerShellProcessorArchitecture = 'win-x64'
                $strPowerShellReleaseMetadata = 'https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/metadata.json'
                $strPowerShellVersion = (Invoke-RestMethod -Uri $strPowerShellReleaseMetadata).StableReleaseTag -replace '^v'
                if ($boolPreferZIP) {
                    $boolUseMSI = $false
                } else {
                    $boolUseMSI = $true
                }
            }
            'ARM64' {
                $strPowerShellProcessorArchitecture = 'win-arm64'
                $strPowerShellReleaseMetadata = 'https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/metadata.json'
                $strPowerShellVersion = (Invoke-RestMethod -Uri $strPowerShellReleaseMetadata).StableReleaseTag -replace '^v'
                if ([version]$strPowerShellReleaseMetadata -ge $versionARM64MSI) {
                    if ($boolPreferZIP) {
                        $boolUseMSI = $false
                    } else {
                        $boolUseMSI = $true
                    }
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
                #TODO: Confirm PowerShell 7 doesn't work on IA64 Windows for funzies
                Write-Error ('Unknown processor architecture: ' + $strOSProcessorArchitecture)
                $strPowerShellProcessorArchitecture = ''
                $strPowerShellVersion = ''
            }
        }

        if ($strPowerShellProcessorArchitecture -ne '') {
            if ($boolUseMSI) {
                $strPowerShellRelease = 'PowerShell-' + $strPowerShellVersion + '-' + $strPowerShellProcessorArchitecture + '.msi'
            } else {
                $strPowerShellRelease = 'PowerShell-' + $strPowerShellVersion + '-' + $strPowerShellProcessorArchitecture + '.zip'
            }

            $strDownloadURL = 'https://github.com/PowerShell/PowerShell/releases/download/v' + $strPowerShellVersion + '/' + $strPowerShellRelease

            $strTargetFolder = Get-DownloadFolder
            if ($null -ne $strTargetFolder) {
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

        # TODO: Determine distribution of Linux and generate the file to download accordingly, store it in $strPowerShellRelease

        $strDownloadURL = 'https://github.com/PowerShell/PowerShell/releases/download/v' + $strPowerShellVersion + '/' + $strPowerShellRelease
    } elseif ($IsMacOS) {
        switch ($strDotNetOSArchitecture) {
            'X64' {
                $strPowerShellProcessorArchitecture = 'osx-x64'
            }
            'Arm64' {
                $strPowerShellProcessorArchitecture = 'osx-arm64'
            }
        }

        # TODO: Generate the file to download programmatically, store it in $strPowerShellRelease

        $strDownloadURL = 'https://github.com/PowerShell/PowerShell/releases/download/v' + $strPowerShellVersion + '/' + $strPowerShellRelease
    }

    $strPowerShellReleaseMetadata = 'https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/metadata.json'
    $strPowerShellVersion = (Invoke-RestMethod -Uri $strPowerShellReleaseMetadata).StableReleaseTag -replace '^v'

    $strTargetFolder = Get-DownloadFolder
    if ($null -ne $strTargetFolder) {
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
