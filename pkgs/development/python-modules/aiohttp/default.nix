{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  fetchpatch2,
  substituteAll,
  isPy310,
  isPyPy,

  # build-system
  cython,
  setuptools,

  # native dependencies
  llhttp,

  # dependencies
  aiohappyeyeballs,
  aiosignal,
  async-timeout,
  attrs,
  frozenlist,
  multidict,
  propcache,
  yarl,

  # optional dependencies
  aiodns,
  brotli,
  brotlicffi,

  # tests
  freezegun,
  gunicorn,
  proxy-py,
  pytest-codspeed,
  pytest-cov-stub,
  pytest-mock,
  pytest-xdist,
  pytestCheckHook,
  python-on-whales,
  re-assert,
  trustme,
}:

buildPythonPackage rec {
  pname = "aiohttp";
  version = "3.11.12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "aio-libs";
    repo = "aiohttp";
    tag = "v${version}";
    hash = "sha256-GveluMxw100ZllDF+MT4QkZVD9q7UWHwF7IBK85J/j0=";
  };

  patches = [
    (substituteAll {
      src = ./unvendor-llhttp.patch;
      llhttpDev = lib.getDev llhttp;
      llhttpLib = lib.getLib llhttp;
    })
    (fetchpatch2 {
      # https://github.com/aio-libs/aiohttp/issues/10421
      # https://github.com/aio-libs/aiohttp/pull/10423
      url = "https://github.com/aio-libs/aiohttp/commit/51daf7190e7674773c22011a4e443df8b5e66437.patch";
      hash = "sha256-fADetk2tqg92J2sSgzKVTEhbQRSYl6430dxdVZuFx5I=";
    })
  ];

  postPatch = ''
    rm -r vendor
    patchShebangs tools
    touch .git  # tools/gen.py uses .git to find the project root
  '';

  build-system = [
    cython
    setuptools
  ];

  preBuild = ''
    make cythonize
  '';

  dependencies = [
    aiohappyeyeballs
    aiosignal
    async-timeout
    attrs
    frozenlist
    multidict
    propcache
    yarl
  ] ++ optional-dependencies.speedups;

  optional-dependencies.speedups = [
    aiodns
    (if isPyPy then brotlicffi else brotli)
  ];

  nativeCheckInputs = [
    freezegun
    gunicorn
    proxy-py
    pytest-codspeed
    pytest-cov-stub
    pytest-mock
    pytest-xdist
    pytestCheckHook
    python-on-whales
    re-assert
    trustme
  ];

  disabledTests =
    [
      # Disable tests that require network access
      "test_client_session_timeout_zero"
      "test_mark_formdata_as_processed"
      "test_requote_redirect_url_default"
      # don't run benchmarks
      "test_import_time"
    ]
    # these tests fail with python310 but succeeds with 11+
    ++ lib.optionals isPy310 [
      "test_https_proxy_unsupported_tls_in_tls"
      "test_tcp_connector_raise_connector_ssl_error"
    ]
    ++ lib.optionals stdenv.hostPlatform.is32bit [ "test_cookiejar" ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      "test_addresses" # https://github.com/aio-libs/aiohttp/issues/3572, remove >= v4.0.0
      "test_close"
    ];

  __darwinAllowLocalNetworking = true;

  preCheck =
    ''
      # aiohttp in current folder shadows installed version
      rm -r aiohttp
      touch tests/data.unknown_mime_type # has to be modified after 1 Jan 1990

      export HOME=$(mktemp -d)
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      # Work around "OSError: AF_UNIX path too long"
      export TMPDIR="/tmp"
    '';

  meta = with lib; {
    changelog = "https://github.com/aio-libs/aiohttp/blob/v${version}/CHANGES.rst";
    description = "Asynchronous HTTP Client/Server for Python and asyncio";
    license = licenses.asl20;
    homepage = "https://github.com/aio-libs/aiohttp";
    maintainers = with maintainers; [ dotlambda ];
  };
}
