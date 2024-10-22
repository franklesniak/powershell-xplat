






#region DownloadPowerShell7ForWin10IoTCore
##############################################################################################
# Part 1 - Download PowerShell 7 for Windows 10 IoT Core
#
# See also: https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/install-powershell.ps1

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
        Write-Error "Get-DownloadFolder was unable to locate suitable folder path for downloads. Returning `$null"
        $null
    }
}

function Get-PSVersion {
    if (Test-Path variable:\PSVersionTable) {
        $PSVersionTable.PSVersion
    } else {
        [version]("1.0")
    }
}

function Test-PowerShellCommand {
    # The function takes one argument: a string with the PowerShell command for which we are
    # checking existence, i.e., the parameter passed to Get-Command
    #
    # The function returns $true if the command is available;
    #   $false otherwise
    #
    # Example usage:
    #
    # $boolResult = Test-PowerShellCommand "Expand-Archive"
    # if ($boolResult) {
    #   # Do something with Expand-Archive
    # } else {
    #   # Don't do anything with Expand-Archive because it does not exist
    # }

    trap {
        # Intentionally left empty to prevent terminating errors from halting processing
    }

    if ($args.Count -le 0) {
        $false
    } else {
        if (($args[0]).GetType().FullName -ne "System.String") {
            $false
        } else {
            $strCommand = ([string]($args[0]))

            $cmdletInfo = $null

            # Retrieve the newest error on the stack prior to calling the unreliable command
            $refLastKnownError = Get-ReferenceToLastError

            # Store current error preference; we will restore it after we call the unreliable command
            $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

            # Set ErrorActionPreference to SilentlyContinue; this will suppress error output.
            # Terminating errors will not output anything, kick to the empty trap statement and then
            # continue on. Likewise, non-terminating errors will also not output anything, but they
            # do not kick to the trap statement; they simply continue on.
            $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

            # Call the unreliable command
            $cmdletInfo = Get-Command $strCommand

            # Restore the former error preference
            $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

            # Retrieve the newest error on the error stack
            $refNewestCurrentError = Get-ReferenceToLastError

            if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
                $false
            } else {
                if ($null -eq $strCommand) {
                    $false
                } else {
                    $true
                }
            }
        }
    }
}

