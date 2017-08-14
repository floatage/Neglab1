import QtQuick 2.0
import QtQuick.Controls 1.3

Rectangle{
    id: plotPanel

    property var parentRef: null
    property Component floatComponent: null
    property var floatInstance: null

    //0: ready  1: ploting  2: pause  3: finished
    property int plotStatus: 0
    property var gatherInfor: null

    Component {
        id: iconItem

        Rectangle{
            id: iconRect
            width: iconLen
            height: iconLen

            property real iconLen : 20
            property string imgSource
            property real imgScale: 1.0

            signal iconClicked()

            Image {
                id:iconPic
                source: imgSource
                scale: imgScale
                smooth: true
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton
                property var mask: null

                onClicked: {
                    iconRect.iconClicked()
                }

                onPressed: {
                    if (mask === null){
                        mask = Qt.createQmlObject(
                                    'import QtGraphicalEffects 1.0;ColorOverlay{anchors.fill:iconPic;source:iconPic;color:"#6DF"}',
                                    iconRect, "")
                    }
                    iconPic.scale *= 0.9
                }

                onReleased: {
                    if (mask !== null)
                        mask.destroy()
                    iconPic.scale /= 0.9
                }
            }
        }
    }

    Rectangle{
        id: plotAreaToolBar
        width: parent.width
        height: 40

        Rectangle{
            id: fileIconGroup
            width:parent.width * 0.195
            height: parent.height * 0.5
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.05
            anchors.verticalCenter: parent.verticalCenter

            Row{
                spacing: (parent.width - creatIcon.width*3)/2

                Loader {
                    id: creatIcon
                    sourceComponent: iconItem
                    onLoaded: item.imgSource = "/img/creat.png"
                }

                Loader {
                    id: saveIcon
                    sourceComponent: iconItem
                    onLoaded: item.imgSource = "/img/save.png"
                }

                Loader {
                    id: openIcon
                    sourceComponent: iconItem
                    onLoaded: {
                        item.imgSource = "/img/open.png"
                    }
                }
            }
        }

        Rectangle{
            id: plotAreaToolBarSplitLine
            width: 1
            height: parent.height * 0.5
            anchors.left: fileIconGroup.right
            anchors.leftMargin: parent.width * 0.05
            anchors.verticalCenter: parent.verticalCenter
            color: "#F2F2F2"
        }

        Rectangle{
            id: deviceIconGroup
            width:parent.width * 0.252
            height: parent.height * 0.625
            anchors.left: plotAreaToolBarSplitLine.right
            anchors.leftMargin: parent.width * 0.05
            anchors.verticalCenter: parent.verticalCenter

            Row{
                id: deviceIconGroupRow
                spacing: (parent.width - inforIcon.width*4)/3
                anchors.verticalCenter: parent.verticalCenter

                Loader {
                    id: inforIcon
                    sourceComponent: iconItem
                    onLoaded: {
                        item.imgSource = "/img/userinfor.png"
                        item.imgScale = 0.85
                    }

                    Connections{
                        target: inforIcon.item
                        onIconClicked: {
                            var rootItemComponent = plotPanel.floatComponent
                            if(rootItemComponent === null){
                                rootItemComponent = Qt.createComponent("GatherInforPanel.qml");
                            }

                            if (plotPanel.floatInstance === null){
                                if(rootItemComponent.status === Component.Ready) {
                                    var wx = deviceIconGroup.x - 245
                                    var wy = plotAreaToolBar.y + plotAreaToolBar.height
                                    plotPanel.floatInstance = rootItemComponent.createObject(plotPanel, {"parentRef":plotPanel, "x":wx, "y":wy});
                                }
                            }
                            else{
                                plotPanel.floatInstance.destroy()
                            }
                        }
                    }
                }

                Loader {
                    id: deviceStartIcon
                    sourceComponent: iconItem
                    onLoaded: {
                        item.imgSource = "/img/start.png"
                        item.imgScale = 0.85
                    }

                    Connections{
                        target: deviceStartIcon.item
                        onIconClicked: {
                            if (plotPanel.plotStatus === 0 || plotPanel.plotStatus === 2){
                                plotPanel.plotStatus = 1
                                deviceStartIcon.item.imgSource = "/img/pause.png"
                            }
                            else if(plotPanel.plotStatus == 1){
                                plotPanel.plotStatus = 2
                                deviceStartIcon.item.imgSource = "/img/start.png"
                            }
                        }
                    }
                }

//                Loader {
//                    id: devicePauseIcon
//                    sourceComponent: iconItem
//                    onLoaded: {
//                        item.imgSource = "/img/pause.png"
//                        item.imgScale = 0.85
//                    }
//                }

                Loader {
                    id: deviceStopIcon
                    sourceComponent: iconItem
                    onLoaded: {
                        item.imgSource = "/img/stop.png"
                        item.imgScale = 0.85
                    }
                }
            }
        }

        Rectangle{
            id: plotIconGroup
            width:parent.width * 0.272
            height: parent.height * 0.625
            anchors.right: parent.right
            anchors.rightMargin: parent.width * 0.025
            anchors.verticalCenter: parent.verticalCenter

            Component {
                id: switchButtonIcon

                Rectangle{
                    id: clickArea
                    width: 60
                    height: 25
                    radius: 5
                    color: isSelected ? selectColor : disSelectColor
                    border.width: isSelected ? 0 : 1
                    border.color: "#F2F2F2"

                    property string buttonText : 'value'
                    property color selectColor : "#999"
                    property color disSelectColor: "#FFF"
                    property color selectTextColor : "#333"
                    property color disSelectTextColor: "#FFF"
                    property bool isSelected: false

                    Label{
                        id: clickAreaText
                        text:buttonText
                        font.family: "微软雅黑"
                        font.pixelSize: 12
                        font.letterSpacing: 2
                        color: isSelected ? disSelectTextColor : selectTextColor
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton
                        onClicked:{
                            if (isSelected){
                                clickArea.color =  disSelectColor
                                clickArea.border.width = 1
                                clickAreaText.color = selectTextColor
                                isSelected = false
                            }
                            else{
                                clickArea.color =  selectColor
                                clickArea.border.width = 0
                                clickAreaText.color = disSelectTextColor
                                isSelected = true
                            }
                        }
                    }
                }
            }

            Row{
                spacing: (parent.width - dataPlotMode.width*3)/2
                Loader {
                    id: dataPlotMode
                    sourceComponent: switchButtonIcon
                    onLoaded: {
                        item.buttonText = "数据"
                        item.isSelected = true
                    }
                }

                Loader {
                    id: implancePlotMode
                    sourceComponent: switchButtonIcon
                    onLoaded: {
                        item.buttonText = "阻抗"
                    }
                }

                Loader {
                    id: ratePlotMode
                    sourceComponent: switchButtonIcon
                    onLoaded: {
                        item.buttonText = "频谱"
                    }
                }
            }
        }

        Rectangle {
            id: plotAreaToolBarBottomBorder
            width: parent.width
            height: 1
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            color: "#66FFFF"
        }
    }

    Rectangle{
        id: plotArea
        width: parent.width
        height: parent.height - plotAreaToolBar.height
        anchors.top: plotAreaToolBar.bottom
    }
}

