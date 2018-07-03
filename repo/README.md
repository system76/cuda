# Debian Packaging Repo Config

Place the assets required by the CUDA toolkit into the `assets` directory,
within this directory.

```
assets
├── 9.0
│   ├── installer-9.0
│   ├── patch-9.0-1.run
│   ├── patch-9.0-2.run
│   └── patch-9.0-3.run
├── 9.1
│   ├── installer-9.1
│   ├── patch-9.1-1.run
│   ├── patch-9.1-2.run
│   └── patch-9.1-3.run
└── 9.2
    ├── installer-9.2
    └── patch-9.2-1.run
sources.toml
```

Then build the repo with [debrepbuild](https://github.com/pop-os/debrepbuild),
and host the directories on your package server.
