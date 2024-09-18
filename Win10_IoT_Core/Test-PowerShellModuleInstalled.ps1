[cmdletbinding()]

param (
    [Parameter(Mandatory = $false)][switch]$DoNotCheckForModuleUpdates
)

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

function Get-PowerShellModuleUsingHashtable {
    <#
    .SYNOPSIS
    Gets a list of installed PowerShell modules for each entry in a hashtable.

    .DESCRIPTION
    The Get-PowerShellModuleUsingHashtable function steps through each entry in the
    supplied hashtable and gets a list of installed PowerShell modules for each entry.

    .PARAMETER ReferenceToHashtable
    Is a reference to a hashtable. The value of the reference should be a hashtable
    with keys that are the names of PowerShell modules and values that are initialized
    to be enpty arrays.

    .EXAMPLE
    $hashtableModuleNameToInstalledModules = @{}
    $hashtableModuleNameToInstalledModules.Add('PnP.PowerShell', @())
    $hashtableModuleNameToInstalledModules.Add('Microsoft.Graph.Authentication', @())
    $hashtableModuleNameToInstalledModules.Add('Microsoft.Graph.Groups', @())
    $hashtableModuleNameToInstalledModules.Add('Microsoft.Graph.Users', @())
    $refHashtableModuleNameToInstalledModules = [ref]$hashtableModuleNameToInstalledModules
    Get-PowerShellModuleUsingHashtable -ReferenceToHashtable $refHashtableModuleNameToInstalledModules

    This example gets the list of installed PowerShell modules for each of the four
    modules listed in the hashtable. The list of each respective module is stored in
    the value of the hashtable entry for that module.

    .OUTPUTS
    None
    #>

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

    #region DownloadLocationNotice  ################################################
    # The most up-to-date version of this script can be found on the author's GitHub
    # repository at https://github.com/franklesniak/PowerShell_Resources
    #endregion DownloadLocationNotice  ################################################

    # Version 1.0.20240401.0

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][ref]$ReferenceToHashtable
    )

    $VerbosePreferenceAtStartOfFunction = $VerbosePreference

    $arrModulesToGet = @(($ReferenceToHashtable.Value).Keys)

    for ($intCounter = 0; $intCounter -lt $arrModulesToGet.Count; $intCounter++) {
        Write-Verbose ('Checking for ' + $arrModulesToGet[$intCounter] + ' module...')
        $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
        ($ReferenceToHashtable.Value).Item($arrModulesToGet[$intCounter]) = @(Get-Module -Name ($arrModulesToGet[$intCounter]) -ListAvailable)
        $VerbosePreference = $VerbosePreferenceAtStartOfFunction
    }
}

