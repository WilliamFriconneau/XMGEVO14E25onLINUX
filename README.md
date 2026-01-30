# XMG EVO 14 (E25) - CachyOS Configuration

[cite_start]Ce dépôt contient les optimisations spécifiques pour le XMG EVO 14 équipé d'un processeur AMD Ryzen 7 255 (Zen 4) et d'un GPU Radeon 780M[cite: 797, 798]. [cite_start]Cette configuration est optimisée pour un affichage à 120Hz et une réactivité accrue du système[cite: 805].

## Optimisations du Noyau (Cmdline)

Les paramètres suivants sont injectés via le chargeur de démarrage pour améliorer la gestion de l'énergie et la stabilité graphique :

* [cite_start]**AMD P-State Active** : Force l'utilisation du pilote amd-pstate pour une gestion efficace des fréquences[cite: 796, 821].
* [cite_start]**Optimisations GPU** : Configuration du Display Core (`amdgpu.dcdebugmask`, `amdgpu.dcfeaturemask`) et désactivation du scatter-gather (`amdgpu.sg_display=0`) pour stabiliser les hautes fréquences de rafraîchissement[cite: 796, 821].
* [cite_start]**Énergie** : Activation de `rcutree.enable_rcu_lazy=1` pour réduire les interruptions CPU inutiles[cite: 796].
* [cite_start]**Blacklist** : Désactivation de `ucsi_acpi` pour éviter des erreurs ACPI connues sur ce châssis[cite: 796].

## Planificateur d'E/S (Udev)

Le système utilise des planificateurs différenciés selon le type de stockage :
* [cite_start]**NVMe/SSD** : Utilisation du scheduler `adios` pour minimiser la latence sur les supports flash[cite: 1002].
* [cite_start]**HDD** : Utilisation de `bfq` pour optimiser les accès sur disques rotatifs[cite: 1002].

## Pilotes et Modprobe

* [cite_start]**Correctif Tuxedo** : Application du fichier `amdgpu-tuxedo-fix.conf` pour la compatibilité spécifique du matériel Tuxedo/Schenker[cite: 1002].
* [cite_start]**Désactivation UCPI** : Forçage de la désactivation via modprobe pour assurer la stabilité[cite: 1002].

## Environnement de Bureau (KDE Plasma)

Les réglages d'interface suivants sont appliqués :
* [cite_start]**Gestes** : Activation des gestes à 3 doigts pour les bureaux virtuels sur Wayland[cite: 1002].
* [cite_start]**Souris** : Profil d'accélération "Flat" (plat) pour une précision brute du pointeur[cite: 1002].
