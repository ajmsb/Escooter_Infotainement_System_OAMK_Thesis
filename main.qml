import QtQuick
import QtQuick.Window
import QtLocation
import QtPositioning
import Qt5Compat.GraphicalEffects

Window {
    id: root
    minimumWidth: 640
    minimumHeight: 360
    maximumWidth: minimumWidth
    maximumHeight: minimumHeight
    visible: true
    title: qsTr("E-Scooter Dashboard")
    color: "#0a0a0a"
    // Colors properties
    property string eGreen: "#caff00"
    property string eGrey: "#3d3d3d"
    property string eLightGrey: "#c2c2c2"

    property var dashboardData

    // Battery color logic
    function getBatteryColor() {
        const percent = root.dashboardData ? root.dashboardData.batteryPercent : 0
        if (percent > 50)
            return root.eGreen
        if (percent > 20)
            return "#ffaa00"
        return "#ff3366"
    }

    Row {
        spacing: 20
        anchors.centerIn: parent
        // Menu Column
        Column {
            spacing: 20
            anchors.verticalCenter: parent.verticalCenter

            Row {
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter
                Rectangle {
                    width: 40
                    height: 40
                    color: "#111111"
                    radius: 10
                    border.color: "#222222"
                    border.width: 2
                }
            }
            Row {
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter
                Rectangle {
                    width: 40
                    height: 40
                    color: "#111111"
                    radius: 10
                    border.color: "#222222"
                    border.width: 2
                }
            }
            Row {
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter
                Rectangle {
                    width: 40
                    height: 40
                    color: "#111111"
                    radius: 10
                    border.color: "#222222"
                    border.width: 2
                }
            }
            Row {
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter
                Rectangle {
                    width: 40
                    height: 40
                    color: "#111111"
                    radius: 10
                    border.color: "#222222"
                    border.width: 2
                }
            }
            Row {
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter
                Rectangle {
                    width: 40
                    height: 80
                    color: "#111111"
                    radius: 10
                    border.color: "#222222"
                    border.width: 2
                }
            }
        }
        // Display Column
        Column {
            spacing: 20
            anchors.verticalCenter: parent.verticalCenter

            //Time & Weather Row
            Row {
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter
                Column {
                    spacing: 10
                    Rectangle {
                        width: 140
                        height: 100
                        color: "#111111"
                        radius: 10
                        border.color: "#222222"
                        border.width: 2

                        Column {
                            spacing: -15
                            anchors.centerIn: parent
                            Text {
                                id: tempText

                                anchors.horizontalCenter: parent.horizontalCenter
                                text: new Date().toLocaleDateString(
                                          Qt.locale(),
                                          "dddd") + " " + (root.dashboardData ? root.dashboardData.temperature : "--") + "°C"
                                color: root.eGreen
                                font.pointSize: 14
                                font.bold: false
                                //horizontalAlignment: Text.AlignHCenter
                                //verticalAlignment: Text.AlignVCenter
                            }
                            Text {
                                //anchors.top: tempText.bottom
                                anchors.horizontalCenter: parent.horizontalCenter

                                text: new Date().toLocaleTimeString(
                                          Qt.locale(), "h:mm")
                                color: root.eGreen
                                font.pointSize: 35
                                font.bold: true
                                //horizontalAlignment: Text.AlignHCenter
                                //verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }

            // Mode Selection
            Row {
                spacing: 5
                anchors.horizontalCenter: parent.horizontalCenter
                Rectangle {
                    width: 68
                    height: 40
                    color: "#caff00"
                    radius: 10
                    // border.color: "#222222"
                    // border.width: 2
                    Text {
                        anchors.centerIn: parent
                        text: "ECO"
                        color: "#000000"
                        font.pointSize: 12
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                Rectangle {
                    width: 68
                    height: 40
                    color: "#111111"
                    radius: 10
                    border.color: "#222222"
                    border.width: 2
                    Text {
                        anchors.centerIn: parent
                        text: "TRB"
                        color: root.eGreen
                        font.pointSize: 12
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
            // Media Player Row
            Row {
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter
                Rectangle {
                    width: 140
                    height: 140
                    color: "#111111"
                    radius: 10
                    border.color: "#222222"
                    border.width: 2
                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        topPadding: 10
                        text: "Media Player\n TBD"
                        color: root.eGreen
                        font.pointSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.margins: 10
                        spacing: 5

                        Rectangle {
                            width: 30
                            height: 30
                            color: root.eGreen
                            radius: 15
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                id: previous
                                font.pixelSize: 20
                                text: "<"
                                color: "#000000"
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                //anchors.verticalCenter: parent.verticalCenter
                                //anchors.centerIn: parent
                                leftPadding: 8
                            }
                        }
                        Rectangle {
                            width: 50
                            height: 50
                            color: root.eGreen
                            radius: 25
                            Text {
                                id: name
                                font.pixelSize: 52
                                text: "▶"
                                color: "#000000"
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                anchors.verticalCenter: parent.verticalCenter
                                leftPadding: 15
                            }

                        }
                        Rectangle {
                            width: 30
                            height: 30
                            color: root.eGreen
                            radius: 15
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                id: next
                                font.pixelSize: 20
                                text: ">"
                                color: "#000000"
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                //anchors.verticalCenter: parent.verticalCenter
                                //anchors.centerIn: parent
                                leftPadding: 8
                            }
                        }
                    }

                }
            }
        }
        // Speed Column
        Column {
            spacing: 0
            leftPadding: 20
            //anchors.verticalCenter: parent.verticalCenter
            //Speed Bar
            Row {

                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 160
                    height: 140
                    color: "#111111"
                    radius: 10
                    border.color: "#222222"
                    border.width: 2

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: Math.max(
                                    (parent.height - 4)
                                    * ((root.dashboardData ? root.dashboardData.speed : 0) / 25),
                                    0)
                        color: root.eGreen
                        radius: parent.radius

                        Behavior on height {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: (root.dashboardData ? root.dashboardData.speed : 0) + " km/h"
                        color: "#000000"
                        font.pointSize: 20
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            // Batterie bar
            Row {
                // topPadding: 0
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter
                Column {
                    id: col

                    //anchors.verticalCenter: parent.verticalCenter
                    Text {
                        text: "BATTERY"
                        color: root.eGreen
                        font.pointSize: 12
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        id: batteryRect
                        width: 160
                        height: 40
                        color: root.eGrey
                        radius: 10
                        Rectangle {
                            anchors.left: batteryRect.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: Math.max(
                                       0,
                                       (parent.width) * ((root.dashboardData ? root.dashboardData.batteryPercent : 0) / 100))
                            color: root.getBatteryColor()
                            radius: parent.radius
                            Text {
                                anchors.centerIn: parent
                                text: (root.dashboardData ? root.dashboardData.batteryPercent : 0)
                                      + "%"
                                color: "#000000"
                                font.pointSize: 16
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            Behavior on width {
                                NumberAnimation {
                                    duration: 400
                                    easing.type: Easing.OutQuad
                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 500
                                }
                            }
                        }
                    }
                }
            }
            Row {
                // topPadding: 0
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter
                Column {

                    //anchors.verticalCenter: parent.verticalCenter
                    Text {
                        text: "RIDING TIME"
                        color: root.eGreen
                        font.pointSize: 12
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        width: 160
                        height: 40
                        color: root.eGrey
                        radius: 10
                        Rectangle {
                            width: 160
                            height: 40
                            color: root.eGrey
                            radius: 10
                            Text {
                                anchors.centerIn: parent
                                text: "TBD"
                                color: "#000000"
                                font.pointSize: 16
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }
            Row {
                // topPadding: 0
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter
                Column {

                    Text {
                        text: "RANGE"
                        color: root.eGreen
                        font.pointSize: 12
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        width: 160
                        height: 40
                        color: root.eGrey
                        radius: 10
                        Text {
                            anchors.centerIn: parent
                            text: "TBD"
                            color: "#000000"
                            font.pointSize: 16
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            // Row {
            //     spacing: 20
            //     anchors.horizontalCenter: parent.horizontalCenter
            //     Rectangle {
            //         width: 160
            //         height: 40
            //         color: "#111111"
            //         radius: 10
            //         border.color: "#222222"
            //         border.width: 2
            //     }
            // }
            // Row {
            //     spacing: 20
            //     anchors.horizontalCenter: parent.horizontalCenter
            //     Rectangle {
            //         width: 160
            //         height: 40
            //         color: "#111111"
            //         radius: 10
            //         border.color: "#222222"
            //         border.width: 2
            //     }
            // }
        }
        // Map Column
        Column {
            spacing: 20
            anchors.verticalCenter: parent.verticalCenter
            Row {
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter
                // Map placeholder
                Rectangle {
                    width: 200
                    height: 320
                    color: "#111111"
                    radius: 10
                    border.color: "#222222"
                    border.width: 2

                    Loader {
                        id: mapLoader
                        anchors.fill: parent
                        anchors.margins: 2
                        sourceComponent: mapComponent
                        onStatusChanged: {
                            if (status === Loader.Error) {
                                console.warn("Map failed to load - using placeholder")
                                sourceComponent = null
                            }
                        }
                    }

                    Component {
                        id: mapComponent

                        Item {
                            Map {
                                id: theMap
                                anchors.fill: parent
                                plugin: Plugin {
                                    name: "osm"
                                }
                                center: QtPositioning.coordinate(
                                            65.0121, 25.4651) // Oulu, Finland
                                zoomLevel: 13
                                visible: false
                            }

                            Rectangle {
                                id: maskRect
                                anchors.fill: parent
                                radius: 10
                                visible: false
                            }

                            OpacityMask {
                                id: maskedMap
                                anchors.fill: parent
                                source: theMap
                                maskSource: maskRect

                                MouseArea {
                                    anchors.fill: parent

                                    property point startPos
                                    property var startCenter

                                    onPressed: function (mouse) {
                                        startPos = Qt.point(mouse.x, mouse.y)
                                        startCenter = theMap.center
                                    }

                                    onPositionChanged: function (mouse) {
                                        if (pressed) {
                                            // Convert start and current positions to coordinates
                                            var startCoord = theMap.toCoordinate(
                                                        startPos)
                                            var currentCoord = theMap.toCoordinate(
                                                        Qt.point(mouse.x,
                                                                 mouse.y))

                                            // Calculate the difference
                                            var latDiff = startCoord.latitude
                                                    - currentCoord.latitude
                                            var lonDiff = startCoord.longitude
                                                    - currentCoord.longitude

                                            // Apply the difference to the original center
                                            theMap.center = QtPositioning.coordinate(
                                                        startCenter.latitude + latDiff,
                                                        startCenter.longitude + lonDiff)
                                        }
                                    }

                                    onWheel: function (wheel) {
                                        if (wheel.angleDelta.y > 0) {
                                            theMap.zoomLevel = Math.min(
                                                        theMap.zoomLevel + 1,
                                                        theMap.maximumZoomLevel)
                                        } else {
                                            theMap.zoomLevel = Math.max(
                                                        theMap.zoomLevel - 1,
                                                        theMap.minimumZoomLevel)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
