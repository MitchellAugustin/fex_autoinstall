# Automated installer for Steam & FEX on arm64

This does the following:
- Installs FEX PPA and dependencies
- Downloads and installs steam deb
- Downloads a stock Ubuntu 24.04 RootFS via FEXRootFSFetcher
- Unsquashes the downloaded rootfs, installs NVIDIA 580-open drivers and other packages needed for gaming
- Re-squashes the rootfs
- Applies apparmor profiles for FEXBash and Steam
- Patches the Steam launcher to launch with FEXBash on arm64

Note:
- This is third-party software for experimental use. It is not supported by Canonical, Valve, NVIDIA, or the FEX developers. Use at your own risk.
- Your x86 RootFS will not receive automatic updates.

Before using this script:
- Ensure that your host's graphics drivers are up-to-date

How to use:
`cd ~ && wget https://raw.githubusercontent.com/MitchellAugustin/fex_autoinstall/refs/heads/main/fex_autoinstall_poc.sh && bash fex_autoinstall_poc.sh`
