{ lib, fetchFromGitHub }:

fetchFromGitHub {
  name = "nktfh100-fonts";

  owner = "nktfh100";
  repo = "nixos-config";
  rev = "65ea7a9003378fcd30adc4aaa62cc08cb321c143";

  postFetch = ''
    mkdir -p $out/share/fonts/truetype
    unzip -P 12345678 -j $out/pkgs/fonts/fonts.zip \*.ttf -d $out/share/fonts/truetype
  '';

  sha256 = "sha256-A8Vb1y9GyhJjbf+t0Cp0upramg6MiHNQX+XSs7/YMtk=";

  meta = with lib; {
    homepage = "";
    description = "nktfh100 fonts";
    license = licenses.ofl;
    platforms = platforms.all;
    maintainers = with maintainers; [ nktfh100 ];
  };
}
