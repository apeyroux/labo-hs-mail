{ # Fetch the latest haskell.nix and import its default.nix
  haskellNix ? import (builtins.fetchTarball "https://github.com/input-output-hk/haskell.nix/archive/master.tar.gz") {}

# haskell.nix provides access to the nixpkgs pins which are used by our CI,
# hence you will be more likely to get cache hits when using these.
# But you can also just use your own, e.g. '<nixpkgs>'.
, nixpkgsSrc ? haskellNix.sources.nixpkgs-2003

# haskell.nix provides some arguments to be passed to nixpkgs, including some
# patches and also the haskell.nix functionality itself as an overlay.
, nixpkgsArgs ? haskellNix.nixpkgsArgs

# import nixpkgs with overlays
, pkgs ? import nixpkgsSrc nixpkgsArgs
}: let

  # hie
  all-hies = fetchTarball "https://github.com/infinisil/all-hies/archive/master.tar.gz";

  pkgs = import haskellNix.sources.nixpkgs-2003 (haskellNix.nixpkgsArgs // {
    #  crossSystem = haskellNix.pkgs.lib.systems.examples.musl64;
    overlays = haskellNix.nixpkgsArgs.overlays ++ [
      (import all-hies {}).overlay
    ];
  });

in pkgs.haskell-nix.project {
  # 'cleanGit' cleans a source directory based on the files known by git
  src = pkgs.haskell-nix.haskellLib.cleanGit {
    name = "labo-hs-mail";
    src = ./.;
  };
  modules = [
    {
      packages.HaskellNet-SSL = {
        patches = [ ./patches/SSL.hs.patch ];
        components.library.depends = [
          (pkgs.haskell-nix.hackage-package {
            name = "network-bsd";
            version = "2.8.1.0";
            compiler-nix-name = "ghc865";
          }).components.library
          (pkgs.haskell-nix.hackage-package {
            name = "network";
            version = "3.1.0.1";
            compiler-nix-name = "ghc865";
          }).components.library
      ];
      };
    }
  ];
  # For `cabal.project` based projects specify the GHC version to use.
  compiler-nix-name = "ghc865"; # Not used for `stack.yaml` based projects.
}
