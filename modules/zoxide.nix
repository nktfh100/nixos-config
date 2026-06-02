{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ zoxide ];

  home-manager.users.nktfh100.programs.bash.bashrcExtra = ''
    export _ZO_DOCTOR=0
    eval "$(zoxide init --cmd cd bash)"
  '';

}
