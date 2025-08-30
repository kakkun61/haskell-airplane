{
  description = "Description for the project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ];
      systems = nixpkgs.lib.systems.flakeExposed;
      perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          package = pkgs.stdenv.mkDerivation {
            name = "example";
            src = ./.;
            buildInputs = with pkgs; [
              cabal-install
              ghc
            ];
            buildCommand = ''
              # `cabal build` writes a file at a local repository,
              # and so it must be writable.
              cp -r --no-preserve=all $src/.local-repository .
              # This cabal.config file declares using the local repository.
              export CABAL_CONFIG=$src/cabal.config
              # Set a writable directory for cabal
              export CABAL_DIR=$TMPDIR/cabal
              cabal="cabal --project-dir=$src --builddir=$TMPDIR --verbose"
              $cabal v2-build --only-dependencies all
              $cabal v2-build all
              $cabal v2-install --installdir=$out all
            '';
          };
        in
        {
          packages.default = package;
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              haskell.compiler.ghc984
              haskellPackages.cabal-install
              haskellPackages.cabal-plan
              haskellPackages.fourmolu
              haskellPackages.ShellCheck
              nixpkgs-fmt
              nodePackages.cspell
              stdenv
            ];
          };
        };
      flake = { };
    };
}
