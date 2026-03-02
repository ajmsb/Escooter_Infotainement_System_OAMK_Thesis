import QtQuick
import QtQuick.Window
import QtLocation
import QtPositioning
import Qt5Compat.GraphicalEffects
import QtMultimedia


Window {
    id: root
    minimumWidth: 640
    minimumHeight: 360
    maximumWidth: minimumWidth
    maximumHeight: minimumHeight
    visible: true
    title: qsTr("E-Scooter Dashboard")
    color: bgColor
    // Colors properties
    property string eGreen: "#caff00"
    property string eGrey: "#3d3d3d"
    property string eLightGrey: "#c2c2c2"
    property string bgColor: "#0a0a0a"

    property var dashboardData
    property var routeSimulator

    // Battery color logic
    function getBatteryColor() {
        const percent = root.dashboardData ? root.dashboardData.batteryPercent : 0
        if (percent > 50)
            return root.eGreen
        if (percent > 20)
            return "#ffaa00"
        return "#ff3366"
    }
    
    // Format milliseconds to mm:ss
    function formatTime(milliseconds) {
        if (isNaN(milliseconds) || milliseconds <= 0) {
            return "0:00"
        }
        var totalSeconds = Math.floor(milliseconds / 1000)
        var minutes = Math.floor(totalSeconds / 60)
        var seconds = totalSeconds % 60
        return minutes + ":" + (seconds < 10 ? "0" : "") + seconds
    }
    
    // Extract song name from file path
    function getSongName(filePath) {
        if (filePath === "" || filePath === null) {
            return "No File"
        }
        var path = filePath.toString()
        var fileName = path.substring(path.lastIndexOf('/') + 1)
        // Remove .mp3 extension
        if (fileName.endsWith(".mp3")) {
            fileName = fileName.substring(0, fileName.length - 4)
        }
        return fileName
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

                // Media player backend
                MediaPlayer {
                    id: audioPlayer
                    source: "qrc:/assets/media/The Rosenberg Trio - For Sephora (Instrumental).mp3"
                    audioOutput: AudioOutput {
                        id: audioOutput
                        volume: 0.7
                    }
                    
                    onPlaybackStateChanged: {
                        console.log("Playback state:", playbackState)
                    }
                    
                    onMetaDataChanged: {
                        console.log("Metadata changed")
                        console.log("Title:", metaData.stringValue(MediaMetaData.Title))
                        console.log("Artist:", metaData.stringValue(MediaMetaData.Artist))
                        
                        // Try to get cover art - check different metadata keys
                        var coverArtUrl = metaData.value(MediaMetaData.CoverArtUrlLarge) 
                                       || metaData.value(MediaMetaData.CoverArtUrlSmall)
                                       || metaData.value(MediaMetaData.ThumbnailImage)
                        
                        console.log("Cover art URL type:", typeof coverArtUrl)
                        console.log("Cover art URL:", coverArtUrl)
                        
                        if (coverArtUrl && coverArtUrl.toString() !== "") {
                            albumArt.source = coverArtUrl
                        }
                    }
                }
                
                //media player UI
                Rectangle {
                    id: mediaPlayerUI
                    width: 140
                    height: 140
                    color: "transparent"
                    radius: 10
                    border.color: "#222222"
                    border.width: 2
                    clip: true
                    
                    // Album art
                    Image {
                        id: albumArt
                        anchors.fill: mediaPlayerUI
                        source: "qrc:/assets/media/cover.jpg"
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        z: 4
                        
                        Component.onCompleted: {
                            console.log("=== ALBUM ART DEBUG ===")
                            console.log("Source:", source)
                            console.log("Status:", status)
                            console.log("Width:", width, "Height:", height)
                        }
                        
                        onStatusChanged: {
                            console.log("Album art status:", status, "(0=Null, 1=Ready, 2=Loading, 3=Error)")
                        }
                    }                   
                    
                    // Song info and progress
                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 5

                        // Song title
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: {
                                var title = audioPlayer.metaData.stringValue(MediaMetaData.Title)
                                if (title && title !== "") {
                                    return title
                                }
                                return root.getSongName(audioPlayer.source)
                            }
                            color: root.eGreen
                            font.pointSize: 12
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            width: parent.width
                            style: Text.Outline
                            styleColor: "#000000"
                        }
                        
                        // Progress indicator
                        Rectangle {
                            width: 120
                            height: 4
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: root.eGrey
                            radius: 2
                            
                            Rectangle {
                                width: audioPlayer.duration > 0 ? (parent.width * audioPlayer.position / audioPlayer.duration) : 0
                                height: parent.height
                                color: root.eGreen
                                radius: parent.radius
                                
                                Behavior on width {
                                    NumberAnimation { duration: 100 }
                                }
                            }
                        }
                        
                        // Time display
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: formatTime(audioPlayer.position) + " / " + formatTime(audioPlayer.duration)
                            color: root.eLightGrey
                            font.pointSize: 10
                            horizontalAlignment: Text.AlignHCenter
                            style: Text.Outline
                            styleColor: "#000000"
                        }
                    }

                    // Playback controls
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.margins: 10
                        spacing: 5
                        z: 1

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
                                leftPadding: 8
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    audioPlayer.position = Math.max(0, audioPlayer.position - 5000)
                                }
                            }
                        }
                        
                        Rectangle {
                            width: 50
                            height: 50
                            color: root.eGreen
                            radius: 25
                            
                            Text {
                                id: playPauseIcon
                                font.pixelSize: 52
                                text: audioPlayer.playbackState === MediaPlayer.PlayingState ? "ll" : "▶"
                                color: "#000000"
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                anchors.verticalCenter: parent.verticalCenter
                                leftPadding: text === "▶" ? 15 : 12
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (audioPlayer.source.toString() === "") {
                                        console.log("No audio file loaded")
                                        return
                                    }
                                    
                                    if (audioPlayer.playbackState === MediaPlayer.PlayingState) {
                                        audioPlayer.pause()
                                    } else {
                                        audioPlayer.play()
                                    }
                                }
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
                                leftPadding: 8
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    audioPlayer.position = Math.min(audioPlayer.duration, audioPlayer.position + 5000)
                                }
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
                        text: "REMAINING TIME"
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
                        text: "DISTANCE"
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
                            text: root.dashboardData 
                                ? (root.dashboardData.distance).toFixed(2) + " km"
                                : "0.00 km"
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
                                center: root.dashboardData && root.dashboardData.isRiding 
                                    ? QtPositioning.coordinate(
                                        root.dashboardData.latitude,
                                        root.dashboardData.longitude)
                                    : QtPositioning.coordinate(65.012295, 25.470932)
                                zoomLevel: 14
                                visible: false
                                
                                // Route polyline - shows the path following roads
                                MapPolyline {
                                    id: routeLine
                                    line.width: 4
                                    line.color: root.bgColor
                                    path: [
                                        QtPositioning.coordinate(65.012295, 25.470932),
                                        QtPositioning.coordinate(65.012615, 25.471401),
                                        QtPositioning.coordinate(65.012653, 25.471447),
                                        QtPositioning.coordinate(65.012691, 25.471509),
                                        QtPositioning.coordinate(65.013001, 25.471958),
                                        QtPositioning.coordinate(65.013068, 25.472055),
                                        QtPositioning.coordinate(65.013216, 25.472270),
                                        QtPositioning.coordinate(65.013343, 25.472452),
                                        QtPositioning.coordinate(65.013442, 25.472598),
                                        QtPositioning.coordinate(65.013515, 25.472695),
                                        QtPositioning.coordinate(65.013837, 25.473170),
                                        QtPositioning.coordinate(65.013920, 25.473296),
                                        QtPositioning.coordinate(65.014118, 25.473597),
                                        QtPositioning.coordinate(65.014168, 25.473674),
                                        QtPositioning.coordinate(65.014197, 25.473560),
                                        QtPositioning.coordinate(65.014213, 25.473502),
                                        QtPositioning.coordinate(65.014335, 25.473057),
                                        QtPositioning.coordinate(65.014369, 25.472934),
                                        QtPositioning.coordinate(65.014384, 25.472880),
                                        QtPositioning.coordinate(65.014395, 25.472839),
                                        QtPositioning.coordinate(65.014628, 25.471988),
                                        QtPositioning.coordinate(65.014660, 25.471870),
                                        QtPositioning.coordinate(65.014684, 25.471783),
                                        QtPositioning.coordinate(65.014729, 25.471843),
                                        QtPositioning.coordinate(65.014809, 25.471806),
                                        QtPositioning.coordinate(65.014857, 25.471892),
                                        QtPositioning.coordinate(65.015095, 25.472248),
                                        QtPositioning.coordinate(65.015187, 25.472384),
                                        QtPositioning.coordinate(65.015247, 25.472458),
                                        QtPositioning.coordinate(65.015286, 25.472520),
                                        QtPositioning.coordinate(65.015702, 25.473147),
                                        QtPositioning.coordinate(65.015758, 25.473207),
                                        QtPositioning.coordinate(65.015795, 25.473260),
                                        QtPositioning.coordinate(65.015891, 25.472904),
                                        QtPositioning.coordinate(65.015992, 25.472527),
                                        QtPositioning.coordinate(65.016094, 25.472350),
                                        QtPositioning.coordinate(65.016297, 25.471599),
                                        QtPositioning.coordinate(65.016319, 25.471491),
                                        QtPositioning.coordinate(65.016342, 25.471010),
                                        QtPositioning.coordinate(65.016388, 25.470851),
                                        QtPositioning.coordinate(65.016942, 25.469930),
                                        QtPositioning.coordinate(65.017204, 25.469516),
                                        QtPositioning.coordinate(65.017578, 25.468907),
                                        QtPositioning.coordinate(65.017590, 25.468887),
                                        QtPositioning.coordinate(65.017734, 25.468710),
                                        QtPositioning.coordinate(65.018824, 25.468114),
                                        QtPositioning.coordinate(65.018935, 25.468126),
                                        QtPositioning.coordinate(65.019000, 25.468175),
                                        QtPositioning.coordinate(65.019100, 25.468305),
                                        QtPositioning.coordinate(65.019206, 25.468208),
                                        QtPositioning.coordinate(65.019235, 25.468192),
                                        QtPositioning.coordinate(65.019264, 25.468177),
                                        QtPositioning.coordinate(65.019322, 25.468162),
                                        QtPositioning.coordinate(65.019362, 25.468155),
                                        QtPositioning.coordinate(65.019401, 25.468155),
                                        QtPositioning.coordinate(65.019441, 25.468199),
                                        QtPositioning.coordinate(65.019558, 25.468117),
                                        QtPositioning.coordinate(65.020496, 25.468252),
                                        QtPositioning.coordinate(65.020549, 25.468260),
                                        QtPositioning.coordinate(65.020688, 25.468214),
                                        QtPositioning.coordinate(65.020765, 25.468213),
                                        QtPositioning.coordinate(65.021662, 25.468349),
                                        QtPositioning.coordinate(65.021716, 25.468390),
                                        QtPositioning.coordinate(65.021834, 25.468480),
                                        QtPositioning.coordinate(65.022046, 25.468507),
                                        QtPositioning.coordinate(65.022091, 25.468513),
                                        QtPositioning.coordinate(65.022145, 25.468518),
                                        QtPositioning.coordinate(65.022171, 25.468520),
                                        QtPositioning.coordinate(65.022298, 25.468541),
                                        QtPositioning.coordinate(65.022316, 25.468544),
                                        QtPositioning.coordinate(65.022427, 25.468561),
                                        QtPositioning.coordinate(65.022527, 25.468491),
                                        QtPositioning.coordinate(65.022554, 25.468484),
                                        QtPositioning.coordinate(65.023118, 25.468574),
                                        QtPositioning.coordinate(65.023135, 25.468595),
                                        QtPositioning.coordinate(65.023221, 25.468701),
                                        QtPositioning.coordinate(65.023409, 25.468901),
                                        QtPositioning.coordinate(65.023430, 25.468924),
                                        QtPositioning.coordinate(65.023528, 25.469031),
                                        QtPositioning.coordinate(65.023571, 25.469197),
                                        QtPositioning.coordinate(65.023591, 25.469201),
                                        QtPositioning.coordinate(65.023615, 25.469210),
                                        QtPositioning.coordinate(65.023689, 25.469234),
                                        QtPositioning.coordinate(65.023739, 25.469255),
                                        QtPositioning.coordinate(65.023765, 25.469259),
                                        QtPositioning.coordinate(65.023815, 25.469231),
                                        QtPositioning.coordinate(65.024034, 25.469405),
                                        QtPositioning.coordinate(65.024226, 25.469568),
                                        QtPositioning.coordinate(65.024380, 25.469949),
                                        QtPositioning.coordinate(65.024397, 25.469919),
                                        QtPositioning.coordinate(65.024406, 25.469853),
                                        QtPositioning.coordinate(65.024437, 25.469924),
                                        QtPositioning.coordinate(65.025045, 25.470413),
                                        QtPositioning.coordinate(65.025442, 25.470742),
                                        QtPositioning.coordinate(65.025492, 25.470801),
                                        QtPositioning.coordinate(65.025815, 25.471060),
                                        QtPositioning.coordinate(65.025853, 25.471090),
                                        QtPositioning.coordinate(65.025879, 25.470899),
                                        QtPositioning.coordinate(65.025899, 25.470752),
                                        QtPositioning.coordinate(65.026015, 25.470853),
                                        QtPositioning.coordinate(65.026279, 25.471060),
                                        QtPositioning.coordinate(65.026427, 25.471114),
                                        QtPositioning.coordinate(65.026626, 25.471166),
                                        QtPositioning.coordinate(65.026867, 25.471137),
                                        QtPositioning.coordinate(65.027114, 25.471035),
                                        QtPositioning.coordinate(65.027360, 25.470852),
                                        QtPositioning.coordinate(65.027637, 25.470579),
                                        QtPositioning.coordinate(65.027720, 25.470498),
                                        QtPositioning.coordinate(65.027701, 25.470169),
                                        QtPositioning.coordinate(65.027639, 25.470241),
                                        QtPositioning.coordinate(65.027324, 25.470527),
                                        QtPositioning.coordinate(65.027189, 25.470625),
                                        QtPositioning.coordinate(65.027070, 25.470689),
                                        QtPositioning.coordinate(65.026950, 25.470746)
                                    ]
                                }
                                
                                // Vehicle marker - shows current position
                                MapCircle {
                                    id: vehicleMarker
                                    center: root.dashboardData 
                                        ? QtPositioning.coordinate(
                                            root.dashboardData.latitude,
                                            root.dashboardData.longitude)
                                        : QtPositioning.coordinate(65.012295, 25.470932)
                                    radius: 20
                                    color: root.eGreen
                                    border.width: 3
                                    border.color: "#000000"
                                    opacity: 0.9
                                }
                                
                                // Start position marker
                                MapCircle {
                                    center: QtPositioning.coordinate(65.012295, 25.470932)
                                    radius: 15
                                    color: "#00aaff"
                                    border.width: 2
                                    border.color: "#ffffff"
                                }
                                
                                // End position marker
                                MapCircle {
                                    center: QtPositioning.coordinate(65.026950, 25.470746)
                                    radius: 15
                                    color: "#ff3366"
                                    border.width: 2
                                    border.color: "#ffffff"
                                }
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
                                    z: 0

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

                                // Start Ride Button
                                Rectangle {
                                    id: starJourney
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 5
                                    width: parent.width * .8
                                    height: 40
                                    radius: 10
                                    color: root.dashboardData && root.dashboardData.isRiding ? "#ff3366" : root.eGreen
                                    visible: true
                                    z: 10
                                    
                                    Behavior on color {
                                        ColorAnimation { duration: 300 }
                                    }
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: root.dashboardData && root.dashboardData.isRiding ? "STOP RIDE" : "START RIDE"
                                        color: "#000000"
                                        font.pointSize: 11
                                        font.bold: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            console.log("Button clicked!")
                                            if (root.routeSimulator) {
                                                console.log("Calling toggleRide()")
                                                root.routeSimulator.toggleRide()
                                            } else {
                                                console.log("routeSimulator is null!")
                                            }
                                        }
                                        cursorShape: Qt.PointingHandCursor
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
