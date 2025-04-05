# Inventory Tool

I am building a cross-platform systems inventory tool using, primarily, PowerShell Core 6.x and PowerShell 7.x. However, if run on a Windows System using Windows PowerShell 5.1, I need it to work. In addition, if run on Windows, I want the script to work all the way back to Windows PowerShell v1. I expect the tool to run on Windows. The tool needs to run on macOS version Sierra (10.12) and newer, and it needs to run on various Linux distributions, including but not limited to:

- Debian 8.7 and newer
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

Each of these operating systems return OS version information slightly differently.

Here are the list of properties that I plan to have in my CMDB:

- OSType: The high-level category of the operating system, identifying its core family. This field provides a simple, standardized label for grouping systems by OS type, facilitating broad classification across diverse platforms.
  - Windows: "Windows" (static)
  - macOS: "macOS" (static)
  - Linux: "Linux" (static)
- OSID: A unique identifier for the operating system, typically extracted directly from system metadata where available. For Linux, this is sourced from the ID field of tools like /etc/os-release, providing a short, machine-readable name. For Windows and macOS, it is statically assigned to ensure consistency across platforms where no native equivalent exists.
  - Windows: "Windows" (static)
  - macOS: "macOS" (static)
  - Linux: `ID` extracted directly from operating system tools that provide OS information (e.g., `/etc/os-release`); field might contain values such as "ubuntu", "debian", "rhel", etc.
- OSName: The base name of the operating system, representing its core identity without additional version or edition details. This field captures the fundamental OS designation as reported by native tools, providing a concise label for identification.
  - Windows: Extracted from Win32_OperatingSystem -> Caption; e.g., "Microsoft Windows 11 Pro"
  - macOS: ProductName from sw_vers (i.e., "macOS")
  - Linux: `NAME` extracted directly from operating system tools that provide OS information (e.g., `/etc/os-release`); field might contain values such as "Ubuntu", "Debian GNU/Linux", etc.
- OSPrettyName: The human-readable, full name of the operating system, combining its base name with version or variant details where applicable. This field is designed for display purposes, offering a descriptive and recognizable label as reported by the OS.
  - Windows: Win32_OperatingSystem -> Caption
  - macOS: Combine ProductName + ProductVersion ("macOS 10.12.6")
  - Linux: `PRETTY_NAME` extracted directly from operating system tools that provide OS information (e.g., `/etc/os-release`); field might contain values such as "Ubuntu 16.04.7 LTS (Xenial Xerus)"
- OSVersionString: The complete version string as directly reported by the operating system, capturing the full, unparsed version identifier. This field serves as the raw source for subsequent version parsing, preserving the original format for reference or troubleshooting.
  - Windows: The major.minor.build portions are derived from `[System.Environment]::OSVersion`, while the revision is extracted from the "product version" from the file `C:\Windows\System32\ntoskrnl.exe`
  - macOS: Extracted from `sw_vers` -> `ProductVersion`. Note: excludes build strings (e.g., "16G1510", which are instead stored in OSBuildString)
  - Linux: `VERSION_ID` extracted directly from operating system tools that provide OS information (e.g., `/etc/os-release`), or parsed `VERSION`
- OSVersionMajorString: The major version number of the operating system as a string, extracted from the full version string. This field retains the raw text representation of the major version, serving as the source for integer conversion and preserving non-numeric cases.
- OSVersionMajor: The major version number of the operating system as an integer, derived from OSVersionMajorString through successful conversion. This field enables numeric comparisons and sorting, representing the primary version tier.
- OSVersionMinorString: The minor version number of the operating system as a string, extracted from the full version string. This field preserves the raw text of the minor version, acting as the source for integer conversion and retaining leading zeros or non-numeric values. Captures platform-specific formatting, such as leading zeros in Linux.
- OSVersionMinor: The minor version number of the operating system as an integer, derived from OSVersionMinorString through successful conversion. This field supports numeric operations, representing the secondary version tier.
- OSVersionBuild: The build number of the operating system as an integer, derived from OSBuildString through successful conversion. This field is primarily applicable to Windows, where build numbers are numeric, and may be populated for macOS with parsing; it remains blank for Linux due to the absence of a comparable numeric build.
  - Windows: Should be populated
  - macOS: Would require string parsing on macOS (possible because build strings follow a standard format) or maybe leave macOS blank
  - Linux: Not applicable; left blank
