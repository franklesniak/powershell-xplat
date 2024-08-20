##############################################################################################
# Copyright (c) 2020, Frank Lesniak
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are
# permitted provided that the following conditions are met:
#
#  Redistributions of source code must retain the above copyright notice, this list of
#  conditions and the following disclaimer.
#
#  Redistributions in binary form must reproduce the above copyright notice, this list of
#  conditions and the following disclaimer in the documentation and/or other materials
#  provided with the distribution.
#
#  Neither the name of Frank Lesniak nor the names of any contributors may be used to
#  endorse or promote products derived from this software without specific prior written
#  permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS
# OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##############################################################################################

# PowerShell v7.0.0 demonstration on macOS
# Written by Frank Lesniak
# Last updated: 2020-04-28

##########################################
# Part 1: Install PowerShell

# Install Homebrew
# You likely will need to enter your password when you run this command, so keep an eye on it:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
# Confirm no errors occurred. If they did, re-run the command.

# Install PowerShell (latest version):
brew cask install powershell
# Again, you may need to enter your password during the installation process.

# To later update PowerShell:
#brew update
#brew cask upgrade powershell

# Start PowerShell
pwsh

# Display PowerShell version info
$PSVersionTable

##########################################
# Part 2: Get Operating System info

# Show that we're on a mac
$isMacOS

# ...and we're not on Linux or Windows
$isLinux

# ...and not on Windows
$isWindows

# No Get-ComputerInfo :(
Get-ComputerInfo
# Previous command will throw error

# But... we can get the version of macOS:
if (Test-Path variable:\isMacOS)
{
    # Is PowerShell v6 or Newer
    if ($isMacOS)
    {
        $versionMacOS = [version](sw_vers -productVersion)
    } `
    else `
    {
        $versionMacOS = $null
    }
} `
else `
{
    # Cannot be MacOS if PowerShell 5 or older
	$versionMacOS = $null
}

# Display the version of macOS
$versionMacOS

# Exit PowerShell
exit

##########################################
# Part 3: Remotely Connect to macOS

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

sudo launchctl stop com.openssh.sshd
sudo launchctl start com.openssh.sshd

# macOS is now listening for connections and can be connected-to using Enter-PSSession
# To do this, run a command like this from another system:
# Enter-PSSession -HostName SFEL1WKS99 -UserName flesniak