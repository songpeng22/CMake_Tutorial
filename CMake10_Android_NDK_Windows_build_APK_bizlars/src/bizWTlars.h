#pragma once

#include "bizlars.h"

#include <sstream>

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

class BizWTlars
{
private:
    short adcHandle;

public:
    BizWTlars();

    bool open(void);
    bool close(void);
    bool readWeight(int *weightOut, int *tareOut, int *state);
    bool zeroScale();
    bool setTare();
    bool clearTare();

private:
    bool makeAuthentication(bool withIdentityString, std::stringstream *IDstring = nullptr);    
    void checkForAuthentication();
    void checkForAuthentication(bool needAuthentication, bool needLogbook);
};


