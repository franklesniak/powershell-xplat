#region Readme #####################################################################
# This demo script is intended to be run on against Azure Cloud Shell.
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

#region Part 1: What Version of PowerShell and What Modules? #######################
# Show PowerShell version info
$PSVersionTable

# Get the list of ready-to-go modules:
Get-Module

# Get the list of installed modules:
Get-Module -ListAvailable
#endregion Part 1: What Version of PowerShell and What Modules? #######################

#region Part 2: Examine Operating System ###########################################
# Are we on Linux?
$IsLinux

# Are we on macOS?
$IsMacOS

# Are we on Windows?
$IsWindows

# Fun fact: Azure Cloud Shell had a Windows variant at one time! Microsoft ditched it
# for Linux :)

Get-ComputerInfo
# Previous command will throw error
# No Get-ComputerInfo :(
#endregion Part 2: Examine Operating System ###########################################

#region Part 4: Load Helper Functions ##############################################
function Split-StringOnLiteralString {
    # Split-StringOnLiteralString is designed to split a string the way the way that I
    # expected it to be done - using a literal string (as opposed to regex). It's also
    # designed to be backward-compatible with all versions of PowerShell and has been
    # tested successfully on PowerShell v1. My motivation for creating this function
    # was 1) I wanted a split function that behaved more like VBScript's Split
    # function, 2) I did not want to be messing around with RegEx, and 3) I needed code
    # that was backward-compatible with all versions of PowerShell.
    #
    # This function takes two positional arguments
    # The first argument is a string, and the string to be split
    # The second argument is a string or char, and it is that which is to split the string in the first parameter
    #
    # Note: This function always returns an array, even when there is zero or one element in it.
    #
    # Example:
    # $result = Split-StringOnLiteralString 'foo' ' '
    # # $result.GetType().FullName is System.Object[]
    # # $result.Count is 1
    #
    # Example 2:
    # $result = Split-StringOnLiteralString 'What do you think of this function?' ' '
    # # $result.Count is 7

    #region License ################################################################
    # Copyright 2023 Frank Lesniak

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

    #region DownloadLocationNotice #################################################
    # The most up-to-date version of this script can be found on the author's GitHub
    # repository at https://github.com/franklesniak/PowerShell_Resources
    #endregion DownloadLocationNotice #################################################

    $strThisFunctionVersionNumber = [version]'2.0.20230708.0'

    trap {
        Write-Error 'An error occurred using the Split-StringOnLiteralString function. This was most likely caused by the arguments supplied not being strings'
    }

    if ($args.Length -ne 2) {
        Write-Error 'Split-StringOnLiteralString was called without supplying two arguments. The first argument should be the string to be split, and the second should be the string or character on which to split the string.'
        $result = @()
    } else {
        $objToSplit = $args[0]
        $objSplitter = $args[1]
        if ($null -eq $objToSplit) {
            $result = @()
        } elseif ($null -eq $objSplitter) {
            # Splitter was $null; return string to be split within an array (of one element).
            $result = @($objToSplit)
        } else {
            if ($objToSplit.GetType().Name -ne 'String') {
                Write-Warning 'The first argument supplied to Split-StringOnLiteralString was not a string. It will be attempted to be converted to a string. To avoid this warning, cast arguments to a string before calling Split-StringOnLiteralString.'
                $strToSplit = [string]$objToSplit
            } else {
                $strToSplit = $objToSplit
            }

            if (($objSplitter.GetType().Name -ne 'String') -and ($objSplitter.GetType().Name -ne 'Char')) {
                Write-Warning 'The second argument supplied to Split-StringOnLiteralString was not a string. It will be attempted to be converted to a string. To avoid this warning, cast arguments to a string before calling Split-StringOnLiteralString.'
                $strSplitter = [string]$objSplitter
            } elseif ($objSplitter.GetType().Name -eq 'Char') {
                $strSplitter = [string]$objSplitter
            } else {
                $strSplitter = $objSplitter
            }

            $strSplitterInRegEx = [regex]::Escape($strSplitter)

            # With the leading comma, force encapsulation into an array so that an array is
            # returned even when there is one element:
            $result = @([regex]::Split($strToSplit, $strSplitterInRegEx))
        }
    }

    # The following code forces the function to return an array, always, even when there are
    # zero or one elements in the array
    $intElementCount = 1
    if ($null -ne $result) {
        if ($result.GetType().FullName.Contains('[]')) {
            if (($result.Count -ge 2) -or ($result.Count -eq 0)) {
                $intElementCount = $result.Count
            }
        }
    }
    $strLowercaseFunctionName = $MyInvocation.InvocationName.ToLower()
    $boolArrayEncapsulation = $MyInvocation.Line.ToLower().Contains('@(' + $strLowercaseFunctionName + ')') -or $MyInvocation.Line.ToLower().Contains('@(' + $strLowercaseFunctionName + ' ')
    if ($boolArrayEncapsulation) {
        $result
    } elseif ($intElementCount -eq 0) {
        , @()
    } elseif ($intElementCount -eq 1) {
        , (, ($args[0]))
    } else {
        $result
    }
}

