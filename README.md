# meta-sulka-bsp

This meta-layer provides the board support package metadata that hardens the boot path of a Sulka image.

Sulka is a Yocto Linux distribution that focuses on security hardening.
It ships hardened defaults across the kernel, the bootloader and the userspace, and expects the integrator to consciously relax hardening where their product requires it, rather than the other way round.

## What This Layer Provides

At present the layer covers the bootloader, which in the Sulka reference implementation is U-Boot.
`recipes-bsp/u-boot/` adds a hardening configuration fragment and a series of patches that together lock down the U-Boot console:

- The boot-stop string is no longer read from the `bootstopkeycrypt` environment variable, so it cannot be recovered from the environment.
- U-Boot gains an explicit locked/unlocked state, and a check for whether it has been unlocked.
- Entering the correct encrypted stop string unlocks the console.
- U-Boot refuses to drop into the CLI unless it has been unlocked.
- Command allowlisting restricts which commands may be run from the console.

The console password is set at build time.
If it is left unset, the build emits a warning and interactive login to U-Boot is disabled entirely, which is the safe default but will lock you out of the console.
See the [bootloader section of the user guide](https://altidsec.com/sulka/documentation/user-guide.html#bootloader-u-boot) for the details, and the [configuration variables](https://altidsec.com/sulka/documentation/user-guide.html#configuration-variables) section for how to set it.

## Layer Information

| | |
|---|---|
| Layer name | `meta-sulka-bsp` |
| Priority | 10 |
| Yocto compatibility | Wrynose (`LAYERSERIES_COMPAT = "wrynose"`) |
| Declared layer dependencies | None |
| Target bootloader | U-Boot 2026.01 |

The U-Boot bbappend is version-specific, so a BSP that pins a different U-Boot version will need the bbappend renamed and the patches checked against that version.
For an example of taking the Sulka layers onto real hardware, see the [Raspberry Pi reference project](https://codeberg.org/AltidSec/kas-sulka-raspberrypi-example).

## Documentation

To get started, read [the quick start guide](https://altidsec.com/sulka/documentation/quick-start.html).
More information about Sulka can be found in the [user guide](https://altidsec.com/sulka/documentation/user-guide.html).

If the website is unavailable, the same content can be read from [the documentation repository](https://codeberg.org/AltidSec/sulka-docs/src/branch/main/source).

## Contributing

Send pull requests, patches, comments or questions to the AltidSec repositories in Codeberg, and feel free to open issues to start discussions. Use `*-next` branches as pull request targets.

Maintainer:
Esa Jääskelä <esa.jaaskela@suomi24.fi>

## License

The metadata in this layer is licensed under the MIT license. See [COPYING.MIT](COPYING.MIT) for the full text.
Individual recipes fetch and build upstream components under their own licenses.
