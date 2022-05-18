import QtQuick 2.1
import QtQuick.Window 2.1

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    Rectangle
    {
        anchors.fill: parent
        color: "cyan"
		Text
		{
            id: idText
            anchors.centerIn: parent
			text: "Hello World_1st!!!"
		}

        
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: idText.text = "ret:" + scale.ret + "\nweight:" + scale.weight + "\ntare:" + scale.tare//Date().toString()
    }
}
