{
  inputs = {
    nixpkgs.url =
      "github:NixOS/nixpkgs/nixos-23.05"; # Using other channel (unstable/22.05/etc will cause issue recorded in the bottom of this file)
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
  };

  outputs = { self, nixpkgs, devenv, systems, ... }@inputs:
    let forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in {
      devShells = forEachSystem (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [{
              # https://devenv.sh/reference/options/
              packages = with pkgs; [
                ansible
              ];

              enterShell = "";
            }];
          };
        });
    };
}
