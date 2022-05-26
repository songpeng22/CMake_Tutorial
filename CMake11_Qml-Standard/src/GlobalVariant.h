#ifndef _GLOBAL_VARIANT_H_
#define _GLOBAL_VARIANT_H_

#include <QCoreApplication>
#include <QSettings>
#include <QFile>
#include <QDebug>

class GlobalVariant : public QObject
{
    Q_OBJECT
public:
    explicit GlobalVariant(QObject *parent = 0)
    {
        m_value = 1;
    }

    ~GlobalVariant()
    {

    }
public:
    Q_INVOKABLE inline void setValue(int value) {
        m_value = value;
    }
    Q_INVOKABLE inline int value() {
        return m_value;
    }
public:
    static GlobalVariant * Instance()
    {
        static GlobalVariant _instance;
        return &_instance;
    }
protected:
    QString m_subQml;
    int m_value;
};

Q_DECLARE_METATYPE(GlobalVariant*)

#endif//_GLOBAL_VARIANT_H_
