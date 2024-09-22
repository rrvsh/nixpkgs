{
  lib,
  clang,
  mkAppleDerivation,
  buildPackages,
  shell_cmds,
}:

mkAppleDerivation {
  releaseName = "developer_cmds";

  outputs = [
    "out"
    "man"
  ];

  xcodeHash = "sha256-4Ucyy4esmaekoVysvDTGq5/F/zH2CfU+iGmsmYykLa8=";

  postPatch = ''
    substituteInPlace rpcgen/rpc_main.c \
      --replace-fail '/usr/bin/cpp' '${lib.getBin buildPackages.clang}/bin/${buildPackages.clang.targetPrefix}cpp'
  '';

  postInstall = ''
    HOST_PATH='${lib.getBin shell_cmds}/bin' patchShebangs --host "$out/bin"
  '';

  meta = {
    description = "Developer commands for Darwin";
    license = [
      lib.licenses.bsd3
      lib.licenses.bsdOriginal
    ];
  };
}
