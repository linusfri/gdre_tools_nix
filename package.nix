{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  alsa-lib,
  dbus,
  fontconfig,
  icu,
  libdecor,
  libGL,
  libpulseaudio,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxkbcommon,
  libxrandr,
  libxrender,
  speechd-minimal,
  udev,
  vulkan-loader,
  wayland,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gdre_tools";
  version = "2.7.0";

  src = fetchzip {
    url = "https://github.com/GDRETools/gdsdecomp/releases/download/v${finalAttrs.version}/GDRE_tools-v${finalAttrs.version}-linux.zip";
    stripRoot = false;
    hash = "sha256-TXO0dK2thej5yimSn8OxMDcfWPXqgWDCGtmIaWK3pA0=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  # lib.getLib selects the output containing the .so files, for example fontconfig.lib, not fontconfig.bin.
  runtimeDependencies = map lib.getLib [
    alsa-lib
    dbus
    fontconfig
    icu
    libdecor
    libGL
    libpulseaudio
    libx11
    libxcursor
    libxext
    libxi
    libxinerama
    libxkbcommon
    libxrandr
    libxrender
    speechd-minimal
    udev
    vulkan-loader
    wayland
  ];

  # runtimeDependencies only apply to executables; the .NET NativeAOT library dlopens ICU itself.
  appendRunpaths = [ (lib.makeLibraryPath [ icu ]) ];

  installPhase = ''
    runHook preInstall

    install -Dm755 gdre_tools.x86_64 -t $out/lib/gdre_tools
    install -Dm755 libGodotMonoDecompNativeAOT.so -t $out/lib/gdre_tools
    install -Dm644 gdre_tools.pck -t $out/lib/gdre_tools

    # Godot resolves the .pck next to the real executable path, so a symlink is enough.
    mkdir -p $out/bin
    ln -s $out/lib/gdre_tools/gdre_tools.x86_64 $out/bin/gdre_tools

    runHook postInstall
  '';

  meta = {
    description = "Godot reverse engineering tools: PCK extractor, GDScript decompiler and project recovery";
    homepage = "https://github.com/GDRETools/gdsdecomp";
    changelog = "https://github.com/GDRETools/gdsdecomp/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "gdre_tools";
  };
})
