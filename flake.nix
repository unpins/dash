{
  description = "Standalone build of dash";

  nixConfig = {
    extra-substituters = [ "https://unpins.cachix.org" ];
    extra-trusted-public-keys = [ "unpins.cachix.org-1:DDaShjbZ8VvcqxeTcAU3kV9vxZQBlyb7V/uLBHfTynI=" ];
  };

  inputs.unpins-lib.url = "github:unpins/nix-lib";

  # Linux/macOS: pkgsStatic.dash (with libedit for interactive line editing).
  # Windows: routed through Cosmopolitan (`windowsBuild = import ./cosmo.nix
  # …`) because mingw cross of dash is blocked by the same gnulib/POSIX-fork
  # gaps that block bash/coreutils — dash's job control needs real fork()
  # and signal handling. Cosmocc implements fork() on Windows via
  # CreateProcessW + page copy. Per-binary cosmo recipe inline in
  # `./cosmo.nix` (drop libedit, apelink ELF→PE in postFixup).
  #
  # dash uses libedit for line editing in interactive mode. libedit links
  # ncurses to look up terminal capabilities. Without our fallback list
  # baked in, the binary depends on host terminfo (`/usr/share/terminfo`
  # on Linux/macOS) — fine on a typical Ubuntu/Fedora/macOS desktop, but
  # fails silently on Alpine without ncurses-terminfo-base, scratch
  # containers, or any "minimal" environment. Swap libedit's `ncurses` arg
  # for the embedded-fallbacks variant (database stays enabled, so host
  # terminfo still wins when present — the fallback array is just a safety
  # net for missing files).
  outputs = { self, unpins-lib }:
    unpins-lib.lib.mkStandaloneFlake {
      inherit self;
      name = "dash";
      windowsBuild = import ./cosmo.nix { inherit unpins-lib; };
      build = pkgs:
        let
          p = pkgs.pkgsStatic;
          ncursesFB = unpins-lib.lib.embedFallbackTerminfo p.ncurses;
        in
        p.dash.override {
          libedit = p.libedit.override { ncurses = ncursesFB; };
        };
    };
}
