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
            if ((Test-Path $strDownloads) -eq $false) {
                Write-Error 'Get-DownloadFolder was unable to create downloads folder. Returning $null'
                $null
            } else {
                return $strDownloads
            }
        } else {
            return $strDownloads
        }
    } else {
        Write-Error 'Get-DownloadFolder was unable to locate suitable folder path for downloads. Returning $null'
        $null
    }
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

#region Download SysInternals Streams ##############################################
$strDownloadURL = 'https://download.sysinternals.com/files/Streams.zip'
$strDownloadFile = 'Streams.zip'
$strDownloadFolder = Get-DownloadFolder

if ([string]::IsNullOrEmpty($strDownloadFolder)) {
    Write-Error 'Get-DownloadFolder returned $null. Exiting script.'
    exit
}

Set-Location $strDownloadFolder

$strDownloadPath = Join-Path $strDownloadFolder $strDownloadFile
$actionPreferenceFormerProgressPreference = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $strDownloadURL -OutFile $strDownloadPath
$ProgressPreference = $actionPreferenceFormerProgressPreference
#endregion Download SysInternals Streams ##############################################

#region Extract Streams.zip ########################################################
$strSubfolder = 'Streams'
$strSubfolderPath = Join-Path $strDownloadFolder $strSubfolder
if (Test-Path $strSubfolderPath) {
    Remove-Item -Path $strSubfolderPath -Recurse -Force
}
# Create the folder
New-Item -Path $strSubfolderPath -ItemType Directory | Out-Null

Expand-Archive -Path $strDownloadPath -DestinationPath $strSubfolderPath
#endregion Extract Streams.zip ########################################################

Set-Location $strSubfolderPath
& '.\Streams.exe' -d -s -q
