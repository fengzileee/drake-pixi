# Pixi Package for Drake Robotics Toolbox

This repository provides a [Pixi](https://pixi.prefix.dev/latest/) package for [Drake](https://drake.mit.edu/). It automates the installation of both C++ and Python APIs from source directly into a Pixi workspace. The tags in this repository are synchronized with the corresponding versions of Drake.

## Usage

To use this package, update your project's `pixi.toml` to include `preview = ["pixi-build"]` in the workspace table and add `drake` as a git dependency.

### Minimum `pixi.toml` Example

```toml
[workspace]
channels = ["https://prefix.dev/conda-forge"]
platforms = ["linux-64", "osx-arm64"]
preview = ["pixi-build"]

[dependencies]
# Pin to a tag of Drake release version
drake = { git = "https://github.com/fengzileee/drake-pixi", tag = "1.45.0" }

# Or a branch name
# drake = { git = "https://github.com/fengzileee/drake-pixi", branch = "main" }

# Or a commit hash
# drake = { git = "https://github.com/fengzileee/drake-pixi", rev = "a89c56eaf2792064384d8ab892052fd95ee345f2" }
```

### Installation and Verification
Assuming your workspace directory is structured as follows:

``` 
my-drake-project/
└── pixi.toml
```

Running `pixi shell` will trigger the build and installation of Drake from source within your isolated `pixi` workspace. Once the process is complete, you can verify the installation by running:

``` sh
python -m pydrake.tutorials
```

After the installation, you might need to shutdown the bazel server manually.

## Compatibility

Tested with:
- Pixi: v0.62.2
- OS: Ubuntu 20.04 (x86_64) and macOS 15.5 (Apple Silicon)