function Get-FileDownloadWithInvokeWebRequest {
    # The first argument is a string representing the full file path in which to store the
    #   download
    # The second argument is an integer indicating the current attempt number. When calling
    #   this function for the first time, it should be 1
    # The third argument is the maximum number of attempts that the function will observe
    #   before giving up
    # The fourth argument is a string representing the full URL from which the download is
    #   retrieved
    # The fifth argument is optional. If supplied, it's a boolean value that indicates whether
    #   a progress bar should be suppressed
    #
    # The function returns $true if the process completed successfully; $false otherwise
    #
    # Example usage:
    #
    # $strTargetFileForDownload = "C:\Users\flesniak\Downloads\foo.zip"
    # $strDownloadURL = "https://www.website.com/sampledownload.zip"
    # $boolSuccess = Get-FileDownloadWithInvokeWebRequest $strTargetFileForDownload 1 3 $strDownloadURL

    trap {
        # Intentionally left empty to prevent terminating errors from halting processing
    }

    $strDescriptionOfWhatWeAreDoingInThisFunction = "downloading a file using Invoke-WebRequest"

    $boolOutputErrorOnUnreliableCommandRetry = $false
    $boolOutputWarningOnUnreliableCommandRetry = $false
    $boolOutputVerboseOnUnreliableCommandRetry = $false
    $boolOutputDebugOnUnreliableCommandRetry = $true
    $boolOutputErrorOnUnreliableCommandMaximumAttemptsExceeded = $false
    $boolOutputWarningOnUnreliableCommandMaximumAttemptsExceeded = $false
    $boolOutputVerboseOnUnreliableCommandMaximumAttemptsExceeded = $false
    $boolOutputDebugOnUnreliableCommandMaximumAttemptsExceeded = $true

    if ($args.Count -lt 4) {
        $false
    } else {
        $strTargetFileForDownload = $args[0]
        $intCurrentAttemptNumber = $args[1]
        $intMaximumAttempts = $args[2]
        $strDownloadURL = $args[3]
        if ($args.Count -ge 5) {
            $boolShowProgressBar = $args[4]
        } else {
            $boolShowProgressBar = $true
        }

        if ($boolShowProgressBar -eq $false) {
            # Store current progress preference; we will restore it after we call Invoke-WebRequest
            $actionPreferenceFormerProgressPreference = $global:progressPreference

            # Set ProgressPreference to SilentlyContinue; this will suppress the progress bar.
            $global:progressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
        }

        # Retrieve the newest error on the stack prior to calling Invoke-WebRequest
        $refLastKnownError = Get-ReferenceToLastError

        # Store current error preference; we will restore it after we call Invoke-WebRequest
        $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

        # Set ErrorActionPreference to SilentlyContinue; this will suppress error output.
        # Terminating errors will not output anything, kick to the empty trap statement and then
        # continue on. Likewise, non-terminating errors will also not output anything, but they
        # do not kick to the trap statement; they simply continue on.
        $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

        # Call Invoke-WebRequest
        Invoke-WebRequest -Uri $strDownloadURL -OutFile $strTargetFileForDownload

        # Restore the former error preference
        $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

        # Retrieve the newest error on the error stack
        $refNewestCurrentError = Get-ReferenceToLastError

        if ($boolShowProgressBar -eq $false) {
            # Restore the former ProgressPreference variable
            $global:progressPreference = $actionPreferenceFormerProgressPreference
        }

        if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
            if ($intCurrentAttemptNumber -lt $intMaximumAttempts) {
                if ($boolOutputErrorOnUnreliableCommandRetry) {
                    Write-Error ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ". Waiting for " + [string]([math]::Pow(2, ($args[1]))) + " seconds, then retrying...")
                } elseif ($boolOutputWarningOnUnreliableCommandRetry) {
                    Write-Warning ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ". Waiting for " + [string]([math]::Pow(2, ($args[1]))) + " seconds, then retrying...")
                } elseif ($boolOutputVerboseOnUnreliableCommandRetry) {
                    Write-Verbose ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ". Waiting for " + [string]([math]::Pow(2, ($args[1]))) + " seconds, then retrying...")
                } elseif ($boolOutputDebugOnUnreliableCommandRetry) {
                    Write-Debug ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ". Waiting for " + [string]([math]::Pow(2, ($args[1]))) + " seconds, then retrying...")
                }
                Start-Sleep -Seconds ([math]::Pow(2, ($args[1])))

                if ($args.Count -ge 5) {
                    $objResultIndicator = Get-FileDownloadWithInvokeWebRequest $strTargetFileForDownload ($intCurrentAttemptNumber + 1) $intMaximumAttempts $strDownloadURL $boolShowProgressBar
                } else {
                    $objResultIndicator = Get-FileDownloadWithInvokeWebRequest $strTargetFileForDownload ($intCurrentAttemptNumber + 1) $intMaximumAttempts $strDownloadURL
                }
                $objResultIndicator
            } else {
                # Number of attempts exceeded maximum
                if ($boolOutputErrorOnUnreliableCommandMaximumAttemptsExceeded) {
                    if (($args[2]) -ge 2) {
                        Write-Error ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ". Giving up after too many attempts!")
                    } else {
                        Write-Error ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ".")
                    }
                } elseif ($boolOutputWarningOnUnreliableCommandMaximumAttemptsExceeded) {
                    if (($args[2]) -ge 2) {
                        Write-Warning ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ". Giving up after too many attempts!")
                    } else {
                        Write-Warning ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ".")
                    }
                } elseif ($boolOutputVerboseOnUnreliableCommandMaximumAttemptsExceeded) {
                    if (($args[2]) -ge 2) {
                        Write-Verbose ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ". Giving up after too many attempts!")
                    } else {
                        Write-Verbose ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ".")
                    }
                } elseif ($boolOutputDebugOnUnreliableCommandMaximumAttemptsExceeded) {
                    if (($args[2]) -ge 2) {
                        Write-Debug ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ". Giving up after too many attempts!")
                    } else {
                        Write-Debug ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ".")
                    }
                }

                $false
            }
        } else {
            $true
        }
    }
}


function Get-FileDownload {
    #$versionPS = Get-PSVersion
    #if ($versionPS.Major -ge 3)
    if (Test-PowerShellCommand "Invoke-WebRequest") {
        # Invoke-WebRequest exists; use it
    } else {
        # Invoke-WebRequest does not exist; fall-back to .NET WebClient
    }
}

# Set up parameters - customize these as needed for your environment!
$strDownloadFolder = Get-DownloadFolder
$strPowerShellVersion = "7.1.1"
$strPowerShellOSAbbreviation = "win"
$strPowerShellCPUPlatformAbbreviation = "arm32"
$strPowerShellZIPFileNameToDownloadRoot = "PowerShell-" + $strPowerShellVersion + "-" + $strPowerShellOSAbbreviation + "-" + $strPowerShellCPUPlatformAbbreviation
$strPowerShellZIPFileNameToDownload = $strPowerShellZIPFileNameToDownloadRoot + ".zip"
$strDownloadSourceRootPath = "https://github.com/PowerShell/PowerShell/releases/download/v" + $strPowerShellVersion + "/" # Should end in forward slash

