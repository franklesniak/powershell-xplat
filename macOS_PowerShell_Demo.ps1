#region Readme #####################################################################
# This demo script is intended to be run on macOS. It demonstrates how to install
# PowerShell on macOS using Homebrew, and how to get the version of macOS using
# PowerShell. It also shows how to enable SSH Remoting on macOS and how to connect
# to a macOS system using PowerShell Remoting.
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

#region Part 0: Install Homebrew ###################################################
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
# Confirm no errors occurred. If they did, re-run the command.
#endregion Part 0: Install Homebrew ###################################################

#region Part 1: Install PowerShell #################################################
# Install PowerShell (latest version):
brew install --cask powershell

# To later update PowerShell:
# brew update
# brew upgrade --cask powershell

# Start PowerShell
pwsh

# Display PowerShell version info
$PSVersionTable
#endregion Part 1: Install PowerShell #################################################

#region Part 2: Get Basic Operating System Info ####################################
# Show that we're on a mac
$IsMacOS

# ...and we're not on Linux:
$IsLinux

# ...and not on Windows
$IsWindows

Get-ComputerInfo
# Previous command will throw error
# No Get-ComputerInfo :(
#endregion Part 2: Get Basic Operating System Info ####################################

#region Part 3: Get macOS Version ##################################################
if (Test-Path variable:\isMacOS) {
    # Is PowerShell v6 or Newer
    if ($isMacOS) {
        $versionMacOS = [version](sw_vers -productVersion)
    } else {
        $versionMacOS = $null
    }
} else {
    # Cannot be MacOS if PowerShell 5 or older
	$versionMacOS = $null
}

# Display the version of macOS
$versionMacOS

# Exit PowerShell
exit
#endregion Part 3: Get macOS Version ##################################################

#region Part 4: Remotely Connect to macOS ##########################################
# Make sure SSH Remoting is enabled by following these steps:
# --Open System Preferences.
# --Click on Sharing.
# --Check Remote Login to set Remote Login: On.
# --Allow access to the appropriate users.
# --Configuring the Computer Name

# Validate the path to PowerShell
ls /usr/local/bin/pwsh

# Edit the SSH Server config:
sudo nano /private/etc/ssh/sshd_config
# Un-comment (remove the hashtag on) the line that begins with PasswordAuthentication (PG DWN x 3), and ensure it's set to yes
# Add a Subsystem line (PG DWN x 3) minus the hashtag comment symbol):
#Subsystem	powershell	/usr/local/bin/pwsh -sshs -NoLogo -NoProfile
# Save the file (Ctrl+O, enter), then exit (Ctrl+X)

# Restart the SSH Server
sudo launchctl stop com.openssh.sshd
sudo launchctl start com.openssh.sshd

# macOS is now listening for connections and can be connected-to using Enter-PSSession
# To do this, run a command like this from another system:
# Enter-PSSession -HostName SFEL1WKS99 -UserName flesniak
#endregion Part 4: Remotely Connect to macOS ##########################################