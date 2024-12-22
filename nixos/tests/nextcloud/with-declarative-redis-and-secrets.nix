{
  name,
  pkgs,
  testBase,
  system,
  ...
}:

with import ../../lib/testing-python.nix { inherit system pkgs; };
runTest (
  { config, lib, ... }:
  let
    inherit (config) adminuser;
  in
  {
    inherit name;
    meta = with lib.maintainers; {
      maintainers = [
        eqyiel
        ma27
      ];
    };

    imports = [ testBase ];

    nodes = {
      nextcloud =
        { config, pkgs, ... }:
        {
          environment.systemPackages = [ pkgs.jq ];
          services.nextcloud = {
            caching = {
              apcu = false;
              redis = true;
              memcached = false;
            };
            notify_push = {
              enable = true;
              bendDomainToLocalhost = true;
              logLevel = "debug";
            };
            extraAppsEnable = true;
            extraApps.notify_push = config.services.nextcloud.package.packages.apps.notify_push;
            # This test also validates that we can use an "external" database
            database.createLocally = false;
            config = {
              dbtype = "pgsql";
              dbname = "nextcloud";
              dbuser = adminuser;
              dbpassFile = config.services.nextcloud.config.adminpassFile;
            };

            secretFile = "/etc/nextcloud-secrets.json";

            settings = {
              allow_local_remote_servers = true;
              redis = {
                dbindex = 0;
                timeout = 1.5;
                # password handled via secretfile below
              };
            };
            configureRedis = true;
          };

          services.redis.servers."nextcloud" = {
            enable = true;
            port = 6379;
            requirePass = "secret";
          };

          systemd.services.nextcloud-setup = {
            requires = [ "postgresql.service" ];
            after = [ "postgresql.service" ];
          };

          services.postgresql = {
            enable = true;
          };
          systemd.services.postgresql.postStart = lib.mkAfter ''
            password=$(cat ${config.services.nextcloud.config.dbpassFile})
            ${config.services.postgresql.package}/bin/psql <<EOF
              CREATE ROLE ${adminuser} WITH LOGIN PASSWORD '$password' CREATEDB;
              CREATE DATABASE nextcloud;
              ALTER DATABASE nextcloud OWNER to ${adminuser};
            EOF
          '';

          # This file is meant to contain secret options which should
          # not go into the nix store. Here it is just used to set the
          # redis password.
          environment.etc."nextcloud-secrets.json".text = ''
            {
              "redis": {
                "password": "secret"
              }
            }
          '';
        };
    };

    test-helpers.extraTests = ''
      with subtest("non-empty redis cache"):
          # redis cache should not be empty
          nextcloud.fail('test 0 -lt "$(redis-cli --pass secret --json KEYS "*" | jq "len")"')

      with subtest("notify-push"):
          client.execute("${lib.getExe pkgs.nextcloud-notify_push.passthru.test_client} http://nextcloud ${config.adminuser} ${config.adminpass} >&2 &")
          nextcloud.wait_until_succeeds("journalctl -u nextcloud-notify_push | grep -q \"Sending ping to ${config.adminuser}\"")
    '';
  }
)
