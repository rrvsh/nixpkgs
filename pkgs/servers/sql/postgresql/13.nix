import ./generic.nix {
  version = "13.20";
  # "Stamp 13.20"
  rev = "c8f198c3acb59ed858b5b9b88b4fbc55cece544e";
  hash = "sha256-GkDtzqwjMJipvr0wykM9Z5Tb0R7WgJA/PGPTVUXxf7Q=";
  muslPatches = {
    disable-test-collate-icu-utf8 = {
      url = "https://git.alpinelinux.org/aports/plain/main/postgresql13/disable-test-collate.icu.utf8.patch?id=69faa146ec9fff3b981511068f17f9e629d4688b";
      hash = "sha256-jS/qxezaiaKhkWeMCXwpz1SDJwUWn9tzN0uKaZ3Ph2Y=";
    };
    dont-use-locale-a = {
      url = "https://git.alpinelinux.org/aports/plain/main/postgresql13/dont-use-locale-a-on-musl.patch?id=69faa146ec9fff3b981511068f17f9e629d4688b";
      hash = "sha256-fk+y/SvyA4Tt8OIvDl7rje5dLs3Zw+Ln1oddyYzerOo=";
    };
  };
}
