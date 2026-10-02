{
  writers,
  python3Packages,
  google-chrome,
}:

writers.writePython3Bin "webshot" {
  libraries = [ python3Packages.playwright ];
  flakeIgnore = [ "E501" ];
} (builtins.replaceStrings [ "@chrome@" ] [ "${google-chrome}/bin/google-chrome-stable" ] (builtins.readFile ./webshot.py))
