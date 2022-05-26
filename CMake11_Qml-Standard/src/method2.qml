import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.4

Item
{
	width:500
	height:500

	Rectangle{
		id:idRect1
		objectName : "objRect1"
		color: "teal"
		width:300
		height:300

        Text
        {
            text:"this is method2.qml"
        }
	}
}