$strWin10IoTCoreDeviceIPOrHostname = "10.1.2.132"
$strWin10IoTCoreUsername = "Administrator"
$strWin10IoTCoreDownloadPathRoot = ("U:\Users\" + $strWin10IoTCoreUsername + "\Downloads")

function Get-PSVersion {
    if (Test-Path variable:\PSVersionTable) {
        $PSVersionTable.PSVersion
    } else {
        [version]("1.0")
    }
}

# Download PowerShell ZIP
Invoke-WebRequest -Uri ($strDownloadSourceRootPath + $strPowerShellZIPFileNameToDownload) -OutFile (Join-Path $strDownloadFolder $strPowerShellZIPFileNameToDownload)
# TO-DO: Create backward-compatible approach for this

$versionPowerShell = Get-PSVersion
#endregion DownloadPowerShell7ForWin10IoTCore

#region ConnectToWin10IoTCorePS51
##############################################################################################
# Part 2 - Connect to Windows 10 IoT Core using Remote PowerShell

# Make sure the target system is in the trusted hosts list
# From PowerShell: winrm set winrm/config/client `@`{TrustedHosts=`"10.1.2.132`"`}
# From Command Prompt: winrm set winrm/config/client @{TrustedHosts="10.1.2.132"}

# Connect to Windows 10 IoT Core (PowerShell version 5.1)
$credential = Get-Credential $strWin10IoTCoreUsername
$PSSession = New-PSSession -ComputerName $strWin10IoTCoreDeviceIPOrHostname -Credential $credential

# Copy the downloaded version of PowerShell to the Windows 10 IoT Core system
if ($versionPowerShell.Major -ge 5) {
    Copy-Item (Join-Path $strDownloadFolder $strPowerShellZIPFileNameToDownload) -Destination $strWin10IoTCoreDownloadPathRoot -ToSession $PSSession
} else {
    Write-Error "Cannot copy a file to a PSSession on PowerShell v4 and previous; need to identify and write workaround!"
}

# Enter the PSSession for the IoT Core device
Enter-PSSession $PSSession
#endregion ConnectToWin10IoTCorePS51

#region SetUpPS51EnvironmentOnWin10IotCore
##############################################################################################
# Part 3 - Set Up Needed Variables and Functions Within Remote PowerShell Environment

# Set up and replay relevant functions because they do not exist in the remote session

#region FunctionsToSupportErrorHandling
function Get-ReferenceToLastError {
    # Function returns $null if no errors on on the $error stack;
    # Otherwise, function returns a reference (memory pointer) to the last error that occurred.
    if ($error.Count -gt 0) {
        [ref]($error[0])
    } else {
        $null
    }
}

function Test-ErrorOccurred {
    # Function accepts two positional arguments:
    #
    # The first argument is a reference (memory pointer) to the last error that had occurred
    #   prior to calling the command in question - that is, the command that we want to test
    #   to see if an error occurred.
    #
    # The second argument is a reference to the last error that had occurred as-of the
    #   completion of the command in question
    #
    # Function returns $true if it appears that an error occurred; $false otherwise

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
#endregion FunctionsToSupportErrorHandling

#region FunctionsSupportingCheckForExistenceOfObjectType
function Get-ExportedTypesFromRuntimeAssemblySafely {
    # The first argument is a reference to a System.Object[] (array) that will be used to store output.
    #   The function guarantees that the output will always be an array, even when a single item is
    #   returned.
    # The second argument is a reference (pointer) to a System.Reflection.RuntimeAssembly object from
    #   which we will get its exported types
    #
    # The function returns 0 if no error; 1 if no error but no data; 2 if error
    #
    # Example usage:
    #
    # $arrReturnData = @()
    # $arrAssemblies = @([AppDomain]::CurrentDomain.GetAssemblies())
    # $intReturnCode = Get-ExportedTypesFromRuntimeAssemblySafely ([ref]$arrReturnData) ([ref]($arrAssemblies[0]))

    trap {
        # Intentionally left empty to prevent terminating errors from halting processing
    }

    # TO-DO: Validate input

    $strDescriptionOfWhatWeAreDoingInThisFunction = "getting exported types from a runtime assembly; this is expected when the computer is missing dependencies for .NET assemblies"

    $boolOutputErrorOnUnreliableCommandMaximumAttemptsExceeded = $false
    $boolOutputWarningOnUnreliableCommandMaximumAttemptsExceeded = $false
    $boolOutputVerboseOnUnreliableCommandMaximumAttemptsExceeded = $false
    $boolOutputDebugOnUnreliableCommandMaximumAttemptsExceeded = $true

    # Retrieve the newest error on the stack prior to calling the unreliable command
    $refLastKnownError = Get-ReferenceToLastError

    # Store current error preference; we will restore it after we call the unreliable command
    $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

    # Set ErrorActionPreference to SilentlyContinue; this will suppress error output.
    # Terminating errors will not output anything, kick to the empty trap statement and then
    # continue on. Likewise, non-terminating errors will also not output anything, but they
    # do not kick to the trap statement; they simply continue on.
    $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

    # Call the unreliable command
    $output = @((($args[1]).Value).GetExportedTypes())

    # Restore the former error preference
    $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

    # Retrieve the newest error on the error stack
    $refNewestCurrentError = Get-ReferenceToLastError

    if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
        if ($boolOutputErrorOnUnreliableCommandMaximumAttemptsExceeded) {
            Write-Error ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ".")
        } elseif ($boolOutputWarningOnUnreliableCommandMaximumAttemptsExceeded) {
            Write-Warning ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ".")
        } elseif ($boolOutputVerboseOnUnreliableCommandMaximumAttemptsExceeded) {
            Write-Verbose ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ".")
        } elseif ($boolOutputDebugOnUnreliableCommandMaximumAttemptsExceeded) {
            Write-Debug ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ".")
        }

        2 # Indicates a failure
    } else {
        $intReturnCode = 1 # Indicates no error occurred but that no results were obtained
        if ($null -ne $output) {
            if ($output.GetType().FullName -match ([regex]::Escape("[]"))) {
                if (($output.Count) -gt 0) {
                    # We have output
                    (($args[0]).Value) = $output
                    $intReturnCode = 0 # Indicates no error and that results were obtained
                }
            }
        }

        $intReturnCode
    }
}

