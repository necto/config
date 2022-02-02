# SonarSource cpecific:
# this list partially replicates "from-pristine-ubuntu.sh", for the self-sufficiency
sudo apt install -y zlib1g-dev python3-pip ninja-build clangd-12 clang-12 cmake ccache gcc lld
pip3 install lit==12.0.1

# download llvm fork from https://github.com/SonarSource/llvm-project/releases put it into ~/sonarsource-clang*

mkdir -p ~/proj
cd ~/proj
mv ~/sonarsource-clang* ./

tar -xvf sonarsource-clang*

git clone gh:SonarSource/sonar-cpp
cd sonar-cpp
mkdir -p build/asserts
echo 'CC=clang-13 CXX=clang++-13 cmake -DUSE_CCACHE=ON -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DUSE_ASSERTIONS=ON -DUSE_PCH=OFF -DBUILD_SHARED_LIBS=ON -DUSE_LINKER=lld -GNinja ../..' > build/build-asserts.sh
cd build/asserts
bash ../build-asserts.sh
ninja
cd ../..
ln -s build/asserts/compile_commands.json ./
ln -s ~/config/.clang-format ./

# Gradle stuff
# sudo apt install -y default-jdk
# to be continued...
