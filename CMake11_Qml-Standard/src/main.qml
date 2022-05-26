import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.4
import "utils.js" as MyScript
import Qt.Wes.Config 1.0

Window {
    id:root
	objectName: "objWindow1"
    visible: true
    width: 600
    height: 400
    title: qsTr("Hello World")
	//always on top
//	flags: Qt.WindowStaysOnTopHint

    property var object;

	Rectangle{
		id:idRect1
		objectName : "objRect1"
		color: "teal"
		height: idButton1.height
		anchors.left : parent.left
		anchors.right : parent.right

        MouseArea {
            anchors.fill: parent
            onPressed: {
                object = MyScript.createComponentObject(root,"method2.qml");
            }
            onReleased: {
                object.destroy(0);  //delay 0 ms to destroy
                console.log("object destroyed");
            }
        }

		Button {
			id: idButton1
			objectName: "objButton1"
			x: 0
			y: 0
			width: 173
			height: 88
			text: qsTr("txtButton1")
		}
	}
    Rectangle{
        id:idRect2
		objectName : "objRect2"
        color: "plum"
        height:parent.height * 2 / 3
        anchors.left : parent.left
        anchors.right : parent.right
        anchors.top:idRect1.bottom

		Image {
			id: idImageRoot
			objectName : "objImage"
			source: "images/background.png"
			Image {
				id: pole
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.bottom: parent.bottom
				source: "images/pole.png"
			}

			Image {
				id: wheel
				anchors.centerIn: parent
				source: "images/pinwheel.png"
				Behavior on rotation {
					NumberAnimation {
						duration: 250
					}
				}
			}

			MouseArea {
				anchors.fill: parent
				onClicked: wheel.rotation += 90
			}
		}
    }

    function setProperty( objectName,name,value )
    {
        console.log( "setProperty::objectName:" + objectName + ",name:" + name + ",value:" + value );
		if( objectName == "objImage" && name == "visible" )
			idImageRoot.visible = Boolean(value);

        return "some return value"
    }

    Component.onCompleted: {
        console.log( "GlobalVariant.value;",Global.value() );
        Global.setValue( Global.value() + 1 );
        console.log( "GlobalVariant.value;",Global.value() );

//		console.log("config:",Config.isMoblie);
    }

}
