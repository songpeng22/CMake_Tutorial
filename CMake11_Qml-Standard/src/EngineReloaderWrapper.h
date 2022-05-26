#ifndef _ENGINE_RELOADER_WRAPPER_H__
#define _ENGINE_RELOADER_WRAPPER_H__

#include "EngineReloader.h"

class EngineReloaderWrapper : public EngineReloader
{
public:
    EngineReloaderWrapper();
    ~EngineReloaderWrapper();
public slots:
    virtual void setReloadSubQml( QString qsFile );
private:
    virtual void beforeLoad();
    virtual void afterLoad();
    virtual void setContextProperies( QQmlContext * pQmlContext );
    virtual void registerToQml();
    void Clear();
private:
    QString m_subQmlName;
};


#endif//_ENGINE_RELOADER_WRAPPER_H__
