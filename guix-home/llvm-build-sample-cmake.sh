# -DCMAKE_BUILD_RPATH=/home/necto/.guix-profile/lib
# is necessary because libz.so is not available in the default search path
# even though cmake finds it properly, llvm cmake does not
# add the matching RPATH and invocations of tblgen fail during
# compilation
CC=clang CXX=clang++ cmake \
        -DLLVM_ENABLE_TERMINFO=OFF \
        -DLLVM_ENABLE_ZSTD=OFF \
        -DCMAKE_BUILD_TYPE=Debug \
        -DLLVM_ENABLE_ASSERTIONS=ON \
        -DLLVM_ENABLE_DUMP=ON \
        -DLLVM_TARGETS_TO_BUILD=X86 \
        -DCMAKE_INSTALL_PREFIX=../llvm-install \
        -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lld" \
        -DCMAKE_CXX_STANDARD=17 \
        -DLLVM_USE_LINKER=lld \
        -DCMAKE_BUILD_RPATH=/home/necto/.guix-profile/lib \
        -GNinja \
        ../llvm
