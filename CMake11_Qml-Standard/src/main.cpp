#include <QApplication>
#include <QGuiApplication>

#include <QQuickWindow>
#include <QPushButton>
#include <QQuickItem>
//For Debug
#include <QDebug>
//For Qml loading Method 1
#include <QQmlApplicationEngine>
//For Qml loading Method 2
#include <QQuickView>
#include <QQmlContext>
//For Qml loading Method 3
#include <QQuickWidget>
//For Qml loading Method 4
#include <QQmlComponent>
//For Qml loading Method 5
#include "EngineReloaderWrapper.h"
//For Qml loading Method 6
#include "QuickViewReloaderWrapper.h"
//For Debugging
#include <QQmlDebuggingEnabler>


#if 1

int main(int argc, char *argv[])
{
	QGuiApplication app(argc, argv);
	//Settings
	QCoreApplication::setOrganizationName("Bizerba");
	QCoreApplication::setApplicationName("QmlLoader");
	QCoreApplication::setOrganizationDomain("Bizerba.com");
	//Engine
	qDebug() << "QuickViewReloaderWrapper";
	QuickViewReloaderWrapper view;
	QUrl url = QUrl(QStringLiteral("qrc:/method2.qml"));
	view.load(url);

	return app.exec();
}

#elif 1

int main(int argc, char *argv[])
{
	//
	qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));
	//
    QGuiApplication app(argc, argv);
    //Settings
    QCoreApplication::setOrganizationName("Bizerba");
    QCoreApplication::setApplicationName("QmlLoader");
    QCoreApplication::setOrganizationDomain("Bizerba.com");
    //Engine
    EngineReloaderWrapper engine;
    QUrl url = QUrl(QStringLiteral("qrc:/main.qml"));
    engine.load(url);

    return app.exec();
}

#elif 0

/*
* Call QML : Method 4
*
*/
int main(int argc, char *argv[]) {
    QApplication app(argc, argv);

    QQmlEngine *engine = new QQmlEngine;
    QQmlComponent component(engine, QUrl(QStringLiteral("qrc:///method2.qml")));
//    QQmlComponent component(engine, QUrl::fromLocalFile("method2.qml "));

    if(component.isReady()){
        QObject *myObject = component.create();
        QQuickItem *item = qobject_cast<QQuickItem*>(myObject);
        int width = item->width();  // width = 200
        qDebug()<<width;
    }
    return app.exec();
}

#elif 0

/*
* Call QML : Method 3
* QQuickWidget是继承于 QWidget 控件，这种方式主要是用于在 QWidget 界面上加载 QML 界面。
*/
int main(int argc, char *argv[]) {
	QApplication app(argc, argv);

	QQuickWidget *view = new QQuickWidget;
	view->setSource(QUrl::fromLocalFile("method2.qml"));
	view->show();

	return app.exec();
}

#elif 1

/*
* Call QML : Method 2
* 使用 QQuickView 显示 QML 文件，对窗口的控制权（标题、窗口尺寸）是在 C++代码中，QML 文件是以 Item （及 以Item为根的组件）作为根对象。
*/
int main(int argc, char *argv[]) {
	QGuiApplication app(argc, argv);

    qDebug() << "main";
	QQuickView *view = new QQuickView;
	view->setResizeMode(QQuickView::SizeRootObjectToView);
    view->setSource(QUrl(QStringLiteral("qrc:///method2.qml")));
	view->show();

	return app.exec();
}

#elif 1
/*
* Call QML : Method 1 
* 这种方式是加载以 Window为跟对象的 QML 文件，QML 拥有窗口的完整控制权，可以直接设置标题、窗口尺寸等属性。
*/

/*
* Find Sub Object by Function 
* Param : objectName
* Method : From QObject
*/
QObject * FindSubObjectByObjectName(QObject * objParent,QString qstr){
	QObject * objSub = objParent->findChild<QObject*>(qstr);
	if(objSub)
		qDebug() << "PName:" << objParent->objectName() << "SName:" << objSub->objectName() << endl;
	return objSub;
}

