# wget https://mitchellaugustin.com/files/fex_autoinstall_poc.sh && bash fex_autoinstall_poc.sh
SWD=$(pwd)
sudo add-apt-repository -y ppa:fex-emu/fex
sudo apt update
sudo apt install -y fex-emu-armv8.4 fex-emu-wine patchelf
wget https://repo.steampowered.com/steam/archive/stable/steam-launcher_latest_all.deb
wget https://mitchellaugustin.com/files/patch_steam_for_arm64.patch
sudo apt install ./steam-launcher_latest_all.deb
FEXRootFSFetcher -y -a
cd $HOME/.fex-emu/RootFS
unsquashfs -f -d NewRootFS/ Ubuntu_24_04.sqsh
cd NewRootFS
rm ubuntu_rootfs_update.py
wget https://mitchellaugustin.com/files/ubuntu_rootfs_update.py
chmod +x ubuntu_rootfs_update.py
./ubuntu_rootfs_update.py chroot
echo "PWD: " $(pwd)
cd ../
mv Ubuntu_24_04.sqsh Ubuntu2404-old-$(date +%s).sqsh
mksquashfs NewRootFS/ Ubuntu_24_04.sqsh -comp zstd
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
cd $SWD
sudo patch -p1 /usr/lib/steam/bin_steam.sh < patch_steam_for_arm64.patch
echo "We recommend running sudo apt upgrade to ensure everything on your host is up-to-date"
echo "Run FEXBash steam to start steam"
