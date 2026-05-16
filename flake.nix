{
  description = "Standalone build of dash";

  nixConfig = {
    extra-substituters = [ "https://unpins.cachix.org" ];
    extra-trusted-public-keys = [ "unpins.cachix.org-1:DDaShjbZ8VvcqxeTcAU3kV9vxZQBlyb7V/uLBHfTynI=" ];
  };

  inputs.unpins-lib.url = "github:unpins/nix-lib";

  # Linux/macOS: pkgsStatic.dash (with libedit for interactive line editing).
  # Windows: routed through Cosmopolitan (`windowsCosmo = true`) because mingw
  # cross of dash is blocked by the same gnulib/POSIX-fork gaps that block
  # bash/coreutils — dash's job control needs real fork() and signal handling.
  # Cosmocc implements fork() on Windows via CreateProcessW + page copy.
  # Per-target cosmo fix in `unpins/nix-lib/cosmo/dash.nix` (drop libedit,
  # apelink ELF→PE in postFixup).
  outputs = { self, unpins-lib }:
    unpins-lib.lib.mkStandaloneFlake {
      inherit self;
      name = "dash";
      windowsCosmo = true;
    };
}
