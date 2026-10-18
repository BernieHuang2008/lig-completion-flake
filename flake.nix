{
  description = "A flake packaging lig for zsh";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
  let
    systems = [ "x86_64-linux" "aarch64-linux" ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
  in {
    # 核心输出：一个 overlay，将 lig 注入 pkgs
    overlays.default = final: prev: {
      lig = prev.rustPlatform.buildRustPackage {
        pname = "lig";
        version = "unstable";
        src = prev.fetchFromGitHub {
          owner = "BernieHuang2008";
          repo = "lig-completion";
          rev = "da68a565d6d3c305f7a1d93fdd27bcb37c0cd70f"; # 锁定 Commit
          hash = "sha256-...";
        };
        cargoHash = "sha256-...";
        meta.mainProgram = "lig";
      };
    };

    # 可选：暴露 packages，方便 `nix build github:你/lig-flake` 直接构建
    packages = forAllSystems (system:
      let pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; };
      in { inherit (pkgs) lig; default = pkgs.lig; }
    );
  };
}
