# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   CURRENT_INSTALLED_DIR     = ${VCPKG_ROOT_DIR}\installed\${TRIPLET}
#   DOWNLOADS                 = ${VCPKG_ROOT_DIR}\downloads
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#   VCPKG_TOOLCHAIN           = ON OFF
#   TRIPLET_SYSTEM_ARCH       = arm x86 x64
#   BUILD_ARCH                = "Win32" "x64" "ARM"
#   DEBUG_CONFIG              = "Debug Static" "Debug Dll"
#   RELEASE_CONFIG            = "Release Static"" "Release DLL"
#   VCPKG_TARGET_IS_WINDOWS
#   VCPKG_TARGET_IS_UWP
#   VCPKG_TARGET_IS_LINUX
#   VCPKG_TARGET_IS_OSX
#   VCPKG_TARGET_IS_FREEBSD
#   VCPKG_TARGET_IS_ANDROID
#   VCPKG_TARGET_IS_MINGW
#   VCPKG_TARGET_EXECUTABLE_SUFFIX
#   VCPKG_TARGET_STATIC_LIBRARY_SUFFIX
#   VCPKG_TARGET_SHARED_LIBRARY_SUFFIX

if (EXISTS $ENV{LAS_LOCAL_PATH})
    message(STATUS "[las] using local path")
    set(SOURCE_PATH $ENV{LAS_LOCAL_PATH})
else()
    message(STATUS "[las] using github")
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REF d5061056a3c2121a05debfa49d7434f49636c199
        SHA512 ba8dd26ca8dabe67a650e370f35ed6a84a6878df99d2469a9f1c9ff6a188223203855d00a5343da3bc6dfe4e7c0c492bcd790a7fe99e49768ff9db46672ce286
        REPO lucianodasilva/las)
endif()

# Check if one or more features are a part of a package installation.
# See /docs/maintainers/vcpkg_check_features.md for more details
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    test BUILD_TESTS
    batch BUILD_BATCH)

vcpkg_configure_cmake (
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS 
        ${FEATURE_OPTIONS})

vcpkg_install_cmake ()

if (BUILD_BATCH)
    vcpkg_copy_tools (
        TOOL_NAMES las-batch
        AUTO_CLEAN)
endif()


# merge cmake config files
vcpkg_cmake_config_fixup(
    PACKAGE_NAME ${PORT}
    CONFIG_PATH "share/${PORT}")

# Remove duplicate headers
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")


# Copy license file
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# Copy usage file
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
