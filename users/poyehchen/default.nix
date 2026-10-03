{
  config,
  lib,
  pkgs,
  inputs,
  dotfiles,
  ...
}:
let
  gpgKey = "0A507FC2325D77EA";
  gpgFingerprint = "225E808C4DFA1DFA3CF686570A507FC2325D77EA";
in
{
  imports = [
    ./shell.nix
    ./theming.nix
  ];

  # Out-of-store root for stowed dotfiles: edits in the repo apply without a rebuild.
  _module.args.dotfiles = "${config.hjem.users.poyehchen.directory}/nix-config/dotfiles";

  users.users.poyehchen = {
    isNormalUser = true;
    uid = 1000;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
      "i2c"
      "tss"
    ];
  };

  hjem.users.poyehchen = {
    packages = with pkgs; [
      neovim
      git
      kitty
      brave-origin
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

      # Dev
      gdb
      gef
      clang
      (lib.hiPrio gcc)
      cmake
      mold
      lshw
      uv
      go
      bun

      # Archives
      unrar
      unzip
      zip
      unar

      # CLI
      ripgrep
      fd
      bat
      dua
      eza
      ffmpeg
      btop-rocm
      imv
      imagemagick
      jq
      yq-go
      just
      nmap
      nmon
      geoip
      geolite-legacy
      lxqt.pavucontrol-qt
      tree-sitter
      nodejs
      asdf-vm
      proton-vpn
      proton-vpn-cli
    ];

    files = {
      ".editorconfig".source = "${dotfiles}/editorconfig";

      # gpg refuses a group/world-readable homedir.
      ".gnupg" = {
        type = "directory";
        permissions = "700";
      };
      ".gnupg/gpg.conf".text = ''
        armor
        cert-digest-algo SHA512
        charset utf-8
        default-preference-list SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed
        fixed-list-mode
        keyid-format 0xlong
        list-options show-uid-validity
        no-comments
        no-emit-version
        no-greeting
        no-symkey-cache
        personal-cipher-preferences AES256 AES192 AES
        personal-compress-preferences ZLIB BZIP2 ZIP Uncompressed
        personal-digest-preferences SHA512 SHA384 SHA256
        require-cross-certification
        s2k-cipher-algo AES256
        s2k-digest-algo SHA512
        throw-keyids
        use-agent
        verify-options show-uid-validity
        with-fingerprint
      '';
    };

    xdg.config.files."git/config" = {
      generator = lib.generators.toGitINI;
      value = {
        user = {
          name = "Po-Yeh Chen";
          email = "snlk374@gmail.com";
          signingKey = gpgKey;
        };
        tag.gpgSign = true;
        init.defaultBranch = "main";
      };
    };

    # Import the public key and mark it ultimately trusted; both steps are idempotent.
    systemd.services.gpg-import-keys = {
      description = "Import GnuPG public keys";
      wantedBy = [ "default.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        ${lib.getExe pkgs.gnupg} --batch --import ${../../keys/0x0A507FC2325D77EA.asc}
        echo "${gpgFingerprint}:6:" | ${lib.getExe pkgs.gnupg} --batch --import-ownertrust
      '';
    };
  };
}
