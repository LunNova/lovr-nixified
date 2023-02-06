{ stdenv
, cmake
, libglvnd
, xorg
, libxkbcommon
, pkgconfig
, ode
, msdfgen
, freetype
, vulkan-headers
, glslang
, openxr-loader
, openxr
, glfw
, lua
, luajit
, python3
, addOpenGLRunpath
, autoPatchelfHook
}:

stdenv.mkDerivation {
  name = "lovr";
  src = ./.;

  prePatch = ''
    rm -rf deps
    mkdir -p deps/msdfgen
    ln -sfd ${ode} deps/ode
    cp -r ${msdfgen}/* deps/msdfgen/
    ln -sfd ${glslang} deps/glslang
    ln -sfd ${openxr} deps/openxr
    chmod -R 0777 deps/msdfgen
    sed -i 's!RELATIVE !!g' deps/msdfgen/CMakeLists.txt
    ls -l deps/msdfgen/cmake
  '';

  cmakeFlags = [
    "-DLOVR_SYSTEM_GLFW=ON"
    "-DLOVR_SYSTEM_LUA=ON"
    "-DLOVR_SYSTEM_OPENXR=ON"
    "-DCMAKE_SKIP_RPATH=ON"
  ];

  nativeBuildInputs = [
    cmake
    pkgconfig
    python3
    addOpenGLRunpath
    #autoPatchelfHook
  ];

  buildInputs = [
    xorg.libX11
    xorg.libXcursor
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXi
    xorg.libXdmcp
    libglvnd.dev
    libxkbcommon
    freetype
    vulkan-headers
    openxr-loader
    glfw
    lua
    luajit
    stdenv.cc.cc.lib
  ];

  preInstall = ''
    ls /build/*-source
  '';

  postFixup = ''
    for exe in $out/bin/*; do
      echo "adding opengl runpath to $exe"
      addOpenGLRunpath "$exe"
    done
    patchelf --print-rpath $out/bin/lovr
  '';
}
