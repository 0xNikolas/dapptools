{
  description = "dapptools";

  inputs = {
    # same as in default.nix
    nixpkgs.url = "github:NixOS/nixpkgs/aa576357673d609e618d87db43210e49d4bb1789";
    ethereum-hevm.url = "github:ethereum/hevm";
  };

  outputs = { self, nixpkgs, ethereum-hevm }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"

        "x86_64-darwin"
        "x86_64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      packages =
        forAllSystems (system:
          let
            pkgs = nixpkgsFor.${system};

            dapptoolsSrc = pkgs.callPackage (import ./nix/dapptools-src.nix) { };
          in
          rec {
            dapp = pkgs.callPackage (import ./src/dapp) { inherit dapptoolsSrc hevm seth; };
            ethsign = pkgs.callPackage (import ./src/ethsign) { };
            hevm = ethereum-hevm.packages.${system}.hevm;
            seth = pkgs.callPackage (import ./src/seth) { inherit dapptoolsSrc hevm ethsign; };
          });
    };
}
