# System76 CUDA Toolkit Packaging

Due to issues with how NVIDIA and Canonical package the CUDA toolkit, System76 is offering better
packaging for our users. This provides all of the debian packaging information needed to build
multiple versions of the CUDA toolkit in parallel, where the resulting packages may be installed
alongside each other. Users that install multiple toolkits only need to use `update-alternatives`
to switch between different versions of the toolkit.

## system76-cuda Metapackage

The `cuda` directory contains the metapackage required by each of the toolkits. This installs the
required shared development dependencies, as well as some system configuration files to get toolkits
working out of the box. This package should be built and installed first on the build server.

## system76-cuda-X.Y Packages

The `cuda-X.Y` directories contain the specific versions of the toolkit, which depend upon the
`system76-cuda` metapackage built from the `cuda` directory. These can be built and installed in
parallel, as there are no conflicting files. `update-alternatives` is used post-install to add a
new entry for the symlink at `/usr/lib/cuda`. Each `cuda-X.Y` directory contains its own Makefile,
which will download the installer & patches for that release, if they are not already located in
the directory.

## Listing & Switching Between Toolkits

The `update-altneratives` command may be used to view installed toolkits, and switch between them.

```
sudo update-alternatives --list cuda
sudo update-alternatives --config cuda
```

You may verify that you have the correct toolkit active by checking the `version.txt` file
associated with that release of the toolkit:

```
$ cat /usr/lib/cuda/version.txt
CUDA Version 9.2.88
CUDA Patch Version 9.2.88.1
```
