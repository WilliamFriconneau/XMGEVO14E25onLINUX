# XMG EVO 14 (E25) - CachyOS System Configuration

Ce dépôt contient les optimisations et paramètres spécifiques pour le XMG EVO 14 (châssis xmgw) fonctionnant sous CachyOS.

## Spécifications Matérielles
- **CPU** : AMD Ryzen 7 255 (Zen 4)[cite: 1].
- **GPU** : AMD Radeon 780M (RDNA 3)[cite: 1].
- **Écran** : 2880x1800 @ 120Hz[cite: 1].
- **Bluetooth** : Intel AX210.

## Paramètres du Noyau (Command Line)
Les options suivantes sont ajoutées au démarrage pour optimiser la gestion d'énergie et la stabilité graphique :
- `rcutree.enable_rcu_lazy=1` : Réduit les réveils CPU inutiles.
- `amd_pstate=active` : Active le pilote de performance AMD.
- `amdgpu.sg_display=0` : Désactive le scatter-gather pour stabiliser l'affichage.
- `amdgpu.dcdebugmask=0x610` & `amdgpu.dcfeaturemask=0x8` : Optimisations du Display Core.
- `amdgpu.abmlevel=0` : Désactive la gestion adaptative du rétroéclairage.
- `module_blacklist=ucsi_acpi` : Désactive le module UCSI pour éviter des erreurs système.

## Optimisations E/S (Udev)
Le système utilise des planificateurs d'E/S différenciés :
- **NVMe / SSD** : Scheduler `adios` pour une latence minimale.
- **Disques rotatifs** : Scheduler `bfq`.

## Pilotes et Modules
- `amdgpu-tuxedo-fix.conf` : Correctifs spécifiques pour le matériel Tuxedo/Schenker.
- `no-ucsi.conf` : Forçage de la désactivation du module UCSI.

## Environnement KDE Plasma
- **Gestes** : Activation des gestes à 3 doigts pour les bureaux virtuels sur Wayland.
- **Souris** : Profil d'accélération "Flat" sans accélération logicielle.
