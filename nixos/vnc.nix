{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:
lib.mkIf specialArgs.vnc.enable {
  # Allow PulseAudio and VNC in firewall
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --source ${specialArgs.vnc.clientIp} --dport 4713 -j nixos-fw-accept
    iptables -A nixos-fw -p tcp --source ${specialArgs.vnc.clientIp} --dport 5900 -j nixos-fw-accept
  '';

  # Enable sound server
  services.pulseaudio = {
    enable = true;
    tcp = {
      enable = true;
      anonymousClients.allowedIpRanges = [ specialArgs.vnc.clientIp ];
    };
  };

  # Enable linger so wayvnc service will start
  users.users.${specialArgs.username}.linger = true;
}
