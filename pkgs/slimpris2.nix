# MPRIS 2 remote control of Lyrion Music Server: https://github.com/mavit/slimpris2
{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  intltool,
  gettext,
  pkg-config,
  pandoc,
  gobject-introspection,
  wrapGAppsNoGuiHook,
  glib,
  libsoup_3,
  python3,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "slimpris2";
  version = "4.0.2";

  src = fetchFromGitHub {
    owner = "mavit";
    repo = "slimpris2";
    tag = finalAttrs.version;
    hash = "sha256-ho3iFWW+qj+nwPlY8VIvqZ9NBI95Cuosk4ibXvp1XYA=";
  };

  nativeBuildInputs = [
    autoreconfHook
    intltool
    gettext
    pkg-config
    pandoc
    gobject-introspection
    wrapGAppsNoGuiHook
  ];
  buildInputs = [
    glib
    libsoup_3
  ];

  # Substituted into the script's shebang by the Makefile.
  PYTHON = lib.getExe (
    python3.withPackages (ps: [
      ps.dbus-python
      ps.pygobject3
      ps.pyxdg
      ps.simplejson
      ps.six
    ])
  );

  meta = {
    description = "MPRIS remote control of Lyrion Music Server";
    homepage = "https://github.com/mavit/slimpris2";
    license = lib.licenses.gpl3Only;
    mainProgram = "slimpris2";
    platforms = lib.platforms.linux;
  };
})
