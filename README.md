# Setup

```sh
git clone git@github.com:DavidMCerdeira/bao-benchmarks.git --branch wip/rh850
cd bao-benchmarks
git submodule init
git submodule update

./runme-rh850-u2a16.sh
Usage:
  runme-rh850-u2a16.sh ctx-switch
  runme-rh850-u2a16.sh irq-lat [guest|native]
  runme-rh850-u2a16.sh irq-lat-wce

Examples:
  runme-rh850-u2a16.sh ctx-switch
  runme-rh850-u2a16.sh irq-lat guest
  runme-rh850-u2a16.sh irq-lat native
  runme-rh850-u2a16.sh irq-lat-wce

Notes:
  - Guest scenarios flash one or more guest HEX images, then build+run Bao.
  - Native scenario flashes the native HEX and runs without Bao.
```

# TOOLCHAIN

```
./build-gcc-v850-elf-toolchain.sh
```

# TOOLS
Requires Renesas `rfp-cli` for Linux: https://www.renesas.com/rfp



