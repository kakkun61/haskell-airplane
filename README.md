# Building Haskell Projects in Airplane Mode

This repository demonstrates how to build a Haskell project with Nix without haskell.nix.

The key idea is using a local repository. We can build projects with dependencies offline after downloading all the necessary packages. We can determine which packages to download by reading _plan.json_ (or maybe _cabal.project.freeze_), then download their sdist archives from Hackage to the local repository. In the end, we do not need an internet connection to build the project.

## How to update the local repository

First create _plan.json_ file:

```txt
$ cabal build --only-dependencies --dry-run
```

and then download sdist files:

```txt
$ make download-dependencies
```

You must perform these steps online, of course.

## Unconfirmed Scenarios

The behavior when using `source-repository-package` in _cabal.project_ is currently unconfirmed.
