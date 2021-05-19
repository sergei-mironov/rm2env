{ pkgs ? import <nixpkgs> {}
, stdenv ? pkgs.stdenv
}:
let
  python = pkgs.python37Packages;
  local = rec {
    callPackage = pkgs.lib.callPackageWith collection;
    collection = rec {

      inherit (python) paramiko;
      # inherit (pkgs) libevdev;

      screeninfo = python.buildPythonPackage rec {
        pname = "screeninfo";
        version = "0.6.6";
        doCheck = false; # Minotaur doesn't have tests

        propagatedBuildInputs = [ pkgs.xlibs.xrandr ];

        src = python.fetchPypi {
          inherit pname version;
          sha256 = "sha256:0vq2igzfi3din1fah18fzp7wdh089hf28s3lwm321k11jhycqgy9";
        };
      };

      libevdev = python.buildPythonPackage rec {
        pname = "libevdev";
        version = "0.9";
        # doCheck = false; # Minotaur doesn't have tests

        # nativeBuildInputs = [ pkgs.libevdev ];
        LD_LIBRARY_PATH="${pkgs.libevdev}/lib";

        src = python.fetchPypi {
          inherit pname version;
          sha256 = "sha256:17agnigmzscmdjqmrylg1lza03hwjhgxbpf4l705s6i7p7ndaqrs";
        };
      };

      setuptools-lint = python.buildPythonPackage rec {
        pname = "setuptools-lint";
        version = "0.6.0";

        src = python.fetchPypi {
          inherit pname version;
          sha256 = "16a1ac5n7k7sx15cnk03gw3fmslab3a7m74dc45rgpldgiff3577";
        };

        propagatedBuildInputs = with python; [ pylint ];
      };


      evdev = python.buildPythonPackage rec {
        pname = "evdev";
        version = "1.3.0";

        src = python.fetchPypi {
          inherit pname version;
          sha256 = "sha256:0kb3636yaw9l8xi8s184w0r0n9ic5dw3b8hx048jf9fpzss4kimi";
        };

        buildInputs = [ pkgs.linuxHeaders ];

        patchPhase = ''
          substituteInPlace setup.py --replace /usr/include/linux ${pkgs.linuxHeaders}/include/linux
        '';
        doCheck = false;
        # disabled = isPy34;  # see http://bugs.python.org/issue21121
      };

      pynput = python.buildPythonPackage rec {
        pname = "pynput";
        version = "1.7.3";
        doCheck = false; # Minotaur doesn't have tests

        propagatedBuildInputs = with python ; [ evdev xlib sphinx setuptools-lint ];

        src = python.fetchPypi {
          inherit pname version;
          sha256 = "sha256:0a7q5raypa2y6494g3f8ykwl96lbd29ijvcgwn3px146mfhb2l2f";
        };
      };

      remarkable_mouse = python.buildPythonPackage rec {
        name = "remarkable_mouse";
        version = "1.0.0";
        doCheck = false;

        propagatedBuildInputs = with python ; [ screeninfo libevdev pynput
        sphinx paramiko ];

        nativeBuildInputs = [ pkgs.libevdev ];

        src = ./3rdparty/remarkable_mouse;
      };



      mypyps = ppkgs: with ppkgs; [
        screeninfo
      ];

      mypython = pkgs.python37.withPackages mypyps;

      shell = pkgs.mkShell {
        name = "shell";
        buildInputs = [
          mypython
          remarkable_mouse
        ];
      shellHook = with pkgs; ''
        export PYTHONPATH=`pwd`/python:$PYTHONPATH
        export LD_LIBRARY_PATH=${pkgs.libevdev}/lib/:${pkgs.xorg.libX11}/lib:${pkgs.xorg.libXrandr}/lib
      '';
      };
    };
  };
in
  local.collection

