{ lib
, buildPythonPackage
, fetchFromGitHub
, pytest-asyncio
, pytest-httpserver
, pytestCheckHook
, pythonOlder
, pyyaml
, requests
, tomli
, tomli-w
, types-pyyaml
, types-toml
, typing-extensions
, urllib3
}:

buildPythonPackage rec {
  pname = "responses";
  version = "0.24.1";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  __darwinAllowLocalNetworking = true;

  src = fetchFromGitHub {
    owner = "getsentry";
    repo = pname;
    rev = "refs/tags/${version}";
    hash = "sha256-fvfEHJioyjQoEvIgZZKt9/AKtzTgo0APGUK7lDrbahs=";
  };

  propagatedBuildInputs = [
    pyyaml
    requests
    types-pyyaml
    types-toml
    urllib3
  ]  ++ lib.optionals (pythonOlder "3.8") [
    typing-extensions
  ];


  nativeCheckInputs = [
    pytest-asyncio
    pytest-httpserver
    pytestCheckHook
    tomli-w
  ] ++ lib.optionals (pythonOlder "3.11") [
    tomli
  ];

  pythonImportsCheck = [
    "responses"
  ];

  meta = with lib; {
    description = "Python module for mocking out the requests Python library";
    homepage = "https://github.com/getsentry/responses";
    changelog = "https://github.com/getsentry/responses/blob/${version}/CHANGES";
    license = licenses.asl20;
    maintainers = with maintainers; [ fab ];
  };
}
