# Automated Steam & FEX installer for Ubuntu on arm64

## How to use
`wget https://raw.githubusercontent.com/MitchellAugustin/fex_autoinstall/refs/heads/main/fex_autoinstall_poc.sh && bash fex_autoinstall_poc.sh`

## This does the following
- Installs FEX PPA and dependencies
- Downloads and installs steam deb
- Enables thunking for graphics libraries
- Applies apparmor profiles for FEXBash and Steam
- Patches the Steam launcher to launch with FEXBash on arm64

## Notes
- This is designed for Ubuntu 24.04 and may require modifications for use on other distros/releases
- This is third-party software for experimental use. It is not supported by Canonical, Valve, NVIDIA, or the FEX developers. Use at your own risk.
- Your x86 RootFS will not receive automatic updates.

## Before using this script
- Ensure that your host's graphics drivers are up-to-date

## Troubleshooting
- If you experience any future crashes in games that were initially playable, update your RootFS by using [FEXRootFSFetcher](https://wiki.fex-emu.com/index.php/Development:Setting_up_RootFS#Quick_Setup_with_FEXRootFSFetcher).
- If Steam fails to launch with an "exec format error" or similar, ensure that [patch_steam_for_arm64.patch](https://github.com/MitchellAugustin/fex_autoinstall/blob/main/patch_steam_for_arm64.patch) has been correctly applied to your /usr/lib/steam/bin_steam.sh
