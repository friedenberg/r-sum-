{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    utils.url = "github:numtide/flake-utils";
    utils-pandoc.url  = "github:friedenberg/dev-flake-templates?dir=pandoc";
    chromium-html-to-pdf.url = "github:friedenberg/chromium-html-to-pdf";
    # chromium-html-to-pdf.url = "git+file:///Users/sasha/eng/chromium-html-to-pdf";
    markdown-to-resume.url = "github:friedenberg/markdown-to-resume";
    # markdown-to-resume.inputs.chromium-html-to-pdf.follows = "chromium-html-to-pdf";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    utils,
    utils-pandoc,
    chromium-html-to-pdf,
    markdown-to-resume,
  }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

      in rec {
        devShells.default = pkgs.mkShell {
          packages = (with pkgs; [
            pandoc
            just
            chromium-html-to-pdf.packages.${system}.html-to-pdf
            markdown-to-resume.packages.${system}.markdown-to-resume
          ]);

          inputsFrom = [];
        };
      }
    );
}
