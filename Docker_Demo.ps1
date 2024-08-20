# PowerShell demonstration on Docker
# Written by Frank Lesniak
# Last updated: 2020-04-28

# Install Docker if it isn't already; may require a reboot

# Start docker from start menu

# Hey, the latest tag works for PowerShell!
docker run -it mcr.microsoft.com/powershell

# Open the PowerShell Docker repository:
#https://hub.docker.com/_/microsoft-powershell
# What the heck is the latest?

# Check PowerShell version
$PSVersionTable

# Is this Windows?
$IsWindows

# Get information about the OS
$compInfo = Get-ComputerInfo
$compInfo.OsVersion
$compInfo.WindowsVersion
$compInfo.OsBuildNumber

# Show more specific edition info
$compInfo.OsOperatingSystemSKU
$compInfo.WindowsEditionId
$compInfo.WindowsInstallationType

# Check computer name
hostname

# Check username
whoami

# Close the docker container
exit

# Start a Nano Server container - now that's more exotic!
docker run -it mcr.microsoft.com/powershell:nanoserver-1909

# Is this Windows?
$IsWindows

# Get information about the OS
$compInfo = Get-ComputerInfo
# Failed!

# Check the registry:
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"

# Close the docker container
exit