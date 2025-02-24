{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  stdenv,
  darwin,
  libusb1,
  versionCheckHook,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "cyme";
  version = "1.8.5";

  src = fetchFromGitHub {
    owner = "tuna-f1sh";
    repo = "cyme";
    rev = "v${version}";
    hash = "sha256-4lnW6p7MaAZdvyXddIoB8TuEQSCmBYOwyvOA1r2ZKxk=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-eUBhMI/ff99SEU76yYvCzEvyLHtQqXgk/bHqmxPQlnc=";

  nativeBuildInputs =
    [
      pkg-config
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      darwin.DarwinTools
    ];

  buildInputs = [
    libusb1
  ];

  checkFlags =
    [
      # doctest that requires access outside sandbox
      "--skip=udev::hwdb::get"
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      # system_profiler is not available in the sandbox
      "--skip=test_run"
    ];

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/${meta.mainProgram}";
  versionCheckProgramArg = [ "--version" ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    homepage = "https://github.com/tuna-f1sh/cyme";
    changelog = "https://github.com/tuna-f1sh/cyme/releases/tag/${src.rev}";
    description = "Modern cross-platform lsusb";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ h7x4 ];
    platforms = platforms.linux ++ platforms.darwin ++ platforms.windows;
    mainProgram = "cyme";
  };
}
