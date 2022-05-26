pragma Singleton
import QtQuick 2.4
import Qt.Wes.Config 1.0

QtObject {
    //平台
    property bool isMoblie: Qt.platform.os==="android" || Qt.platform.os==="ios" //是否是安卓或者ios true为是 false为不是
	//颜色
	property color btnColorDown : "#909090"
	property color btnColorNormal : "#FEB648"
	property color btnColorBorderDown : "#17a81a"
	property color btnColorBorderNormal : "white"
	
    //基础单位
//    property int baseLength: Math.round(TextStandard.font.pixelSize * 72 / TextStandard.font.pointSize / 25.4 * 2)

//    function length(pureLength){
//        return isMoblie && pureLength ? Math.round( pureLength*baseLength) : baseLength
//    }
}

