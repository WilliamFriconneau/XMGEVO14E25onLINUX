#!/usr/bin/fish

# Script de configuration pour XMG EVO 14 - CachyOS

function ask_confirm
    set -l task $argv[1]
    echo -e "\n[?] $task"
    read -l -P "Appliquer ? (y/n) : " res
    if test "$res" = "y" -o "$res" = "Y"
        return 0
    end
    return 1
end

echo "--- Optimisation Système XMG EVO 14 ---"

# 1. Mise à jour du Bootloader (Kernel Cmdline)
if ask_confirm "Configurer la ligne de commande du noyau ?"
    set -l params "rcutree.enable_rcu_lazy=1 amd_pstate=active amdgpu.dcdebugmask=0x610 amdgpu.sg_display=0 amdgpu.dcfeaturemask=0x8 amdgpu.abmlevel=0 module_blacklist=ucsi_acpi"
    if test -f /etc/default/grub
        sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"/GRUB_CMDLINE_LINUX_DEFAULT=\"$params /" /etc/default/grub
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    else
        echo "GRUB non trouvé. Veuillez ajouter ces paramètres manuellement à votre bootloader : $params"
    end
end

# 2. Règles Udev pour les Schedulers
if ask_confirm "Installer les règles Udev pour les disques (adios/bfq) ?"
    set -l udev_rules 'ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="adios"
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="adios"'
    echo "$udev_rules" | sudo tee /etc/udev/rules.d/60-scheduler.rules > /dev/null
    sudo udevadm control --reload
end

# 3. Fichiers Modprobe
if ask_confirm "Appliquer les correctifs modprobe (amdgpu & ucsi) ?"
    echo "options amdgpu tuxedo_fix=1" | sudo tee /etc/modprobe.d/amdgpu-tuxedo-fix.conf > /dev/null
    echo "blacklist ucsi_acpi" | sudo tee /etc/modprobe.d/no-ucsi.conf > /dev/null
end

# 4. Paramètres KDE Plasma
if ask_confirm "Appliquer les réglages KDE (Gestes & Souris) ?"
    # Gestes 3 doigts
    kwriteconfig6 --file kwinrc --group "Wayland-Gestures" --key "VirtualDesktop3FingerGesture" "true"
    # Profil de souris Flat
    kwriteconfig6 --file kcminputrc --group "Mouse" --key "AccelerationProfile" "Flat"
    kwriteconfig6 --file kcminputrc --group "Mouse" --key "PointerAcceleration" "0"
    kwriteconfig6 --file kcminputrc --group "Libinput" --key "PointerAccelerationProfile" "1"
    echo "Réglages KDE appliqués. Une reconnexion est nécessaire."
end

echo "Configuration terminée."
