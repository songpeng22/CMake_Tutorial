#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QQmlContext>

#include "test.h"
#include "USBTest.h"
#include "libusb.h"
#include "bizWTlars.h"
#include "scale.h"

#if 0 

void printdev(libusb_device *dev) {
	libusb_device_descriptor desc;
	int r = libusb_get_device_descriptor(dev, &desc);
	if (r < 0) {
		qDebug() <<"failed to get device descriptor"<<endl;
		return;
	}
	qDebug() <<"Number of possible configurations: "<<(int)desc.bNumConfigurations<<"  ";
	qDebug() <<"Device Class: "<<(int)desc.bDeviceClass<<"  ";
	qDebug() <<"VendorID: "<<desc.idVendor<<"  ";
	qDebug() <<"ProductID: "<<desc.idProduct;
	libusb_config_descriptor *config;
	libusb_get_config_descriptor(dev, 0, &config);
	qDebug() <<"Interfaces: "<<(int)config->bNumInterfaces<<" ||| ";
	const libusb_interface *inter;
	const libusb_interface_descriptor *interdesc;
	const libusb_endpoint_descriptor *epdesc;
	for(int i=0; i<(int)config->bNumInterfaces; i++) {
		inter = &config->interface[i];
		qDebug() <<"Number of alternate settings: "<<inter->num_altsetting<<" | ";
		for(int j=0; j<inter->num_altsetting; j++) {
			interdesc = &inter->altsetting[j];
			qDebug() <<"Interface Number: "<<(int)interdesc->bInterfaceNumber<<" | ";
			qDebug() <<"Number of endpoints: "<<(int)interdesc->bNumEndpoints<<" | ";
			for(int k=0; k<(int)interdesc->bNumEndpoints; k++) {
				epdesc = &interdesc->endpoint[k];
				qDebug() <<"Descriptor Type: "<<(int)epdesc->bDescriptorType<<" | ";
				qDebug() <<"EP Address: "<<(int)epdesc->bEndpointAddress<<" | ";
			}
		}
	}
	qDebug()<<endl<<endl<<endl;
	libusb_free_config_descriptor(config);
}

#endif

int main(int argc, char *argv[])
{
    QCoreApplication::setApplicationName("posscale");

    qDebug() << "main().........................................................................................................................1";

	QString weight;
    QString tare;
	BizWTlars bizLars;
    int nWeight = 0;
    int nTare = 0;
    int nState = 0;

	int nRet = bizLars.readWeight(&nWeight,&nTare,&nState);
	weight = QString("%1").arg(nWeight);
	tare = QString("%1").arg(nTare);

	qDebug() << "readWeight nRet:" << nRet << " weight:" << weight << " tare:" << tare << "...................................................................................1";

#if 0
    USBTestLog();
    libUSBTest();
#elif 0
    libusb_device **devs; //pointer to pointer of device, used to retrieve a list of devices
	libusb_context *ctx = NULL; //a libusb session
	int r; //for return values
	ssize_t cnt; //holding number of devices in list
	r = libusb_init(&ctx); //initialize a library session
	if(r < 0) {
		qDebug() <<"Init Error "<<r; //there was an error
				return 1;
	}
	libusb_set_debug(ctx, 3); //set verbosity level to 3, as suggested in the documentation
	cnt = libusb_get_device_list(ctx, &devs); //get the list of devices
	if(cnt < 0) {
		qDebug() <<"Get Device Error"; //there was an error
	}
	qDebug() << cnt <<" Devices in list."; //print total number of usb devices
		ssize_t i; //for iterating through the list
	for(i = 0; i < cnt; i++) {
				printdev(devs[i]); //print specs of this device
		}
		libusb_free_device_list(devs, 1); //free the list, unref the devices in it
		libusb_exit(ctx); //close the session
		return 0;

#endif
#if 0
    testLog();
#endif
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

	Scale scale;
	engine.rootContext()->setContextProperty("scale", &scale);

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
