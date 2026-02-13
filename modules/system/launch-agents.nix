{ ... }:

{
  # LaunchAgents für automatischen Start von Apps beim Login
  launchd.user.agents.maccy = {
    serviceConfig = {
      ProgramArguments = [
        "/Applications/Maccy.app/Contents/MacOS/Maccy"
      ];
      RunAtLoad = true;
      KeepAlive = false;
      ProcessType = "Interactive";
    };
  };

  launchd.user.agents.hammerspoon = {
    serviceConfig = {
      ProgramArguments = [
        "/Applications/Hammerspoon.app/Contents/MacOS/Hammerspoon"
      ];
      RunAtLoad = true;
      KeepAlive = false;
      ProcessType = "Interactive";
    };
  };

  launchd.user.agents.blink1control = {
    serviceConfig = {
      ProgramArguments = [
        "/Applications/Blink1Control2.app/Contents/MacOS/Blink1Control2"
      ];
      RunAtLoad = true;
      KeepAlive = false;
      ProcessType = "Interactive";
    };
  };
}
