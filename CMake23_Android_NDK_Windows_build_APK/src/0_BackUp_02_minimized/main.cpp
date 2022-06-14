//#include <QApplication>
//#include <QLabel>
#include <iostream>
using namespace std;

int main(int argc, char *argv[])
{
#if 1
    std::cout << "Hello World";
    std::string str = "test";
    std::cout << str;
    return 0;
#elif 0
    QApplication app(argc, argv);

    QLabel label("Hello, world");
    label.show();

    return app.exec();
#else
    QApplication a(argc, argv);
    MainWindow w;
    w.show();

    return a.exec();
#endif
}