int main(int argc, char *argv[]) {
	//For Debugging
	QQmlDebuggingEnabler enabler;
	//
	QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
	QGuiApplication app(argc, argv);
	QQmlApplicationEngine engine;
	engine.load(QUrl(QStringLiteral("qrc:///main.qml")));
	if (engine.rootObjects().isEmpty()) return -1;
	QQuickWindow * rootWindow = (QQuickWindow *)engine.rootObjects().first();
	if (rootWindow) {
		rootWindow->setProperty("width", 1024);
		rootWindow->setProperty("height", 768);
	}
	QObject * qmlObjectParent = Q_NULLPTR;
	QObject * qmlObjectSub = Q_NULLPTR;
	//Find Root
	QObject* rootObject = engine.rootObjects().first();
	//Find Sub1
	qmlObjectSub = FindSubObjectByObjectName(rootObject, "objRect1");
	if (Q_NULLPTR == qmlObjectSub)
		return -1;
	//Find Sub2
	qmlObjectParent = qmlObjectSub;
	qmlObjectSub = FindSubObjectByObjectName(qmlObjectParent, "objButton1");
	if (Q_NULLPTR == qmlObjectSub)
		return -1;

	QPushButton * btn = (QPushButton *) qmlObjectSub;
	if (btn)
		btn->setProperty("text", "textNew3");

	return app.exec();
}

#elif 0
/*
* Find Sub Object(Button) by objectName
* Method : From QQuickWindow
*/
int main(int argc, char *argv[]){
	QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
	QGuiApplication app(argc, argv);
	QQmlApplicationEngine engine;
	engine.load(QUrl(QStringLiteral("qrc:///main.qml")));
	if (engine.rootObjects().isEmpty()) return -1;
	QQuickWindow * rootWindow = (QQuickWindow *)engine.rootObjects().first();
	if (rootWindow) {
		rootWindow->setProperty("width", 1024);
		rootWindow->setProperty("height", 768);
	}
	QObject * btn = Q_NULLPTR;
	auto list = rootWindow->contentItem()->childItems();
	for (QQuickItem *item : list) {
		qDebug() << item->objectName() << endl;
		if (item->objectName() == "objButton1") {
			qDebug() << "Found the button";
			btn = item;
		}
		if (btn) break;
	}
	if(btn)
		btn->setProperty("text", "textNew1");

	return app.exec();
}

#elif 0
/*
* Find Sub Object by objectName
* Method : From QObject
*/
int main(int argc, char *argv[])
{
	QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
	QGuiApplication app(argc, argv);
	QQmlApplicationEngine engine;
	engine.load(QUrl(QStringLiteral("qrc:///main.qml")));
	if (engine.rootObjects().isEmpty())
		return -1;
	QObject* rootObject = engine.rootObjects().first();
	QObject * btn = rootObject->findChild<QObject*>("objButton1");

	btn->setProperty( "text", "textNew2" );

	return app.exec();
}

#elif 1

int main(int argc, char *argv[])
{
	QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
	QGuiApplication app(argc, argv);
	QQmlApplicationEngine engine;
	engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
	if (engine.rootObjects().isEmpty())
		return -1;
	return app.exec();
}

#endif

#if 0
/*
 * Trace out objectName under rootObj
 */
int main(int argc, char *argv[])
{
	QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

	QGuiApplication app(argc, argv);

	QQmlApplicationEngine engine;
	engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
	if (engine.rootObjects().isEmpty())
		return -1;
	QObject *rootObj = engine.rootObjects().first();
	qDebug() << Q_FUNC_INFO << "\n" << rootObj->objectName() << endl;
	foreach(auto o1, rootObj->children()) {
		qDebug() << o1->objectName() << endl;
	}

	return app.exec();
}

#endif


