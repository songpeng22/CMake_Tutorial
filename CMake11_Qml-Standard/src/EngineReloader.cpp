/*
 * author: Tim Song
 * contributor: J-P Nurmi
 */
#include "EngineReloader.h"
#include <QQuickStyle>
#include <QQmlContext>
#include <QQuickWindow>

EngineReloader::EngineReloader(QObject *parent) : QObject(parent), m_instance(0)
{
    m_qmlContext = nullptr;
}

void EngineReloader::load(QUrl &source)
{
    m_source = source;
    reload();
}

void EngineReloader::reloadStyle(const QString &style)
{
    m_style = style;
    // This method is called from QML, so we cannot just immediately delete the QML engine in here,
    // because the execution would return to an engine that was destroyed. Just like in C++ you cannot
    // delete the sender of a signal.
    m_instance->deleteLater();
    connect(m_instance, SIGNAL(destroyed()), this, SLOT(reload()));
}

void EngineReloader::reload()
{
    qDebug() << "+EngineReloader::reload()";

    qmlClearTypeRegistrations();

    QQuickStyle::setStyle(m_style);
    m_instance = new QQmlApplicationEngine(this);
    m_qmlContext = m_instance->rootContext();
    this->beforeLoad();
    m_instance->load(m_source);
    this->afterLoad();

    qDebug() << "-EngineReloader::reload()";
}

void EngineReloader::beforeLoad()
{
    qDebug() << "EngineReloader::beforeLoad()";
}

void EngineReloader::afterLoad()
{
    qDebug() << "EngineReloader::afterLoad()";
}
