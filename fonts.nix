{ lib, fetchzip }:

fetchzip {
  name = "nktfh100-fonts";

  url = "https://github.com/nktfh100/nixos-config/raw/76ce60e6cb482c7dc69eb37c5206cd5da38d0474/fonts.zip";

  postFetch = ''
    mkdir -p $out/share/fonts/truetype
    unzip -P 12345678 -j $downloadedFile \*.ttf -d $out/share/fonts/truetype
  '';

  sha256 = "";

  meta = with lib; {
    homepage = "";
    description = "nktfh100 fonts";
    license = licenses.ofl;
    platforms = platforms.all;
    maintainers = with maintainers; [ nktfh100 ];
  };
}