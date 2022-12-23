{
  description = "A very basic flake";

  inputs.nixpkgs.url = "github:grwlf/nixpkgs/local13";

  outputs = { self, nixpkgs }: {

    packages = {};

    devShells = forAllSystems (system:
      let pkgs = nixpkgsFor.${system};
      in {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            inkscape
            xpdf
            pdftk
            ghostscript
            poppler_utils
          ];
        };
      });
  };

}
