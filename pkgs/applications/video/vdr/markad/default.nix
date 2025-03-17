{
  lib,
  stdenv,
  vdr,
  fetchFromGitHub,
  ffmpeg,
}:
stdenv.mkDerivation rec {
  pname = "vdr-markad";
  version = "4.2.10";

  src = fetchFromGitHub {
    repo = "vdr-plugin-markad";
    owner = "kfb77";
    hash = "sha256-qnE/0gnuY982qYz3ouUKFPURNkxM0XKWqf3w5ZwczV0=";
    rev = "V${version}";
  };

  buildInputs = [
    vdr
    ffmpeg
  ];

  postPatch = ''
    substituteInPlace command/Makefile --replace '/usr' ""

    substituteInPlace plugin/markad.cpp \
      --replace "/usr/bin" "$out/bin" \
      --replace "/var/lib/markad" "$out/var/lib/markad"

    substituteInPlace command/markad-standalone.cpp \
      --replace "/var/lib/markad" "$out/var/lib/markad"
  '';

  buildFlags = [
    "DESTDIR=$(out)"
    "VDRDIR=${vdr.dev}/lib/pkgconfig"
  ];

  installFlags = buildFlags;

  meta = {
    inherit (src.meta) homepage;
    description = "Plugin for VDR that marks advertisements";
    mainProgram = "markad";
    maintainers = [ lib.maintainers.ck3d ];
    inherit (vdr.meta) platforms license;
  };
}