- OSVersionPatchString: The patch level or point release of the operating system, indicating incremental updates within a major and minor version, such as '6' in macOS 10.12.6 or '7' in Ubuntu 16.04.7. For older Windows versions, it may reflect Service Pack-like updates (e.g., "1" for Windows Vista Service Pack 1, i.e., maps to `Win32_OperatingSystem` -> `ServicePackMajorVersion`); in Windows versions starting with Windows 8 and Windows Server 2012, this field is not applicable as updates are tracked via build and revision numbers.
- OSVersionPatch: i.e., OSVersionPatchString after conversion to integer, if successful
- OSVersionRevisionString: The revision level of the operating system, indicating the smallest update granularity, such as monthly cumulative patches in Windows 10/11 (e.g., '2861' in 10.0.22631.2861) or micro-updates in older Windows versions (e.g., '5512' in 5.1.2600.5512). This field is typically not applicable to macOS or Linux, where updates are managed through point releases or build numbers.
- OSVersionRevision: The patch level or point release of the operating system as an integer, derived from OSVersionPatchString through successful conversion. This field enables numeric analysis of fine-grained updates, primarily for Windows systems tracking cumulative patches or micro-updates.
- OSBuildString: The raw build string of the operating system as reported, capturing the build identifier in its native format. This field stores the build number for Windows and the alphanumeric build string for macOS; it is not applicable to Linux, where kernel version is used instead.
  - Windows: stores the build number in string format
  - macOS: stores the macOS build string (from `sw_vers` -> `BuildVersion`)
  - Linux: not applicable
- OSServicePack: The Service Pack level of the operating system, specific to older Windows versions, indicating a major bundled update (e.g., '3' for Windows XP SP3). This field is not applicable to Windows 10/11, macOS, or Linux, where updates are handled through other mechanisms like build numbers, revisions, or point releases."
  - Windows: extracted from `Win32_OperatingSystem` -> `ServicePackMajor`
  - macOS: not applicable
  - Linux: not applicable
- OSEdition: The edition or variant of the operating system, identifying specific configurations or feature sets. This field captures edition details where available, defaulting to a neutral value or null when not applicable.
  - Windows: "Pro" (parsed from `Win32_OperatingSystem` -> `Caption`).
  - macOS: N/A (or "Base" as default).
  - Linux: "Workstation" (e.g., Fedora), "LTS" (Ubuntu), or N/A.
- OSSKU: The numeric Stock Keeping Unit (SKU) of the operating system, a Windows-specific identifier denoting its product type or licensing variant. This field is extracted from `Win32_OperatingSystem` -> `OperatingSystemSKU` and is not applicable to macOS or Linux.
  - Windows: 4 (Professional), 48 (Home), etc.
  - macOS: N/A
  - Linux: N/A
- OSCodename: The codename of the operating system, providing a human-friendly alias for its version or release. This field is reserved for future use, with no static lookup tables maintained at this time, allowing for dynamic population as needed.
  - Windows: "23H2" (to be used in the future)
  - macOS: "Sierra" (to be used in the future)
  - Linux: "Xenial Xerus" (to be used in the future)
- OSKernelVersion: The version string of the operating system kernel, identifying the core software layer. This field captures the kernel version for Linux and macOS, and for Windows, it uses the product version of the kernel executable to approximate kernel-level detail.
  - Windows: e.g., "10.0.22621.2861" (from the "product version" from the file `C:\Windows\System32\ntoskrnl.exe`)
  - macOS: e.g., "16.7.0" (Darwin kernel from `uname -r`)
  - Linux: e.g., "4.15.0-34-generic" (from `uname --kernel-version`)
- OSArchitecture: The system architecture of the operating system, indicating the processor instruction set (e.g., x86, x86-64, ARM32, ARM64). This field is reserved for future use, capturing hardware compatibility details when implemented."
  - Windows: "x86-64" (e.g., from [System.Environment]::Is64BitOperatingSystem)
  - macOS: "x86-64" or "ARM64" (post-Sierra)
  - Linux: "x86_64" (from uname -m)

