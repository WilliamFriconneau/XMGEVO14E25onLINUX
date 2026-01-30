# XMG EVO 14 (E24) - Configuration système CachyOS

Modifications appliquées pour optimiser la consommation, la stabilité et contourner certains bugs firmware/BIOS.

## Matériel

| Composant | Détail |
|-----------|--------|
| Modèle | XMG EVO 14 (E24) |
| CPU | AMD Ryzen 7 8845HS (Hawk Point) |
| GPU | AMD Radeon 780M (RDNA3 iGPU) |
| WiFi/BT | Intel AX210 |
| OS | CachyOS (Arch-based) |

## Paramètres kernel

```
quiet nowatchdog splash rw
rootflags=subvol=/@
rd.luks.uuid=23c07d66-188c-4b64-bf37-fb03e80bb9df
rd.luks.options=discard,tpm2-device=auto
resume=/dev/mapper/luks-23c07d66-188c-4b64-bf37-fb03e80bb9df
resume_offset=1768678
rcutree.enable_rcu_lazy=1
amd_pstate=active
amdgpu.dcdebugmask=0x610
amdgpu.sg_display=0
amdgpu.dcfeaturemask=0x8
amdgpu.abmlevel=0
module_blacklist=ucsi_acpi
```

### Détail des paramètres

#### Général

| Paramètre | Rôle |
|-----------|------|
| `nowatchdog` | Désactive le watchdog matériel, économise ~0.5W |
| `rcutree.enable_rcu_lazy=1` | RCU lazy callbacks, réduit les wakeups CPU |

#### LUKS + TPM2

| Paramètre | Rôle |
|-----------|------|
| `rd.luks.options=discard,tpm2-device=auto` | Déchiffrement auto via TPM2 + TRIM passthrough |
| `resume_offset=1768678` | Offset du swapfile pour hibernation sur BTRFS |

#### AMD GPU (contournements bugs)

| Paramètre | Rôle |
|-----------|------|
| `amd_pstate=active` | Driver pstate actif (EPP, meilleure gestion power) |
| `amdgpu.dcdebugmask=0x610` | Contourne bugs display controller |
| `amdgpu.sg_display=0` | Désactive scatter-gather display (instabilité) |
| `amdgpu.dcfeaturemask=0x8` | Désactive certaines features DC problématiques |
| `amdgpu.abmlevel=0` | Désactive Adaptive Backlight Management |

#### Blacklist module

| Paramètre | Rôle |
|-----------|------|
| `module_blacklist=ucsi_acpi` | Contourne bug UCSI causant des erreurs ACPI et empêchant les états C profonds |

## Règles udev

**Fichier** : `/etc/udev/rules.d/60-io-schedulers.rules`

```udev
# HDD : BFQ (optimisé latence rotating)
ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"

# SSD SATA/eMMC : ADIOS
ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="adios"

# NVMe : ADIOS
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="adios"
```

ADIOS est le scheduler I/O par défaut de CachyOS, optimisé pour SSD/NVMe avec faible overhead.

## Modprobe

### `amdgpu-tuxedo-fix.conf`

Contient probablement des options spécifiques pour contourner des problèmes avec le BIOS Tuxedo/XMG.

### `no-ucsi.conf`

```
blacklist ucsi_acpi
```

Redondant avec `module_blacklist` kernel mais assure le blacklist même si cmdline modifiée.

## Configuration KDE

### Entrée (souris/touchpad)

| Paramètre | Valeur | Effet |
|-----------|--------|-------|
| `AccelerationProfile` | Flat | Accélération linéaire (1:1) |
| `PointerAcceleration` | 0 | Pas de modificateur de vitesse |
| `VirtualDesktop3FingerGesture` | true | Changement bureau avec 3 doigts |

## Problèmes connus

### Consommation idle élevée (~10W au lieu de ~5W)

**Causes identifiées** :
- Bug BIOS empêchant certains états PC6/C6
- Périphériques PCIe ne passant pas en ASPM L1.2
- Tokens LUKS-TPM corrompus causant des retries

**Diagnostic** :
```bash
sudo powertop
cat /sys/kernel/debug/pmc_core/package_cstate_show
```

## Historique

| Date | Modification |
|------|--------------|
| 2025-01-28 | Ajout `amdgpu-tuxedo-fix.conf` |
| 2025-01-29 | Création `tuned.conf` (vide) |
| 2025-01-30 | Blacklist `ucsi_acpi` (kernel + modprobe) |

## Références

- [XMG EVO 14 sur ArchWiki](https://wiki.archlinux.org/title/Laptop/Schenker)
- [AMD GPU kernel parameters](https://docs.kernel.org/gpu/amdgpu/module-parameters.html)
- [CachyOS optimizations](https://cachyos.org/)
