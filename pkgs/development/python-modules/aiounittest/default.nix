{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  pytestCheckHook,
  wrapt,
}:

buildPythonPackage rec {
  pname = "aiounittest";
  version = "1.4.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kwarunek";
    repo = pname;
    tag = version;
    hash = "sha256-hcfcB2SMduTopqdRdMi63UTTD7BWc5g2opAfahWXjlw=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [ wrapt ];

  nativeCheckInputs = [ pytestCheckHook ];

  pythonImportsCheck = [ "aiounittest" ];

  meta = with lib; {
    description = "Test asyncio code more easily";
    homepage = "https://github.com/kwarunek/aiounittest";
    license = licenses.mit;
    maintainers = [ ];
  };
}
