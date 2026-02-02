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
  };
}
