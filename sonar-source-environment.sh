# SonarSource cpecific:
# this list partially replicates "from-pristine-ubuntu.sh", for the self-sufficiency
sudo apt install -y zlib1g-dev python3-pip ninja-build clangd-17 clang-17 cmake ccache gcc lld
pip3 install lit==15.0.7

# Checkout our fork of llvm
mkdir -p ~/proj
cd ~/proj
git clone gh:SonarSource/llvm-project
cd llvm-project

# Checkout Z3 submodule
git submodule init
git submodule update

# Build Z3
mkdir z3-build
cd z3-build
CC=clang-17 CXX=clang++-17 cmake \
  -DZ3_BUILD_LIBZ3_SHARED=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=../llvm-install \
  -GNinja \
  ../z3
ninja
ninja install

# Build LLVM (takes a while)
mkdir -p build
echo 'CC=clang-17 CXX=clang++-17 cmake \
        -DLLVM_Z3_INSTALL_DIR=${PWD}/../llvm-install \
        -DLLVM_ENABLE_Z3_SOLVER=ON \
        -DLLVM_ENABLE_TERMINFO=OFF \
        -DLLVM_ENABLE_ZSTD=OFF \
        -DCMAKE_BUILD_TYPE=assertions \
        -DLLVM_ENABLE_ASSERTIONS=ON \
        -DLLVM_ENABLE_DUMP=ON \
        -DLLVM_TARGETS_TO_BUILD=X86 \
        -DCMAKE_INSTALL_PREFIX=../llvm-install \
        -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" \
        -DCMAKE_CXX_STANDARD=17 \
        -DLLVM_USE_LINKER=lld \
        -GNinja \
        ../llvm' > build/cmake.sh
cd build
bash cmake.sh
ninja
cd ~/proj

# Add our forked clang-format to PATH
mkdir -p ~/.sonar/bin/
echo 'export PATH="~/.sonar/bin/:$PATH"' > ~/.profile
ln -s ~/proj/llvm-project/build/bin/clang-format ~/.sonar/bin/

# JNI is needed to build our project
sudo apt install -y openjdk-19-jdk default-jdk

# Checkout and build sonar-cpp using LLVM sources directly
cd ~/proj
git clone gh:SonarSource/sonar-cpp
cd sonar-cpp
mkdir -p build/asserts
echo 'CC=clang-17 CXX=clang++-17 \
    cmake -DUSE_CCACHE=ON \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DUSE_LLVM_SOURCE=../../../llvm-project/ \
    -DUSE_ASSERTIONS=ON \
    -DUSE_PCH=OFF \
    -DBUILD_SHARED_LIBS=ON \
    -DUSE_LINKER=lld \
    -GNinja \
    ../..' > build/cmake-asserts.sh
cd build/asserts
bash ../cmake-asserts.sh
ninja
cd ../..
ln -s build/asserts/compile_commands.json ./

# Gradle stuff
# to be continued...
