{ lib, python3Packages, fetchFromGitHub, hidapi, libusb1 }:

let
  # hidapi-usb: required by pydualsense, not yet in nixpkgs
  hidapi-usb = python3Packages.buildPythonPackage rec {
    pname = "hidapi-usb";
    version = "0.3.2";

    src = python3Packages.fetchPypi {
      inherit version;
      pname = "hidapi_usb";
      hash = "sha256-oxp+2i+qqYd1uwiS2Dh8/PzO62iYQQXpR936MnDIFk0=";
    };

    format = "pyproject";

    buildInputs = [ hidapi libusb1 ];
    nativeBuildInputs = with python3Packages; [ cython setuptools ];
    propagatedBuildInputs = [ python3Packages.cffi ];
    doCheck = false;

    meta = {
      description = "Python bindings for hidapi";
      license = lib.licenses.gpl3Only;
    };
  };

  pydualsense = python3Packages.buildPythonPackage rec {
    pname = "pydualsense";
    version = "0.7.5";

    src = python3Packages.fetchPypi {
      inherit pname version;
      hash = "sha256-YgX8AJE4f8p7geKT3xlCD0Mlh1GcyHpBz4rEIqdwKgs=";
    };

    format = "pyproject";

    propagatedBuildInputs = [ hidapi-usb ];
    nativeBuildInputs = [ python3Packages.poetry-core ];
    doCheck = false;

    meta = {
      description = "Python library for the DualSense PS5 controller";
      homepage = "https://github.com/flok/pydualsense";
      license = lib.licenses.mit;
    };
  };

   pythonEnv = python3Packages.python.withPackages (_: [ pydualsense ]);
in python3Packages.buildPythonApplication {
  pname = "pydualsensex";
  version = "unstable-2024";

  src = fetchFromGitHub {
    owner = "scj643";
    repo = "pydualsensex";
    rev = "master";
    hash = "sha256-5c83kCf9PSXV/Oi3kxATLCQA5v4L7cGKjPfFcmKeRdM=";
  };

  format = "other";

  dontBuild = true;
  installPhase = ''
    mkdir -p $out/bin $out/lib/pydualsensex
    cp main.py $out/lib/pydualsensex/main.py
    cat > $out/bin/pydualsensex << EOF
#!/bin/sh
export LD_LIBRARY_PATH="${hidapi}/lib:${libusb1}/lib:\$LD_LIBRARY_PATH"
exec ${pythonEnv}/bin/python $out/lib/pydualsensex/main.py "\$@"
EOF
    chmod +x $out/bin/pydualsensex
  '';

  doCheck = false;

  meta = {
    description = "adaptive trigger bridge for BeamNG.drive";
    homepage = "https://github.com/scj643/pydualsensex";
    license = lib.licenses.mit;
    mainProgram = "pydualsensex";
  };
}
