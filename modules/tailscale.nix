{ ... }:

{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraSetFlags = [ "--accept-routes" ];
  };
}
