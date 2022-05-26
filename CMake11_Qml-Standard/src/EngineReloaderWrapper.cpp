#include "EngineReloaderWrapper.h"
//API
#include <QQmlContext>
#include <QGuiApplication>

//
#include "GlobalVariant.h"

EngineReloaderWrapper::EngineReloaderWrapper()
{

}

EngineReloaderWrapper::~EngineReloaderWrapper()
{

}

void EngineReloaderWrapper::setContextProperies(QQmlContext * pQmlContext)
{
    qDebug() << "EngineReloaderWrapper::setContextProperies()";

    //Engine
    pQmlContext->setContextProperty("engine", this);
    //Engine.Global
    pQmlContext->setContextProperty("Global",GlobalVariant::Instance());
}

void EngineReloaderWrapper::registerToQml()
{
    qDebug() << "EngineReloaderWrapper::registerToQml()";

    qmlRegisterSingletonType(QUrl("qrc:/base/Config.qml"), "Qt.Wes.Config", 1, 0, "Config");

}

void EngineReloaderWrapper::beforeLoad()
{
    qDebug() << "EngineReloaderWrapper::beforeLoad()";

    setContextProperies(m_qmlContext);
    registerToQml();
}

void EngineReloaderWrapper::afterLoad()
{
    qDebug() << "EngineReloaderWrapper::afterLoad()";

    QObject *rootObject = qobject_cast<QObject*>(m_instance->rootObjects().first());

    QVariant returnedValue;
	QVariant objectName = "objImage";
	QVariant name = "visible";
	QVariant value = false;
    QMetaObject::invokeMethod(rootObject, "setProperty",
			Qt::DirectConnection,
            Q_RETURN_ARG(QVariant, returnedValue),
            Q_ARG(QVariant, objectName),
			Q_ARG(QVariant, name),
			Q_ARG(QVariant, value));
	qDebug() << "QML function returned:" << returnedValue;
}

void EngineReloaderWrapper::setReloadSubQml( QString qsFile )
{
    qDebug() << "EngineReloaderWrapper::setReloadSubQml" << qsFile;

}
