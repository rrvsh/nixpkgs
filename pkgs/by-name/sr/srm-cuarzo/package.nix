{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, pkg-config
, libdisplay-info
, libdrm
, libGL
, libinput
, mesa
, seatd
, udev
}:
stdenv.mkDerivation (self: {
  pname = "srm-cuarzo";
  version = "0.10.0-1";
  rev = "v${self.version}";
  hash = "sha256-qkJVVoGU07wwcPsrIJi1gkl0uJaZM42kAX8PFQ68HDM=";

  src = fetchFromGitHub {
    inherit (self) rev hash;
    owner = "CuarzoSoftware";
    repo = "SRM";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libdisplay-info
    libdrm
    libGL
    libinput
    mesa
    seatd
    udev
  ];

  outputs = [ "out" "dev" ];

  preConfigure = ''
    # The root meson.build file is in src/
    cd src
  '';

  meta = {
    description = "Simple Rendering Manager";
    homepage = "https://github.com/CuarzoSoftware/SRM";
    maintainers = [ lib.maintainers.dblsaiko ];
    platforms = lib.platforms.linux;
  };
})
