{ lib, fetchFromGitHub }:

fetchFromGitHub {
  name = "nktfh100-fonts";

  owner = "nktfh100";
  repo = "nixos-config";
  rev = "76d000b607b61852c11fc08d292fc737b66b5d4f";

  postFetch = ''
    mkdir -p $out/share/fonts/truetype
    unzip -P 12345678 -j $out/fonts.zip \*.ttf -d $out/share/fonts/truetype
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
