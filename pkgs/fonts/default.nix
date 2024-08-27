{ pkgs, lib, fetchFromGitHub }:

fetchFromGitHub {
  name = "nktfh100-fonts";

  owner = "nktfh100";
  repo = "nixos-config";
  rev = "65ea7a9003378fcd30adc4aaa62cc08cb321c143";

  postFetch = ''
    mkdir -p $out/share/fonts/truetype
    unzip -P 12345678 -j $out/pkgs/fonts/fonts.zip \*.ttf -d $out/share/fonts/truetype
  '';

  sha256 = "sha256-O9GXuyQIgXSKYhvhv7/LNvlLirxBesWAnU/qJrBwwgg=";

  nativeBuildInputs = [ pkgs.unzip ];

  meta = with lib; {
    homepage = "";
    description = "nktfh100 fonts";
    license = licenses.ofl;
    platforms = platforms.all;
    maintainers = with maintainers; [ nktfh100 ];
  };
}
