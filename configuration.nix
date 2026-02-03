# Run `nixos-help` to access the NixOS manual or see configuration.nix(5).

# For lanzaboote secure boot
#>sudo nix registry add github nix-community/lanzaboote

{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # System Packages
  environment.systemPackages = with pkgs; [
    alsa-tools
    bluez
    cowsay
    cmatrix
    dotnetCorePackages.sdk_9_0_1xx-bin
    fastfetch
    file
    firefox
    flatpak
    fprintd
    gcc
    git
    gnupg
    hollywood
    htop
    imagemagick
    kdePackages.filelight
    killall
    libreoffice
    lm_sensors
    papirus-icon-theme
    pinentry-qt  # for gnupg
    pciutils  # lspci
    powertop
    prismlauncher
    python3
    rnote
    signal-desktop
    sl
    syncthing
    tailscale
    tree
    thunderbird
    unzip
    usbutils  # lsusb
    vscode
    wget
    xournalpp
    zip
  ];

  # program config
  programs = {
    gnupg.agent = {
      enable = true;
    };
  };

  # System services
  services = {
    displayManager = {
      autoLogin.enable = true;
      autoLogin.user = "iurii";
      sddm.enable = true;           # SDDM Login Manager
      sddm.wayland.enable = true;   # Hopefully fix slow sign-in
    };
    desktopManager.plasma6.enable = true;  # KDE Plasma
    flatpak.remotes = [{
      name = "flathub-beta";
      location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
    }];
    fprintd.enable = true;                 # Fingerprint auth
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;  # "JACK" applications.
    };
    printing.enable = true;                # CUPS printing service
    pulseaudio.enable = false;             # PulseAudio (disabled - PipeWire used)
    resolved.enable = true;
    syncthing = {
      enable = true;
      group = "users";
      user = "iurii";
      dataDir = "/home/iurii/.config/syncthing";
      configDir = "/home/iurii/.config/syncthing";

      guiAddress = "127.0.0.1:8384";
      openDefaultPorts = true;

      overrideDevices = true;
      overrideFolders = true;

      # extraFlags = [ "--no-default-folder" ];

      settings = {
        gui = {
          user = "iurii";
          password = "iurii";
        };
        devices = {
          "okden" = {
            id = "PNPGXFS-Y2H4VVU-RADD3PJ-FMVVPKG-WDVUP5N-ZSPG4YV-DF3ATYV-LFH2FQC";
            address = "tcp://okden:22000";
          };
      	 "9a" = {
            id = "ERYSEQI-A33KBCP-NTAFW6W-ZMJFPAF-RZXDXC7-GKTVBV4-3HMDYU2-TB52VAC";
            addresss = "tcp://9a:22000";
          };
        };
        folders = {
          "DCIM" = {
            id = "sm-g996u1_hqgp-photos";
            path = "/home/iurii/Pictures";
            devices = [ "okden" "9a" ];
            versioning.type = "trashcan";
          };
          "Documents" = {
            id = "yj2ep-3vnx7";
            path = "/home/iurii/Documents";
            devices = [ "okden" "9a" ];
            versioning.type = "simple";
          };
        };
      };
    };
    tailscale = {  # must run sudo tailscale up initially
      enable = true;
      extraDaemonFlags = [ "--no-logs-no-support" ];
    };
  };

  systemd.services = {
    bluetooth = {
      description = "Bluetooth Daemon";
      wants = [ "dbus.service" ];
      after = [ "dbus.service" ];

      serviceConfig = {
        ExecStart = "/run/current-system/sw/bin/bluetoothd";
        Type = "simple";
        Restart = "always";
      };
      wantedBy = [ "multi-user.target" ];
    };
    tailscale-autoconnect = {
      description = "Automatic connection to Tailscale";
      # make sure tailscale is running before trying to connect to tailscale
      after = [ "network-pre.target" "tailscale.service" ];
      wants = [ "network-pre.target" "tailscale.service" ];
      # wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = with pkgs; ''
        # wait for tailscaled to settle
        sleep 2
        # check if we are already authenticated to tailscale
        status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
        if [ $status = "Running" ]; then # if so, then do nothing
          exit 0
        fi
      '';
    };
    book2audiofix = {
      description = "Enable the audio amp to turn on speakers on GalaxyBook 2 Pro 360";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig.User = "root";
      serviceConfig.Group = "root";
      serviceConfig.ExecStart = "/home/iurii/Documents/Recovery/necessary-verbs.sh";
      serviceConfig.Type = "simple";
    };
    syncthing-init.wantedBy = [ ];
  };
  
  # Speaking of PipeWire, enable realtime CPU priority for smoother audio
  security.rtkit.enable = true;

  # Automatic updating
  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
  };

  # Automatic cleanup & experimental packages
  nix = {
    gc.automatic = true;
    gc.dates = "daily";
    gc.options = "--delete-older-than 10d";
    settings.auto-optimise-store = true;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  # Boot & Kernel
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  systemd.network.wait-online.enable = false;   # don't wait to be online to boot
  systemd.services.NetworkManager-wait-online.enable = false; # """"
  boot.initrd.systemd.network.wait-online.enable = false;  # """"
  boot.initrd.network.enable = false;
  #boot.initrd.kernelModules = [
  #  "nvme"
  #  "xhci_pci"
  #  "usbhid"
  #  "hid_generic"
  #  "i915"
  #];
  # boot.initrd.includeDefaultModules = false;
  boot.kernelParams = [ "fsck.mode=skip" ];

  # Networking
  networking.hostName = "book2";
  networking.networkmanager.enable = true;
  networking.firewall = {
    # enable the firewall
    enable = true;

    # always allow traffic from your Tailscale network
    trustedInterfaces = [ "tailscale0" ];

    # allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [ config.services.tailscale.port ];

    # let you SSH in over the public internet
    allowedTCPPorts = [ 22 ];
  };

  # Hardware conf extras
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  environment.variables = {
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
  };

  # Time & Locale
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Fonts
  fonts.packages = with pkgs; [
    jetbrains-mono
  ];

  # User setup
  users.users.iurii = {
    isNormalUser = true;
    description = "Iurii Chmykhun";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      # ...
    ];
  };

  system.stateVersion = "25.11";
}
