{
  description = "Packaging for lig-completion (source lives in a separate repo)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
  let
    systems = [ "x86_64-linux" "aarch64-linux" ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
  in {
    # 对外暴露的 overlay：dotfiles 通过它拿到 pkgs.lig
    overlays.default = final: prev: {
      lig = prev.rustPlatform.buildRustPackage {
        pname = "lig";
        version = "unstable";

        # 源码来自另一个仓库，按 commit 锁定，保证可复现
        src = prev.fetchFromGitHub {
          owner = "BernieHuang2008";
          repo = "lig-completion";
          rev = "da68a565d6d3c305f7a1d93fdd27bcb37c0cd70f";
          hash = prev.lib.fakeHash;     # ← 待替换
        };

        cargoHash = prev.lib.fakeHash;   # ← 待替换

        meta = with prev.lib; {
          description = "IDE-style terminal autocompletion";
          homepage = "https://github.com/BernieHuang2008/lig-completion";
          mainProgram = "lig";
        };
      };
    };

    # 让 `nix build` 能直接构建，方便独立调试
    packages = forAllSystems (system:
      let pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; };
      in { inherit (pkgs) lig; default = pkgs.lig; }
    );
  };
}
