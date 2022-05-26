mkdir build
pushd build
cmake -G "Visual Studio 12 2013 Win64" -DCMAKE_PREFIX_PATH=C:/Qt/Qt5.10.1/5.10.1/msvc2013_64 ..\src 
cd ..

