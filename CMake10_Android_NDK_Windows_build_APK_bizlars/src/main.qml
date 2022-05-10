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
            
            anchors.centerIn: parent
			text: "Hello World_1st!!!"
		}
    }
}
