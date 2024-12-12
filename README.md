# podepmgr

**Portable Dependency Manager - a tool for running programs off of external media**

# About

`podepmgr` is a command line tool for running and managing programs on external media. It provides a quick and simple interactive CLI for running programs, and the necessary tools to load any necessary dependencies or run scripts beforhand.

Running programs off of external drives tends to be difficult since they commonly require certain registry keys, paths in the system environment, or certain tweaks in order to make them work between computers.

Instead of developing new launch scripts every time, you can import these tweaks into `podepmgr`, which will take care of them for you and abstract them away with every new PC you connect your drives onto!

# Usage

Once installed, use `podepmgr start` to launch the main interface. This is normally done via the included `boot` script.

Use `podepmgr edit` to edit your configuration, and add new environments and plugins. You can also update the `config.json` file manually.