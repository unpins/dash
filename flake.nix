{
  description = "dash as a single self-contained binary";

  nixConfig = {
    extra-substituters = [ "https://unpins.cachix.org" ];
    extra-trusted-public-keys = [ "unpins.cachix.org-1:DDaShjbZ8VvcqxeTcAU3kV9vxZQBlyb7V/uLBHfTynI=" ];
  };

  inputs.unpins-lib.url = "github:unpins/nix-lib";

  # Windows goes through Cosmopolitan, not mingw: same gnulib/POSIX-fork gaps as
  # bash/coreutils block the mingw cross. Cosmocc emulates fork() via
  # CreateProcessW.
  #
  # Swap libedit's ncurses for the embedded-fallbacks variant so interactive
  # line editing works without host /usr/share/terminfo (Alpine, scratch). Host
  # terminfo still wins when present.
  outputs = { self, unpins-lib }:
    unpins-lib.lib.mkStandaloneFlake {
      inherit self;
      name = "dash";

      engine = "unpin-llvm";
      multicall = {
        inferLinkInputs = true;
        darwin = true;
        programs = [{ name = "dash"; }];
      };

      # nixpkgs lists [ bsd3 gpl2Plus ]; the GPL entry only covers the
      # build-time mksignames.c (its output, not code, lands in the binary).
      # Upstream COPYING and the distros label dash BSD-3-Clause.
      license = "BSD-3-Clause";

      # dash has no `--version` (it errors on `--`), so exercise the interpreter.
      smoke = [ "-c" "echo unpins-smoke-ok" ];
      smokePattern = "unpins-smoke-ok";

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
