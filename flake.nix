{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    pyDBML-src = {
      url = "github:Vanderhoof/PyDBML";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    pyDBML-src,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      pyDBMLSqlite-src = ./.;
    in
      with pkgs.python3Packages; {
        packages = rec {
          pydbml = buildPythonPackage {
            pname = "pydbml";
            version = "git";
            pyproject = true;

            src = pyDBML-src;

            nativeBuildInputs = [
              setuptools
              setuptools-scm
            ];

            propagatedBuildInputs = [
              pyparsing
            ];
          };

          default = pyDBMLSqlite;
          pyDBMLSqlite = buildPythonApplication {
            pname = "pyDBMLSqlite";
            version = "git";
            pyproject = true;
            src = pyDBMLSqlite-src;

            nativeBuildInputs = [
              poetry-core
            ];

            propagatedBuildInputs = [
              click
              pydbml
            ];
          };
        };
        devShells.default = pkgs.mkShellNoCC {
          packages = [
            pkgs.poetry
            pkgs.ruff
            (python.withPackages (ps: [
              self.packages.${system}.pydbml
              ps.click
              pytest
            ]))
          ];
        };
      });
}
