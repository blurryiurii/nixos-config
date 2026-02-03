{ config, pkgs, ... }:

{
  # Program settings
  programs = {
    bash = {
      enable = true;
      shellAliases = {
        p1 = "ping 1.1.1.1";
        ll = "ls -l";
        nr = "sudo nixos-rebuild switch --flake ~/nixos-config#book2";
        conf = "nano ~/nixos-config/configuration.nix";
      };
    };
    firefox = {
      enable = true;
      policies.DisableTelemetry = true;
      profiles.default = {
        isDefault = true;

        settings = {
          "accessibility.typeaheadfind" = true;
          "accessibility.typeaheadfind.flashBar" = 0;
          "app.normandy.first_run" = false;
          "app.shield.optoutstudies.enabled" = false;

          "browser.bookmarks.addedImportButton" = false;
          "browser.bookmarks.restore_default_bookmarks" = false;
          "browser.bookmarks.showMobileBookmarks" = false;
          "browser.contentblocking.category" = "strict";
          "browser.download.useDownloadDir" = false;

          "browser.newtab.privateAllowed" = false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.feeds.topsites" = false;
          "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = false;
          "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = false;
          "browser.newtabpage.activity-stream.showSearch" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.activity-stream.showWeather" = false;
          "browser.newtabpage.pinned" = "[null,{\"url\":\"https://google.com\",\"label\":\"@google\",\"searchTopSite\":true}]";
          "browser.uiCustomization.state" = builtins.toJSON {
            placements = {
              "widget-overflow-fixed-list" = [];
              "unified-extensions-area" = [
                "sponsorblocker_ajay_app-browser-action"
                "jid1-mnnxcxisbpnsxq_jetpack-browser-action"
                "ublock0_raymondhill_net-browser-action"
                "addon_darkreader_org-browser-action"
                "_88ebde3a-4581-4c6b-8019-2a05a9e3e938_-browser-action"
                "plasma-browser-integration_kde_org-browser-action"
                "_a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7_-browser-action"
              ];
              "nav-bar" = [
                "back-button"
                "forward-button"
                "stop-reload-button"
                "customizableui-special-spring1"
                "urlbar-container"
                "customizableui-special-spring2"
                "downloads-button"
                "unified-extensions-button"
                "fxa-toolbar-menu-button"
                "reset-pbm-toolbar-button"
              ];
              "toolbar-menubar" = [ "menubar-items" ];
              "TabsToolbar" = [ "tabbrowser-tabs" ];
              "vertical-tabs" = [];
              "PersonalToolbar" = [ "import-button" "personal-bookmarks" ];
            };

            "seen" = [
              "addon_darkreader_org-browser-action"
              "jid1-mnnxcxisbpnsxq_jetpack-browser-action"
              "ublock0_raymondhill_net-browser-action"
              "_88ebde3a-4581-4c6b-8019-2a05a9e3e938_-browser-action"
              "plasma-browser-integration_kde_org-browser-action"
              "sponsorblocker_ajay_app-browser-action"
              "_a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7_-browser-action"
              "developer-button"
              "screenshot-button"
            ];

            "dirtyAreaCache" = [
              "unified-extensions-area"
              "nav-bar"
              "toolbar-menubar"
              "TabsToolbar"
              "vertical-tabs"
              "PersonalToolbar"
            ];

            "currentVersion" = 23;
            "newElementCount" = 3;
          };
        };
      };
    };
    git = {
      enable = true;
      settings = {
        user.name = "Iurii Chmykhun";
        user.email = "ichmykhun@gmail.com";

        init.defaultBranch = "main";
        pull.rebase = true;
        
        commit.gpgsign = true;
        user.signingkey = "C417F5D214098F1E";

        alias = {
          c = "commit";
          s = "status";
          p = "pull";
        };
      };
    };
  };

  home.packages = with pkgs; [

  ];

  home.file = {
    # KDE dotfiles deployment
    ".config/kdeglobals".source = ./dotfiles/kdeglobals;
    ".config/plasmarc".source = ./dotfiles/plasmarc;
    ".config/plasmashellrc".source = ./dotfiles/plasmashellrc;
    ".config/plasma-localerc".source = ./dotfiles/plasma-localerc;
    ".config/plasmanotifyrc".source = ./dotfiles/plasmanotifyrc;
    ".config/systemsettingsrc".source = ./dotfiles/systemsettingsrc;

    # KWin/session
    ".config/kwinrc".source = ./dotfiles/kwinrc;
    ".config/kscreenlockerrc".source = ./dotfiles/kscreenlockerrc;
    ".config/ksmserverrc".source = ./dotfiles/ksmserverrc;
    ".config/ksplashrc".source = ./dotfiles/ksplashrc;

    # Input + shortcuts
    ".config/kcminputrc".source = ./dotfiles/kcminputrc;
    ".config/kglobalshortcutsrc".source = ./dotfiles/kglobalshortcutsrc;

    # Power
    ".config/powerdevilrc".source = ./dotfiles/powerdevilrc;

    # KDE apps
    ".config/dolphinrc".source = ./dotfiles/dolphinrc;
    ".config/konsolerc".source = ./dotfiles/konsolerc;
    ".config/konsolesshconfig".source = ./dotfiles/konsolesshconfig;
    ".config/okularrc".source = ./dotfiles/okularrc;
    ".config/okularpartrc".source = ./dotfiles/okularpartrc;
    ".config/partitionmanagerrc".source = ./dotfiles/partitionmanagerrc;
    ".config/krunnerrc".source = ./dotfiles/krunnerrc;

    # Appearance
    ".config/breezerc".source = ./dotfiles/breezerc;
  
    # General rc
    ".config/user-dirs.dirs".source = ./dotfiles/user-dirs.dirs;
    ".nanorc".source = ./dotfiles/nanorc;

  };

  home.sessionVariables = {
    EDITOR = "nano";
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
  };

  programs.home-manager.enable = true;

  home.stateVersion = "25.11";
}
