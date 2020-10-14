# SonarSource cpecific:
apt install -y zlib1g-dev

# download llvm fork from https://github.com/SonarSource/llvm-project/releases put it into ~/proj/sonarsource-clang*

tar -xvf sonarsource-clang*

cd ~/proj
git clone gh:SonarSource/sonar-cpp
cd sonar-cpp
mkdir -p build/cmake
cd build/cmake
CC=clang-10 CXX=clang++-10 cmake -DUSE_CCACHE=ON -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DUSE_PCH=OFF -DUSE_LINKER=lld -GNinja ../..
ninja
cd ..
mkdir -p exe/tester
ln -s cmake/tester exe/tester/tester
mkdir -p exe/reproducer
ln -s cmake/reproducer exe/reproducer/reproducer
mkdir -p exe/subprocess
ln -s cmake/subprocess exe/subprocess/subprocess
