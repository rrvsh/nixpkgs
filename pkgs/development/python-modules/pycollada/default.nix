{
  lib,
  fetchPypi,
  buildPythonPackage,
  numpy,
  python-dateutil,
}:

buildPythonPackage rec {
  pname = "pycollada";
  version = "0.9";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-gk9ugJ5RDWSbWYSm6o5hTOXPJwyB6rb76q8K5x3mpq8=";
  };

  propagatedBuildInputs = [
    numpy
    python-dateutil
  ];

  # Some tests fail because they refer to test data files that don't exist
  # (upstream packaging issue)
  doCheck = false;

  meta = with lib; {
    description = "Python library for reading and writing collada documents";
    homepage = "http://pycollada.github.io/";
    license = licenses.bsd3;
    platforms = with platforms; linux ++ darwin;
    maintainers = with maintainers; [ bjornfor ];
  };
}
