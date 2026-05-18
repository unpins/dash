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
#   - apelink ELF -> PE32+ in postFixup so `bin/dash.exe` is what
#     gets stripped/joined upstream.
{ unpins-lib }:
pkgs:
let
  cosmoPkgs = unpins-lib.lib.cosmoStaticCross pkgs;
in
unpins-lib.lib.cosmoApelink pkgs { binName = "dash"; }
  (cosmoPkgs.dash.overrideAttrs (oa: {
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

  env = (oa.env or { }) // {
    NIX_CFLAGS_COMPILE = builtins.concatStringsSep " " [
      (oa.env.NIX_CFLAGS_COMPILE or "")
      "-Wno-implicit-function-declaration"
    ];
  };
}))