And here are my notes on how I would implement this inventory solution:

- Windows returns it as a .NET version string in the format major.minor.build.revision. I believe the major, minor, build, and revision numbers are always integers. I retrieve the major, minor, and build numbers from the string in Win32_OperatingSystem -> Version. To accurately get the revision number of the operating system, I would get the "product version" from the file `C:\Windows\System32\ntoskrnl.exe`, and extract the OS revision number from there. If I cannot get the revision number from ntoskrnl.exe, I would run `cmd /c ver` and dump the results to a temp file, then parse the temp file for the revision number. If I still cannot get the revision number using this method, then I would get the "file version" of the file `C:\Windows\System32\ntoskrnl.exe`, and extract the revision number from there.
  - Older versions of Windows additionally have a service pack number (note: PowerShell runs all the way back to Windows XP and Windows Server 2003, which did have service packs, so I would like to consider this). Win32_OperatingSystem -> ServicePackMajorVersion contains the service pack number.
- Windows also has a "pretty name" that is typically exposed in Win32_OperatingSystem -> Caption
- On Windows Vista, Windows Server 2008, and newer, Win32_OperatingSystem -> OperatingSystemSKU indicates the "edition" of Windows
- On Linux, I try commands in the following order of preference:
  - Run `/etc/os-release`
    - If that command succeeds, it returns text data in the format `key=value`. I store the results in a hashtable, where each key represents an operating system property.
    - If I find the key `ID` and its value equals `alpine`, then:
      - Run `/etc/alpine-release`, which returns the version number in string format (`major.minor.patch`), where `major`, `minor`, and `patch` are all integers. The results of this command get written to the operating system "VERSION" property.
      - Write `alpine` to an operating system "ID" property
      - Write `Alpine Linux` to an operating system "NAME" property
    - If I find the key `ID` and its value equals `arch`, then:
      - I run `uname --kernel-release` and consider the results an operating system "VERSION_ID" property.
      - I also write `arch` to an operating system "ID" property
      - And, I write `Rolling Release` in the operating system "PRETTY_NAME" property
  - If `/etc/os-release` doesn't exist or the command fails, I run `/etc/alpine-release`
    - If the command succeeds, it returns the version number in string format (`major.minor.patch`), where `major`, `minor`, and `patch` are all integers. The results of this command get written to the operating system "VERSION" property.
    - Write `alpine` to an operating system "ID" property
    - Write `Alpine Linux` to an operating system "NAME" property
  - If `/etc/alpine-release` doesn't exist or the command fails, I run `lsb_release`:
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
    - Next, run `uname -s` and confirm the result is `Linux`. If so:
      - Write `Linux` to the operating system "NAME" property
      - Run `uname -r` and write the result to the operating system property `VERSION_ID`
      - Concatenate the "VERSION" propety with "(kernel ", the "VERSION_ID" property, and ")".
      - Run `uname -v` and write the result to the operating system property `KERNEL_VERSION`
  - If `/etc/debian_version` doesn't exist or the command fails, I run `/etc/SuSe-release`:
    - This command returns the "pretty name" of the SuSe release. I consider this an operating system "PRETTY_NAME" property
    - I also write `suse` to an operating system "ID_LIKE" property
    - The command also returns a key value pair like `CODENAME=xxx`. I take `xxx` in this example and consider it an operating system "VERSION_CODENAME" property
    - Note: `/etc/SuSe-release` is deprecated in favor of `/etc/os-release` on SUSE (SLES 12 SP1+, OpenSUSE 42.2+)
  - If `/etc/SuSe-release` doesn't exist or the command fails, I run `/etc/redhat-release`:
    - This command returns the "pretty name" of the RHEL release. I consider this an operating system "PRETTY_NAME" property
    - Note: `/etc/redhat-release` is deprecated in favor of `/etc/os-release` on RHEL 7+
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

As I design the solution, I'm comfortable mapping operating system properties to fields, but I don't want to create new data fields, such as the macOS version codename, that would require maintaining a static lookup table. For example, I do not wish to translate macOS version numbers to operating system code names (e.g., translating 10.12.x to Sierra).

Please evaluate this psuedocode for each operating system version that I must support (go through every permutation). Is its operating system information detected correctly?
