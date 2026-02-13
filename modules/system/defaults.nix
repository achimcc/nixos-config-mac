{ ... }:

{
  system.defaults.NSGlobalDomain = {
    # Tastatur
    KeyRepeat = 2;
    InitialKeyRepeat = 15;
    ApplePressAndHoldEnabled = false;

    # UI/UX
    AppleShowAllExtensions = true;
    AppleInterfaceStyle = "Dark";  # Dark Mode
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;

    # Scrolling
    "com.apple.swipescrolldirection" = true;  # Natural scrolling
  };

  system.defaults.screencapture = {
    location = "~/Pictures/Screenshots";
    type = "png";
    disable-shadow = false;
  };

  system.defaults.CustomUserPreferences = {
    "com.apple.finder" = {
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = true;
      ShowRemovableMediaOnDesktop = true;
    };

    "org.p0deje.Maccy" = {
      # Tastenkombination: Command+Shift+V für Popup
      KeyboardShortcuts_popup = "{\"carbonModifiers\":768,\"carbonKeyCode\":9}";
      # Paste direkt beim Auswählen aus dem Verlauf (0 = nur kopieren, 1 = direkt einfügen)
      pasteByDefault = 1;
      # Such-, Titel- und Footer-Ansicht aktiviert
      showSearch = 1;
      showTitle = 1;
      showFooter = 1;
      # Fenstergröße
      windowSize = "[450,800]";
      # Automatische Updates deaktivieren (wird durch Homebrew verwaltet)
      SUEnableAutomaticChecks = 0;
    };
  };
}
