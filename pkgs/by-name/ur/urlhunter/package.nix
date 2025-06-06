{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:

buildGoModule rec {
  pname = "urlhunter";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "utkusen";
    repo = "urlhunter";
    rev = "v${version}";
    sha256 = "sha256-QRQLN8NFIIvlK+sHNj0MMs7tlBODMKHdWJFh/LwnysI=";
  };

  vendorHash = "sha256-tlFCovCzqgaLcxcGmWXLYUjaAvFG0o11ei8uMzWJs6Q=";

  meta = with lib; {
    description = "Recon tool that allows searching shortened URLs";
    mainProgram = "urlhunter";
    longDescription = ''
      urlhunter is a recon tool that allows searching on URLs that are
      exposed via shortener services such as bit.ly and goo.gl.
    '';
    homepage = "https://github.com/utkusen/urlhunter";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ fab ];
  };
}
