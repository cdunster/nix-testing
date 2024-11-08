{ ... }: {
  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = "test";
  };

  # Configuration when building with build-vm
  virtualisation.vmVariant.virtualisation = {
    memorySize = 2048; # MB
    cores = 3;
    graphics = false;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  system.stateVersion = "23.05";
}
