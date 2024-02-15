{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ zoxide ];

  home-manager.users.nktfh100.programs.bash.bashrcExtra = ''
    eval "$(zoxide init --cmd cd bash)"
  '';

}
