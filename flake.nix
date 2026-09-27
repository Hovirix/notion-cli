{
  description = "Notion CLI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
    }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor = system: import nixpkgs { inherit system; };
      treefmtEvalFor =
        system:
        treefmt-nix.lib.evalModule (pkgsFor system) {
          projectRootFile = "flake.nix";
          programs = {
            deadnix.enable = true;
            nixfmt.enable = true;
            ruff.enable = true;
            statix.enable = true;
          };
        };
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
          ntn = pkgs.callPackage ./package.nix { };
        in
        {
          default = ntn;
          inherit ntn;
        }
      );

      checks = forAllSystems (system: {
        formatting = (treefmtEvalFor system).config.build.check self;
      });

      formatter = forAllSystems (system: (treefmtEvalFor system).config.build.wrapper);
    };
}
