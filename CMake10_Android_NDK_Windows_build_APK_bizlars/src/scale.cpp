#include "scale.h"

Scale::Scale(QObject *parent) : QObject(parent)
{
    m_ret = -1;
    m_ret = bizLars.open();
#if 1
    if( m_ret != true )
#else
    if( m_ret != ADC_SUCCESS )
#endif
    {
        qDebug() << "bizlars open failed,ret:" << m_ret << "..................................................................6";
    }
    else
    {
        qDebug() << "bizlars open success,ret:" << m_ret << ".................................................................1";
    }
}

Scale::~Scale()
{
    m_ret = bizLars.close();
#if 1
    if( m_ret != true )
#else
    if( m_ret != ADC_SUCCESS )
#endif
    {
        qDebug() << "bizlars close failed..................................................................1";
    }
    else
    {
        qDebug() << "bizlars close success..................................................................1";
    }
}