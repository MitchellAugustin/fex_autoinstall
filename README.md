# Automated Steam & FEX installer for Ubuntu on arm64

## How to use
- In desktop mode right click and select the "Open in Terminal" option.
- If you have not already done so, run the following command on the new terminal window: `wget https://raw.githubusercontent.com/esullivan-nvidia/fex_autoinstall/refs/heads/main/fex_autoinstall_poc.sh && bash fex_autoinstall_poc.sh`
- Once installation has completed and for all subsequent runs, Steam can be started by running `FEXBash steam` from the same terminal window.

## This does the following
- Installs FEX PPA and dependencies
- Downloads and installs steam deb
- Enables thunking for graphics libraries
- Applies apparmor profiles for FEXBash and Steam
- Installs the necessary x86 libraries to have DLSS function
- Patches the Steam launcher to launch with FEXBash on arm64

## Notes
- This is designed for Ubuntu 24.04 and may require modifications for use on other distros/releases
- This is third-party software for experimental use. It is not supported by Canonical, Valve, NVIDIA, or the FEX developers. Use at your own risk.
- Your x86 RootFS will not receive automatic updates.
- Clicking the launcher from the desktop icon will not work. It will produce the following error: "You are missing the following 32-bit libraries, and Steam may not run: libc.so.6"
- Once the `fex_autoinstall_poc.sh` script has been run it does not need to be run again. If it is run a second time `FEXRootFSFetcher` will prompt if the operation should be canceled or if the existing rootfs should be overwritten or validated. Any of these options will leave the rootfs in a functional state. Just select one and let the script complete normally.

```
Ubuntu_24_04.sqsh already exists. What do you want to do?
Options:
	0: Cancel
	1: Overwrite
	2: Validate
```

- It is recommended to run applications with Proton 10. This can be done by right clicking the game in steam and selecting "Properties". Then click on the "Force the use of a specific Steam Play compatibility tool" box and select Proton 10 from the drop down menu.

## Before using this script
- Ensure that your host's graphics drivers are up-to-date

## Troubleshooting
- If you experience any future crashes in games that were initially playable, update your RootFS by using [FEXRootFSFetcher](https://wiki.fex-emu.com/index.php/Development:Setting_up_RootFS#Quick_Setup_with_FEXRootFSFetcher).
- If Steam fails to launch with an "exec format error", "You are missing the following 32-bit libraries, and Steam may not run: libc.so.6", or similar, ensure that [patch_steam_for_arm64.patch](https://github.com/MitchellAugustin/fex_autoinstall/blob/main/patch_steam_for_arm64.patch) has been correctly applied to your /usr/lib/steam/bin_steam.sh. (If the patch does not apply, you can launch with `FEXBash steam` instead.)
