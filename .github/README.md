<h1 align="center">Pyrite</h1>

> [!NOTE]
> **Pyrite is an experimental fork of [Bazzite](https://github.com/ublue-os/bazzite), and is not an official Bazzite project.** Pyrite publishes signed images for `pyrite-deck`, `pyrite-deck-gnome`, `pyrite-nvidia-open` and `pyrite-gnome-nvidia-open`, but no ISOs. See [Installing Pyrite](#installing-pyrite). The other download links and `rpm-ostree rebase` commands below install upstream Bazzite, and the website, documentation, and community links also belong to Bazzite.

[![build-pyrite](https://github.com/lutvzn/pyrite/actions/workflows/build.yml/badge.svg)](https://github.com/lutvzn/pyrite/actions/workflows/build.yml) [![build-pyrite-isos](https://github.com/lutvzn/pyrite/actions/workflows/build_iso.yml/badge.svg)](https://github.com/lutvzn/pyrite/actions/workflows/build_iso.yml) [![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/lutvzn/pyrite/badge)](https://scorecard.dev/viewer/?uri=github.com/lutvzn/pyrite) [![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/lutvzn/pyrite)

---

# Table of Contents
- [Table of Contents](#table-of-contents)
  - [Installing Pyrite](#installing-pyrite)
  - [About \& Features](#about--features)
    - [Desktop](#desktop)
    - [Steam Deck/Home Theater PCs (HTPCs)](#steam-deckhome-theater-pcs-htpcs)
      - [Alternative Handhelds](#alternative-handhelds)
    - [GNOME](#gnome)
    - [Features from Upstream](#features-from-upstream)
      - [Universal Blue](#universal-blue)
      - [Features from Fedora Linux (Kinoite \& Silverblue)](#features-from-fedora-linux-kinoite--silverblue)
  - [Why](#why)
  - [Showcase](#showcase)
  - [Documentation](#documentation)
  - [Verification](#verification)
  - [Secure Boot](#secure-boot)
  - [Contributor Metrics](#contributor-metrics)
  - [Star History](#star-history)
  - [Special Thanks](#special-thanks)
  - [Build Your Own](#build-your-own)
    - [How to Sign Your Images](#how-to-sign-your-images)
  - [Join The Community](#join-the-community)
---

## Installing Pyrite

Pyrite is installed by rebasing an existing Fedora Atomic or Bazzite system. Replace `pyrite-deck` with the image you want:

| Image | For |
| --- | --- |
| `pyrite-deck` | Steam Deck and HTPCs, KDE |
| `pyrite-deck-gnome` | Steam Deck and HTPCs, GNOME |
| `pyrite-nvidia-open` | Desktops with NVIDIA's open kernel modules, KDE |
| `pyrite-gnome-nvidia-open` | Desktops with NVIDIA's open kernel modules, GNOME |

The first rebase can't check signatures yet, because Pyrite's signing key is only installed by the image itself:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/lutvzn/pyrite-deck:stable
```

After rebooting, switch to the signed image so later updates are verified:

```bash
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/lutvzn/pyrite-deck:stable
```

## About & Features

[Please see the Bazzite website](https://bazzite.gg/) for a newcomer-friendly explanation of Bazzite, which Pyrite is based on. This readme will cover everything in-depth.

Pyrite is a fork of [Bazzite](https://bazzite.gg/), a custom [Fedora Atomic](https://fedoraproject.org/atomic-desktops/) image built with [cloud native](https://universal-blue.org/#cloud-native) technology that brings the best of Linux gaming to **all of your devices - including your favorite handheld**.

Pyrite is built from [ublue-os/main](https://github.com/ublue-os/main) using [Fedora](https://fedoraproject.org/) technology, which means expanded hardware support and built in drivers are included. Additionally, Pyrite adds the following features:

- Uses the [OGC kernel](https://www.github.com/OpenGamingCollective/linux)
- HDR and VRR available by default.
- Full hardware accelerated codec support for H264 decoding.
- [xone](https://github.com/medusalix/xone) driver for Xbox controllers.
- Enhanced support for steering wheels with multiple extra drivers.
- Full support for [DisplayLink](https://www.synaptics.com/products/displaylink-graphics).
- [vkBasalt](https://github.com/DadSchoorse/vkBasalt), [MangoHud](https://github.com/flightlessmango/Mangohud), and [OBS VkCapture](https://github.com/nowrep/obs-vkcapture) installed and available by default.
- [ROM Properties Page shell extension](https://github.com/GerbilSoft/rom-properties) included.
- [Distrobox](https://github.com/89luca89/distrobox) preinstalled.
- Automated `bees` service for reducing the disk space used by wine prefix contents.
- Support for HDMI CEC.
- [Input Remapper](https://github.com/sezanzeb/input-remapper) preinstalled and enabled. <sub><sup>(Available but default-disabled on the Deck variant, may be enabled with `ujust restore-input-remapper`)</sup></sub>
- [Bazzite Portal](https://github.com/ublue-os/yafti-gtk) provides an easy way to install numerous applications( and tweaks, including installing [LACT](https://github.com/ilya-zlobintsev/LACT) and IDEs over Brew. It additionally provides easy buttons to update, rebase and even reset the system image to defaults.
- [Waydroid](https://waydro.id/) preinstalled for running Android apps. Set it up with this [quick guide](https://docs.bazzite.gg/Installing_and_Managing_Software/Waydroid_Setup_Guide/).
- Manage applications using [Flatseal](https://github.com/tchx84/Flatseal), [Warehouse](https://github.com/flattool/warehouse), and [Gear Lever](https://github.com/mijorus/gearlever).
- [OpenRazer](https://openrazer.github.io) drivers built in, Select OpenRazer in Bazzite Portal or run `ujust install-openrazer` in a terminal to begin using it.
- [OpenTabletDriver](https://opentabletdriver.net/) udev rules built in, with the full software suite installable via Bazzite Portal or by running `ujust install-opentabletdriver` in a terminal.
- [Webapp Manager](https://github.com/linuxmint/webapp-manager) is available for creating applications from websites for a variety of browsers, including Firefox.

### Desktop

Common variant available as `bazzite`, suitable for desktop computers.

- Automatic updates for the OS, Flatpaks, and more - powered by [uupd](https://github.com/ublue-os/uupd).

> [!IMPORTANT]
> **Bazzite ISOs can be downloaded from the Bazzite [website](https://download.bazzite.gg), and a helpful install guide can be found [here](https://docs.bazzite.gg/General/Installation_Guide/).**

Rebase from an existing upstream Fedora Atomic to this image if you want **Open Source GPU Drivers**:
(Please note: Mesa's Open Source option for NVIDIA GPUs, NVK is still prone to errors at the time of writing, for any issues relating to NVK [please submit a report with Mesa](https://docs.mesa3d.org/bugs.html), not Ublue/Bazzite/Pyrite)

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite:stable
```

or for devices with Nvidia GPUs wanting the **NVIDIA Proprietary Drivers**:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-nvidia:stable
```

**For users with Secure Boot enabled:** Follow our [secure boot documentation](#secure-boot) prior to rebasing.

### Steam Deck/Home Theater PCs (HTPCs)
Variant designed for usage as an alternative to SteamOS on the Steam Deck, and for a console-like experience on HTPCs, available as `bazzite-deck`:

- Directly boots to Game mode matching SteamOS's behavior.
- **Automatic `bees` greatly trims the size of compatdata.**
- **Support for every language supported by upstream Fedora.**
- **Uses Wayland on the desktop with [support for Steam input](https://github.com/Supreeeme/extest).**
- Features ported versions of most SteamOS packages, including drivers, firmware updaters, and fan controllers.
- Patched Mesa for proper framerate control from Gamescope.
- Comes with patches from [SteamOS BTRFS](https://gitlab.com/popsulfr/steamos-btrfs) for full BTRFS support for the SD card by default.
- Ships with a ported copy of [SDGyroDSU](https://github.com/kmicki/SteamDeckGyroDSU), enabled by default.
- Option to install [Decky Loader](https://github.com/SteamDeckHomebrew/decky-loader), [EmuDeck](https://www.emudeck.com/), [RetroDECK](https://retrodeck.net/), and [ProtonUp-Qt](https://davidotek.github.io/protonup-qt/), among numerous other useful packages on installation.
- Custom update system allows for the OS, Flatpaks, and more to be updated directly from the Game mode UI powered by [uupd](https://github.com/ublue-os/uupd).
- Built in support for Windows dual-boot thanks to Fedora's installation of GRUB being left intact.
- Update break something? Easily roll back to the previous version of Pyrite thanks to `rpm-ostree`'s rollback functionality. You can even select previous images at boot.
- Steam and Lutris preinstalled on the image as layered packages.
- Out of the box support for [sched-ext](https://github.com/sched-ext/scx) schedulers.
- Kyber I/O scheduler to prevent I/O starvation when installing games or during background `duperemove` process.
- Applies SteamOS's kernel parameters.
- Color calibrated display profiles for matte and reflective Steam Deck screens included.
- Steam Deck hardware-specific services can be disabled by running `ujust disable-bios-updates` and `ujust disable-firmware-updates` in the terminal. These are automatically disabled on non-Deck hardware, and on Decks with DeckHD displays or 32GB RAM mods.
- More information can be found [here](https://docs.bazzite.gg/Handheld_and_HTPC_edition/Steam_Gaming_Mode/) on the Bazzite Steam Deck images.

> [!IMPORTANT]
> **Bazzite ISOs can be downloaded from the Bazzite [website](https://download.bazzite.gg), and a helpful install guide can be found [here](https://docs.bazzite.gg/General/Installation_Guide/).**

Rebase from an existing upstream Fedora Atomic to this image:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-deck:stable
```

#### Alternative Handhelds

Please refer to the Bazzite [Handheld Wiki](https://docs.bazzite.gg/Handheld_and_HTPC_edition/Handheld_Wiki/) for required setting changes and Decky Loader plugins for Steam Gaming Mode on your specific Handheld.

### GNOME

Builds with the GNOME desktop environment are available in both desktop and deck flavors. These builds come with the following additional features:

- [Variable refresh rate support and fractional scaling enabled under Wayland](https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/1154).
- Custom menu in the top bar for returning to game mode, launching Steam, and opening a number of useful utilities.
- [GSConnect](https://extensions.gnome.org/extension/1319/gsconnect/) preinstalled and ready to use.
- Numerous optional extensions pre-installed, including [important user experience fixes](https://www.youtube.com/watch?v=nbCg9_YgKgM).
- Automatic updates for the [Firefox GNOME theme](https://github.com/rafaelmardojai/firefox-gnome-theme) and [Thunderbird GNOME theme](https://github.com/rafaelmardojai/thunderbird-gnome-theme). <sup><sub>(If installed)</sub></sup>

> [!IMPORTANT]
> **Bazzite ISOs can be downloaded from the Bazzite [website](https://download.bazzite.gg), and a helpful install guide can be found [here](https://docs.bazzite.gg/General/Installation_Guide/).**

Rebase from an existing upstream Fedora Atomic to this image:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-gnome:stable
```

To rebase an existing ostree system to a Desktop Environment with the **Proprietary NVIDIA Drivers** release:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-gnome-nvidia:stable
```

To rebase an existing ostree system to the **Steam Deck/HTPC** release:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-deck-gnome:stable
```

**For users with Secure Boot enabled:** Follow our [secure boot documentation](#secure-boot) prior to rebasing.

### Features from Upstream

#### Universal Blue

- Proprietary Nvidia drivers pre-installed. <sub><sup>(Only for Nvidia images)</sup></sub>
- Flathub is enabled by default.
- [`ujust`](https://github.com/casey/just) commands for convenience.
- Multi-media codecs out of the box.
- Rollback Pyrite from any build within the last 90 days.

#### Features from Fedora Linux (Kinoite & Silverblue)

- A rock solid and stable base.
- System packages stay relatively up to date.
- Can layer Fedora packages to the image without losing them between updates.
- Security focused with [SELinux](https://github.com/SELinuxProject/selinux) preinstalled and configured out of the box.
- The ability to rebase to different Fedora Atomic images, if desired, without losing user data.
- Printing support thanks to [CUPS](https://www.cups.org/) being preinstalled.

## Why

Bazzite, the project Pyrite is forked from, started as a project to resolve some of the issues that plague SteamOS, mainly out of date packages (despite an Arch base) and the lack of a functional package manager.

Despite this project also being image-based, you are able to install any Fedora package straight from the command line. These packages will persist across updates <sub><sup>(So go ahead and install that obscure VPN software you spent an hour trying to get working in SteamOS)</sup></sub>. Additionally, Pyrite is updated multiple times a week with packages from upstream Fedora, giving you the best possible performance and latest features - all on a stable base.

Pyrite ships with the latest Linux kernel and SELinux enabled by default with full support for secure boot <sub><sup>(Run `ujust enroll-secure-boot-key` and enter the password `universalblue` if prompted to enroll our key)</sup></sub> and disk encryption, making this a sensible solution for general computing. <sup><sub>(Yes, you can print from Pyrite)</sub></sup>

Read the Bazzite [FAQ](https://docs.bazzite.gg/General/FAQ/) for details on what makes it stand out from other Linux based operating systems.

## Showcase

![KDE Vapor Theme](/repo_content/desktop1.png?raw=true "KDE Vapor Theme")
![KDE VGUI2 Theme](/repo_content/desktop2.png?raw=true "KDE VGUI2 Theme")
![Steam Gaming Mode](/repo_content/gamemode.png?raw=true "Steam Gaming Mode")
![Waydroid](/repo_content/waydroid.png?raw=true "Waydroid")
![Distrobox Terminals](/repo_content/distrobox.png?raw=true "Distrobox Terminals")
![GNOME](/repo_content/gnome1.png?raw=true "GNOME")
![GNOME](/repo_content/gnome2.png?raw=true "GNOME")

## Documentation

- [Installing and Managing Applications](https://docs.bazzite.gg/Installing_and_Managing_Software/)
- [Updates, Rollbacks, and Rebasing](https://docs.bazzite.gg/Installing_and_Managing_Software/Updates_Rollbacks_and_Rebasing/)
- [Gaming Guide](https://docs.bazzite.gg/Gaming/)

View [additional documentation](http://docs.bazzite.gg/) surrounding the project.

## Verification

These images are signed with sigstore's [cosign](https://docs.sigstore.dev/cosign/key_management/overview/). You can verify the signature by downloading the `cosign.pub` key from this repo and running the following command:

```bash
cosign verify --key cosign.pub --new-bundle-format=false ghcr.io/lutvzn/pyrite-deck
```

## Secure Boot

> [!WARNING]
> **Steam Deck Users: The Steam Deck does not come with secure boot enabled and does not ship with any keys enrolled by default. Do not enable this unless you absolutely know what you're doing.**

Secure boot is supported with our custom key. The pub key can be found in the root of this repository [here](https://github.com/ublue-os/bazzite/blob/main/secure_boot.der).
If you'd like to enroll this key prior to installation or rebase, download the key and run the following:

```bash
sudo mokutil --timeout -1
sudo mokutil --import secure_boot.der
```

For users already on a Universal Blue image, you may instead run `ujust enroll-secure-boot-key`.

If asked for a password, use `universalblue`.

## Contributor Metrics

[![Pyrite contributors](https://contrib.rocks/image?repo=lutvzn/pyrite)](https://github.com/lutvzn/pyrite/graphs/contributors)

## Star History

<a href="https://star-history.com/#lutvzn/pyrite&Date" >
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=lutvzn/pyrite&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=lutvzn/pyrite&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=lutvzn/pyrite&type=Date" loading="lazy" />
  </picture>
</a>

## Special Thanks

Pyrite builds on Bazzite, a community effort that wouldn't exist without everyone's support. Below are some of the people who've helped Bazzite along the way:

- [amelia.svg](https://bsky.app/profile/ameliasvg.bsky.social) - For creating our logo and overall branding.
- [SuperRiderTH](https://github.com/SuperRiderTH) - For creating our Steam game mode startup video.
- [evlaV](https://gitlab.com/evlaV) *(Now retired)* - For making Valve's code available and for being [this person](https://xkcd.com/2347/).
- [ChimeraOS](https://chimeraos.org/) - For gamescope-session and for valuable support along the way.
- [Jovian-NixOS](https://github.com/Jovian-Experiments) - For supporting us with technical issues and for creating a similar project. Seriously, go check it out. It's our Nix-based cousin.
- [sentry](https://copr.fedorainfracloud.org/coprs/sentry/) - For assistance with needed kernel patches and for creating the [kernel-fsync repo](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/).
- [nicknamenamenick](https://github.com/nicknamenamenick) - For being the MVP nearly single-handedly upkeeping our documentation and support literature, and countless cases of helping users.
- [Steam Deck Homebrew](https://deckbrew.xyz) - For choosing to support distributions other than SteamOS despite the extra work, and a special thanks to [PartyWumpus](https://github.com/PartyWumpus) for getting Decky Loader working with SELinux for us.
- [cyrv6737](https://github.com/cyrv6737) - For the initial inspiration and the base that became bazzite-arch.

## Build Your Own

Pyrite is built entirely via GitHub Actions. Creating your own custom version of it is as easy as forking this repository, adding a private signing key, and enabling the fork's GitHub Actions. Running the `Build Pyrite` workflow will then generate custom images for all variants of Pyrite.

If you only want to generate images for the variants of Pyrite you are using, list them in `DEFAULT_BUILD_IMAGES` in `build.py`; the build workflow builds only those. The ISO and cleanup workflows read the full `IMAGES` table in `build.py`. A few things still assume particular variants exist:

- ISOs use `pyrite` or `pyrite-gnome` as their live environment, so keep the matching variant if you build ISOs.
- `DEFAULT_IMAGE` in `build.py` must name a variant you kept.
- `.github/workflows/retag.yml`, which is for emergency use only, has its own list of all variants.

We also ship a config for the popular [pull app](https://github.com/apps/pull) if you'd like to keep your fork in sync with upstream. Enable this app on your repo to keep track of Bazzite changes while also making your own modifications.

### How to Sign Your Images

1. First, [familiarize yourself](https://docs.github.com/en/actions/security-guides/encrypted-secrets) with keeping secrets on GitHub.
2. [Generate a new key pair](https://docs.sigstore.dev/cosign/key_management/signing_with_self-managed_keys/) with Cosign (`cosign generate-key-pair`). This key pair must have no password.
3. Replace the `cosign.pub` file in your public repo with the one you generated - you and your users will need it to check the signatures.
4. Add the private key (stored as text inside the `cosign.key` file) as a Repository Secret in the fork's settings page, in the `Settings -> Secrets and variables -> Actions` menu. Name the secret `SIGNING_SECRET`.

## Join The Community

The Bazzite community can be found on the [Bazzite Discord](https://discord.gg/f8MUghG5PB). View the [archive](https://www.answeroverflow.com/c/1072614816579063828/1143023993041993769) of support threads without an account.
