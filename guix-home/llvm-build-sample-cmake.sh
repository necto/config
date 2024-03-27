CC=clang-18 CXX=clang++ cmake \
        -DLLVM_ENABLE_TERMINFO=OFF \
        -DLLVM_ENABLE_ZLIB=OFF \
        -DLLVM_ENABLE_ZSTD=OFF \
        -DCMAKE_BUILD_TYPE=Debug \
        -DLLVM_ENABLE_ASSERTIONS=ON \
        -DLLVM_ENABLE_DUMP=ON \
        -DLLVM_TARGETS_TO_BUILD=X86 \
        -DCMAKE_INSTALL_PREFIX=../llvm-install \
        -DLLVM_PARALLEL_LINK_JOBS=4 \
        -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lld" \
        -DCMAKE_CXX_STANDARD=17 \
        -GNinja \
        ../llvm
