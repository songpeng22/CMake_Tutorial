mkdir build
pushd build
cmake --graphviz=test.dot -G "Visual Studio 9 2008" ..\src 
cd ..
