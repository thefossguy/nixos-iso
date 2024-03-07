{ lib, pkgs, config, home-manager, ... }:

let
  NixOSMajor = builtins.elemAt (lib.versions.splitVersion lib.version) 0;
  NixOSMinor = builtins.elemAt (lib.versions.splitVersion lib.version) 1;
  NixOSRelease = "${NixOSMajor}.${NixOSMinor}";
in

{
  imports = [ home-manager.nixosModules.default ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    # since the latest kernel package is installed, there will be a ZFS conflict because
    # 1. ZFS is developed out of tree and needs to catch up to the latest release
    # 2. NixOS has ZFS enabled as a default
    # so force a list of filesystems which I use; sans-ZFS
    supportedFilesystems = lib.mkForce [
      "ext4"
      "f2fs"
      "vfat"
      "xfs"
    ];
  };

  time = {
    timeZone = "Asia/Kolkata";
    hardwareClockInLocalTime = true;
  };

  nixpkgs.config.allowUnfree = true; # allow non-FOSS pkgs
  environment.systemPackages = with pkgs; [
    # base system packages + packages what I *need*
    cloud-utils # provides growpart
    dig # provides dig and nslookup
    dmidecode
    file
    findutils
    gawk
    gettext # for translation (human lang; Eng <-> Hindi)
    gnugrep
    gnused
    hdparm
    inotify-tools
    iproute2
    iputils
    lsof
    minisign
    nvme-cli
    parallel
    pciutils # provides lspci and setpci
    pinentry # pkg summary: GnuPG’s interface to passphrase input
    procps # provides pgrep, kill, watch, ps, pidof, uptime, sysctl, free, etc
    psmisc # provides killall, fuser, pslog, pstree, etc
    pv
    python3Minimal
    rsync
    smartmontools
    tree
    usbutils
    util-linux # provides blkid, losetup, lsblk, rfkill, fallocate, dmesg, etc
    vim # it is a necessity
    wol

    # shells
    dash

    # download clients
    curl
    wget

    # compression and decompression
    bzip2
    gnutar
    gzip
    unzip
    xz
    zip
    zstd

    # programming tools + compilers
    #cargo-deb # generate .deb packages solely based on Cargo.toml
    #cargo-ndk # extension for building Android NDK projects
    #binutils # provides readelf, objdump, strip, as, objcopy (GNU; not LLVM)
    #gdb
    b4 # applying patches from mailing lists
    cargo-audit # audit crates for security vulnerabilities
    cargo-benchcmp # compare Rust micro-benchmarks
    cargo-binstall # install Rust binaries instead of building them from src
    cargo-bisect-rustc # find exactly which rustc commit/release-version which prevents your code from building now
    cargo-bloat # find what takes the most space in the executable
    cargo-cache # manage cargo cache (${CARGO_HOME}); print and remove dirs selectively
    cargo-chef # for speeding up container builds using layer caching
    cargo-deps # build dependency graph of Rust projects
    cargo-dist # distribute on crates.io
    cargo-flamegraph # flamegraphs without Perl or pipes
    cargo-hack # build project with all the possible variations of options/flags and check which ones fail and/or succeed
    cargo-outdated # show outdated deps
    cargo-profiler # profile Rust binaries
    cargo-public-api # detect breaking API changes and semver violations
    cargo-show-asm # display ASM, LLVM-IR, MIR and WASM for the Rust src
    cargo-sweep # cleanup unused build files
    cargo-udeps # find unused dependencies
    cargo-update # update installed binaries
    cargo-valgrind
    cargo-vet # ensure that the third-party dependencies are audited by a trusted source
    cargo-watch # run cargo commands when the src changes
    rustup # provides rustfmt, cargo-clippy, rustup, cargo, rust-lldb, rust-analyzer, rustc, rust-gdb, cargo-fmt

    # power management
    acpi
    lm_sensors

    # dealing with other distro's packages
    dpkg
    rpm

    # for media consumption, manipulation and metadata info
    ffmpeg
    imagemagick
    mediainfo

    # network monitoring
    iperf # this is iperf3
    iperf2 # this is what is usually 'iperf' on other distros
    nload

    # other utilities
    asciinema
    buildah
    fzf
    parted
    picocom
    ubootTools
    ventoy

    # utilities written in Rust
    choose
    du-dust
    dua
    fd
    hyperfine
    procs
    sd
    tre-command

    # virtualisation
    qemu_kvm

    # tools specific to Nix
    nix-output-monitor
    nvd # diff between NixOS generations
  ];

  programs = {
    adb.enable = true;
    bandwhich.enable = true;
    ccache.enable = true;
    command-not-found.enable = true;
    dconf.enable = true;
    git.enable = true;
    gnupg.agent.enable = true;
    htop.enable = true;
    iotop.enable = true;
    mtr.enable = true;
    skim.fuzzyCompletion = true;
    sniffnet.enable = true;
    tmux.enable = true;
    traceroute.enable = true;
    trippy.enable = true;
    usbtop.enable = true;

    bash = {
      enableCompletion = true;
      # notifications when long-running terminal commands complete
      undistractMe = {
        enable = true;
        playSound = true;
        timeout = 300; # notify only if said command has been running for this many seconds
      };
      # aliases for the root user
      # doesn't affect 'pratham' since there is an `unalias -a` in /home/pratham/.bashrc
      shellAliases = {
        "e" = "${pkgs.vim}/bin/vim";
      };
    };

    nano = {
      enable = true;
      syntaxHighlight = true;
    };
  };

  home-manager.users.nixos = { lib, pkgs, ... }: {
    home = {
      stateVersion = "${NixOSRelease}";
      username = "nixos";
      homeDirectory = "/home/nixos";
    };

    programs = {
      aria2.enable = true;
      bat.enable = true;
      bottom.enable = true;
      broot.enable = true;
      btop.enable = true;
      ripgrep.enable = true;
      tealdeer.enable = true;
      yt-dlp.enable = true;
      zoxide.enable = true;

      direnv = {
        enable = true;
        enableBashIntegration = true;
        nix-direnv.enable = true;
      };

      neovim = {
        enable = true;
        extraPackages = with pkgs; [
          clang-tools # provides clangd
          gcc # for nvim-tree's parsers
          lldb # provides lldb-vscode
          lua-language-server
          nil # language server for Nix
          nixpkgs-fmt
          nodePackages.bash-language-server
          ruff
          shellcheck
          tree-sitter # otherwise nvim complains that the binary 'tree-sitter' is not found
        ];
      };
    };

    home.file."get-git-repos" = {
      executable = true;
      text = ''
        set -x
        while ! ping 1.1.1.1 -c 1 1>/dev/null || ! ping 8.8.8.8 -c 1 1>/dev/null; do
            sleep 1
        done

        repoURL='https://gitlab.com/thefossguy/dotfiles'
        targetDir="$HOME/.dotfiles"
        if [[ ! -d "$targetDir" ]]; then
            ${pkgs.git}/bin/git clone --bare "$repoURL" "$targetDir"
            ${pkgs.git}/bin/git --git-dir="$targetDir" --work-tree="$HOME" checkout -f
            rm -rf "$HOME/.config/nvim"
        fi

        repoURL='https://gitlab.com/thefossguy/prathams-nixos'
        targetDir="$HOME/prathams-nixos"
        if [[ ! -d "$targetDir" ]]; then
            ${pkgs.git}/bin/git clone "$repoURL" "$targetDir"
        fi
        set +x
      '';
    };
  };

  environment.variables = {
    # for 'sudo -e' || 'sudoedit'
    EDITOR = "nvim";
    VISUAL = "nvim";
    # systemd
    SYSTEMD_PAGER = "";
    SYSTEMD_EDITOR = "nvim";
    TERM = "xterm-256color";
  };

  # yes, I want docs
  documentation = {
    enable = true;
    dev.enable = true;
    doc.enable = true;
    info.enable = true;
    man = {
      enable = true;
      generateCaches = true;
    };
  };

  isoImage.squashfsCompression = "zstd -Xcompression-level 22";
}
