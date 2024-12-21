{
  description = "a justfile that takes a Pandoc-flavored markdown file and
  renders it as a resume in various formats";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    utils.url = "github:numtide/flake-utils";
    utils-pandoc.url  = "github:friedenberg/dev-flake-templates?dir=pandoc";
    chromium-html-to-pdf.url = "github:friedenberg/chromium-html-to-pdf";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, utils, utils-pandoc, chromium-html-to-pdf }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        name = "html-to-pdf";
        buildInputs = with pkgs; [ pandoc just chromium-html-to-pdf ];
        html-to-pdf = (
          pkgs.writeScriptBin name (builtins.readFile ./justfile)
        ).overrideAttrs(old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });

      in rec {
        defaultPackage = packages.html-to-pdf;
        packages.html-to-pdf = pkgs.symlinkJoin {
          name = name;
          paths = [ html-to-pdf ] ++ buildInputs;
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
        };

        devShells.default = pkgs.mkShell {
          packages = (with pkgs; [
            pandoc
            just
          ]);

          inputsFrom = [];
        };
      }
    );
}
