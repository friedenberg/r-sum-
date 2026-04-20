{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/3e20095fe3c6cbb1ddcef89b26969a69a1570776";
    utils.url = "https://flakehub.com/f/numtide/flake-utils/0.1.102";

    resume-builder.url = "github:friedenberg/resume-builder";
    chrest.url = "github:amarbel-llc/chrest";
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
      resume-builder,
      chrest,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            resume-builder.packages.${system}.resume-builder
            chrest.packages.${system}.default
            pkgs.just
          ];
        };
      }
    );
}
