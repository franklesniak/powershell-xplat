# PowerShell v7.0.0 demonstration on Windows 10 x64
# Written by Frank Lesniak
# Last updated: 2020-04-28

$strDownloadFolder = "C:\Users\flesniak\Downloads"
$strPowerShellVersion = "7.0.0"
$strPowerShellZIPFileNameToDownloadRoot = "PowerShell-" + $strPowerShellVersion + "-win-x64"
$strPowerShellZIPFileNameToDownload = $strPowerShellZIPFileNameToDownloadRoot + ".msi"
$strDownloadSourceRootPath = "https://github.com/PowerShell/PowerShell/releases/download/v7.0.0/" # Should end in forward slash

# Download PowerShell ZIP
Invoke-WebRequest -Uri ($strDownloadSourceRootPath + $strPowerShellZIPFileNameToDownload) -OutFile (Join-Path $strDownloadFolder $strPowerShellZIPFileNameToDownload)

# Install PowerShell
$strPathToMsiExec = Join-Path ($env:SystemRoot) "System32"
$strPathToMsiExec = Join-Path $strPathToMsiExec "msiexec.exe"

$arrArgumentList = @("/i", (Join-Path $strDownloadFolder $strPowerShellZIPFileNameToDownload), "/qb-!", "REBOOT=ReallySuppress")

Start-Process -FilePath $strPathToMsiExec -ArgumentList $arrArgumentList -Wait

# Install OpenSSH Features
$arrFeaturesToInstall = @(Get-WindowsCapability -Online | Where-Object {$_.Name -like "OpenSSH*"} | `
    Where-Object {$_.State -ne ([Microsoft.Dism.Commands.PackageFeatureState]::Installed)} | `
	ForEach-Object {$_.Name})
$arrFeaturesToInstall | ForEach-Object {Add-WindowsCapability -Online -Name $_}

# Start the SSH Server service
Start-Service sshd

# Configure the SSH Server service to automatically start
Set-Service -Name sshd -StartupType 'Automatic'

# Confirm the Firewall rule is configured. It should be created automatically by setup. 
Get-NetFirewallRule -Name *ssh*
# Review the rule to confirm that it is enabled

# Connect to the local host over SSH to confirm that the protocol is working, at least locally
ssh WMP\ad_flesniak@localhost

# Once connected, exit the "remote" SSH session
exit

$strProgramFilesEightDotThreeFileName = Get-CimInstance Win32_Directory -Filter 'Name="C:\\Program Files"' |
    Select-Object EightDotThreeFileName | ForEach-Object {$_.EightDotThreeFileName}

$strEightDotThreePathToPowerShell7 = Join-Path $strProgramFilesEightDotThreeFileName "PowerShell"
$strEightDotThreePathToPowerShell7 = Join-Path $strEightDotThreePathToPowerShell7 "7"
$strEightDotThreePathToPowerShell7 = Join-Path $strEightDotThreePathToPowerShell7 "pwsh.exe"

# Display the path so that it can be used in a later step
$strEightDotThreePathToPowerShell7

# Open the SSH server config file
notepad $env:ProgramData\ssh\sshd_config
# Make sure that the PasswordAuthentication line is uncommented and set to yes
# Add a Subsystem line (minus the hashtag comment symbol):
#Subsystem	powershell	c:/progra~1/powershell/7/pwsh.exe -sshs -NoLogo -NoProfile
# Except replace the c:/progra~1/powershell/7/pwsh.exe witht he output listed in the PowerShell prompt

# Restart the SSH Server service
Restart-Service sshd