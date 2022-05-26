#include "QuickViewReloaderWrapper.h"
//API
#include <QQmlContext>
#include <QGuiApplication>
#include <QDir>

QuickViewReloaderWrapper::QuickViewReloaderWrapper()
{

}

QuickViewReloaderWrapper::~QuickViewReloaderWrapper()
{

}

void QuickViewReloaderWrapper::beforeLoad()
{
    qDebug() << "QuickViewReloaderWrapper::beforeLoad()";
    setContextProperies(m_qmlContext);
    registerToQml();
}

void QuickViewReloaderWrapper::afterLoad()
{
    qDebug() << "QuickViewReloaderWrapper::afterLoad()";
}

void QuickViewReloaderWrapper::setContextProperies(QQmlContext * pQmlContext)
{
    qDebug() << "+QuickViewReloaderWrapper::setContextProperies()";
    //Engine.path
    pQmlContext->setContextProperty("applicationDirPath", QGuiApplication::applicationDirPath());
    pQmlContext->setContextProperty("applicationFilePath", QGuiApplication::applicationFilePath());
    pQmlContext->setContextProperty("QDircurrentpath", QDir::currentPath());
    pQmlContext->setContextProperty("QDirRootPath", QDir::rootPath());
    pQmlContext->setContextProperty("QDirHomePath", QDir::homePath());
    //
    qDebug() << "-QuickViewReloaderWrapper::setContextProperies()";
}

void QuickViewReloaderWrapper::registerToQml()
{
    qDebug() << "+QuickViewReloaderWrapper::registerToQml()";
    
    qDebug() << "-QuickViewReloaderWrapper::registerToQml()";
}


