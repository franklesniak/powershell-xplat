# PowerShell demonstration on Azure Cloud Shell
# Written by Frank Lesniak
# Last updated: 2020-04-28

##########################################
# Part 1: What version of PowerShell and what modules?

# Show PowerShell version info
$PSVersionTable

# Get the list of ready-to-go modules:
Get-Module

# Get the list of installed modules:
Get-Module -ListAvailable


##########################################
# Part 2: Examine Operating System

# Show that we're on a mac
$isLinux

# ...and we're not on MacOS or Windows
$isMacOS

# ...and not on Windows
$isWindows
# Fun fact: Azure Cloud Shell has a Windows variant at one time! Microsoft ditched it for Linux :)

# No Get-ComputerInfo :(
Get-ComputerInfo
# Previous command will throw error

##########################################
# Part 3: What OS is this, really?

# Create helper function for string-parsing
function Split-StringOnLiteralString
{
    trap
    {
        Write-Error "An error occurred using the Split-StringOnLiteralString function. This was most likely caused by the arguments supplied not being strings"
    }

    if ($args.Length -ne 2) `
    {
        Write-Error "Split-StringOnLiteralString was called without supplying two arguments. The first argument should be the string to be split, and the second should be the string or character on which to split the string."
    } `
    else `
    {
        if (($args[0]).GetType().Name -ne "String") `
        {
            Write-Warning "The first argument supplied to Split-StringOnLiteralString was not a string. It will be attempted to be converted to a string. To avoid this warning, cast arguments to a string before calling Split-StringOnLiteralString."
            $strToSplit = [string]$args[0]
        } `
        else `
        {
            $strToSplit = $args[0]
        }

        if ((($args[1]).GetType().Name -ne "String") -and (($args[1]).GetType().Name -ne "Char")) `
        {
            Write-Warning "The second argument supplied to Split-StringOnLiteralString was not a string. It will be attempted to be converted to a string. To avoid this warning, cast arguments to a string before calling Split-StringOnLiteralString."
            $strSplitter = [string]$args[1]
        } `
        elseif (($args[1]).GetType().Name -eq "Char") `
        {
            $strSplitter = [string]$args[1]
        } `
        else `
        {
            $strSplitter = $args[1]
        }

        $strSplitterInRegEx = [regex]::Escape($strSplitter)

        [regex]::Split($strToSplit, $strSplitterInRegEx)
    }
}

# Create a helper function used by Test-CommandExistence to retrieve a pointer to the last error that occurred
function Get-ReferenceToLastError
{
    # Function returns $null if no errors on on the $error stack;
    # Otherwise, function returns a reference (memory pointer) to the last error that occurred.
    if ($error.Count -gt 0)
    {
        [ref]($error[0])
    } `
    else `
    {
        $null
    }
}

# Create a helper function used by Test-CommandExistence to see if an error occurred
function Test-ErrorOccurred
{
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
    if (($null -ne ($args[0])) -and ($null -ne ($args[1])))
    {
        # Both not $null
        if ((($args[0]).Value) -ne (($args[1]).Value))
        {
            $boolErrorOccurred = $true
        }
    } `
    else `
    {
        # One is $null, or both are $null
        # NOTE: ($args[0]) could be non-null, while ($args[1])
        # could be null if $error was cleared; this does not indicate an error.
        # So:
        # If both are null, no error
        # If ($args[0]) is null and ($args[1]) is non-null, error
        # If ($args[0]) is non-null and ($args[1]) is null, no error
        if (($null -eq ($args[0])) -and ($null -ne ($args[1])))
        {
            $boolErrorOccurred
        }
    }

    $boolErrorOccurred
}

# Create helper function to test for the existence of a command
function Test-CommandExistence
{
    # The first argument is a scriptblock containing the command to run
    # 
    # The function returns $true if the command exists; $false otherwise
    #
    # Example usage:
    #
    # $boolCommandExists = Test-CommandExistence {dir} # returns $true
    # $boolCommandExists = Test-CommandExistence {FakeCommandMadeUp} # returns $false

    trap
    {
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

    $output = & ($args[0])

    # Restore the former error preference
    $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

    # Retrieve the newest error on the error stack
    $refNewestCurrentError = Get-ReferenceToLastError

    if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError)
    {
        $false
    } `
    else `
    {
        $true
    }
}

# Create helper function to run a command and store the output if successful
function Invoke-CommandSafely
{
    # The first argument is a reference to an object in which the output will be stored
    # The second argument is a scriptblock containing the command to run
    # 
    # The function returns $true if the command ran successfully; $false otherwise
    #
    # Example usage:
    #
    # $strOutput = [string]
    # $boolSuccess = Invoke-CommandSafely ([ref]$strOutput) {dir} # returns $true
    # $boolSuccess = Invoke-CommandSafely ([ref]$strOutput) {fakecommandmadeup} # returns $false and doesn't modify $strOutput

    trap
    {
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

    $output = & ($args[1])

    # Restore the former error preference
    $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

    # Retrieve the newest error on the error stack
    $refNewestCurrentError = Get-ReferenceToLastError

    if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError)
    {
        $false
    } `
    else `
    {
        ($args[0]).Value = $output
        $true
    }
}

# Create a backward-compatible, case-insensitive hashtable
$cultureDoNotCare = [System.Globalization.CultureInfo]::InvariantCulture
$caseInsensitiveHashCodeProvider = New-Object -TypeName "System.Collections.CaseInsensitiveHashCodeProvider" -ArgumentList @($cultureDoNotCare)
$caseInsensitiveComparer = New-Object -TypeName "System.Collections.CaseInsensitiveComparer" -ArgumentList @($cultureDoNotCare)
$hashtableOSInfo = New-Object -TypeName "System.Collections.Hashtable" -ArgumentList @($caseInsensitiveHashCodeProvider, $caseInsensitiveComparer)

# Create a second "bridge" hashtable
$hashtableBridgeOSInfo = New-Object -TypeName "System.Collections.Hashtable" -ArgumentList @($caseInsensitiveHashCodeProvider, $caseInsensitiveComparer)

# Adopted from: https://unix.stackexchange.com/a/6348/409368
# This needs to be tested more-exhaustively on the minimum OS versions that PowerShell 6.0 (original release) supported
if (Test-Path variable:\isLinux) {
    if ($isLinux) {
        if (Test-Path (Join-Path "/etc" "os-release")) {
            # /etc/os-release exists
            $textFileOSRelease = Get-Content (Join-Path "/etc" "os-release")
            $textFileOSRelease |
                ForEach-Object {
                    $arrLine = Split-StringOnLiteralString $_ "="
                    if ($arrLine.Count -eq 2) {
                        # Found key-value pair
                        $strKey = $arrLine[0]
                        if ($hashtableOSInfo.ContainsKey($strKey) -eq $false) {
                            $intValueLength = ($arrLine[1]).Length
                            if ($intValueLength -ge 2) {
                                if ((($arrLine[1])[0] -eq "`"") -and (($arrLine[1])[$intValueLength - 1] -eq "`"")) {
                                    # Value is wrapped in quotation marks; remove them
                                    $strValue = ($arrLine[1]).Substring(1, $intValueLength - 2)
                                } else {
                                    $strValue = $arrLine[1]
                                }
                            } else {
                                $strValue = $arrLine[1]
                            }
                            $hashtableOSInfo.Add($strKey, $strValue)
                        } else {
                            # Duplicate key in hashtable
                            # Bad entry in file; do nothing
                        }
                    } else {
                        # Malformed line; ignore
                    }
                }
        } elseif (Test-CommandExistence { lsb_release }) {
            $strKey = "VERSION"
            $strValue = [string]
            $boolSuccess = Invoke-CommandSafely ([ref]$strValue) {lsb_release --version --short *>&1}
            if ($boolSuccess -eq $false) {
                $strValue = $null
            }
            $hashtableOSInfo.Add($strKey, $strValue)

            $strKey = "NAME" # This appears to be the best match; could also be "ID"
            $strValue = [string]
            $boolSuccess = Invoke-CommandSafely ([ref]$strValue) {lsb_release --id --short *>&1}
            if ($boolSuccess -eq $false) {
                $strValue = $null
            }
            $hashtableOSInfo.Add($strKey, $strValue)

            $strKey = "PRETTY_NAME"
            $strValue = [string]
            $boolSuccess = Invoke-CommandSafely ([ref]$strValue) {lsb_release --description --short *>&1}
            if ($boolSuccess -eq $false) {
                $strValue = $null
            }
            $hashtableOSInfo.Add($strKey, $strValue)

            $strKey = "VERSION_ID"
            $strValue = [string]
            $boolSuccess = Invoke-CommandSafely ([ref]$strValue) {lsb_release --release --short *>&1}
            if ($boolSuccess -eq $false) {
                $strValue = $null
            }
            $hashtableOSInfo.Add($strKey, $strValue)

            $strKey = "VERSION_CODENAME"
            $strValue = [string]
            $boolSuccess = Invoke-CommandSafely ([ref]$strValue) {lsb_release --codename --short *>&1}
            if ($boolSuccess -eq $false) {
                $strValue = $null
            }
            $hashtableOSInfo.Add($strKey, $strValue)
        } elseif (Test-Path (Join-Path "/etc" "lsb-release")) {
            # /etc/lsb-release exists
            $textFileOSRelease = Get-Content (Join-Path "/etc" "lsb-release")
            $textFileOSRelease |
                ForEach-Object {
                    $arrLine = Split-StringOnLiteralString $_ "="
                    if ($arrLine.Count -eq 2) {
                        # Found key-value pair
                        $strKey = $arrLine[0]
                        if ($hashtableBridgeOSInfo.ContainsKey($strKey) -eq $false) {
                            $intValueLength = ($arrLine[1]).Length
                            if ($intValueLength -ge 2) {
                                if ((($arrLine[1])[0] -eq "`"") -and (($arrLine[1])[$intValueLength - 1] -eq "`"")) {
                                    # Value is wrapped in quotation marks; remove them
                                    $strValue = ($arrLine[1]).Substring(1, $intValueLength - 2)
                                } else {
                                    $strValue = $arrLine[1]
                                }
                            } else {
                                $strValue = $arrLine[1]
                            }
                            $hashtableBridgeOSInfo.Add($strKey, $strValue)
                        } else {
                            # Duplicate key in hashtable
                            # Bad entry in file; do nothing
                        }
                    } else {
                        # Malformed line; ignore
                    }
                }
            # Build translated hashtable

            $strBridgeKey = "DISTRIB_VERSION"
            $strKey = "VERSION"
            $strValue = $null
            if ($hashtableBridgeOSInfo.ContainsKey($strBridgeKey)) {
                $strValue = $hashtableBridgeOSInfo.Item($strBridgeKey)
            }
            $hashtableOSInfo.Add($strKey, $strValue)

            $strBridgeKey = "DISTRIB_ID"
            $strKey = "NAME" # This appears to be the best match; could also be "ID"
            $strValue = $null
            if ($hashtableBridgeOSInfo.ContainsKey($strBridgeKey)) {
                $strValue = $hashtableBridgeOSInfo.Item($strBridgeKey)
            }
            $hashtableOSInfo.Add($strKey, $strValue)

            $strBridgeKey = "DISTRIB_DESCRIPTION"
            $strKey = "PRETTY_NAME"
            $strValue = $null
            if ($hashtableBridgeOSInfo.ContainsKey($strBridgeKey)) {
                $strValue = $hashtableBridgeOSInfo.Item($strBridgeKey)
            }
            $hashtableOSInfo.Add($strKey, $strValue)

            $strBridgeKey = "DISTRIB_RELEASE"
            $strKey = "VERSION_ID"
            $strValue = $null
            if ($hashtableBridgeOSInfo.ContainsKey($strBridgeKey)) {
                $strValue = $hashtableBridgeOSInfo.Item($strBridgeKey)
            }
            $hashtableOSInfo.Add($strKey, $strValue)

            $strBridgeKey = "DISTRIB_CODENAME"
            $strKey = "VERSION_CODENAME"
            $strValue = $null
            if ($hashtableBridgeOSInfo.ContainsKey($strBridgeKey)) {
                $strValue = $hashtableBridgeOSInfo.Item($strBridgeKey)
            }
            $hashtableOSInfo.Add($strKey, $strValue)
        } elseif (Test-Path (Join-Path "/etc" "debian_version")) {
            $textFileDebianVersion = Get-Content (Join-Path "/etc" "debian_version")
            $strKey = "VERSION"
            $strValue = $textFileDebianVersion[0]
            $hashtableOSInfo.Add($strKey, $strValue)

            $strKey = "ID_LIKE"
            $strValue = "debian"
            $hashtableOSInfo.Add($strKey, $strValue)
        } elseif (Test-Path (Join-Path "/etc" "SuSe-release")) {
            $textFileOpenSUSEVersion = Get-Content (Join-Path "/etc" "SuSe-release")
            $strKey = "PRETTY_NAME"
            $strValue = $textFileOpenSUSEVersion[0]
            $hashtableOSInfo.Add($strKey, $strValue)

            $strKey = "ID_LIKE"
            $strValue = "suse"
            $hashtableOSInfo.Add($strKey, $strValue)

            for ($intLineNumber = 1; $intLineNumber -lt $textFileOpenSUSEVersion.Count; $intLineNumber++) {
                $strLine = $textFileOpenSUSEVersion[$intLineNumber]
                $arrLine = Split-StringOnLiteralString $strLine " = "
                if ($arrLine.Count -ne 2) {
                    $arrLine = Split-StringOnLiteralString $strLine "="
                }
                if ($arrLine.Count -eq 2) {
                    $strKey = $arrLine[0]
                    if ($strKey -eq "CODENAME") {
                        $strKey = "VERSION_CODENAME"
                    }
                    $strValue = $arrLine[1]
                    $hashtableOSInfo.Add($strKey, $strValue)
                }
            }
        } elseif (Test-Path (Join-Path "/etc" "redhat-release")) {
            $textFileRedHatVersion = Get-Content (Join-Path "/etc" "redhat-release")
            $strKey = "PRETTY_NAME"
            $strValue = $textFileRedHatVersion[0]
            $hashtableOSInfo.Add($strKey, $strValue)
        } else {
            $strKey = "NAME"
            $strValue = [string]
            $boolSuccess = Invoke-CommandSafely ([ref]$strValue) {uname --operating-system *>&1}
            if ($boolSuccess -eq $false) {
                $strValue = $null
            }
            $hashtableOSInfo.Add($strKey, $strValue)

            $strKey = "VERSION_ID"
            $strValue = [string]
            $boolSuccess = Invoke-CommandSafely ([ref]$strValue) {uname --kernel-release *>&1}
            if ($boolSuccess -eq $false) {
                $strValue = $null
            }
            $hashtableOSInfo.Add($strKey, $strValue)

            $strKey = "VERSION"
            $strValue = [string]
            $boolSuccess = Invoke-CommandSafely ([ref]$strValue) {uname --kernel-version *>&1}
            if ($boolSuccess -eq $false) {
                $strValue = $null
            }
            $hashtableOSInfo.Add($strKey, $strValue)
        }
    }
}

# Display OS Findings:
$hashtableOSInfo
