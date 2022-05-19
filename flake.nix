{
  description = "Haskell hello world example";

  inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  
  outputs = { self, nixpkgs, flake-utils, haskellNix }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      overlays = [ haskellNix.overlay
        (final: prev: {
          helloProject =
            final.haskell-nix.project' {
              src = ./.;
              compiler-nix-name = "ghc8107";
            };
        })
      ];
      pkgs = import nixpkgs { inherit system overlays; inherit (haskellNix) config; };
      flake = pkgs.helloProject.flake {};
    in flake // {
      packages.default = flake.packages."hello-flake:exe:hello-flake";
      apps.default = {
        type = "app";
        program = "${flake.packages."hello-flake:exe:hello-flake"}/bin/hello-flake";
      };
    });
}
