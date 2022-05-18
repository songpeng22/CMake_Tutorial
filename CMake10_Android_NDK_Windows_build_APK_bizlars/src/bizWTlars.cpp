
#include "bizWTlars.h"
#include "bizlars.h"
#include "authentication.h"

#include <iostream>
#include <string.h>

#include <QDebug>
#include <QString>
#include <QFileInfo>
#include <QDir>
#include <QLibrary>

//#define VERSION_FOR_AUTHENTICATION	"01.44"
#define VERSION_FOR_AUTHENTICATION	"01.45"

static const char STX = 0x02;
static const char ETX = 0x03;
static const char FS  = 0x1C;
static const char GS  = 0x1D;

// defines for authentication
#define ADW_AUTH_CRC_START      0x4461      /* start value for the Polynomial */
#define ADW_AUTH_CRC_POLY       0x1021      /* Polynomial-coeffizient */
#define ADW_AUTH_CRC_MASK       0x0000      /* Mask for the Polynomial */

BizWTlars::BizWTlars()
{
    QString currentPath = QDir::currentPath();
    qDebug() << "currentPath is:" << currentPath << "............";
#if 0
    QString filePath1 = "/data/bin/libc++.so";
    QString filePath2 = "/data/bin/libusb.so";
    QString filePath3 = "/data/bin/libbizlars.so";
   
    QFileInfo check_file(filePath1);
    // check if file exists and if yes: Is it really a file and no directory?
    if (check_file.exists() && check_file.isFile()) {
        qDebug() << "file exist......";
    } else {
        qDebug() << "library not exist......";
    }

    QLibrary library;
    library.setFileName(filePath1);
    bool ret = library.load();
    qDebug() << filePath1 << "library.load() ret:" << ret << "............";
    if(library.isLoaded())
    {
        qDebug() << "library is loaded......";
    }
    else
    {
        qDebug() << "library not loaded:" << library.errorString() << "...............";
    }
    //
    library.setFileName(filePath2);
    ret = library.load();
    qDebug() << filePath2 << "library.load() ret:" << ret << "............";
    if(library.isLoaded())
    {
        qDebug() << "library is loaded......";
    }
    else
    {
        qDebug() << "library not loaded:" << library.errorString() << "...............";
    }
    //
    library.setFileName(filePath3);
    ret = library.load();
    qDebug() << filePath3 << "library.load() ret:" << ret << "............";
    if(library.isLoaded())
    {
        qDebug() << "library is loaded......";
    }
    else
    {
        qDebug() << "library not loaded:" << library.errorString() << "...............";
    }
#endif
    
    adcHandle = 0;
}
#if 1
bool BizWTlars::open(void)
{
    short			errorCode = 0;
    unsigned char	performSWReset = 1;

    errorCode = AdcOpen(NULL, NULL, NULL, &adcHandle, performSWReset);

    if (errorCode == ADC_SUCCESS) {
        checkForAuthentication();
    }

    return (errorCode == ADC_SUCCESS);
}

bool BizWTlars::close(void)
{
    short errorCode;

    if (adcHandle)
    {
        errorCode = AdcClose(adcHandle);
        if (errorCode != ADC_SUCCESS) {
            return false;
        }
    }

    return true;
}

void BizWTlars::checkForAuthentication()
{
    short       errorCode;
    short       registrationRequest;
    AdcState    adcState;
    AdcWeight   weight;
    AdcTare     tare;
    AdcBasePrice  basePrice;
    AdcPrice    sellPrice;

    registrationRequest = 0;

    errorCode = AdcReadWeight(adcHandle, registrationRequest, &adcState, &weight, &tare, &basePrice, &sellPrice);
    if (errorCode == ADC_SUCCESS) {
        checkForAuthentication(adcState.bit.needAuthentication, adcState.bit.needLogbook);
    } else if (errorCode == ADC_E_AUTHENTICATION) {
        makeAuthentication(true);
    }
}

void BizWTlars::checkForAuthentication(bool needAuthentication, bool needLogbook)
{
    if (needAuthentication ||
        needLogbook) {
        bool swIdentify = false;
        if (needLogbook) {
            swIdentify = true;
        }
        makeAuthentication(swIdentify);
    }
}

