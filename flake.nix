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
          example-project = pkgs.stdenv.mkDerivation {
            pname = "example";
            version = "0";
            src = ./.;
            buildInputs = with pkgs; [
              cabal-install
              ghc
            ];
            buildPhase = ''
              runHook preBuild

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

              runHook postBuild
            '';
            installPhase = ''
              runHook preInstall
              $cabal v2-install --installdir=$out --install-method=copy all
              runHook postInstall
            '';
          };
          download-dependencies = pkgs.stdenv.mkDerivation {
            pname = "haskell-airplane-download-dependencies";
            version = "0";
            src = ./dev;
            meta.mainProgram = "haskell-airplane-download-dependencies";
            buildInputs = with pkgs; [
              haskellPackages.cabal-plan
              wget
            ];
            buildPhase = ''
              runHook preBuild
              cp $src/download-dependencies haskell-airplane-download-dependencies
              runHook postBuild
            '';
            installPhase = ''
              runHook preInstall
              install -D --target-directory=$out/bin haskell-airplane-download-dependencies
              runHook postInstall
            '';
          };
        in
        {
          packages.default = example-project;

          formatter = pkgs.nixpkgs-fmt;

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
