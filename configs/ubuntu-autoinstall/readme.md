Extract the Ubuntu LTS Server ISO to ```<dir>```
<br>```mkdir -p <dir>/source-files/server```
<br>```touch <dir>/source-files/server/meta-data```
<br>copy ```user-data``` file in repo to ```<dir>/source-files/server/user-data```
<br><br>From ```<dir>/source-files``` run the following.
<br>```xorriso -as mkisofs -r \```
<br>```-V 'Ubuntu 22.04 LTS AUTO (EFIBIOS)' \```
<br>```-o ../ubuntu-22.04.4-Server-autoinstall.iso \```
<br>```--grub2-mbr ../BOOT/1-Boot-NoEmul.img \```
<br>```-partition_offset 16 \```
<br>```--mbr-force-bootable \```
<br>```-append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b ../BOOT/2-Boot-NoEmul.img \```
<br>```-appended_part_as_gpt \```
<br>```-iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \```
<br>```-c '/boot.catalog' \```
<br>```-b '/boot/grub/i386-pc/eltorito.img' \```
<br>```-no-emul-boot -boot-load-size 4 \```
<br>```-boot-info-table \```
<br>```--grub2-boot-info \```
<br>```-eltorito-alt-boot \```
<br>```-e '--interval:appended_partition_2:::' \```
<br>```-no-emul-boot   .```
<br><br>Add the following to ```<dir>/source-files/boot/grub/grub.cfg```
<br>```menuentry "Autoinstall Ubuntu Workstation" {```
<br>```    set gfxpayload=keep```
<br>```    linux   /casper/vmlinuz quiet autoinstall ds=nocloud\;s=/cdrom/server/  ---```
<br>```    initrd  /casper/initrd```
<br>```}```
