{
  lib,
  stdenv,
  fetchurl,

  # nativeBuildInputs
  cmake,
  desktop-file-utils,
  intltool,
  llvmPackages,
  ninja,
  perl,
  pkg-config,
  wrapGAppsHook3,

  # buildInputs
  SDL2,
  adwaita-icon-theme,
  cairo,
  curl,
  exiv2,
  glib,
  glib-networking,
  gmic,
  graphicsmagick,
  gtk3,
  icu,
  ilmbase,
  isocodes,
  jasper,
  json-glib,
  lcms2,
  lensfun,
  libaom,
  libavif,
  libexif,
  libgphoto2,
  libheif,
  libjpeg,
  libjxl,
  libpng,
  librsvg,
  libsecret,
  libsoup_2_4,
  libtiff,
  libwebp,
  libxslt,
  lua,
  openexr_3,
  openjpeg,
  osm-gps-map,
  pcre,
  portmidi,
  pugixml,
  sqlite,
  # Linux only
  colord,
  colord-gtk,
  libX11,
  ocl-icd,
  # Darwin only
  gtk-mac-integration,

  versionCheckHook,
  nix-update-script,
}:

stdenv.mkDerivation rec {
  version = "5.0.0";
  pname = "darktable";

  src = fetchurl {
    url = "https://github.com/darktable-org/darktable/releases/download/release-${version}/darktable-${version}.tar.xz";
    hash = "sha256-6qE25uYku1MScoLiaq+gRBq8wYm1U3FGXh9aikk/o6E=";
  };

  nativeBuildInputs = [
    cmake
    desktop-file-utils
    intltool
    llvmPackages.llvm
    ninja
    perl
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs =
    [
      SDL2
      adwaita-icon-theme
      cairo
      curl
      exiv2
      glib
      glib-networking
      gmic
      graphicsmagick
      gtk3
      icu
      ilmbase
      isocodes
      jasper
      json-glib
      lcms2
      lensfun
      libaom
      libavif
      libexif
      libgphoto2
      libheif
      libjpeg
      libjxl
      libpng
      librsvg
      libsecret
      libsoup_2_4
      libtiff
      libwebp
      libxslt
      lua
      openexr_3
      openjpeg
      osm-gps-map
      pcre
      portmidi
      pugixml
      sqlite
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      colord
      colord-gtk
      libX11
      ocl-icd
    ]
    ++ lib.optional stdenv.hostPlatform.isDarwin gtk-mac-integration
    ++ lib.optional stdenv.cc.isClang llvmPackages.openmp;

  cmakeFlags =
    [
      "-DBUILD_USERMANUAL=False"
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      "-DUSE_COLORD=OFF"
      "-DUSE_KWALLET=OFF"
    ];

  # darktable changed its rpath handling in commit
  # 83c70b876af6484506901e6b381304ae0d073d3c and as a result the
  # binaries can't find libdarktable.so, so change LD_LIBRARY_PATH in
  # the wrappers:
  preFixup =
    let
      libPathEnvVar = if stdenv.hostPlatform.isDarwin then "DYLD_LIBRARY_PATH" else "LD_LIBRARY_PATH";
      libPathPrefix =
        "$out/lib/darktable" + lib.optionalString stdenv.hostPlatform.isLinux ":${ocl-icd}/lib";
    in
    ''
      for f in $out/share/darktable/kernels/*.cl; do
        sed -r "s|#include \"(.*)\"|#include \"$out/share/darktable/kernels/\1\"|g" -i "$f"
      done

      gappsWrapperArgs+=(
        --prefix ${libPathEnvVar} ":" "${libPathPrefix}"
      )
    '';

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  versionCheckProgramArg = [ "--version" ];
  doInstallCheck = true;

  passthru.updateScript = nix-update-script {
    rev-prefix = "release-";
  };

  meta = {
    description = "Virtual lighttable and darkroom for photographers";
    homepage = "https://www.darktable.org";
    changelog = "https://github.com/darktable-org/darktable/releases/tag/release-${version}";
    license = lib.licenses.gpl3Plus;
    platforms = with lib.platforms; linux ++ darwin;
    maintainers = with lib.maintainers; [
      flosse
      mrVanDalo
      paperdigits
      freyacodes
    ];
  };
}
