{ options-count, ... }:

{
  boot.loader.grub.minegrub-theme = {
    enable = true;
    splash = "100% Reproducible!";
    # boot-options-count = options-count;
  };
}