function Test-PowerShellModuleInstalledUsingHashtable {
    <#
    .SYNOPSIS
    Tests to see if a PowerShell module is installed based on entries in a hashtable.
    If the PowerShell module is not installed, an error or warning message may
    optionally be displayed.

    .DESCRIPTION
    The Test-PowerShellModuleInstalledUsingHashtable function steps through each entry
    in the supplied hashtable and, if there are any modules not installed, it
    optionally throws an error or warning for each module that is not installed. If all
    modules are installed, the function returns $true; otherwise, if any module is not
    installed, the function returns $false.

    .PARAMETER ReferenceToHashtableOfInstalledModules
    Is a reference to a hashtable. The hashtable must have keys that are the names of
    PowerShell modules with each key's value populated with arrays of
    ModuleInfoGrouping objects (the result of Get-Module).

    .PARAMETER ThrowErrorIfModuleNotInstalled
    Is a switch parameter. If this parameter is specified, an error is thrown for each
    module that is not installed. If this parameter is not specified, no error is
    thrown.

    .PARAMETER ThrowWarningIfModuleNotInstalled
    Is a switch parameter. If this parameter is specified, a warning is thrown for each
    module that is not installed. If this parameter is not specified, or if the
    ThrowErrorIfModuleNotInstalled parameter was specified, no warning is thrown.

    .PARAMETER ReferenceToHashtableOfCustomNotInstalledMessages
    Is a reference to a hashtable. The hashtable must have keys that are custom error
    or warning messages (string) to be displayed if one or more modules are not
    installed. The value for each key must be an array of PowerShell module names
    (strings) relevant to that error or warning message.

    If this parameter is not supplied, or if a custom error or warning message is not
    supplied in the hashtable for a given module, the script will default to using the
    following message:

    <MODULENAME> module not found. Please install it and then try again.
    You can install the <MODULENAME> PowerShell module from the PowerShell Gallery by
    running the following command:
    Install-Module <MODULENAME>;

    If the installation command fails, you may need to upgrade the version of
    PowerShellGet. To do so, run the following commands, then restart PowerShell:
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force;
    Install-Module PowerShellGet -MinimumVersion 2.2.4 -SkipPublisherCheck -Force -AllowClobber;

    .PARAMETER ReferenceToArrayOfMissingModules
    Is a reference to an array. The array must be initialized to be empty. If any
    modules are not installed, the names of those modules are added to the array.

    .EXAMPLE
    $hashtableModuleNameToInstalledModules = @{}
    $hashtableModuleNameToInstalledModules.Add('PnP.PowerShell', @())
    $hashtableModuleNameToInstalledModules.Add('Microsoft.Graph.Authentication', @())
    $hashtableModuleNameToInstalledModules.Add('Microsoft.Graph.Groups', @())
    $hashtableModuleNameToInstalledModules.Add('Microsoft.Graph.Users', @())
    $refHashtableModuleNameToInstalledModules = [ref]$hashtableModuleNameToInstalledModules
    Get-PowerShellModuleUsingHashtable -ReferenceToHashtable $refHashtableModuleNameToInstalledModules
    $hashtableCustomNotInstalledMessageToModuleNames = @{}
    $strGraphNotInstalledMessage = 'Microsoft.Graph.Authentication, Microsoft.Graph.Groups, and/or Microsoft.Graph.Users modules were not found. Please install the full Microsoft.Graph module and then try again.' + [System.Environment]::NewLine + 'You can install the Microsoft.Graph PowerShell module from the PowerShell Gallery by running the following command:' + [System.Environment]::NewLine + 'Install-Module Microsoft.Graph;' + [System.Environment]::NewLine + [System.Environment]::NewLine + 'If the installation command fails, you may need to upgrade the version of PowerShellGet. To do so, run the following commands, then restart PowerShell:' + [System.Environment]::NewLine + 'Set-ExecutionPolicy Bypass -Scope Process -Force;' + [System.Environment]::NewLine + '[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;' + [System.Environment]::NewLine + 'Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force;' + [System.Environment]::NewLine + 'Install-Module PowerShellGet -MinimumVersion 2.2.4 -SkipPublisherCheck -Force -AllowClobber;' + [System.Environment]::NewLine + [System.Environment]::NewLine
    $hashtableCustomNotInstalledMessageToModuleNames.Add($strGraphNotInstalledMessage, @('Microsoft.Graph.Authentication', 'Microsoft.Graph.Groups', 'Microsoft.Graph.Users'))
    $refhashtableCustomNotInstalledMessageToModuleNames = [ref]$hashtableCustomNotInstalledMessageToModuleNames
    $boolResult = Test-PowerShellModuleInstalledUsingHashtable -ReferenceToHashtableOfInstalledModules $refHashtableModuleNameToInstalledModules -ThrowErrorIfModuleNotInstalled -ReferenceToHashtableOfCustomNotInstalledMessages $refhashtableCustomNotInstalledMessageToModuleNames

    This example checks to see if the PnP.PowerShell, Microsoft.Graph.Authentication,
    Microsoft.Graph.Groups, and Microsoft.Graph.Users modules are installed. If any of
    these modules are not installed, an error is thrown for the PnP.PowerShell module
    or the group of Microsoft.Graph modules, respectively, and $boolResult is set to
    $false. If all modules are installed, $boolResult is set to $true.

    .OUTPUTS
    [boolean] - Returns $true if all modules are installed; otherwise, returns $false.
    #>

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

    #region DownloadLocationNotice  ################################################
    # The most up-to-date version of this script can be found on the author's GitHub
    # repository at https://github.com/franklesniak/PowerShell_Resources
    #endregion DownloadLocationNotice  ################################################

    # Version 1.1.20240401.0

    [CmdletBinding()]
    [OutputType([Boolean])]
    param (
        [Parameter(Mandatory = $true)][ref]$ReferenceToHashtableOfInstalledModules,
        [switch]$ThrowErrorIfModuleNotInstalled,
        [switch]$ThrowWarningIfModuleNotInstalled,
        [Parameter(Mandatory = $false)][ref]$ReferenceToHashtableOfCustomNotInstalledMessages,
        [Parameter(Mandatory = $false)][ref]$ReferenceToArrayOfMissingModules
    )

    $boolThrowErrorForMissingModule = $false
    $boolThrowWarningForMissingModule = $false

    if ($ThrowErrorIfModuleNotInstalled.IsPresent -eq $true) {
        $boolThrowErrorForMissingModule = $true
    } elseif ($ThrowWarningIfModuleNotInstalled.IsPresent -eq $true) {
        $boolThrowWarningForMissingModule = $true
    }

    $boolResult = $true

    $hashtableMessagesToThrowForMissingModule = @{}
    $hashtableModuleNameToCustomMessageToThrowForMissingModule = @{}
    if ($null -ne $ReferenceToHashtableOfCustomNotInstalledMessages) {
        $arrMessages = @(($ReferenceToHashtableOfCustomNotInstalledMessages.Value).Keys)
        foreach ($strMessage in $arrMessages) {
            $hashtableMessagesToThrowForMissingModule.Add($strMessage, $false)

            ($ReferenceToHashtableOfCustomNotInstalledMessages.Value).Item($strMessage) | ForEach-Object {
                $hashtableModuleNameToCustomMessageToThrowForMissingModule.Add($_, $strMessage)
            }
        }
    }

    $arrModuleNames = @(($ReferenceToHashtableOfInstalledModules.Value).Keys)
    foreach ($strModuleName in $arrModuleNames) {
        $arrInstalledModules = @(($ReferenceToHashtableOfInstalledModules.Value).Item($strModuleName))
        if ($arrInstalledModules.Count -eq 0) {
            $boolResult = $false

            if ($hashtableModuleNameToCustomMessageToThrowForMissingModule.ContainsKey($strModuleName) -eq $true) {
                $strMessage = $hashtableModuleNameToCustomMessageToThrowForMissingModule.Item($strModuleName)
                $hashtableMessagesToThrowForMissingModule.Item($strMessage) = $true
            } else {
                $strMessage = $strModuleName + ' module not found. Please install it and then try again.' + [System.Environment]::NewLine + 'You can install the ' + $strModuleName + ' PowerShell module from the PowerShell Gallery by running the following command:' + [System.Environment]::NewLine + 'Install-Module ' + $strModuleName + ';' + [System.Environment]::NewLine + [System.Environment]::NewLine + 'If the installation command fails, you may need to upgrade the version of PowerShellGet. To do so, run the following commands, then restart PowerShell:' + [System.Environment]::NewLine + 'Set-ExecutionPolicy Bypass -Scope Process -Force;' + [System.Environment]::NewLine + '[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;' + [System.Environment]::NewLine + 'Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force;' + [System.Environment]::NewLine + 'Install-Module PowerShellGet -MinimumVersion 2.2.4 -SkipPublisherCheck -Force -AllowClobber;' + [System.Environment]::NewLine + [System.Environment]::NewLine
                $hashtableMessagesToThrowForMissingModule.Add($strMessage, $true)
            }

            if ($null -ne $ReferenceToArrayOfMissingModules) {
                ($ReferenceToArrayOfMissingModules.Value) += $strModuleName
            }
        }
    }

    if ($boolThrowErrorForMissingModule -eq $true) {
        $arrMessages = @($hashtableMessagesToThrowForMissingModule.Keys)
        foreach ($strMessage in $arrMessages) {
            if ($hashtableMessagesToThrowForMissingModule.Item($strMessage) -eq $true) {
                Write-Error $strMessage
            }
        }
    } elseif ($boolThrowWarningForMissingModule -eq $true) {
        $arrMessages = @($hashtableMessagesToThrowForMissingModule.Keys)
        foreach ($strMessage in $arrMessages) {
            if ($hashtableMessagesToThrowForMissingModule.Item($strMessage) -eq $true) {
                Write-Warning $strMessage
            }
        }
    }

    return $boolResult
}

