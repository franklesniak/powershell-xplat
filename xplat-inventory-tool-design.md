# Inventory Tool

I am building a cross-platform systems inventory tool using PowerShell Core 6.x and PowerShell 7.x. I expect the tool to run on Windows. The tool needs to run on macOS version Sierra (10.12) and newer, and it needs to run on various Linux distributions, including but not limited to:

- Debian 8.7 and newer; Debian 9 and newer
- Ubuntu 14.04, 16.04, 17.04, and newer
- Raspberry Pi OS (formerly known as Raspbian) Stretch and newer
- Kali Linux (likely version 2018.1 and newer)
- Fedora 25 and newer
- Red Hat Enterprise Linux (RHEL) 7 and newer
- CentOS 7 and newer
- Alpine Linux (likely version 3.6 and newer)
- SUSE Linux Enterprise Server (SLES) (likely version 12 SP1 and newer)
- OpenSUSE 42.2 and newer
- Arch Linux (release state as of mid-2016 and newer)

The inventory tool should run on the oldest versions of these distributions supported by PowerShell Core 6.0 and run on the newest versions of these distributions as well.

Generally speaking, I have the code written to retrieve the OS version and processor architecture from Windows, macOS, and various Linux distributions.

However, each of these operating systems return the OS version slightly differently.

- Windows returns it as a .NET version string in the format major.minor.build.revision. I believe the major, minor, build, and revision numbers are always integers.
  - Older versions of Windows additionally have a service pack number (note: PowerShell runs all the way back to Windows XP and Windows Server 2003, which did have service packs, so I would like to consider this)
- Windows also has a "pretty name" that is typically exposed in Win32_OperatingSystem -> Name
- On Windows Vista, Windows Server 2008, and newer, Win32_OperatingSystem -> OperatingSystemSKU indicates the "edition" of Windows
- On Linux, I try commands in the following order of preference:
  - `/etc/alpine-release`
  - If `/etc/alpine-release` doesn't exist or the command fails, I run `/etc/os-release`
    - If that command succeeds, it returns text data in the format `key=value`. I store the results in a hashtable, where each key represents an operating system property.
    - If I find the key `ID` and its value equals `arch`, then I run `uname --kernel-release` and consider the results an operating system "VERSION_ID" property
  - If `/etc/os-release` doesn't exist or the command fails, I run `lsb_release`:
    - `lsb_release --version --short` and consider the results an operating system "VERSION" property
    - `lsb_release --id --short` and consider the results an operating system "NAME" property
    - `lsb_release --description --short` and consider the results an operating system "PRETTY_NAME" property
    - `lsb_release --release --short` and consider the results an operating system "VERSION_ID" property
    - `lsb_release --codename --short` and consider the results an operating system "VERSION_CODENAME" property
  - If `lsb_release` doesn't exist or the command fails, I run `/etc/lsb-release`, which returns text data in the format `key=value`. I process it as follows:
    - Whatever data is stored in the `DISTRIB_VERSION` key, I consider an operating system "VERSION" property
    - Whatever data is stored in the `DISTRIB_ID` key, I consider an operating system "NAME" property. I have a note that this appears to be the best match; however, the "ID" property could also be a good match.
    - Whatever data is stored in the `DISTRIB_DESCRIPTION` key, I consider an operating system "PRETTY_NAME" property
    - Whatever data is stored in the `DISTRIB_RELEASE` key, I consider an operating system "VERSION_ID" property
    - Whatever data is stored in the `DISTRIB_CODENAME` key, I consider an operating system "VERSION_CODENAME" property
  - If `/etc/lsb-release` doesn't exist or the command fails, I run `/etc/debian_version`:
    - This command returns the version of the Debian distribution. I consider this an operating system "VERSION" property
    - I also write `debian` to an operating system "ID_LIKE" property
  - If `/etc/debian_version` doesn't exist or the command fails, I run `/etc/SuSe-release`:
    - This command returns the "pretty name" of the SuSe release. I consider this an operating system "PRETTY_NAME" property
    - I also write `suse` to an operating system "ID_LIKE" property
    - The command also returns a key value pair like `CODENAME=xxx`. I take `xxx` in this example and consider it an operating system "VERSION_CODENAME" property
  - If `/etc/SuSe-release` doesn't exist or the command fails, I run `/etc/redhat-release`:
    - This command returns the "pretty name" of the RHEL release. I consider this an operating system "PRETTY_NAME" property
  - If `/etc/redhat-release` doesn't exist or the command fails, I run:
    - `uname --operating-system` and consider the results an operating system "NAME" property
    - `uname --kernel-release` and consider the results an operating system "VERSION_ID" property
    - `uname --kernel-version` and consider the results and operating system "VERSION" property
- On macOS:
  - `sw_vers -productVersion` returns a version number like `11.7.10`. These version strings do not always have three parts, however; `11.0` would be considered a valid macOS version string. A two part version is in the format `major.minor`, where `major` and `minor` are always integers. A three part version number is in the format `major.minor.patch`, where `major`, `minor`, and `patch` are always integers.
    - Note: macOS build numbers are explained at the following link: [X post](https://x.com/homebysix/status/936032319340556291)
    - Note: a partial list of macOS build numbers are listed at the following link: [List of macOS/versions and builds](https://en.namu.wiki/w/macOS/%EB%B2%84%EC%A0%84%20%EB%B0%8F%20%EB%B9%8C%EB%93%9C%20%EC%9D%BC%EB%9E%8C)
    - Note: a more complete list of macOS build numbers can be found on individual pages on betawiki.net such as this [macOS Sequoia page](https://betawiki.net/wiki/MacOS_Sequoia)
  - `sw_vers -productName` seems to always return `macOS`
  - `sw_vers -buildVersion` returns an alphanumeric build number. For example, `20G1427`

On Linux, the list of properties I build ends up returning properties and values like the following:

```text
PRETTY_NAME                    CBL-Mariner/Linux
SUPPORT_URL                    https://aka.ms/cbl-mariner
BUG_REPORT_URL                 https://aka.ms/cbl-mariner
NAME                           Common Base Linux Mariner
ANSI_COLOR                     1;34
HOME_URL                       https://aka.ms/cbl-mariner
VERSION_ID                     2.0
ID                             mariner
VERSION                        2.0.20250207
```

Am I missing anything?
