#ifndef _ENGINE_RELOADER_H__
#define _ENGINE_RELOADER_H__

//Common
#include <QObject>
#include <QDebug>
#include <QString>
#include <QDir>
#include <QUrl>
//Engine
#include <QQmlApplicationEngine>
#include <QQmlContext>
//Style
#include <QQuickStyle>

class EngineReloader : public QObject
{
    Q_OBJECT

public:
    EngineReloader(QObject *parent = 0);

    void load(QUrl &source);
private:
    virtual void beforeLoad();
    virtual void afterLoad();
public slots:
    void reloadStyle(const QString &style);

private slots:
    void reload();

protected:
    QUrl m_source;
    QString m_style;
    QQmlApplicationEngine *m_instance;
    QQmlContext * m_qmlContext;
};


#endif//_ENGINE_RELOADER_H__