function Test-CommandExistence {
    #region FunctionHeader #########################################################
    # This function executes a command (scriptblock) and determines if it results in an
    # error. This is useful when trying to determine if a non-cmdlet function is
    # available, e.g., a binary outside of PowerShell.
    #
    # One positional argument is required: a scriptblock object that contains the
    # command to be run
    #
    # The function returns $true if the command executed successfully (i.e., it
    # exists); $false otherwise
    #
    # Example usage:
    # Test-CommandExistence { lsb_release }
    #
    # Version: 1.0.20241003.0
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

    trap {
        # Intentionally left empty to prevent terminating errors from halting
        # processing
    }

    #region FunctionsToSupportErrorHandling ########################################
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
    #endregion FunctionsToSupportErrorHandling ########################################

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

    $output = & ($args[0])

    # Restore the former error preference
    $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

    # Retrieve the newest error on the error stack
    $refNewestCurrentError = Get-ReferenceToLastError

    if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
        # Error occurred

        # Return failure indicator:
        return $false
    } else {
        # No error occurred
        return $true
    }
}

function Invoke-CommandSafely {
    #region FunctionHeader #########################################################
    # This function runs a command "safely" by surpressing errors, if any. If the
    # command is successful, it returns the output of the command by reference.
    #
    # Two positional arguments are required:
    #
    # The first argument is a reference to an object, typically a string object if a
    # console command is being run, which will be used to store the command's
    # output.
    #
    # The second argument is a scriptblock object that contains the command to be run.
    #
    # The function returns $true if the process completed successfully; $false
    # otherwise
    #
    # Example usage:
    # $strOutput = [string]
    # $boolSuccess = Invoke-CommandSafely ([ref]$strOutput) {wmic os get caption}
    # # The above command returns $true, and the output of the command is stored in
    # # $strOutput
    #
    # Version: 1.0.20241003.0
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

    #region FunctionsToSupportErrorHandling ########################################
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
    #endregion FunctionsToSupportErrorHandling ########################################

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

    $output = & ($args[1])

    # Restore the former error preference
    $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

    # Retrieve the newest error on the error stack
    $refNewestCurrentError = Get-ReferenceToLastError

    if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
        # Error occurred

        # Return failure indicator:
        return $false
    } else {
        # No error occurred

        # Return data by reference:
        $refOutput.Value = $output

        # Return success indicator:
        return $true
    }
}
#endregion Part 4: Load Helper Functions ##############################################

#region Part 5: What OS Is This, Anyway? ###########################################
$hashtableOSInfo = @{}

# Create a second "bridge" hashtable
$hashtableBridgeOSInfo = @{}

