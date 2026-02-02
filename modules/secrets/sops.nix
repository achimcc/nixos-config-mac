{ config, ... }:

{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age.keyFile = "/Users/achim/.config/sops/age/keys.txt";

    secrets = {
      # Beispiel-Secrets - können später angepasst werden
      # aws_credentials = {
      #   path = "/Users/achim/.aws/credentials";
      # };
      # github_token = {
      #   owner = "achim";
      #   mode = "0600";
      # };
    };
  };
}