bool BizWTlars::zeroScale()
{
    short       errorCode;
    AdcState    adcState;

    errorCode = AdcZeroScale(adcHandle, &adcState);
    if (errorCode == ADC_SUCCESS) {
        checkForAuthentication(adcState.bit.needAuthentication, adcState.bit.needLogbook);
    } else if (errorCode == ADC_E_AUTHENTICATION) {
        makeAuthentication(true);
    }

    return (errorCode == ADC_SUCCESS);
}

bool BizWTlars::setTare()
{
    short       errorCode;
    AdcState    adcState;
    AdcTare     tare;

    tare.frozen = 0;
    tare.type = AdcTareType::ADC_TARE_WEIGHED;

    errorCode = AdcSetTare(adcHandle, &adcState, &tare);
    if (errorCode == ADC_SUCCESS) {
        checkForAuthentication(adcState.bit.needAuthentication, adcState.bit.needLogbook);
    } else if (errorCode == ADC_E_AUTHENTICATION) {
        makeAuthentication(true);
    }

    return (errorCode == ADC_SUCCESS);
}

bool BizWTlars::clearTare()
{
    short       errorCode;
    AdcState    adcState;

    errorCode = AdcClearTare(adcHandle, &adcState);
    if (errorCode == ADC_SUCCESS) {
        checkForAuthentication(adcState.bit.needAuthentication, adcState.bit.needLogbook);
    } else if (errorCode == ADC_E_AUTHENTICATION) {
        makeAuthentication(true);
    }

    return (errorCode == ADC_SUCCESS);
}


bool BizWTlars::readWeight(int *weightOut, int *tareOut, int *state)
{
    if (!adcHandle) {
        return false;
    }

    short       errorCode;
    short       registrationRequest;
    AdcState    adcState;
    AdcWeight   weight;
    AdcTare     tare;
    AdcBasePrice  basePrice;
    AdcPrice    sellPrice;

    registrationRequest = 0;

    errorCode = AdcReadWeight(adcHandle, registrationRequest, &adcState, &weight, &tare, &basePrice, &sellPrice);

    if (errorCode == ADC_SUCCESS)
    {
        *weightOut = weight.value;
        *tareOut = tare.value.value;

/*
#define BUSCI_STATE_VALID_WEIGHT       0
#define BUSCI_STATE_ERROR              1
#define BUSCI_STATE_WEIGHT_UNDERFLOW   2
#define BUSCI_STATE_WEIGHT_IS_ZERO     3
#define BUSCI_STATE_WEIGHT_NOT_STABLE  4
#define BUSCI_STATE_WEIGHT_OVERFLOW    5
#define BUSCI_STATE_WEIGHT_OVER_ZERO_SETRANGE 6
#define BUSCI_STATE_WEIGHT_UNDER_ZERO_SETRANGE 7
#define BUSCI_STATE_SCALE_IN_CALIBRATION_MODE 8
#define BUSCI_STATE_TILT_OVERFLOW 9
#define BUSCI_STATE_LOAD_CIRCUIT 10
*/

        if (adcState.bit.calibMode == 1) {
            *state = BUSCI_STATE_SCALE_IN_CALIBRATION_MODE;
        } else {
            if (adcState.bit.weightUnstable) {
                *state = BUSCI_STATE_WEIGHT_NOT_STABLE;
            } else if (weight.value == 0 || adcState.bit.zeroIndicator == 1) {
                *state = BUSCI_STATE_WEIGHT_IS_ZERO;
            } else if (adcState.bit.underZero) {
                *state = BUSCI_STATE_WEIGHT_UNDERFLOW;
            } else if (adcState.bit.overWeight) {
                *state = BUSCI_STATE_WEIGHT_OVERFLOW;
            } else if (adcState.bit.tiltCompOutsideLimit) {
                *state = BUSCI_STATE_TILT_OVERFLOW;
            } else if (adcState.bit.scaleNotReady) {
                *state = BUSCI_STATE_ERROR;
            } else {
                *state = BUSCI_STATE_VALID_WEIGHT;
            }
        }

/*
        if (adcState.bit.underZero) {
            printf("scale is underload");
        }

        if (adcState.bit.underWeight) {
            printf("/weight within minimum load range");
        }

        if (adcState.bit.overWeight) {
            printf("/scale is overload");
        }

        if (adcState.bit.sameWeight) {
            printf("/no motion since last weighing");
        }

        if (adcState.bit.busy) {
            printf("/scale busy");
        }

        if (adcState.bit.weightUnstable) {
            printf("/scale unstable");
        }

        if (adcState.bit.tiltCompOutsideLimit) {
            printf("/tilt compensation tilt too large");
        }

        if (adcState.bit.calibMode) {
            printf("/scale is in calibration mode");
        }

        if (adcState.bit.scaleNotReady) {
            printf("/scale is not ready");
        }

        if (adcState.bit.zeroIndicator) {
            printf("/scale is inside zero indicator range");
        }

        if (adcState.bit.outsideZeroRange) {
            printf("/switch on scale is outside zero range");
        }

        if (adcState.bit.needAuthentication) {
            printf("/need authentication");
        }

        if (adcState.bit.needLogbook) {
            printf("/need logbook");
        }
       std::cout << std::endl;
        */
        if (adcState.bit.needAuthentication) {
            printf("/need authentication");
        }

        if (adcState.bit.needLogbook) {
            printf("/need logbook");
        }

        checkForAuthentication(adcState.bit.needAuthentication, adcState.bit.needLogbook);

/*
       // print out weight
       FormatValue(weight.value, weight.decimalPlaces, &valueString);
       cout << "Weight:  " << valueString << " " << GetWeightUnit(weight.weightUnit);

       if ((tare.type != ADC_TARE_NO) && (tare.value.value != 0))
       {
           // print tare
           FormatValue(tare.value.value, tare.value.decimalPlaces, &valueString);
           cout << "  Tare:  " << valueString << " " << GetWeightUnit(tare.value.weightUnit);
       }

       cout << "\t";
       */

       // print out adcState
       //PrintAdcState(adcState, MODE_READ_WEIGHT, true);
       //PrintAdcState(adcState, MODE_READ_WEIGHT, false);


       return true;
    } else if (errorCode == ADC_E_AUTHENTICATION) {
        makeAuthentication(true);
    } else {
        printf("AdcReadWeight error: %d\n", errorCode);
    }

    return false;
}


