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
}
