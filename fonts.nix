{ lib, fetchzip }:

fetchzip {
  name = "nktfh100-fonts";

  url = "https://github.com/nktfh100/";

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