{ ... }:

{
  system.defaults.dock = {
    autohide = true;
    autohide-delay = 0.0;
    autohide-time-modifier = 0.2;
    orientation = "bottom";
    show-recents = false;
    tilesize = 48;
    minimize-to-application = true;
    mru-spaces = false;  # Spaces nicht automatisch neu ordnen
    persistent-apps = [
      "/System/Applications/Finder.app"
      "/Applications/Safari.app"
      "/Applications/Warp.app"
      "/Applications/Cursor.app"
      "/Applications/Slack.app"
      "/Applications/1Password.app"
    ];
  };
}