function Test-PowerShellModuleUpdatesAvailableUsingHashtable {
    <#
    .SYNOPSIS
    Tests to see if updates are available for a PowerShell module based on entries in a
    hashtable. If updates are available for a PowerShell module, an error or warning
    message may optionally be displayed.

    .DESCRIPTION
    The Test-PowerShellModuleUpdatesAvailableUsingHashtable function steps through each
    entry in the supplied hashtable and, if there are updates available, it optionally
    throws an error or warning for each module that has updates available. If all
    modules are installed and up to date, the function returns $true; otherwise, if any
    module is not installed or not up to date, the function returns $false.

    .PARAMETER ReferenceToHashtableOfInstalledModules
    Is a reference to a hashtable. The hashtable must have keys that are the names of
    PowerShell modules with each key's value populated with arrays of
    ModuleInfoGrouping objects (the result of Get-Module).

    .PARAMETER ThrowErrorIfModuleNotInstalled
    Is a switch parameter. If this parameter is specified, an error is thrown for each
    module that is not installed. If this parameter is not specified, no error is
    thrown.

    .PARAMETER ThrowWarningIfModuleNotInstalled
    Is a switch parameter. If this parameter is specified, a warning is thrown for each
    module that is not installed. If this parameter is not specified, or if the
    ThrowErrorIfModuleNotInstalled parameter was specified, no warning is thrown.

    .PARAMETER ThrowErrorIfModuleNotUpToDate
    Is a switch parameter. If this parameter is specified, an error is thrown for each
    module that is not up to date. If this parameter is not specified, no error is
    thrown.

    .PARAMETER ThrowWarningIfModuleNotUpToDate
    Is a switch parameter. If this parameter is specified, a warning is thrown for each
    module that is not up to date. If this parameter is not specified, or if the
    ThrowErrorIfModuleNotUpToDate parameter was specified, no warning is thrown.

    .PARAMETER ReferenceToHashtableOfCustomNotInstalledMessages
    Is a reference to a hashtable. The hashtable must have keys that are custom error
    or warning messages (string) to be displayed if one or more modules are not
    installed. The value for each key must be an array of PowerShell module names
    (strings) relevant to that error or warning message.

    If this parameter is not supplied, or if a custom error or warning message is not
    supplied in the hashtable for a given module, the script will default to using the
    following message:

    <MODULENAME> module not found. Please install it and then try again.
    You can install the <MODULENAME> PowerShell module from the PowerShell Gallery by
    running the following command:
    Install-Module <MODULENAME>;

    If the installation command fails, you may need to upgrade the version of
    PowerShellGet. To do so, run the following commands, then restart PowerShell:
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force;
    Install-Module PowerShellGet -MinimumVersion 2.2.4 -SkipPublisherCheck -Force -AllowClobber;

    .PARAMETER ReferenceToHashtableOfCustomNotUpToDateMessages
    Is a reference to a hashtable. The hashtable must have keys that are custom error
    or warning messages (string) to be displayed if one or more modules are not
    up to date. The value for each key must be an array of PowerShell module names
    (strings) relevant to that error or warning message.

    If this parameter is not supplied, or if a custom error or warning message is not
    supplied in the hashtable for a given module, the script will default to using the
    following message:

    A newer version of the <MODULENAME> PowerShell module is available. Please consider
    updating it by running the following command:
    Install-Module <MODULENAME> -Force;

    If the installation command fails, you may need to upgrade the version of
    PowerShellGet. To do so, run the following commands, then restart PowerShell:
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force;
    Install-Module PowerShellGet -MinimumVersion 2.2.4 -SkipPublisherCheck -Force -AllowClobber;

    .PARAMETER ReferenceToArrayOfMissingModules
    Is a reference to an array. The array must be initialized to be empty. If any
    modules are not installed, the names of those modules are added to the array.

    .PARAMETER ReferenceToArrayOfOutOfDateModules
    Is a reference to an array. The array must be initialized to be empty. If any
    modules are not up to date, the names of those modules are added to the array.

    .EXAMPLE
    $hashtableModuleNameToInstalledModules = @{}
    $hashtableModuleNameToInstalledModules.Add('PnP.PowerShell', @())
    $hashtableModuleNameToInstalledModules.Add('Microsoft.Graph.Authentication', @())
    $hashtableModuleNameToInstalledModules.Add('Microsoft.Graph.Groups', @())
    $hashtableModuleNameToInstalledModules.Add('Microsoft.Graph.Users', @())
    $refHashtableModuleNameToInstalledModules = [ref]$hashtableModuleNameToInstalledModules
    Get-PowerShellModuleUsingHashtable -ReferenceToHashtable $refHashtableModuleNameToInstalledModules
    $hashtableCustomNotInstalledMessageToModuleNames = @{}
    $strGraphNotInstalledMessage = 'Microsoft.Graph.Authentication, Microsoft.Graph.Groups, and/or Microsoft.Graph.Users modules were not found. Please install the full Microsoft.Graph module and then try again.' + [System.Environment]::NewLine + 'You can install the Microsoft.Graph PowerShell module from the PowerShell Gallery by running the following command:' + [System.Environment]::NewLine + 'Install-Module Microsoft.Graph;' + [System.Environment]::NewLine + [System.Environment]::NewLine + 'If the installation command fails, you may need to upgrade the version of PowerShellGet. To do so, run the following commands, then restart PowerShell:' + [System.Environment]::NewLine + 'Set-ExecutionPolicy Bypass -Scope Process -Force;' + [System.Environment]::NewLine + '[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;' + [System.Environment]::NewLine + 'Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force;' + [System.Environment]::NewLine + 'Install-Module PowerShellGet -MinimumVersion 2.2.4 -SkipPublisherCheck -Force -AllowClobber;' + [System.Environment]::NewLine + [System.Environment]::NewLine
    $hashtableCustomNotInstalledMessageToModuleNames.Add($strGraphNotInstalledMessage, @('Microsoft.Graph.Authentication', 'Microsoft.Graph.Groups', 'Microsoft.Graph.Users'))
    $refhashtableCustomNotInstalledMessageToModuleNames = [ref]$hashtableCustomNotInstalledMessageToModuleNames
    $hashtableCustomNotUpToDateMessageToModuleNames = @{}
    $strGraphNotUpToDateMessage = 'A newer version of the Microsoft.Graph.Authentication, Microsoft.Graph.Groups, and/or Microsoft.Graph.Users modules was found. Please consider updating it by running the following command:' + [System.Environment]::NewLine + 'Install-Module Microsoft.Graph -Force;' + [System.Environment]::NewLine + [System.Environment]::NewLine + 'If the installation command fails, you may need to upgrade the version of PowerShellGet. To do so, run the following commands, then restart PowerShell:' + [System.Environment]::NewLine + 'Set-ExecutionPolicy Bypass -Scope Process -Force;' + [System.Environment]::NewLine + '[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;' + [System.Environment]::NewLine + 'Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force;' + [System.Environment]::NewLine + 'Install-Module PowerShellGet -MinimumVersion 2.2.4 -SkipPublisherCheck -Force -AllowClobber;' + [System.Environment]::NewLine + [System.Environment]::NewLine
    $hashtableCustomNotUpToDateMessageToModuleNames.Add($strGraphNotUpToDateMessage, @('Microsoft.Graph.Authentication', 'Microsoft.Graph.Groups', 'Microsoft.Graph.Users'))
    $refhashtableCustomNotUpToDateMessageToModuleNames = [ref]$hashtableCustomNotUpToDateMessageToModuleNames
    $boolResult = Test-PowerShellModuleUpdatesAvailableUsingHashtable -ReferenceToHashtableOfInstalledModules $refHashtableModuleNameToInstalledModules -ThrowErrorIfModuleNotInstalled -ThrowWarningIfModuleNotUpToDate -ReferenceToHashtableOfCustomNotInstalledMessages $refhashtableCustomNotInstalledMessageToModuleNames -ReferenceToHashtableOfCustomNotUpToDateMessages $refhashtableCustomNotUpToDateMessageToModuleNames

    This example checks to see if the PnP.PowerShell, Microsoft.Graph.Authentication,
    Microsoft.Graph.Groups, and Microsoft.Graph.Users modules are installed. If any of
    these modules are not installed, an error is thrown for the PnP.PowerShell module
    or the group of Microsoft.Graph modules, respectively, and $boolResult is set to
    $false. If any of these modules are installed but not up to date, a warning
    message is thrown for the PnP.PowerShell module or the group of Microsoft.Graph
    modules, respectively, and $boolResult is set to false. If all modules are
    installed and up to date, $boolResult is set to $true.

    .OUTPUTS
    [boolean] - Returns $true if all modules are installed and up to date; otherwise,
    returns $false.

    .NOTES
    Requires PowerShell v5.0 or newer
    #>

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

    #region DownloadLocationNotice  ################################################
    # The most up-to-date version of this script can be found on the author's GitHub
    # repository at https://github.com/franklesniak/PowerShell_Resources
    #endregion DownloadLocationNotice  ################################################

    # Version 1.1.20240401.0

    [CmdletBinding()]
    [OutputType([Boolean])]
    param (
        [Parameter(Mandatory = $true)][ref]$ReferenceToHashtableOfInstalledModules,
        [switch]$ThrowErrorIfModuleNotInstalled,
        [switch]$ThrowWarningIfModuleNotInstalled,
        [switch]$ThrowErrorIfModuleNotUpToDate,
        [switch]$ThrowWarningIfModuleNotUpToDate,
        [Parameter(Mandatory = $false)][ref]$ReferenceToHashtableOfCustomNotInstalledMessages,
        [Parameter(Mandatory = $false)][ref]$ReferenceToHashtableOfCustomNotUpToDateMessages,
        [Parameter(Mandatory = $false)][ref]$ReferenceToArrayOfMissingModules,
        [Parameter(Mandatory = $false)][ref]$ReferenceToArrayOfOutdatedModules
    )

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

        $versionThisFunction = [version]('1.0.20240326.0')

        if (Test-Path variable:\PSVersionTable) {
            return ($PSVersionTable.PSVersion)
        } else {
            return ([version]('1.0'))
        }
    }

    $versionPS = Get-PSVersion
    if ($versionPS -lt ([version]'5.0')) {
        Write-Warning 'Test-PowerShellModuleUpdatesAvailableUsingHashtable requires PowerShell version 5.0 or newer.'
        return $false
    }

    $boolThrowErrorForMissingModule = $false
    $boolThrowWarningForMissingModule = $false

    if ($ThrowErrorIfModuleNotInstalled.IsPresent -eq $true) {
        $boolThrowErrorForMissingModule = $true
    } elseif ($ThrowWarningIfModuleNotInstalled.IsPresent -eq $true) {
        $boolThrowWarningForMissingModule = $true
    }

    $boolThrowErrorForOutdatedModule = $false
    $boolThrowWarningForOutdatedModule = $false

    if ($ThrowErrorIfModuleNotUpToDate.IsPresent -eq $true) {
        $boolThrowErrorForOutdatedModule = $true
    } elseif ($ThrowWarningIfModuleNotUpToDate.IsPresent -eq $true) {
        $boolThrowWarningForOutdatedModule = $true
    }

    $VerbosePreferenceAtStartOfFunction = $VerbosePreference

    $boolResult = $true

    $hashtableMessagesToThrowForMissingModule = @{}
    $hashtableModuleNameToCustomMessageToThrowForMissingModule = @{}
    if ($null -ne $ReferenceToHashtableOfCustomNotInstalledMessages) {
        $arrMessages = @(($ReferenceToHashtableOfCustomNotInstalledMessages.Value).Keys)
        foreach ($strMessage in $arrMessages) {
            $hashtableMessagesToThrowForMissingModule.Add($strMessage, $false)

            ($ReferenceToHashtableOfCustomNotInstalledMessages.Value).Item($strMessage) | ForEach-Object {
                $hashtableModuleNameToCustomMessageToThrowForMissingModule.Add($_, $strMessage)
            }
        }
    }

    $hashtableMessagesToThrowForOutdatedModule = @{}
    $hashtableModuleNameToCustomMessageToThrowForOutdatedModule = @{}
    if ($null -ne $ReferenceToHashtableOfCustomNotUpToDateMessages) {
        $arrMessages = @(($ReferenceToHashtableOfCustomNotUpToDateMessages.Value).Keys)
        foreach ($strMessage in $arrMessages) {
            $hashtableMessagesToThrowForOutdatedModule.Add($strMessage, $false)

            ($ReferenceToHashtableOfCustomNotUpToDateMessages.Value).Item($strMessage) | ForEach-Object {
                $hashtableModuleNameToCustomMessageToThrowForOutdatedModule.Add($_, $strMessage)
            }
        }
    }

    $arrModuleNames = @(($ReferenceToHashtableOfInstalledModules.Value).Keys)
    foreach ($strModuleName in $arrModuleNames) {
        $arrInstalledModules = @(($ReferenceToHashtableOfInstalledModules.Value).Item($strModuleName))
        if ($arrInstalledModules.Count -eq 0) {
            $boolResult = $false

            if ($hashtableModuleNameToCustomMessageToThrowForMissingModule.ContainsKey($strModuleName) -eq $true) {
                $strMessage = $hashtableModuleNameToCustomMessageToThrowForMissingModule.Item($strModuleName)
                $hashtableMessagesToThrowForMissingModule.Item($strMessage) = $true
            } else {
                $strMessage = $strModuleName + ' module not found. Please install it and then try again.' + [System.Environment]::NewLine + 'You can install the ' + $strModuleName + ' PowerShell module from the PowerShell Gallery by running the following command:' + [System.Environment]::NewLine + 'Install-Module ' + $strModuleName + ';' + [System.Environment]::NewLine + [System.Environment]::NewLine + 'If the installation command fails, you may need to upgrade the version of PowerShellGet. To do so, run the following commands, then restart PowerShell:' + [System.Environment]::NewLine + 'Set-ExecutionPolicy Bypass -Scope Process -Force;' + [System.Environment]::NewLine + '[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;' + [System.Environment]::NewLine + 'Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force;' + [System.Environment]::NewLine + 'Install-Module PowerShellGet -MinimumVersion 2.2.4 -SkipPublisherCheck -Force -AllowClobber;' + [System.Environment]::NewLine + [System.Environment]::NewLine
                $hashtableMessagesToThrowForMissingModule.Add($strMessage, $true)
            }

            if ($null -ne $ReferenceToArrayOfMissingModules) {
                ($ReferenceToArrayOfMissingModules.Value) += $strModuleName
            }
        } else {
            $versionNewestInstalledModule = ($arrInstalledModules | ForEach-Object { [version]($_.Version) } | Sort-Object)[-1]

            $arrModuleNewestInstalledModule = @($arrInstalledModules | Where-Object { ([version]($_.Version)) -eq $versionNewestInstalledModule })

            # In the event there are multiple installations of the same version, reduce to a
            # single instance of the module
            if ($arrModuleNewestInstalledModule.Count -gt 1) {
                $moduleNewestInstalled = @($arrModuleNewestInstalledModule | Select-Object -Unique)[0]
            } else {
                $moduleNewestInstalled = $arrModuleNewestInstalledModule[0]
            }

            $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
            $moduleNewestAvailable = Find-Module -Name $strModuleName -ErrorAction SilentlyContinue
            $VerbosePreference = $VerbosePreferenceAtStartOfFunction

            if ($null -ne $moduleNewestAvailable) {
                if ($moduleNewestAvailable.Version -gt $moduleNewestInstalled.Version) {
                    # A newer version is available
                    $boolResult = $false

                    if ($hashtableModuleNameToCustomMessageToThrowForOutdatedModule.ContainsKey($strModuleName) -eq $true) {
                        $strMessage = $hashtableModuleNameToCustomMessageToThrowForOutdatedModule.Item($strModuleName)
                        $hashtableMessagesToThrowForOutdatedModule.Item($strMessage) = $true
                    } else {
                        $strMessage = 'A newer version of the ' + $strModuleName + ' PowerShell module is available. Please consider updating it by running the following command:' + [System.Environment]::NewLine + 'Install-Module ' + $strModuleName + ' -Force;' + [System.Environment]::NewLine + [System.Environment]::NewLine + 'If the installation command fails, you may need to upgrade the version of PowerShellGet. To do so, run the following commands, then restart PowerShell:' + [System.Environment]::NewLine + 'Set-ExecutionPolicy Bypass -Scope Process -Force;' + [System.Environment]::NewLine + '[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;' + [System.Environment]::NewLine + 'Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force;' + [System.Environment]::NewLine + 'Install-Module PowerShellGet -MinimumVersion 2.2.4 -SkipPublisherCheck -Force -AllowClobber;' + [System.Environment]::NewLine + [System.Environment]::NewLine
                        $hashtableMessagesToThrowForOutdatedModule.Add($strMessage, $true)
                    }

                    if ($null -ne $ReferenceToArrayOfOutdatedModules) {
                        ($ReferenceToArrayOfOutdatedModules.Value) += $strModuleName
                    }
                }
            } else {
                # Couldn't find the module in the PowerShell Gallery
            }
        }
    }

    if ($boolThrowErrorForMissingModule -eq $true) {
        $arrMessages = @($hashtableMessagesToThrowForMissingModule.Keys)
        foreach ($strMessage in $arrMessages) {
            if ($hashtableMessagesToThrowForMissingModule.Item($strMessage) -eq $true) {
                Write-Error $strMessage
            }
        }
    } elseif ($boolThrowWarningForMissingModule -eq $true) {
        $arrMessages = @($hashtableMessagesToThrowForMissingModule.Keys)
        foreach ($strMessage in $arrMessages) {
            if ($hashtableMessagesToThrowForMissingModule.Item($strMessage) -eq $true) {
                Write-Warning $strMessage
            }
        }
    }

    if ($boolThrowErrorForOutdatedModule -eq $true) {
        $arrMessages = @($hashtableMessagesToThrowForOutdatedModule.Keys)
        foreach ($strMessage in $arrMessages) {
            if ($hashtableMessagesToThrowForOutdatedModule.Item($strMessage) -eq $true) {
                Write-Error $strMessage
            }
        }
    } elseif ($boolThrowWarningForOutdatedModule -eq $true) {
        $arrMessages = @($hashtableMessagesToThrowForOutdatedModule.Keys)
        foreach ($strMessage in $arrMessages) {
            if ($hashtableMessagesToThrowForOutdatedModule.Item($strMessage) -eq $true) {
                Write-Warning $strMessage
            }
        }
    }
    return $boolResult
}

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

