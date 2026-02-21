import QtQuick 2.12
import QtQuick.Window 2.12

Window {
    width: 1024
    height: 600
    visible: true
    title: qsTr("E-Scooter Dashboard")
    color: "#0a0a0a"

    // Battery color logic
    function getBatteryColor() {
        if (dashboardData.batteryPercent > 50)
            return "#00ff88"
        if (dashboardData.batteryPercent > 20)
            return "#ffaa00"
        return "#ff3366"
    }

    // Top Bar - Weather & Status
    Rectangle {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 70
        color: "#111111"

        Row {
            anchors.centerIn: parent
            spacing: 20

            // Weather Info
            Rectangle {
                width: 220
                height: 50
                color: "#1a1a1a"
                radius: 10
                border.color: "#2a2a2a"
                border.width: 1

                Row {
                    anchors.centerIn: parent
                    spacing: 12

                    Text {
                        text: dashboardData.weatherIcon
                        font.pixelSize: 32
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        spacing: 2
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: dashboardData.temperature + "°C"
                            font.pixelSize: 22
                            font.bold: true
                            color: "#ffffff"
                        }
                        Text {
                            text: dashboardData.weatherDesc
                            font.pixelSize: 12
                            color: "#888888"
                        }
                    }
                }
            }

            // Riding Mode Badge
            Rectangle {
                width: 140
                height: 50
                color: "#004d3d"
                radius: 10

                Text {
                    anchors.centerIn: parent
                    text: dashboardData.ridingMode
                    font.pixelSize: 16
                    font.bold: true
                    color: "#00ff88"
                }
            }
        }
    }

    // Main Content Area
    Row {
        anchors.top: topBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 15
        spacing: 15

        // Left Column - Speed & Navigation
        Column {
            width: parent.width * 0.48
            height: parent.height
            spacing: 15

            // Speed Display - Much Larger
            Rectangle {
                width: parent.width
                height: parent.height * 0.55
                color: "#111111"
                radius: 15
                border.color: "#222222"
                border.width: 2

                Column {
                    anchors.centerIn: parent
                    spacing: 20

                    // Speed Circle
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 280
                        height: 280
                        radius: 140
                        color: "#0a0a0a"
                        border.color: "#00d9ff"
                        border.width: 6

                        // Animated glow effect
                        // Rectangle {
                        //     anchors.centerIn: parent
                        //     width: parent.width - 20
                        //     height: parent.height - 20
                        //     radius: (parent.width - 20) / 2
                        //     color: "transparent"
                        //     border.color: '#b73954'
                        //     border.width: 2
                        //     opacity: 0.3
                        // }

                        Column {
                            anchors.centerIn: parent
                            spacing: 0

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: dashboardData.speed
                                font.pixelSize: 110
                                font.bold: true
                                color: '#ff00c8'
                                font.family: "Arial"
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "km/h"
                                font.pixelSize: 24
                                color: "#666666"
                                font.letterSpacing: 2
                            }
                        }
                    }
                }
            }

            // Navigation Widget
            Rectangle {
                width: parent.width
                height: parent.height * 0.45 - 15
                color: "#111111"
                radius: 15
                border.color: "#222222"
                border.width: 2

                Column {
                    anchors.fill: parent
                    anchors.margins: 25
                    spacing: 15

                    Text {
                        text: "🧭 NAVIGATION"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#666666"
                        font.letterSpacing: 1
                    }

                    Row {
                        width: parent.width
                        spacing: 20

                        Text {
                            text: "➡️"
                            font.pixelSize: 56
                            color: "#ff9500"
                        }

                        Column {
                            spacing: 8
                            width: parent.width - 80

                            Text {
                                text: dashboardData.nextInstruction
                                font.pixelSize: 24
                                font.bold: true
                                color: "#ffffff"
                                wrapMode: Text.WordWrap
                            }
                             Text {
                                text: "Main Street"
                                font.pixelSize: 16
                                color: "#888888"
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#222222"
                    }

                    Row {
                        width: parent.width
                        spacing: 30

                        Column {
                            spacing: 4
                            Text {
                                text: "ETA"
                                font.pixelSize: 11
                                color: "#666666"
                            }
                            Text {
                                text: "12 min"
                                font.pixelSize: 18
                                font.bold: true
                                color: "#00d9ff"
                            }
                        }

                        Column {
                            spacing: 4
                            Text {
                                text: "DISTANCE"
                                font.pixelSize: 11
                                color: "#666666"
                            }
                            Text {
                                text: "2.5 km"
                                font.pixelSize: 18
                                font.bold: true
                                color: "#00d9ff"
                            }
                        }

                        Column {
                            spacing: 4
                            Text {
                                text: "DESTINATION"
                                font.pixelSize: 11
                                color: "#666666"
                            }
                            Text {
                                text: "Home"
                                font.pixelSize: 18
                                font.bold: true
                                color: "#ffffff"
                            }
                        }
                    }
                }
            }
        }

        // Right Column - Battery & Music
        Column {
            width: parent.width * 0.52 - 15
            height: parent.height
            spacing: 15

            // Battery Widget
            Rectangle {
                width: parent.width
                height: parent.height * 0.55
                color: "#111111"
                radius: 15
                border.color: "#222222"
                border.width: 2

                Column {
                    anchors.centerIn: parent
                    spacing: 25

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 12

                        Text {
                            text: "🔋"
                            font.pixelSize: 28
                        }

                        Text {
                            text: "BATTERY"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#666666"
                            font.letterSpacing: 2
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // Large Battery Percentage
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: dashboardData.batteryPercent + "%"
                        font.pixelSize: 90
                        font.bold: true
                        color: getBatteryColor()

                        Behavior on color {
                            ColorAnimation { duration: 500 }
                        }
                    }

                    // Battery Bar
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 380
                        height: 50
                        color: "#0a0a0a"
                        radius: 25
                        border.color: getBatteryColor()
                        border.width: 3

                        Behavior on border.color {
                            ColorAnimation { duration: 500 }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.margins: 5
                            width: Math.max(0, (parent.width - 10) * (dashboardData.batteryPercent / 100))
                            color: getBatteryColor()
                            radius: 20

                            Behavior on width {
                                NumberAnimation { duration: 400; easing.type: Easing.OutQuad }
                            }

                            Behavior on color {
                                ColorAnimation { duration: 500 }
                            }

                            // Shine effect
                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.margins: 2
                                width: parent.width * 0.4
                                radius: 18
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "#ffffff" }
                                    GradientStop { position: 1.0; color: "transparent" }
                                }
                                opacity: 0.2
                            }
                        }
                    }

                    // Range Estimate
                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 6

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "ESTIMATED RANGE"
                            font.pixelSize: 12
                            color: "#666666"
                            font.letterSpacing: 1
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "~" + Math.floor(dashboardData.batteryPercent * 0.23) + " km"
                            font.pixelSize: 26
                            font.bold: true
                            color: "#ffffff"
                        }
                    }
                }
            }

            // Music Player
            Rectangle {
                width: parent.width
                height: parent.height * 0.45 - 15
                color: "#111111"
                radius: 15
                border.color: "#222222"
                border.width: 2

                Column {
                    anchors.fill: parent
                    anchors.margins: 25
                    spacing: 20

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "🎵 NOW PLAYING"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#666666"
                        font.letterSpacing: 1
                    }

                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: dashboardData.songTitle
                            font.pixelSize: 26
                            font.bold: true
                            color: "#ffffff"
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: dashboardData.artistName
                            font.pixelSize: 18
                            color: "#888888"
                        }
                    }

                    // Progress Bar
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width - 40
                        height: 6
                        color: "#222222"
                        radius: 3

                        Rectangle {
                            width: parent.width * 0.6
                            height: parent.height
                            color: "#00d9ff"
                            radius: 3
                        }
                    }

                    // Playback Controls
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 25

                        Rectangle {
                            width: 60
                            height: 60
                            radius: 30
                            color: "#1a1a1a"
                            border.color: "#333333"
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: "⏮"
                                font.pixelSize: 28
                                color: "#ffffff"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                            }
                        }

                        Rectangle {
                            width: 80
                            height: 80
                            radius: 40
                            color: "#00d9ff"

                            Text {
                                anchors.centerIn: parent
                                text: dashboardData.isPlaying ? "⏸" : "▶"
                                font.pixelSize: 36
                                color: "#0a0a0a"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                            }

                            SequentialAnimation on scale {
                                running: dashboardData.isPlaying
                                loops: Animation.Infinite
                                NumberAnimation { to: 1.05; duration: 1000; easing.type: Easing.InOutQuad }
                                NumberAnimation { to: 1.0; duration: 1000; easing.type: Easing.InOutQuad }
                            }
                        }

                        Rectangle {
                            width: 60
                            height: 60
                            radius: 30
                            color: "#1a1a1a"
                            border.color: "#333333"
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: "⏭"
                                font.pixelSize: 28
                                color: "#ffffff"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }
            }
        }
    }
}