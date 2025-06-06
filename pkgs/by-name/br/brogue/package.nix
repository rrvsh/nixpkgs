{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  SDL,
  ncurses,
  libtcod,
  makeDesktopItem,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "brogue";
  version = "1.7.5";

  src = fetchurl {
    url = "https://drive.google.com/uc?export=download&id=1ED_2nPubP-P0e_PHKYVzZF42M1Y9pUb4";
    hash = "sha256-p0/xgTlWTFl9BHz7Fn90qxlj3YYItvsuA052NdYXBEQ=";
    name = "brogue.tbz2";
  };

  patches = [
    # Pull upstream fix for -fno-common toolchains:
    #  https://github.com/tmewett/BrogueCE/pull/63
    (fetchpatch {
      name = "fno-common.patch";
      url = "https://github.com/tmewett/BrogueCE/commit/2c7ed0c48d9efd06bf0a2589ba967c0a22a8fa87.patch";
      sha256 = "19lr2fa25dh79klm4f4kqyyqq7w5xmw9z0fvylkcckqvcv7dwhp3";
    })
    # error: passing argument 4 of 'buildAMachine' makes integer from pointer without a cast []
    ./fix-compilation.diff
  ];

  prePatch = ''
    sed -i Makefile -e 's,LIBTCODDIR=.*,LIBTCODDIR=${libtcod},g' \
                    -e 's,sdl-config,${lib.getDev SDL}/bin/sdl-config,g'
    sed -i src/platform/tcod-platform.c -e "s,fonts/font,$out/share/brogue/fonts/font,g"
    make clean
    rm -rf src/libtcod*
  '';

  buildInputs = [
    SDL
    ncurses
    libtcod
  ];

  desktopItem = makeDesktopItem {
    name = "brogue";
    desktopName = "Brogue";
    genericName = "Roguelike";
    comment = "Brave the Dungeons of Doom!";
    icon = "brogue";
    exec = "brogue";
    categories = [
      "Game"
      "AdventureGame"
    ];
  };

  installPhase = ''
    install -m 555 -D bin/brogue $out/bin/brogue
    install -m 444 -D ${finalAttrs.desktopItem}/share/applications/brogue.desktop $out/share/applications/brogue.desktop
    install -m 444 -D bin/brogue-icon.png $out/share/icons/hicolor/256x256/apps/brogue.png
    mkdir -p $out/share/brogue
    cp -r bin/fonts $out/share/brogue/
  '';

  # fix crash; shouldn’t be a security risk because it’s an offline game
  hardeningDisable = [
    "stackprotector"
    "fortify"
  ];

  meta = with lib; {
    description = "Roguelike game";
    mainProgram = "brogue";
    homepage = "https://sites.google.com/site/broguegame/";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [
      fgaz
    ];
    platforms = [ "x86_64-linux" ];
  };
})
