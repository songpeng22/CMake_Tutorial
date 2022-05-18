#ifndef _SCALE_H_
#define _SCALE_H_

#include <QObject>
#include <QDebug>
#include <QString>

#include "bizWTlars.h"

class Scale : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString weight READ weight NOTIFY weightChanged)
    Q_PROPERTY(QString tare READ tare NOTIFY tareChanged)
    Q_PROPERTY(int ret READ ret NOTIFY retChanged)
public:
    Scale(QObject *parent = 0);
    ~Scale();
    Q_INVOKABLE QString weight()
    {
        int nWeight = 0;
        int nTare = 0;
        int nState = 0;
        int nRet = bizLars.readWeight(&nWeight,&nTare,&nState);
        m_ret = nRet;
        QString weight = QString("%1").arg(nWeight);
	
        return weight;
    }

    Q_INVOKABLE QString tare()
    {
        int nWeight = 0;
        int nTare = 0;
        int nState = 0;
        int nRet = bizLars.readWeight(&nWeight,&nTare,&nState);
        m_ret = nRet;
        QString tare = QString("%1").arg(nTare);

        return tare;
    }

    Q_INVOKABLE int ret()
    {
        return m_ret;
    }

signals:
    void weightChanged();
    void tareChanged();
    void retChanged();
private:
    BizWTlars bizLars;
    int m_ret;
};

#endif//_SCALE_H_