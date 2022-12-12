{ pkgs ? import <nixpkgs> {}
, stdenv ? pkgs.stdenv
}:
let
  python = pkgs.python3Packages;
  local = rec {
    callPackage = pkgs.lib.callPackageWith collection;
    collection = rec {

      inherit (python) paramiko;
      # inherit (pkgs) libevdev;

      screeninfo = python.buildPythonPackage rec {
        pname = "screeninfo";
        version = "0.6.6";
        doCheck = false; # Minotaur doesn't have tests

        propagatedBuildInputs = [ pkgs.xorg.xrandr ];

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
        sphinx paramiko tkinter ];

        nativeBuildInputs = [ pkgs.libevdev ];

        src = ./3rdparty/remarkable_mouse;
      };

      inherit (python) llfuse;

      anyio = python.buildPythonPackage rec {
        pname = "anyio";
        version = "2.2.0";
        # doCheck = false;

        propagatedBuildInputs = with python ; [ setuptools_scm sniffio idna
        typing-extensions ];

        # nativeBuildInputs = [ pkgs.libevdev ];
        src = python.fetchPypi {
          inherit pname version;
          sha256 = "sha256:1a8lxqhnzi1nkv7sylp3l878a0ckfyizpdjikm32xnaylsrwahaa";
        };

      };

      asks = python.buildPythonPackage rec {
        pname = "asks";
        version = "2.4.12";
        doCheck = false; # Requires overly

        propagatedBuildInputs = with python ; [ anyio async_generator h11 ];

        # nativeBuildInputs = [ pkgs.libevdev ];
        src = python.fetchPypi {
          inherit pname version;
          sha256 = "sha256:1c438zcbkmm2c08mqf7znpvsag83zyl5y18qm7iy9rshnd799piq";
        };
      };

      xdg = python.buildPythonPackage rec {
        pname = "xdg";
        version = "5.0.2";
        # doCheck = false; # Requires overly

        propagatedBuildInputs = with python ; [ ];

        # nativeBuildInputs = [ pkgs.libevdev ];
        src = python.fetchPypi {
          inherit pname version;
          sha256 = "sha256:0qk0hqmacfabnw9x8z4nfwk4sllr43rjhprl5y2in86n7p18b9lr";
        };
      };

      reportlab = python.reportlab.overrideDerivation (old: rec {
        pname = "reportlab";
        version = "3.5.59";
        src = python.fetchPypi {
          inherit pname version;
          sha256 = "sha256:0dj5i64yys0bij1is5f3smbj368s61q1crxv0c5i68zhvjicqmd7";
        };
        patches = [];
      });

      bidict = python.bidict.overrideDerivation (old: rec {
        pname = "bidict";
        version = "0.21.2";
        name = "${pname}-${version}";
        src = python.fetchPypi {
          inherit pname version;
          sha256 = "sha256:02dy0b1k7qlhn7ajyzkrvxhyhjj0hzcq6ws3zjml9hkdz5znz92g";
        };

        doCheck = false; # HACK due to failed tests
        doInstallCheck = false;
        propagatedBuildInputs = with python; [ setuptools_scm ];
      });

      # mytrio = python.trio;
      mytrio = python.trio.overrideDerivation (old: rec {
        pname = "trio";
        version = "0.18.0";
        name = "${pname}-${version}";
        doCheck = false; # HACK due to 2 failed tests
        doInstallCheck = false;
        checkPhase = "";
        src = python.fetchPypi {
          inherit pname version;
          sha256 = "sha256:0xm0bd1rrlb4l9q0nf2n1wg7xh42ljdnm4i4j0651zi73zk6m9l7";
        };
      });

      rmcl = python.buildPythonPackage rec {
        pname = "rmcl";
        version = "0.4.2";

        propagatedBuildInputs = with python ; [ mytrio xdg asks ];

        # patches = [
        #   ./0001-Change-Device-and-User-token-urls.patch
        # ];

        # nativeBuildInputs = [ pkgs.libxdg ];
        src = python.fetchPypi {
          inherit pname version;
          sha256 = "sha256:0ryccqgrcdmali5yn6qrzgyjl9am847sikwgyb5pmjz3wxc4gpjq";
        };

      };

      pdfrw = python.buildPythonPackage rec {
        pname = "pdfrw";
        version = "0.4";
        doCheck = false; # print from python2 ?

        propagatedBuildInputs = with python ; [ pillow ];

        # nativeBuildInputs = [ pkgs.libxdg ];
        src = python.fetchPypi {
          inherit pname version;
          sha256 = "sha256:1x1yp63lg3jxpg9igw8lh5rc51q353ifsa1bailb4qb51r54kh0d";
        };

      };

      svglib = python.buildPythonPackage rec {
        pname = "svglib";
        version = "1.1.0";
        doCheck = false; # Needs pytest-runner

        propagatedBuildInputs = with python ; [ reportlab lxml cssselect2 pillow ];

        # nativeBuildInputs = [ pkgs.libxdg ];
        src = python.fetchPypi {
          inherit pname version;
          sha256 = "sha256:0bj2illa2hxbdf11bxgwcjrh7j88bjcps3fa42yyxsz21qlya3jj";
        };

      };

      rmrl = python.buildPythonPackage rec {
        pname = "rmrl";
        version = "0.2.1";
        doCheck = false;

        propagatedBuildInputs = with python ; [ xdg svglib reportlab pdfrw
        ];

        # nativeBuildInputs = [ pkgs.libxdg ];
        src = python.fetchPypi {
          inherit pname version;
          sha256 = "sha256:1jbibchkcbq87x877h07w1w6lay13m4ccdyg2ymycl432vsbwcn5";
        };

      };

      rmfuse = python.buildPythonPackage rec {
        pname = "rmfuse";
        # version = "0.2.1";
        version = "0.2.3";
        doCheck = false;

        propagatedBuildInputs = with python ; [ llfuse rmrl rmcl bidict ];

        # nativeBuildInputs = with python; [ pytoml ];

        # src = ./3rdparty/rmfuse;
        src = python.fetchPypi {
          inherit pname version;
          sha256 = "sha256:1lkyj1a7yb8dgk1q5kfl30jvxihdh0c0785hh6czq85av3r1xxwl";
        };
      };


      rm_tools = python.buildPythonPackage rec {
        pname = "rm_tools";
        version = "1.0";
        doCheck = false;
        propagatedBuildInputs = with python ; [ pypdf2 ];

        # See https://github.com/reHackable/maxio/tree/master/tools
        src = ./3rdparty/maxio;
      };

      # rMsync = python.buildPythonApplication rec {
      #   pname = "rMsync";
      #   version = "1.0";
      #   pythonPath = with python ; [ rm_tools pikepdf ];
      #   src = ./3rdparty/rMsync;
      #   doCheck = false;
      # };

      # rmfuse = pkgs.poetry2nix.mkPoetryEnv {
      #     projectDir = ./3rdparty/rmfuse;
      # };

      mypyps = ppkgs: with ppkgs; [
        screeninfo
      ];

      mypython = pkgs.python3.withPackages mypyps;


      fraga = pkgs.stdenv.mkDerivation {
        name = "fraga-41";
        buildInputs = [ pkgs.makeWrapper ];
        buildCommand = ''
          . $stdenv/setup
          mkdir -pv $out/bin
          put() {
            cp $1 $out/bin
            chmod +x $out/bin/$(basename $1)
          }
          putbash() {
            put $1
            substituteInPlace $out/bin/$(basename $1) \
              --replace /bin/bash ${pkgs.bash}/bin/bash
          }
          put ${./3rdparty/fraga}/rm2svg.py
          putbash ${./3rdparty/fraga}/pdf2rm.sh
          putbash ${./3rdparty/fraga}/rmlist.sh
          putbash ${./3rdparty/fraga}/rmconvert.sh
          substituteInPlace $out/bin/rmconvert.sh \
            --replace "\''${software}/getpageuuids.awk" ${./3rdparty/fraga/getpageuuids.awk}
          wrapProgram $out/bin/rmconvert.sh \
            --prefix PATH : ${pkgs.lib.makeBinPath (with pkgs; [
                python3 inkscape xpdf pdftk ghostscript poppler_utils])}
        '';
      };

      shell = pkgs.mkShell {
        name = "shell";
        buildInputs = [
          mypython
          remarkable_mouse
          # rmfuse # Doesn't work due to both API changes and dep problems
          pkgs.github-cli
          # rm_tools
          python.pikepdf
          fraga
        ];
      shellHook = with pkgs; ''
        export PATH=`pwd`/3rdparty/remarkable-cli-tooling:`pwd`/3rdparty/rMsync:$PATH
        export PYTHONPATH=`pwd`/python:$PYTHONPATH
        export LD_LIBRARY_PATH=${pkgs.libevdev}/lib/:${pkgs.xorg.libX11}/lib:${pkgs.xorg.libXrandr}/lib
      '';
      };
    };
  };
in
  local.collection

