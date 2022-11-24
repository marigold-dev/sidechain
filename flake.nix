{
  description = "Nix Flake";

  nixConfig = {
    extra-substituters = "https://anmonteiro.nix-cache.workers.dev";
    extra-trusted-public-keys = "ocaml.nix-cache.com-1:/xI2h2+56rwFfKyyFVbkJSeGqSIYMC/Je+7XXqGKDIY=";
  };

  inputs = {
    nixpkgs.url = "github:nix-ocaml/nix-overlays";
    nix-filter.url = "github:numtide/nix-filter";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs.follows = "nixpkgs";

    dream2nix.url = "github:nix-community/dream2nix";
    dream2nix.inputs.nixpkgs.follows = "nixpkgs";

    ligo.url = "gitlab:ligolang/ligo";
    tezos.url = "github:marigold-dev/tezos-nix";
    tezos.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-parts.follows = "flake-parts";
    };
    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = {
    self,
    nixpkgs,
    flake-parts,
    nix-filter,
    dream2nix,
    tezos,
    deploy-rs,
    ligo,
    ...
  }:
    flake-parts.lib.mkFlake {inherit self;} {
      imports = [
        ./nix/js-packages.nix
        ./nix/deku-c
        ./nix/deku-p
      ];
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem = {
        config,
        system,
        self',
        pkgs,
        ...
      }: {
        config = {
          _module.args = {
            pkgs = nixpkgs.makePkgs {
              inherit system;
              extraOverlays = [
                tezos.overlays.default
                (import ./nix/overlay.nix)
                (final: prev: {
                  ocamlPackages = prev.ocaml-ng.ocamlPackages_5_00;
                })
              ];
            };
            nodejs = pkgs.nodejs-16_x;
            dream2nix-lib = dream2nix.lib.init {
              inherit pkgs;
              config.projectRoot = ./.;
            };
          };
          devShells.default = import ./nix/shell.nix {
            inherit pkgs;
            ligo =
              if system == "x86_64-linux"
              then ligo.packages.${system}.ligoLight
              else pkgs.hello;
            deku = self'.packages.deku;
            tuna = self'.packages.tuna;
            deploy-rs = deploy-rs.packages.${system}.default;
          };
          checks = {
            ensure_all_build = pkgs.symlinkJoin {
              name = "all";
              paths = with self';
              with packages; [
                packages."@marigold-dev/deku-c-toolkit"
                packages."@marigold-dev/deku-p-sdk"
                packages."@marigold-dev/deku-toolkit"
                decookies-vm
                deku
                deku-static
                deku-toolkit-nodejs-example
                deku-toolkit-react-example
                docker
                tuna
                website
              ];
            };
          };
        };
      };
      flake = {
        deploy = {
          nodes = import ./networks/betanets/fleet.nix {
            inherit nixpkgs deploy-rs;
            deku-node = self.nixosModules.deku-node;
            rev =
              if self ? rev
              then self.rev
              else "dirty";
          };
          sshUser = "root";
        };

        checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
        formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
        formatter.aarch64-darwin = nixpkgs.legacyPackages.x86_64-linux.alejandra;
      };
    };
}
