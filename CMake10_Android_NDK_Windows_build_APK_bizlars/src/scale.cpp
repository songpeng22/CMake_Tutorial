#include "scale.h"

Scale::Scale(QObject *parent) : QObject(parent)
{
    m_ret = -1;
    if( bizLars.open() != ADC_SUCCESS )
    {
        qDebug() << "bizlars open failed.";
    }
    else
    {
        qDebug() << "bizlars open success.";
    }
}

Scale::~Scale()
{
    if( bizLars.close() != ADC_SUCCESS )
    {
        qDebug() << "bizlars close failed.";
    }
    else
    {
        qDebug() << "bizlars close success.";
    }
}