bool BizWTlars::makeAuthentication(bool withIdentityString, std::stringstream *IDstring /*= nullptr*/)    
{
    short               errorCode;
    unsigned char       random[8];
    unsigned long       size = sizeof(random);
    AdcAuthentication   authentication;
    Authentication      auth(ADW_AUTH_CRC_START, ADW_AUTH_CRC_POLY, ADW_AUTH_CRC_MASK);
	time_t				rawtime;
	struct tm 			*timeinfo;
	char				timeString[80];

    errorCode = AdcGetRandomAuthentication(adcHandle, random, &size);
    if (errorCode == ADC_SUCCESS)
    {
        authentication.chksum = auth.CalcCrc(random, size);
        authentication.swIdentity = NULL;

		if (withIdentityString)
		{
			if (IDstring)
			{
				authentication.swIdentity = (char *)malloc(IDstring->str().size() + 1);
				if (authentication.swIdentity)
					strcpy(authentication.swIdentity, IDstring->str().c_str());
			}
			else
			{
				// get local time
				time(&rawtime);
				timeinfo = localtime(&rawtime);
				strftime(timeString, sizeof(timeString), "%y%m%d%H%M", timeinfo);

				std::stringstream    logBookEntry;
				logBookEntry << STX << "vid" << FS << "13" << GS << \
					"cid" << FS << "129" << GS << \
					"swvl" << FS << "001" << GS << \
					"swid" << FS << "8139" << GS << \
					"swv" << FS << VERSION_FOR_AUTHENTICATION << GS << \
					"date" << FS << timeString << ETX;
				// don't forget the terminating 0
				authentication.swIdentity = (char *)malloc(logBookEntry.str().size() + 1);
				if (authentication.swIdentity)
					strcpy(authentication.swIdentity, logBookEntry.str().c_str());
			}
			errorCode = AdcSetAuthentication(adcHandle, &authentication);
		}
		else
		{
			errorCode = AdcSetAuthentication(adcHandle, &authentication);
		}

        // free memory
        if (authentication.swIdentity)
        {
            free(authentication.swIdentity);
        }

        return (errorCode == ADC_SUCCESS);
    }
	return false;
}
#endif