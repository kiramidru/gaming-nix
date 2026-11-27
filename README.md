# nix-warehouse
A collection of Nix packages for games on `x86_64-linux`.

## Run a game

From the repository root, use `nix flake show` to list the available games, then
run `nix run .#<game>` from a graphical desktop session. For example:

```sh
nix run .#minecraft-launcher
```

For Halo CE, extract the `maps/` directory from your Xbox copy of the game into
`${XDG_DATA_HOME:-$HOME/.local/share}/halo-ce/`. The launcher expects
`maps/ui.map` and the other Xbox maps there. To use a different data directory:

```sh
HALO_DATA_ROOT=/path/to/halo-data nix run .#halo-ce
```

Project Zomboid requires the pinned GOG Linux installer. From the directory
containing `project_zomboid_42_20_2_92872.sh`, add it to the Nix store, then run
from the repository root:

```sh
nix-store --add-fixed sha256 project_zomboid_42_20_2_92872.sh
nix run .#project-zomboid
```