$versionPS = Get-PSVersion

#region Quit if PowerShell Version is Unsupported ##################################
if ($versionPS -lt [version]'5.0') {
    Write-Warning 'This script requires PowerShell v5.0 or higher. Please upgrade to PowerShell v5.0 or higher and try again.'
    return # Quit script
}
#endregion Quit if PowerShell Version is Unsupported ##################################

#region Check for required PowerShell Modules ######################################
$hashtableModuleNameToInstalledModules = @{}
$hashtableModuleNameToInstalledModules.Add('PSCompression', @())
$refHashtableModuleNameToInstalledModules = [ref]$hashtableModuleNameToInstalledModules
Get-PowerShellModuleUsingHashtable -ReferenceToHashtable $refHashtableModuleNameToInstalledModules

$hashtableCustomNotInstalledMessageToModuleNames = @{}

$refhashtableCustomNotInstalledMessageToModuleNames = [ref]$hashtableCustomNotInstalledMessageToModuleNames
$boolResult = Test-PowerShellModuleInstalledUsingHashtable -ReferenceToHashtableOfInstalledModules $refHashtableModuleNameToInstalledModules -ThrowErrorIfModuleNotInstalled -ReferenceToHashtableOfCustomNotInstalledMessages $refhashtableCustomNotInstalledMessageToModuleNames

