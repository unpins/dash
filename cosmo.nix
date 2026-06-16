# dash via cosmoStaticCross for Windows-x86_64.
#
# nixpkgs 25.11 ships dash 0.5.13.2. Builds clean against cosmocc 4.0.2
# without any source patches — superconfigure's minimal.diff (5 hunks of
# `mbstate_t = {}` → `{0}`) turned out unnecessary at this cosmocc
# version.
#
# Two deltas vs the nixpkgs derivation:
#   - libedit's static link chain is satisfied by our cosmo libedit
#     overlay (see nix-lib/cosmo/libedit.nix); the upstream nixpkgs
#     preConfigure already exports `LIBS="$(pkg-config --libs --static
#     libedit)"` which now resolves cleanly under cosmo.
#   - ELF → PE32+ rename to `dash.exe` happens automatically via the
#     cosmo cross stdenv's apelink setup hook.
{ unpins-lib }:
pkgs:
let
  cosmoPkgs = unpins-lib.lib.cosmoStaticCross pkgs;
in
cosmoPkgs.dash.overrideAttrs (oa: {
  # nixpkgs's preConfigure exports `LIBS` only when
  # `hostPlatform.isStatic` is true — our cosmo cross doesn't match
  # that gate, so the libedit-via-pkg-config flags never reach the
  # final link step and `tputs`/`tigetstr` from ncurses come up
  # undefined. Re-run the export unconditionally for cosmo.
  nativeBuildInputs = (oa.nativeBuildInputs or [ ]) ++ [
    cosmoPkgs.buildPackages.pkg-config
  ];
  preConfigure = ''
    export LIBS="$(''${PKG_CONFIG:-pkg-config} --libs --static libedit)"
  '';

  # Windows command lookup: catalog programs install as `<name>.exe` hardlinks
  # (cmd.exe/PowerShell find them via PATHEXT), but Cosmopolitan does not append
  # an executable suffix during path resolution, so a bare `ls` typed at the dash
  # prompt never resolves. The patch teaches dash's PATH search (find_command +
  # shellexec) to retry a candidate with `.exe` when the bare name is missing —
  # mirroring native Windows shells and keeping a single on-disk name (no `ls` +
  # `ls.exe` pair). `__COSMOCC__`-guarded, inert on the Linux/macOS static builds.
  # See docs/platforms/cosmocc.md.
  postPatch = (oa.postPatch or "") + ''
    patch -p1 < ${./findcmd-exe-lookup.patch}
  '';

  env = (oa.env or { }) // {
    NIX_CFLAGS_COMPILE = builtins.concatStringsSep " " [
      (oa.env.NIX_CFLAGS_COMPILE or "")
      "-Wno-implicit-function-declaration"
    ];
  };
})
