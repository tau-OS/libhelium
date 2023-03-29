<img align="left" style="vertical-align: middle" width="120" height="120" src="Helium.png">

# libhelium

The Application Framework for tauOS apps

###

[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)

![Demo Screenshot](demo.png)

## 🛠️ Dependencies

Please make sure you have these dependencies first before building.

```bash
gtk4
libgee-0.8
meson
vala
```

Please note that the demo also requires the following dependencies.

```bash
libbismuth-1.0
blueprint-compiler
```

Generating documentation requires the following.

```bash
valadoc
gi-docgen
```

## 🏗️ Building

Simply clone this repo, then:

```bash
meson _build --prefix=/usr && cd _build
sudo ninja install
```
