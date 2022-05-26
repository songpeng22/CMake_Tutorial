#include "QuickViewReloader.h"
#include <QQuickStyle>
#include <QQmlContext>

QuickViewReloader::QuickViewReloader(QObject *parent) : QObject(parent)
{
    m_qmlContext = nullptr;
}

void QuickViewReloader::load(QUrl &source)
{
    m_source = source;
    reload();
}

void QuickViewReloader::reloadStyle(const QString &style)
{
    m_style = style;
    // This method is called from QML, so we cannot just immediately delete the QML engine in here,
    // because the execution would return to an engine that was destroyed. Just like in C++ you cannot
    // delete the sender of a signal.
    m_view->deleteLater();
    connect(m_view, SIGNAL(destroyed()), this, SLOT(reload()));
}

void QuickViewReloader::reload()
{
    qDebug() << "+QuickViewReloader::reload(" << m_style <<")";

    qmlClearTypeRegistrations();

    QQuickStyle::setStyle(m_style);

    m_view = new QQuickView;
    m_qmlContext = m_view->rootContext();
    this->beforeLoad();
    m_view->setSource(m_source);
    m_view->show();
    this->afterLoad();

    qDebug() << "-QuickViewReloader::reload()";
}

void QuickViewReloader::beforeLoad()
{
    qDebug() << "QuickViewReloader::beforeLoad()";
}

void QuickViewReloader::afterLoad()
{
    qDebug() << "QuickViewReloader::afterLoad()";
}