function Get-TypeNames {
    $arrAssemblies = @([AppDomain]::CurrentDomain.GetAssemblies())

    $boolCheckForDynamicAssembly = $false
    if ($null -ne $arrAssemblies) {
        if ($arrAssemblies.GetType().FullName -match ([regex]::Escape("[]"))) {
            if ($arrAssemblies.Count -ge 1) {
                if (($arrAssemblies[0] | Get-Member | ForEach-Object {$_.Name}) -contains "IsDynamic") {
                    $boolCheckForDynamicAssembly = $true
                }
            }
        }
    }

    $arrAssemblies | `
        ForEach-Object {
            if (($boolCheckForDynamicAssembly -eq $false) -or ($_.IsDynamic -eq $false)) {
                # Cannot GetExportedTypes() on a dynamic assesmbly
                #$_.GetExportedTypes()
                $arrOutput = @()
                $intReturnCode = Get-ExportedTypesFromRuntimeAssemblySafely ([ref]$arrOutput) ([ref]$_)
                if ($intReturnCode -eq 2) {
                    # Error condition
                    Write-Warning ("Unable to call the GetExportedTypes() method on `"" + ([string]$_) + "`"; the list of exported types may be incomplete.")
                } elseif ($intReturnCode -eq 0) {
                    # No error
                    $arrOutput
                }
            }
        } | `
        ForEach-Object {
            ([string]($_.Namespace)) + "." + ([string]($_.Name))
        }
}

function Test-TypeNameAvailability {
    # First argument is a string containing the fully-qualified type name to test for

    # Second argument is optional. If supplied, should be $true or $false indicating whether
    # to load type names into a memory cache using a global variable, using the cache on
    # subsequent function calls. If caching is enabled, it improves performance by approximately 45%

    # Returns $true if the type name is available in the current context; $false otherwise

    # Example usage:
    # Test-TypeNameAvailability "Microsoft.Exchange.Data.RecipientAccessRight" $true

    $strTypeName = $args[0]

    if ($args.Count -gt 1) {
        $boolUseCaching = $args[1]
    } else {
        $boolUseCaching = $false
    }

    if ($boolUseCaching -eq $true) {
        if ((Test-Path variable:global:__arrTypeNameCache) -eq $false) {
            # Create the cached TypeName data
            $global:__arrTypeNameCache = @(Get-TypeNames)
        }
        # Use the existing cache
        $refTypeNameCache = [ref]($global:__arrTypeNameCache)
    } else {
        $arrTypeNameCache = @(Get-TypeNames)
        $refTypeNameCache = [ref]$arrTypeNameCache
    }

    #TO-DO: branch code for PS v3 and newer to use Where-Object to check property
    # directly without a scriptblock - or otherwise improve performance
    $arrResults = @(($refTypeNameCache.Value) | Where-Object {$_ -eq $strTypeName})

    $boolResult = $false
    if ($null -ne $arrResults) {
        if ($arrResults.GetType().FullName -match ([regex]::Escape("[]"))) {
            if ($arrResults.Count -ge 1) {
                $boolResult = $true
            }
        }
    }

    $boolResult
}
#endregion FunctionsSupportingCheckForExistenceOfObjectType

function Test-PowerShellCommand {
    # The function takes one argument: a string with the PowerShell command for which we are
    # checking existence, i.e., the parameter passed to Get-Command
    #
    # The function returns $true if the command is available;
    #   $false otherwise
    #
    # Example usage:
    #
    # $boolResult = Test-PowerShellCommand "Expand-Archive"
    # if ($boolResult) {
    #   # Do something with Expand-Archive
    # } else {
    #   # Don't do anything with Expand-Archive because it does not exist
    # }

    trap {
        # Intentionally left empty to prevent terminating errors from halting processing
    }

    if ($args.Count -le 0) {
        $false
    } else {
        if (($args[0]).GetType().FullName -ne "System.String") {
            $false
        } else {
            $strCommand = ([string]($args[0]))

            $cmdletInfo = $null

            # Retrieve the newest error on the stack prior to calling the unreliable command
            $refLastKnownError = Get-ReferenceToLastError

            # Store current error preference; we will restore it after we call the unreliable command
            $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

            # Set ErrorActionPreference to SilentlyContinue; this will suppress error output.
            # Terminating errors will not output anything, kick to the empty trap statement and then
            # continue on. Likewise, non-terminating errors will also not output anything, but they
            # do not kick to the trap statement; they simply continue on.
            $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

            # Call the unreliable command
            $cmdletInfo = Get-Command $strCommand

            # Restore the former error preference
            $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

            # Retrieve the newest error on the error stack
            $refNewestCurrentError = Get-ReferenceToLastError

            if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
                $false
            } else {
                if ($null -eq $strCommand) {
                    $false
                } else {
                    $true
                }
            }
        }
    }
}

function Get-PSVersion {
    if (Test-Path variable:\PSVersionTable) {
        $PSVersionTable.PSVersion
    } else {
        [version]("1.0")
    }
}

function Test-Windows {
    if (Test-Path variable:\isWindows) {
        $isWindows
    } else {
        $true
    }
}

function Split-StringOnLiteralString {
    trap {
        Write-Error "An error occurred using the Split-StringOnLiteralString function. This was most likely caused by the arguments supplied not being strings"
    }

    if ($args.Length -ne 2) {
        Write-Error "Split-StringOnLiteralString was called without supplying two arguments. The first argument should be the string to be split, and the second should be the string or character on which to split the string."
    } else {
        if (($args[0]).GetType().Name -ne "String") {
            Write-Warning "The first argument supplied to Split-StringOnLiteralString was not a string. It will be attempted to be converted to a string. To avoid this warning, cast arguments to a string before calling Split-StringOnLiteralString."
            $strToSplit = [string]$args[0]
        } else {
            $strToSplit = $args[0]
        }

        if ((($args[1]).GetType().Name -ne "String") -and (($args[1]).GetType().Name -ne "Char")) {
            Write-Warning "The second argument supplied to Split-StringOnLiteralString was not a string. It will be attempted to be converted to a string. To avoid this warning, cast arguments to a string before calling Split-StringOnLiteralString."
            $strSplitter = [string]$args[1]
        } elseif (($args[1]).GetType().Name -eq "Char") {
            $strSplitter = [string]$args[1]
        } else {
            $strSplitter = $args[1]
        }

        $strSplitterInRegEx = [regex]::Escape($strSplitter)

        [regex]::Split($strToSplit, $strSplitterInRegEx)
    }
}

function Expand-ZIPBackwardCompatible {
    # This function takes 1-2 positional arguments
    #
    # If two arguments are specified:
    #   The first argument is the destination path, i.e., the path to which we extract the ZIP.
    #   The second argument is the path to the ZIP file
    #
    # If one argument is specified, it is the path to the ZIP file. In this case, the
    #   destination path will be the current working directory plus a subfolder named the same
    #   as the ZIP file (minus the .ZIP extension, if one exists)
    #
    # The function does not return anything

    $strZIPPath = $null
    $strDestinationPath = $null
    if ($args.Count -ge 2) {
        if (($args[0]).GetType().FullName -eq "System.String") {
            $strDestinationPath = ([string]($args[0]))
        }
        if (($args[1]).GetType().FullName -eq "System.String") {
            $strZIPPath = ([string]($args[1]))
        }
    } elseif ($args.Count -eq 1) {
        if (($args[0]).GetType().FullName -eq "System.String") {
            $strZIPPath = ([string]($args[0]))
        }
        $strDestinationPath = (Get-Location).Path
        if ($null -ne $strZIPPath) {
            # Append folder with name of ZIP (pre-extension) to match behavior of Expand-Archive

            # First, get ZIP file name
            $strProviderZIPPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($strZIPPath)
            $strZIPFileName = Split-Path -Path $strProviderZIPPath -Leaf

            # Remove the .zip extension from the file name, if there is one
            $arrFileName = @(Split-StringOnLiteralString $strZIPFileName ".")
            if ($arrFileName[$arrFileName.Count - 1] -eq "zip") {
                # ZIP file has .zip extension as usual
                $strZIPWithoutExtension = $arrFileName[0]
                for ($intCounter = 1; $intCounter -le ($arrFileName.Count - 2); $intCounter++) {
                    $strZIPWithoutExtension = $strZIPWithoutExtension + "." + $arrFileName[$intCounter]
                }
            } else {
                # ZIP file did not contain .zip extension
                $strZIPWithoutExtension = $strZIPFileName
            }

            # Build the destination path
            $strDestinationPath = Join-Path $strDestinationPath $strZIPWithoutExtension
        }
    }

    if ($null -eq $strZIPPath) {
        Write-Error "Invalid ZIP path specified in Expand-ZIPBackwardCompatible"
    } elseif ($null -eq $strDestinationPath) {
        Write-Error "Invalid destination path specified in Expand-ZIPBackwardCompatible"
    } else {
        # TO-DO: check for existence of ZIP file
        if (Test-PowerShellCommand "Expand-Archive") {
            Expand-Archive -Path $strZIPPath -DestinationPath $strDestinationPath
        } else {
            $strProviderZIPPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($strZIPPath)
            $strProviderDestinationPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($strDestinationPath)

            if ((Test-Path $strDestinationPath) -ne $true) {
                New-Item -Path $strDestinationPath -ItemType Directory | Out-Null
            }

            # Check to see if System.IO.Compression.ZipFile is available
            $boolZipFileTypeNameAvailable = $false
            if (Test-TypeNameAvailability "System.IO.Compression.ZipFile" $true) {
                $boolZipFileTypeNameAvailable = $true
            } else {
                # System.IO.Compression.ZipFile was not available; attempt to load it and then re-check

                # Load the assembly
                if ($versionPowerShell.Major -ge 2) {
                    # Add-Type is available
                    Add-Type -AssemblyName "System.IO.Compression.FileSystem"
                } else {
                    # Add-Type is not available; use [system.reflection.assembly]
                    $reflectionAssemblyResult = [system.reflection.assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")
                }

                # Re-check to make sure it's present
                if (Test-TypeNameAvailability "System.IO.Compression.ZipFile" $false) {
                    $boolZipFileTypeNameAvailable = $true
                }
            }

            if ($boolZipFileTypeNameAvailable) {
                [System.IO.Compression.ZipFile]::ExtractToDirectory($strProviderZIPPath, $strProviderDestinationPath)
            } else {
                if (Test-Windows) {
                    # Is Windows; use the Shell.Application COM object
                    $comObjectShellApplication = New-Object -ComObject "Shell.Application"
                    $comObjectShellApplicationNamespaceZIP = $comObjectShellApplication.Namespace($strProviderZIPPath)
                    $comObjectShellApplicationNamespaceZIPItems = @($comObjectShellApplicationNamespaceZIP.Items())
                    $comObjectShellApplicationNamespaceDestinationFolder = $comObjectShellApplication.Namespace($strProviderDestinationPath)
                    $intCounter = 1
                    $strTempFolderPath = [System.IO.Path]::GetTempPath()
                    $strZIPFileName = Split-Path -Path $strProviderZIPPath -Leaf
                    $comObjectShellApplicationNamespaceZIPItems |
                        ForEach-Object {
                            $comObjectShellApplicationNamespaceDestinationFolder.CopyHere($_, (4 + 16 + 256))

                            # Clean-up temp folder that sometimes gets created
                            $strTempPathToCleanup = Join-Path $strTempFolderPath ("Temporary Directory " + ([string]$intCounter) + " for " + $strZIPFileName)
                            if (Test-Path $strTempPathToCleanup) {
                                # Remove the folder
                                Remove-Item -Path $strTempPathToCleanup -Recurse -Force
                            }
                        }
                } else {
                    # Is not Windows, and all other approaches have failed. Give up!
                    Write-Error "Unable to extract ZIP file; no interfaces available to perform this operation."
                }
            }
        }
    }
}

# Replay relevant variables because they do not yet exist in the remote session

# Get the PowerShell version again, because we are in a remote session
$versionPowerShell = Get-PSVersion

# Extract the ZIP that we transferred to the device
$strPowerShellVersion = "7.1.1"
$strPowerShellOSAbbreviation = "win"
$strPowerShellCPUPlatformAbbreviation = "arm32"
$strPowerShellZIPFileNameToDownloadRoot = "PowerShell-" + $strPowerShellVersion + "-" + $strPowerShellOSAbbreviation + "-" + $strPowerShellCPUPlatformAbbreviation
$strPowerShellZIPFileNameToDownload = $strPowerShellZIPFileNameToDownloadRoot + ".zip"

#$strPowerShellZIPFileNameToDownloadRoot = "PowerShell-7.0.0-win-arm32"
#$strPowerShellZIPFileNameToDownload = $strPowerShellZIPFileNameToDownloadRoot + ".zip"

$strWin10IoTCoreUsername = "Administrator"
$strWin10IoTCoreDownloadPathRoot = Join-Path "U:\Users" $strWin10IoTCoreUsername
$strWin10IoTCoreDownloadPathRoot = Join-Path $strWin10IoTCoreDownloadPathRoot "Downloads"
#endregion SetUpPS51EnvironmentOnWin10IotCore

#region InstallPS7OnWin10IotCore
##############################################################################################
# Part 4 - Install PowerShell 7 on Windows 10 IoT Core
#
# See also: https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/install-powershell.ps1

# Get the PowerShell version again, because we are in a remote session
$versionPowerShell = Get-PSVersion

# Extract the ZIP that we transferred to the device
Set-Location $strWin10IoTCoreDownloadPathRoot
$strZIPPath = Join-Path $strWin10IoTCoreDownloadPathRoot $strPowerShellZIPFileNameToDownload
Expand-ZIPBackwardCompatible $strZIPPath

# Change to extracted folder and set up remoting
Set-Location (Join-Path "." $strPowerShellZIPFileNameToDownloadRoot)
.\Install-PowerShellRemoting.ps1 -PowerShellHome .

# You will get disconnected. This is expected.

#endregion InstallPS7OnWin10IotCore

#region ConnectToWin10IoTCorePS7
##############################################################################################
# Part 5 - Connect Remotely to PowerShell 7 on Windows 10 IoT Core

# If needed, define important variables:
$strWin10IoTCoreDeviceIPOrHostname = "10.1.2.132"
$strPowerShellVersion = "7.1.1"
$strWin10IoTCoreUsername = "Administrator"

# If needed, get credential again:
$credential = Get-Credential $strWin10IoTCoreUsername

# Reconnect, but to the new version
$PSSession = New-PSSession -ComputerName $strWin10IoTCoreDeviceIPOrHostname -Credential $credential -ConfigurationName ("powershell." + $strPowerShellVersion)
Enter-PSSession $PSSession
#endregion ConnectToWin10IoTCorePS7

#region DefineFunctionsForConfiguringWindowsUpdate
##############################################################################################
# Part 6 - Define Helper Functions

# Create a helper function used to check for presence of registry value
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
            Remove-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName
            New-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName -Value $registryValueDesired -Type $registryTypeDesired | Out-Null
        } else {
            # Correct type; check value
            if (($registryvalue.$strValueName) -ne $registryValueDesired) {
                # Incompatible value; update it
                Set-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName -Value $registryValueDesired
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
            Remove-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName
            New-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName -Value $registryValueDesired -Type $registryTypeDesired | Out-Null
        } else {
            # Correct type; check value
            if (($registryvalue.$strValueName) -lt $registryValueDesired) {
                # Incompatible value; update it
                Set-ItemProperty -LiteralPath $strRegistryPath -Name $strValueName -Value $registryValueDesired
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
#endregion DefineFunctionsForConfiguringWindowsUpdate

function Test-Windows {
    if (Test-Path variable:\isWindows) {
        $isWindows
    } else {
        $true
    }
}

#region ConfigureWindowsUpdate
##############################################################################################
# Part 7 - Configure Windows Update



#endregion ConfigureWindowsUpdate

#region DefineFunctionsForCreatingScheduledTask
##############################################################################################
# Part 7 - Define Functions Needed For Creating a Scheduled Task

function Get-PSVersion {
    if (Test-Path variable:\PSVersionTable) {
        $PSVersionTable.PSVersion
    } else {
        [version]("1.0")
    }
}

function Test-Windows {
    if (Test-Path variable:\isWindows) {
        $isWindows
    } else {
        $true
    }
}

#endregion DefineFunctionsForCreatingScheduledTask

# Install a PSModule used for Windows Update management on IoT Core system
Install-Module -Name PSWindowsUpdate -Force

# List the available commands in PSWindowsUpdate
Get-Command -Module PSWindowsUpdate | Sort-Object

# Check for updates
Get-WindowsUpdate -MicrosoftUpdate -Verbose

# Create a helper function used by Test-CommandExistence to retrieve a pointer to the last error that occurred
function Get-ReferenceToLastError {
    # Function returns $null if no errors on on the $error stack;
    # Otherwise, function returns a reference (memory pointer) to the last error that occurred.
    if ($error.Count -gt 0) {
        [ref]($error[0])
    } else {
        $null
    }
}

# Create a helper function used by Test-CommandExistence to see if an error occurred
function Test-ErrorOccurred {
    # Function accepts two positional arguments:
    #
    # The first argument is a reference (memory pointer) to the last error that had occurred
    #   prior to calling the command in question - that is, the command that we want to test
    #   to see if an error occurred.
    #
    # The second argument is a reference to the last error that had occurred as-of the
    #   completion of the command in question
    #
    # Function returns $true if it appears that an error occurred; $false otherwise

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

function Get-ExecutablePathSafely {
    # The first argument is a reference to a string. If the command is valid, and if the
    #    command was an executable, then the string will be populated with its path. If the
    #    command was valid but not an executable (e.g., "dir" on Windows), then the string will
    #    be set to $null. If the command was not valid, then the string is unchanged.
    # The second argument is a string that contains the name of the executable for which we are
    #    to obtain the path. It is assumed that the executable is in the system path
    # 
    # The function returns $true if the command exists; $false otherwise
    #
    # Example usage:
    #
    # $boolCommandExists = Get-ExecutablePathSafely ([ref]$strPath) "cmd" # returns $true, and $strPath would be set to "C:\Windows\system32\cmd.exe"
    # $boolCommandExists = Get-ExecutablePathSafely ([ref]$strPath) "dir" # returns $true and $strPath would be $null
    # $boolCommandExists = Get-ExecutablePathSafely ([ref]$strPath) "fakecommandmadeup" # returns $false and $strPath would be unchanged

    trap {
        # Intentionally left empty to prevent terminating errors from halting processing
    }

    # Retrieve the newest error on the stack prior to calling the unreliable command
    $refLastKnownError = Get-ReferenceToLastError

    # Store current error preference; we will restore it after we call the unreliable command
    $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

    # Set ErrorActionPreference to SilentlyContinue; this will suppress error output.
    # Terminating errors will not output anything, kick to the empty trap statement and then
    # continue on. Likewise, non-terminating errors will also not output anything, but they
    # do not kick to the trap statement; they simply continue on.
    $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

    $output = (Get-Command $args[1]).Path

    # Restore the former error preference
    $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

    # Retrieve the newest error on the error stack
    $refNewestCurrentError = Get-ReferenceToLastError

    if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
        $false
    } else {
        $true
        ($args[0]).Value = $output
    }
}

function Get-PowerShellExecutablePath {
    $strCommand = "powershell"
    if (Test-Path variable:\PSVersionTable) {
        if ($null -ne $PSVersionTable.PSEdition) {
            if ($PSVersionTable.PSEdition -eq "Core") {
                # PowerShell 5.1 or prior
                $strCommand = "pwsh"
            }
        }
    }

    $strPath = [string]
    if (Get-ExecutablePathSafely ([ref]$strPath) $strCommand) {
        $strPath
    } else {
        if (Test-Path variable:\isWindows) {
            $boolIsReallyWindows = $isWindows
        } else {
            $boolIsReallyWindows = $true
        }

        if ($boolIsReallyWindows) {
            $strPath = Join-Path $PSHOME ($strCommand + ".exe")
        } else {
            $strPath = Join-Path $PSHOME $strCommand
        }

        if (Test-Path $strPath) {
            $strPath
        } else {
            $null
        }
    }
}


# Check for updates
Get-WindowsUpdate -MicrosoftUpdate -Verbose

$intTriggerTypeRegistration = 7 # Registration trigger
$intActionTypeExecutable = 0 # Executable action
$COMObjectScheduleService = New-Object -ComObject Schedule.Service
$COMObjectScheduleService.Connect()
$COMObjectScheduleServiceFolder = $COMObjectScheduleService.GetFolder("\")
$COMObjectScheduleServiceTaskDefinition = $COMObjectScheduleService.NewTask(0) # The flags parameter is 0 because it is not supported.
$COMObjectScheduleServiceTaskDefinitionRegistrationInfo = $COMObjectScheduleServiceTaskDefinition.RegistrationInfo
$COMObjectScheduleServiceTaskDefinitionRegistrationInfo.Description = "Start Microsoft Update installation when the task is registered."
$COMObjectScheduleServiceTaskDefinitionRegistrationInfo.Author = "West Monroe Partners"
$COMObjectScheduleServiceTaskDefinitionSettings = $COMObjectScheduleServiceTaskDefinition.Settings
$COMObjectScheduleServiceTaskDefinitionSettings.StartWhenAvailable = $true
$COMObjectScheduleServiceTaskDefinitionTriggers = $COMObjectScheduleServiceTaskDefinition.Triggers
$COMObjectScheduleServiceTaskDefinitionTrigger = $COMObjectScheduleServiceTaskDefinitionTriggers.Create($intTriggerTypeRegistration)
$COMObjectScheduleServiceTaskDefinitionTrigger.ExecutionTimeLimit = "P1D" # Execution limit of one day
$COMObjectScheduleServiceTaskDefinitionTrigger.Id = "RegistrationTriggerId"
$COMObjectScheduleServiceTaskDefinitionAction = $COMObjectScheduleServiceTaskDefinition.Actions.Create($intActionTypeExecutable)

Test-Path 
$COMObjectScheduleServiceTaskDefinitionAction.Path = (Get-PowerShellExecutablePath)
$COMObjectScheduleServiceTaskDefinitionAction.Arguments = @("-Command", "{ScriptHere}")

Action = taskDefinition.Actions.Create( ActionTypeExecutable )


# Return to host
Exit-PSSession
