{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/d981d41ffe5b541eae3782029b93e2af5d229cc2";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/09eb77e94fa25202af8f3e81ddc7353d9970ac1b";
    utils.url = "https://flakehub.com/f/numtide/flake-utils/0.1.102";

    devenv-pandoc.url = "github:friedenberg/eng?dir=pkgs/alfa/devenv-pandoc";
    resume-builder.url = "github:friedenberg/eng?dir=pkgs/bravo/resume-builder";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-stable
    , utils
    , devenv-pandoc
    , resume-builder
    ,
    }:
    utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
      };

    in
    {
      devShells.default = pkgs.mkShell {
        packages = [
          resume-builder.packages.${system}.resume-builder
        ];

        inputsFrom = [
          devenv-pandoc.devShells.${system}.default
        ];
      };
    }
    );
}
