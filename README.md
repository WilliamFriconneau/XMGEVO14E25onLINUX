# XMG EVO 14 (E24) - CachyOS System Configuration

Tweaks applied to optimize power consumption, stability and work around firmware/BIOS bugs.

## Hardware

| Component | Detail |
|-----------|--------|
| Model | XMG EVO 14 (E24) |
| CPU | AMD Ryzen 7 8845HS (Hawk Point) |
| GPU | AMD Radeon 780M (RDNA3 iGPU) |
| WiFi/BT | Intel AX210 |
| OS | CachyOS (Arch-based) |

## Kernel Parameters

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

### Parameters Breakdown

#### General

| Parameter | Purpose |
|-----------|---------|
| `nowatchdog` | Disables hardware watchdog, saves ~0.5W |
| `rcutree.enable_rcu_lazy=1` | RCU lazy callbacks, reduces CPU wakeups |

#### LUKS + TPM2

| Parameter | Purpose |
|-----------|---------|
| `rd.luks.options=discard,tpm2-device=auto` | Auto-unlock via TPM2 + TRIM passthrough |
| `resume_offset=1768678` | Swapfile offset for hibernation on BTRFS |

#### AMD GPU (bug workarounds)

| Parameter | Purpose |
|-----------|---------|
| `amd_pstate=active` | Active pstate driver (EPP, better power management) |
| `amdgpu.dcdebugmask=0x610` | Fixes visual artifacts/glitches in Firefox, Chrome and randomly elsewhere |
| `amdgpu.sg_display=0` | Disables scatter-gather display (causes instability) |
| `amdgpu.dcfeaturemask=0x8` | Disables problematic DC features |
| `amdgpu.abmlevel=0` | Disables Adaptive Backlight Management |

#### Module Blacklist

| Parameter | Purpose |
|-----------|---------|
| `module_blacklist=ucsi_acpi` | Works around UCSI bug causing ACPI errors and preventing deep C-states |

## Udev Rules

**File**: `/etc/udev/rules.d/60-io-schedulers.rules`

```udev
# HDD: BFQ (optimized for rotational latency)
ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"

# SATA SSD/eMMC: ADIOS
ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="adios"

# NVMe: ADIOS
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="adios"
```

ADIOS is CachyOS default I/O scheduler, optimized for SSD/NVMe with low overhead.

## Modprobe

### `amdgpu-tuxedo-fix.conf`

```
options amdgpu dcdebugmask=0x610
```

Fixes random visual artifacts (glitches) appearing mainly in Firefox and Chrome with GPU acceleration. Duplicated in kernel cmdline to ensure earliest possible application.

### `no-ucsi.conf`

```
blacklist ucsi_acpi
```

Redundant with kernel `module_blacklist` but ensures blacklisting even if cmdline is modified.

## KDE Configuration

### Input (mouse/touchpad)

| Parameter | Value | Effect |
|-----------|-------|--------|
| `AccelerationProfile` | Flat | Linear acceleration (1:1) |
| `PointerAcceleration` | 0 | No speed modifier |
| `VirtualDesktop3FingerGesture` | true | Switch desktop with 3-finger swipe |

## Known Issues

### High idle power consumption (~10W instead of ~5W)

**Identified causes**:
- BIOS bug preventing some PC6/C6 states
- PCIe devices not entering ASPM L1.2
- Corrupted LUKS-TPM tokens causing retries

**Diagnostics**:
```bash
sudo powertop
cat /sys/kernel/debug/pmc_core/package_cstate_show
```

## Changelog

| Date | Change |
|------|--------|
| 2025-01-28 | Added `amdgpu-tuxedo-fix.conf` |
| 2025-01-29 | Created `tuned.conf` (empty) |
| 2025-01-30 | Blacklisted `ucsi_acpi` (kernel + modprobe) |

## References

- [XMG EVO 14 on ArchWiki](https://wiki.archlinux.org/title/Laptop/Schenker)
- [AMD GPU kernel parameters](https://docs.kernel.org/gpu/amdgpu/module-parameters.html)
- [CachyOS optimizations](https://cachyos.org/)
