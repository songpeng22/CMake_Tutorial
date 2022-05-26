//utils.js

var newComponent;
var newObject;

/*
 *  var component = Qt.createComponent("Button.qml");
    if (component.status == Component.Ready)
        component.createObject(parent, {x: 100, y: 100});
 */
function createComponentObject(qmlFilePath, parentItem)
{
    newComponent = Qt.createComponent(qmlFilePath);
    //Ready
    if (Component.Ready == newComponent.status) {
        newObject = newComponent.createObject(parentItem);
        console.log("[!!!OK!!!]component Creation:" + qmlFilePath + " component ready");
    }
    //Error
    else if (Component.Error == newComponent.status)
    {
        console.log("[!!!ERR!!!]component Creation:" + qmlFilePath + " component error " + newComponent.errorString());
    }
    else
        console.log("component Creation:" + qmlFilePath + " component not ready");

    if (newObject === null)
        console.log("component Creation: error creating " + qmlFilePath + " object");
    else
        return newObject;
}


