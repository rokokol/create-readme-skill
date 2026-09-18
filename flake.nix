{
  description = "Write a project's README to a fixed set of structure, tone and formatting rules";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      # The pinned toolbox for tests/check.sh, locally and in CI — a linter looked up
      # from a registry at job time makes the run a test of someone else's mirror
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            actionlint
            # The vendored check-sh.sh is moving to reading a script as a tree, out of
            # `shfmt --to-json`, with jq flattening that tree into rows. It arrives before
            # the checker that needs it, so the cascade does not deliver a red run
            jq
            shellcheck
            shfmt
          ];
        };
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}
