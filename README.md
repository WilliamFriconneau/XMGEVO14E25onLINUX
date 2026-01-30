# XMG EVO 14 (E25) - CachyOS System Configuration

Ce dépôt contient les optimisations et paramètres spécifiques pour le XMG EVO 14 (châssis xmgw) fonctionnant sous CachyOS.

## Spécifications Matérielles
- [cite_start]**CPU** : AMD Ryzen 7 255 (Zen 4)[cite: 1].
- [cite_start]**GPU** : AMD Radeon 780M (RDNA 3)[cite: 1].
- [cite_start]**Écran** : 2880x1800 @ 120Hz[cite: 1].
- [cite_start]**Bluetooth** : Intel AX210.

## Paramètres du Noyau (Command Line)
Les options suivantes sont ajoutées au démarrage pour optimiser la gestion d'énergie et la stabilité graphique :
- [cite_start]`rcutree.enable_rcu_lazy=1` : Réduit les réveils CPU inutiles.
- [cite_start]`amd_pstate=active` : Active le pilote de performance AMD.
- [cite_start]`amdgpu.sg_display=0` : Désactive le scatter-gather pour stabiliser l'affichage.
- [cite_start]`amdgpu.dcdebugmask=0x610` & `amdgpu.dcfeaturemask=0x8` : Optimisations du Display Core.
- [cite_start]`amdgpu.abmlevel=0` : Désactive la gestion adaptative du rétroéclairage.
- [cite_start]`module_blacklist=ucsi_acpi` : Désactive le module UCSI pour éviter des erreurs système.

## Optimisations E/S (Udev)
Le système utilise des planificateurs d'E/S différenciés :
- [cite_start]**NVMe / SSD** : Scheduler `adios` pour une latence minimale.
- [cite_start]**Disques rotatifs** : Scheduler `bfq`.

## Pilotes et Modules
- [cite_start]`amdgpu-tuxedo-fix.conf` : Correctifs spécifiques pour le matériel Tuxedo/Schenker.
- [cite_start]`no-ucsi.conf` : Forçage de la désactivation du module UCSI.

## Environnement KDE Plasma
- [cite_start]**Gestes** : Activation des gestes à 3 doigts pour les bureaux virtuels sur Wayland.
- [cite_start]**Souris** : Profil d'accélération "Flat" sans accélération logicielle.
