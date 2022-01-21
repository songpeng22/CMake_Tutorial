set(CMAKE_SYSTEM_NAME Android)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# toolchain
set(tool_chain /opt/android-ndk/ndk/toolchains/llvm/prebuilt/linux-x86_64)
set(CMAKE_C_COMPILER ${tool_chain}/bin/aarch64-linux-android26-clang)
set(CMAKE_CXX_COMPILER ${tool_chain}/bin/aarch64-linux-android26-clang++)

