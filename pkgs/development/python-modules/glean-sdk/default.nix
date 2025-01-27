{
  stdenv,
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  glean-parser,
  pytest-localserver,
  pytestCheckHook,
  rustPlatform,
  semver,
  setuptools,
}:

buildPythonPackage rec {
  pname = "glean-sdk";
  version = "63.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mozilla";
    repo = "glean";
    rev = "v${version}";
    hash = "sha256-egn6RYQHY173fvTCTYrTJltn923UowCjBZg1DI+iHSk=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-eLjPoSn0WqYGrMPqzVh/pzZvh3Ul+aZSYvuJspVM1cU=";
  };

  build-system = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    setuptools
  ];

  dependencies = [
    glean-parser
    semver
  ];

  nativeCheckInputs = [
    pytest-localserver
    pytestCheckHook
  ];

  pytestFlagsArray = [ "glean-core/python/tests" ];

  disabledTests = [
    # RuntimeError: No ping received.
    "test_client_activity_api"
    "test_flipping_upload_enabled_respects_order_of_events"
    # A warning causes this test to fail
    "test_get_language_tag_reports_the_tag_for_the_default_locale"
  ];

  pythonImportsCheck = [ "glean" ];

  meta = {
    broken = stdenv.hostPlatform.isDarwin;
    description = "Telemetry client libraries and are a part of the Glean project";
    homepage = "https://mozilla.github.io/glean/book/index.html";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ melling ];
  };
}