if ($boolResult -eq $false) {
    return # Quit script
}
#endregion Check for required PowerShell Modules ######################################

#region Check for PowerShell module updates ########################################
$boolDoNotCheckForModuleUpdates = $false
if ($null -ne $DoNotCheckForModuleUpdates) {
    if ($DoNotCheckForModuleUpdates.IsPresent -eq $true) {
        $boolDoNotCheckForModuleUpdates = $true
    }
}
if ($boolDoNotCheckForModuleUpdates -eq $false) {
    Write-Verbose 'Checking for module updates...'
    $hashtableCustomNotUpToDateMessageToModuleNames = @{}

    $refhashtableCustomNotUpToDateMessageToModuleNames = [ref]$hashtableCustomNotUpToDateMessageToModuleNames
    $boolResult = Test-PowerShellModuleUpdatesAvailableUsingHashtable -ReferenceToHashtableOfInstalledModules $refHashtableModuleNameToInstalledModules -ThrowErrorIfModuleNotInstalled -ThrowWarningIfModuleNotUpToDate -ReferenceToHashtableOfCustomNotInstalledMessages $refhashtableCustomNotInstalledMessageToModuleNames -ReferenceToHashtableOfCustomNotUpToDateMessages $refhashtableCustomNotUpToDateMessageToModuleNames
}
#endregion Check for PowerShell module updates ########################################

Write-Host 'PowerShell module is present and up-to-date!'
