#!/bin/bash

# Usage: wget https://raw.githubusercontent.com/MitchellAugustin/fex_autoinstall/refs/heads/main/fex_autoinstall_poc.sh && bash fex_autoinstall_poc.sh

# Exit immediately if a command exits with a non-zero status.
set -e

ORIG_DIR=$(pwd)

TEMP_DIR=$(mktemp -d)

cleanup() {
  cd "$ORIG_DIR"
  rm -rf "$TEMP_DIR"
  echo "Cleaned up temporary directory: $TEMP_DIR"
}

trap cleanup EXIT

cd "$TEMP_DIR"
echo "Working in temporary directory: $TEMP_DIR"

echo "Adding FEX-Emu PPA..."
sudo add-apt-repository -y ppa:fex-emu/fex
sudo apt update

echo "Installing FEX-Emu and Vulkan packages..."
sudo apt install -y fex-emu-armv8.4 fex-emu-wine patchelf mesa-vulkan-drivers

echo "Downloading required files..."
wget https://repo.steampowered.com/steam/archive/stable/steam-launcher_latest_all.deb
wget https://raw.githubusercontent.com/MitchellAugustin/fex_autoinstall/refs/heads/main/patch_steam_for_arm64.patch
wget https://raw.githubusercontent.com/MitchellAugustin/fex_autoinstall/refs/heads/main/fex_config_with_thunking_enabled.json

echo "Installing Steam from .deb..."
sudo apt install -y ./steam-launcher_latest_all.deb

echo "Fetching FEX RootFS..."
FEXRootFSFetcher -y -a

echo "Applying FEX config..."
mkdir -p ~/.fex-emu
mv fex_config_with_thunking_enabled.json ~/.fex-emu/Config.json

echo "Configuring AppArmor..."
echo "abi <abi/4.0>,
include <tunables/global>
 
profile FEXBash /usr/bin/FEXBash flags=(unconfined) {
  userns,
 
  # Site-specific additions and overrides. See local/README for details.
  include if exists <local/FEXBash>
}
" > FEXBash_apparmor.txt

sudo mv FEXBash_apparmor.txt /etc/apparmor.d/FEXBash
sudo apparmor_parser -Tr /etc/apparmor.d/steam
sudo apparmor_parser -Tr /etc/apparmor.d/FEXBash

echo "Patching Steam launcher to automatically invoke with FEXBash on arm64..."
sudo patch -p1 /usr/lib/steam/bin_steam.sh < patch_steam_for_arm64.patch

echo "---"
echo "Installation complete!"
echo "We recommend running sudo apt update && sudo apt upgrade to ensure everything on your host is up-to-date"
echo "---"