# Adopted from: https://unix.stackexchange.com/a/6348/409368
# This needs to be tested more-exhaustively on the minimum OS versions that PowerShell 6.0 (original release) supported
if (Test-Path variable:\isLinux) {
    if ($isLinux) {
        if (Test-Path (Join-Path '/etc' 'os-release')) {
            # /etc/os-release exists
            $textFileOSRelease = Get-Content (Join-Path '/etc' 'os-release')
            $textFileOSRelease | ForEach-Object {
                $arrLine = Split-StringOnLiteralString $_ '='
                if ($arrLine.Count -eq 2) {
                    # Found key-value pair
                    $strKey = $arrLine[0]
                    if ($hashtableOSInfo.ContainsKey($strKey) -eq $false) {
                        $intValueLength = ($arrLine[1]).Length
                        if ($intValueLength -ge 2) {
                            if ((($arrLine[1])[0] -eq '"') -and (($arrLine[1])[$intValueLength - 1] -eq '"')) {
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
            $strKey = 'VERSION'
            $strValue = [string]
            $boolSuccess = Invoke-CommandSafely ([ref]$strValue) { lsb_release --version --short *>&1 }
            if ($boolSuccess -eq $false) {
                $strValue = $null
            }
            $hashtableOSInfo.Add($strKey, $strValue)

            $strKey = 'NAME' # This appears to be the best match; could also be 'ID'
            $strValue = [string]
            $boolSuccess = Invoke-CommandSafely ([ref]$strValue) { lsb_release --id --short *>&1 }
            if ($boolSuccess -eq $false) {
                $strValue = $null
            }
            $hashtableOSInfo.Add($strKey, $strValue)

            $strKey = 'PRETTY_NAME'
            $strValue = [string]
            $boolSuccess = Invoke-CommandSafely ([ref]$strValue) { lsb_release --description --short *>&1 }
            if ($boolSuccess -eq $false) {
                $strValue = $null
            }
            $hashtableOSInfo.Add($strKey, $strValue)

            $strKey = 'VERSION_ID'
            $strValue = [string]
            $boolSuccess = Invoke-CommandSafely ([ref]$strValue) { lsb_release --release --short *>&1 }
            if ($boolSuccess -eq $false) {
                $strValue = $null
            }
            $hashtableOSInfo.Add($strKey, $strValue)

            $strKey = 'VERSION_CODENAME'
            $strValue = [string]
            $boolSuccess = Invoke-CommandSafely ([ref]$strValue) { lsb_release --codename --short *>&1 }
            if ($boolSuccess -eq $false) {
                $strValue = $null
            }
            $hashtableOSInfo.Add($strKey, $strValue)
        } elseif (Test-Path (Join-Path '/etc' 'lsb-release')) {
            # /etc/lsb-release exists
            $textFileOSRelease = Get-Content (Join-Path '/etc' 'lsb-release')
            $textFileOSRelease |
                ForEach-Object {
                    $arrLine = Split-StringOnLiteralString $_ '='
                    if ($arrLine.Count -eq 2) {
                        # Found key-value pair
                        $strKey = $arrLine[0]
                        if ($hashtableBridgeOSInfo.ContainsKey($strKey) -eq $false) {
                            $intValueLength = ($arrLine[1]).Length
                            if ($intValueLength -ge 2) {
                                if ((($arrLine[1])[0] -eq '"') -and (($arrLine[1])[$intValueLength - 1] -eq '"')) {
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

            $strBridgeKey = 'DISTRIB_VERSION'
            $strKey = 'VERSION'
            $strValue = $null
            if ($hashtableBridgeOSInfo.ContainsKey($strBridgeKey)) {
                $strValue = $hashtableBridgeOSInfo.Item($strBridgeKey)
            }
            $hashtableOSInfo.Add($strKey, $strValue)

            $strBridgeKey = 'DISTRIB_ID'
            $strKey = 'NAME' # This appears to be the best match; could also be 'ID'
            $strValue = $null
            if ($hashtableBridgeOSInfo.ContainsKey($strBridgeKey)) {
                $strValue = $hashtableBridgeOSInfo.Item($strBridgeKey)
            }
            $hashtableOSInfo.Add($strKey, $strValue)

            $strBridgeKey = 'DISTRIB_DESCRIPTION'
            $strKey = 'PRETTY_NAME'
            $strValue = $null
            if ($hashtableBridgeOSInfo.ContainsKey($strBridgeKey)) {
                $strValue = $hashtableBridgeOSInfo.Item($strBridgeKey)
            }
            $hashtableOSInfo.Add($strKey, $strValue)

            $strBridgeKey = 'DISTRIB_RELEASE'
            $strKey = 'VERSION_ID'
            $strValue = $null
            if ($hashtableBridgeOSInfo.ContainsKey($strBridgeKey)) {
                $strValue = $hashtableBridgeOSInfo.Item($strBridgeKey)
            }
            $hashtableOSInfo.Add($strKey, $strValue)

            $strBridgeKey = 'DISTRIB_CODENAME'
            $strKey = 'VERSION_CODENAME'
            $strValue = $null
            if ($hashtableBridgeOSInfo.ContainsKey($strBridgeKey)) {
                $strValue = $hashtableBridgeOSInfo.Item($strBridgeKey)
            }
            $hashtableOSInfo.Add($strKey, $strValue)
        } elseif (Test-Path (Join-Path '/etc' 'debian_version')) {
            $textFileDebianVersion = Get-Content (Join-Path '/etc' 'debian_version')
            $strKey = 'VERSION'
            $strValue = $textFileDebianVersion[0]
            $hashtableOSInfo.Add($strKey, $strValue)

            $strKey = 'ID_LIKE'
            $strValue = 'debian'
            $hashtableOSInfo.Add($strKey, $strValue)
        } elseif (Test-Path (Join-Path '/etc' 'SuSe-release')) {
            $textFileOpenSUSEVersion = Get-Content (Join-Path '/etc' 'SuSe-release')
            $strKey = 'PRETTY_NAME'
            $strValue = $textFileOpenSUSEVersion[0]
            $hashtableOSInfo.Add($strKey, $strValue)

            $strKey = 'ID_LIKE'
            $strValue = 'suse'
            $hashtableOSInfo.Add($strKey, $strValue)

            for ($intLineNumber = 1; $intLineNumber -lt $textFileOpenSUSEVersion.Count; $intLineNumber++) {
                $strLine = $textFileOpenSUSEVersion[$intLineNumber]
                $arrLine = Split-StringOnLiteralString $strLine ' = '
                if ($arrLine.Count -ne 2) {
                    $arrLine = Split-StringOnLiteralString $strLine '='
                }
                if ($arrLine.Count -eq 2) {
                    $strKey = $arrLine[0]
                    if ($strKey -eq 'CODENAME') {
                        $strKey = 'VERSION_CODENAME'
                    }
                    $strValue = $arrLine[1]
                    $hashtableOSInfo.Add($strKey, $strValue)
                }
            }
        } elseif (Test-Path (Join-Path '/etc' 'redhat-release')) {
            $textFileRedHatVersion = Get-Content (Join-Path '/etc' 'redhat-release')
            $strKey = 'PRETTY_NAME'
            $strValue = $textFileRedHatVersion[0]
            $hashtableOSInfo.Add($strKey, $strValue)
        } else {
            $strKey = 'NAME'
            $strValue = [string]
            $boolSuccess = Invoke-CommandSafely ([ref]$strValue) { uname --operating-system *>&1 }
            if ($boolSuccess -eq $false) {
                $strValue = $null
            }
            $hashtableOSInfo.Add($strKey, $strValue)

            $strKey = 'VERSION_ID'
            $strValue = [string]
            $boolSuccess = Invoke-CommandSafely ([ref]$strValue) { uname --kernel-release *>&1 }
            if ($boolSuccess -eq $false) {
                $strValue = $null
            }
            $hashtableOSInfo.Add($strKey, $strValue)

            $strKey = 'VERSION'
            $strValue = [string]
            $boolSuccess = Invoke-CommandSafely ([ref]$strValue) { uname --kernel-version *>&1 }
            if ($boolSuccess -eq $false) {
                $strValue = $null
            }
            $hashtableOSInfo.Add($strKey, $strValue)
        }
    }
}

# Display OS Findings:
$hashtableOSInfo
#endregion Part 5: What OS Is This, Anyway? ###########################################
