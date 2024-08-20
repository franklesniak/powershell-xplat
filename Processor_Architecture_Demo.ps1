# PowerShell demonstration on different processor architectures
# Written by Frank Lesniak
# Last updated: 2021-04-11

# Note: PowerShell 7 on Raspbian (Raspberry Pi 4) did not process pasted-in
# code correctly when written in Allman style, so I had to abandon it :(

# Create a helper function used to check for presence of registry value
function Test-RegistryValue {
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

# Create helper function to test for the existence of a command
function Test-CommandExistence {
    # The first argument is a scriptblock containing the command to run
    #
    # The function returns $true if the command exists; $false otherwise
    #
    # Example usage:
    #
    # $boolCommandExists = Test-CommandExistence {dir} # returns $true
    # $boolCommandExists = Test-CommandExistence {FakeCommandMadeUp} # returns $false

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

    $output = & ($args[0])

    # Restore the former error preference
    $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

    # Retrieve the newest error on the error stack
    $refNewestCurrentError = Get-ReferenceToLastError

    if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
        $false
    } else {
        $true
    }
}

# Create helper function to run a command and store the output if successful
function Invoke-CommandSafely {
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

    $output = & ($args[1])

    # Restore the former error preference
    $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

    # Retrieve the newest error on the error stack
    $refNewestCurrentError = Get-ReferenceToLastError

    if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
        $false
    } else {
        ($args[0]).Value = $output
        $true
    }
}

$boolIsReallyWindows = $true
if (Test-Path variable:\isWindows) {
    if ($isWindows -eq $false) {
        $boolIsReallyWindows = $false
    }
}

if ($boolIsReallyWindows) {
    # TODO: see if Windows has an equivalent to uname -m
    # For now, set to $null because machine hardware name is not used in Windows administration
    $strSystemArchitecture = $null

    # TODO: see if Windows has an equivalent to uname -p
    # For now, set to $null because processor type is not immediately needed for Windows administration
    $strProcessorArchitecture = $null

    # Retrieve the OS Architecture
    $strRegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
    $strValueName = "PROCESSOR_ARCHITECTURE"
    if (Test-RegistryValue $strRegistryPath $strValueName) {
        $strOSArchitecture = (Get-ItemProperty -Path $strRegistryPath -Name $strValueName).$strValueName
    } else {
        Write-Error "PROCESSOR_ARCHITECTURE registry value missing!"
        $strOSArchitecture = $null
    }

    # Retrieve the architecture of this process
    if ($null -ne $env:PROCESSOR_ARCHITECTURE) {
        $strProcessArchitecture = $env:PROCESSOR_ARCHITECTURE
    } else {
        Write-Error "PROCESSOR_ARCHITECTURE environment variable is missing!"
        $strProcessArchitecture = $null
    }
} else {
    # Either Linux or macOS

    # Get machine hardware name (i.e., underlying system architecture)
    $strOutput = [string]
    $boolResult = Invoke-CommandSafely ([ref]$strOutput) { uname -m *>&1 }
    if ($boolResult -ne $true) {
        $strOutput = $null
    }
    $strSystemArchitecture = $strOutput

    # Get processor type
    $strOutput = [string]
    $boolResult = Invoke-CommandSafely ([ref]$strOutput) { uname -p *>&1 }
    if ($boolResult -ne $true) {
        $strOutput = $null
    }
    $strProcessorArchitecture = $strOutput

    # Get OS architecture
    $strOutput = [string]
    $boolResult = Invoke-CommandSafely ([ref]$strOutput) { uname -i *>&1 }
    if ($boolResult -ne $true) {
        $strOutput = $null
    }
    $strOSArchitecture = $strOutput

    # TO-DO: investigate Multiarch and see if it's possible to have an alternative PowerShell architecture in play
    $strProcessArchitecture = $null
}

# Show system architecture (machine hardware name):
$strSystemArchitecture

# Show processor type
$strProcessorArchitecture

# Show OS architecture
$strOSArchitecture

# Show process architecture
$strProcessArchitecture

# On Windows 10 ARM64, run the above in Windows PowerShell v5.1

# ...and then run in PowerShell 7. Any differences?

# Open the registry editor on Windows 10 (ARM64) and navigate to HKEY_LOCAL_MACHINE\SOFTWARE
# Note the registry key structure, and note the WOW6432Node and WOWAA32Node
# In Windows PowerShell 5.1 (remember the results above) run:
Get-ChildItem "HKLM:\SOFTWARE\"
# Compare to registry editor HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node
