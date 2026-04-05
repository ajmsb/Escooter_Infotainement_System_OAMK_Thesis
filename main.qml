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

    property bool menuOpen: false
    property bool statsViewOpen: false
    property var dashboardData
    property var routeSimulator
    property real currentTemperature: 0
    property string currentTime: new Date().toLocaleTimeString(Qt.locale(), "h:mm")

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: currentTime = new Date().toLocaleTimeString(Qt.locale(), "h:mm")
    }

    // Fetch current temperature from Open-Meteo API (Oulu, Finland)
    function fetchWeather() {
        var xhr = new XMLHttpRequest()
        var url = "https://api.open-meteo.com/v1/forecast?latitude=65.06087&longitude=25.46764&current=temperature_2m"
        xhr.open("GET", url)
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText)
                    currentTemperature = response.current.temperature_2m
                    console.log("Weather updated:", currentTemperature, "°C")
                } else {
                    console.warn("Weather fetch failed, status:", xhr.status)
                }
            }
        }
        xhr.send()
    }

    // Refresh weather every 10 minutes, fetch immediately on start
    Timer {
        id: weatherTimer
        interval: 600000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: fetchWeather()
    }

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

            // Menu Button 
            Row {
                id: menuButton
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter
                Rectangle {
                    width: 40
                    height: 40
                    color: "#111111"
                    radius: 10
                    border.color: "#222222"
                    border.width: 2

                    Image {
                        source: "qrc:/assets/icons/menu.png"
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        fillMode: Image.PreserveAspectFit
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.menuOpen = !root.menuOpen
                    }
                }
            }

            // Statistics preview Button 
            Row {
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter
                Rectangle {
                    id: statsButton
                    width: 40
                    height: 40
                    color: "#111111"
                    radius: 10
                    border.color: "#222222"
                    border.width: 2

                    Image {
                        source: "qrc:/assets/icons/bx_stats.png"
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        fillMode: Image.PreserveAspectFit
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.statsViewOpen = true
                    }
                }
            }

            // Lock control Button
            Row {
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter
                Rectangle {
                    id: lockControl
                    width: 40
                    height: 40
                    color: "#111111"
                    radius: 10
                    border.color: "#222222"
                    border.width: 2

                    Image {
                        id: lockOn
                        source: "qrc:/assets/icons/boxiconslock.png"
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        fillMode: Image.PreserveAspectFit
                    }
                    Image {
                        id: lockOff
                        source: "qrc:/assets/icons/boxiconslockopen.png"
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        fillMode: Image.PreserveAspectFit
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            // Toggle lock state (this is just a visual toggle for now)
                            if (lockOn.visible) {
                                lockOn.visible = false
                                lockOff.visible = true
                                lockControl.color = "#111111"

                                

                            } else {
                                lockOn.visible = true
                                lockOff.visible = false
                                lockControl.color = root.eGreen
                                
                            }
                        }
                    }
                }
            }

            // Head Light control button
            Row {
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter
                Rectangle {
                    id: headlightControl
                    width: 40
                    height: 40
                    color: "#111111"
                    radius: 10
                    border.color: "#222222"
                    border.width: 2

                    Image {
                        id: headlightOn
                        source: "qrc:/assets/icons/Head_light.png"
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        fillMode: Image.PreserveAspectFit
                    }
                    Image {
                        id: headlightOff
                        source: "qrc:/assets/icons/Head_light_off.png"
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        fillMode: Image.PreserveAspectFit
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            // Toggle headlight state (this is just a visual toggle for now)
                            if (headlightOn.visible) {
                                headlightOn.visible = false
                                headlightOff.visible = true
                                headlightControl.color = "#111111"

                                

                            } else {
                                headlightOn.visible = true
                                headlightOff.visible = false
                                headlightControl.color = root.eGreen
                                
                            }
                        }
                    }
                }
            }

            // Volume control slider
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
                    clip: true

                    // Volume fill (grows from bottom)
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: parent.height * audioOutput.volume
                        color: root.eGreen
                        radius: parent.radius
                        opacity: 0.8

                        Behavior on height {
                            NumberAnimation { duration: 100 }
                        }
                    }

                    // Volume icon
                    Image {
                        source: audioOutput.volume == 0
                            ? "qrc:/assets/icons/svg-path.png"
                            : "qrc:/assets/icons/svg-path-3.png"

                        anchors.centerIn: parent
                        width: 20
                        height: 20
                        fillMode: Image.PreserveAspectFit
                        z: 1
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: function(mouse) {
                            // Map click Y position to volume (top = 1.0, bottom = 0.0)
                            var vol = 1.0 - (mouse.y / parent.height)
                            audioOutput.volume = Math.max(0, Math.min(1, vol))
                        }
                        onPositionChanged: function(mouse) {
                            if (pressed) {
                                var vol = 1.0 - (mouse.y / parent.height)
                                audioOutput.volume = Math.max(0, Math.min(1, vol))
                            }
                        }
                    }
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
                            spacing: -10
                            anchors.centerIn: parent
                            Text {
                                id: tempText

                                anchors.horizontalCenter: parent.horizontalCenter
                                text: new Date().toLocaleDateString(
                                          Qt.locale(),
                                          "dddd") + " " + root.currentTemperature.toFixed(1) + "°C"
                                color: root.eGreen
                                font.pointSize: 12
                                font.bold: false
                                //horizontalAlignment: Text.AlignHCenter
                                //verticalAlignment: Text.AlignVCenter
                            }
                            Text {
                                //anchors.top: tempText.bottom
                                anchors.horizontalCenter: parent.horizontalCenter

                                text: root.currentTime
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

            // Mode Selection Row
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
                id: mediaPlayerRow
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter

                // Playlist — add more qrc:/ entries here (and register them in qml.qrc)
                property var songList: [
                    "qrc:/assets/media/The Rosenberg Trio - For Sephora (Instrumental).mp3",
                    "qrc:/assets/media/Balti - Allo.mp3",
                    "qrc:/assets/media/Balti - Ya Galbi.mp3"
                ]
                property int currentSongIndex: 0

                // Media player backend
                MediaPlayer {
                    id: audioPlayer
                    source: mediaPlayerRow.songList[mediaPlayerRow.currentSongIndex]
                    audioOutput: AudioOutput {
                        id: audioOutput
                        volume: 0.7
                    }

                    onMediaStatusChanged: {
                        // Auto-advance to next song when current one finishes
                        if (mediaStatus === MediaPlayer.EndOfMedia) {
                            mediaPlayerRow.currentSongIndex =
                                (mediaPlayerRow.currentSongIndex + 1) % mediaPlayerRow.songList.length
                            audioPlayer.play()
                        }
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
                        z: 1
                        
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
                            id: previousButton
                            width: 30
                            height: 30
                            color: root.eGreen
                            radius: 15
                            anchors.verticalCenter: parent.verticalCenter

                            // Text {
                            //     id: previous
                            //     font.pixelSize: 20
                            //     text: "<"
                            //     color: "#000000"
                            //     verticalAlignment: Text.AlignVCenter
                            //     horizontalAlignment: Text.AlignHCenter
                            //     leftPadding: 8
                            // }
                            Image {
                                source: "qrc:/assets/icons/material-symbols_fast-rewind-rounded-2.png"
                                anchors.centerIn: parent
                                width: 24
                                height: 24
                                fillMode: Image.PreserveAspectFit
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    mediaPlayerRow.currentSongIndex =
                                        (mediaPlayerRow.currentSongIndex - 1 + mediaPlayerRow.songList.length) % mediaPlayerRow.songList.length
                                    audioPlayer.play()
                                }
                            }
                        }
                        
                        Rectangle {
                            id:playPauseButton
                            width: 50
                            height: 50
                            color: root.eGreen
                            radius: 25
                            
                            // Text {
                            //     id: playPauseIcon
                            //     font.pixelSize: 52
                            //     text: audioPlayer.playbackState === MediaPlayer.PlayingState ? "ll" : "▶"
                            //     color: "#000000"
                            //     verticalAlignment: Text.AlignVCenter
                            //     horizontalAlignment: Text.AlignHCenter
                            //     anchors.verticalCenter: parent.verticalCenter
                            //     leftPadding: text === "▶" ? 15 : 12
                            // }

                            Image {
                                id: playPauseIcon
                                source: audioPlayer.playbackState === MediaPlayer.PlayingState 
                                        ? "qrc:/assets/icons/Pause.png" 
                                        : "qrc:/assets/icons/Play.png"
                                anchors.centerIn: parent
                                width: 28
                                height: 28
                                fillMode: Image.PreserveAspectFit
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
                            id:nextButton
                            width: 30
                            height: 30
                            color: root.eGreen
                            radius: 15
                            anchors.verticalCenter: parent.verticalCenter

                            // Text {
                            //     id: next
                            //     font.pixelSize: 20
                            //     text: ">"
                            //     color: "#000000"
                            //     verticalAlignment: Text.AlignVCenter
                            //     horizontalAlignment: Text.AlignHCenter
                            //     leftPadding: 8
                            // }
                            Image {
                                source: "qrc:/assets/icons/material-symbols_fast-rewind-rounded.png"
                                anchors.centerIn: parent
                                width: 22
                                height: 22
                                fillMode: Image.PreserveAspectFit
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    mediaPlayerRow.currentSongIndex =
                                        (mediaPlayerRow.currentSongIndex + 1) % mediaPlayerRow.songList.length
                                    audioPlayer.play()
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
                    color: root.eGrey
                    radius: 10
                    // border.color: "#222222"
                    // border.width: 2

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
                        Text {
                                anchors.centerIn: batteryRect
                                text: (root.dashboardData ? root.dashboardData.batteryPercent : 0)
                                      + "%"
                                color: root.bgColor
                                font.pointSize: 16
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                    }
                }
            }
            // Remaining time
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

                    // Smooth remaining time - updates once per second
                    property string remainingTimeText: "--:--"
                    Timer {
                        id: remainingTimeTimer
                        interval: 1000
                        running: root.dashboardData && root.dashboardData.isRiding
                        repeat: true
                        onTriggered: {
                            var total = root.dashboardData ? root.dashboardData.totalDistance : 0
                            var traveled = root.dashboardData ? root.dashboardData.distance : 0
                            var remaining = total - traveled
                            if (remaining <= 0) {
                                parent.remainingTimeText = "0:00"
                                return
                            }
                            // Fixed 25 km/h → remaining km / 25 km/h = hours
                            var hours = remaining / 25.0
                            parent.remainingTimeText = formatTime(hours * 3600 * 1000)
                        }
                        onRunningChanged: {
                            if (!running)
                                parent.remainingTimeText = "--:--"
                        }
                    }

                    Rectangle {
                        width: 160
                        height: 40
                        color: root.eGrey
                        radius: 10
                        Text {
                            anchors.centerIn: parent
                            text: parent.parent.remainingTimeText
                            color: "#000000"
                            font.pointSize: 16
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
            // Distance
            Row {
                // topPadding: 0
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter
                Column {

                    Text {
                        text: "REMAINING"
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
                            text: {
                                var total = root.dashboardData ? root.dashboardData.totalDistance : 0
                                var traveled = root.dashboardData ? root.dashboardData.distance : 0
                                var remaining = total - traveled
                                if (remaining < 0) remaining = 0
                                return remaining.toFixed(2) + " km"
                            }
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

                            // OSM Plugin
                            Plugin {
                                id: mapPlugin
                                name: "osm"
                            }

                            // Geocode Model for address search
                            GeocodeModel {
                                id: geocodeModel
                                plugin: mapPlugin
                                autoUpdate: false
                                onStatusChanged: {
                                    if (status === GeocodeModel.Ready && count > 0) {
                                        var result = get(0)
                                        theMap.center = result.coordinate
                                        theMap.zoomLevel = 14
                                        destinationMarker.center = result.coordinate
                                        destinationMarker.visible = true

                                        routeQuery.clearWaypoints()
                                        routeQuery.addWaypoint(
                                            QtPositioning.coordinate(
                                                root.dashboardData ? root.dashboardData.latitude : 65.06086919646035,
                                                root.dashboardData ? root.dashboardData.longitude : 25.467637259998213
                                            )
                                        )
                                        routeQuery.addWaypoint(result.coordinate)
                                        routeModel.update()
                                    } else if (status === GeocodeModel.Error) {
                                        console.warn("Geocode error:", errorString)
                                    }
                                }
                            }

                            // Route Query
                            RouteQuery {
                                id: routeQuery
                                travelModes: RouteQuery.CarTravel
                                routeOptimizations: RouteQuery.ShortestRoute
                            }

                            // Route Model
                            RouteModel {
                                id: routeModel
                                plugin: mapPlugin
                                query: routeQuery
                                autoUpdate: false
                                onStatusChanged: {
                                    if (status === RouteModel.Error) {
                                        console.warn("Route error:", errorString)
                                    }
                                }
                            }

                            Map {
                                id: theMap
                                anchors.fill: parent
                                plugin: mapPlugin
                                center: QtPositioning.coordinate(65.06086919646035, 25.467637259998213)
                                zoomLevel: 14
                                visible: false

                                // Use cycling map type from OSM
                                Component.onCompleted: {
                                    for (var i = 0; i < supportedMapTypes.length; i++) {
                                        if (supportedMapTypes[i].name === "Cycle Map") {
                                            activeMapType = supportedMapTypes[i]
                                            break
                                        }
                                    }
                                }

                                Behavior on bearing {
                                    RotationAnimation {
                                        duration: 200
                                        direction: RotationAnimation.Shortest
                                    }
                                }

                                Behavior on center {
                                    CoordinateAnimation { duration: 150 }
                                }

                                // Follow vehicle during ride
                                Connections {
                                    target: root.dashboardData
                                    enabled: root.dashboardData && root.dashboardData.isRiding
                                    function onLatitudeChanged() {
                                        theMap.center = QtPositioning.coordinate(
                                            root.dashboardData.latitude,
                                            root.dashboardData.longitude)
                                    }
                                    function onLongitudeChanged() {
                                        theMap.center = QtPositioning.coordinate(
                                            root.dashboardData.latitude,
                                            root.dashboardData.longitude)
                                    }
                                    function onHeadingChanged() {
                                        theMap.bearing = root.dashboardData.heading
                                    }
                                }

                                // Route display from RouteModel
                                MapItemView {
                                    model: routeModel
                                    delegate: MapRoute {
                                        route: routeData
                                        line.color: root.eGreen
                                        line.width: 4
                                        smooth: true
                                    }
                                }
                                
                                // Vehicle marker - shows current position
                                MapCircle {
                                    id: vehicleMarker
                                    center: root.dashboardData 
                                        ? QtPositioning.coordinate(
                                            root.dashboardData.latitude,
                                            root.dashboardData.longitude)
                                        : QtPositioning.coordinate(65.06086919646035, 25.467637259998213)
                                    radius: 1
                                    color: root.eGreen
                                    border.width: 1
                                    border.color: "#000000"
                                    opacity: 0.5
                                }

                                // Destination marker - shown after search
                                MapCircle {
                                    id: destinationMarker
                                    center: QtPositioning.coordinate(0, 0)
                                    radius: 20
                                    color: "#ff3366"
                                    border.width: 3
                                    border.color: "#ffffff"
                                    visible: false
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

                                // Search Bar Overlay
                                Rectangle {
                                    id: searchBar
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.margins: 6
                                    height: 32
                                    radius: 8
                                    color: "#111111"
                                    border.color: "#333333"
                                    border.width: 1
                                    z: 10

                                    Row {
                                        anchors.fill: parent
                                        anchors.leftMargin: 6
                                        anchors.rightMargin: 4
                                        spacing: 4

                                        TextInput {
                                            id: searchInput
                                            width: parent.width - searchButton.width - 14
                                            height: parent.height
                                            color: root.eLightGrey
                                            font.pointSize: 9
                                            verticalAlignment: TextInput.AlignVCenter
                                            clip: true

                                            Text {
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: "Search destination..."
                                                color: "#666666"
                                                font.pointSize: 9
                                                visible: searchInput.text === ""
                                            }

                                            Keys.onReturnPressed: {
                                                if (text !== "") {
                                                    geocodeModel.query = text
                                                    geocodeModel.update()
                                                }
                                            }
                                        }

                                        Rectangle {
                                            id: searchButton
                                            width: 28
                                            height: 24
                                            anchors.verticalCenter: parent.verticalCenter
                                            color: root.eGreen
                                            radius: 6

                                            Text {
                                                anchors.centerIn: parent
                                                text: "Go"
                                                color: "#000000"
                                                font.pointSize: 8
                                                font.bold: true
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (searchInput.text !== "") {
                                                        geocodeModel.query = searchInput.text
                                                        geocodeModel.update()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                // Route info overlay
                                Rectangle {
                                    anchors.top: searchBar.bottom
                                    anchors.topMargin: 4
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: parent.width - 12
                                    height: 22
                                    radius: 6
                                    color: "#bb111111"
                                    z: 10
                                    visible: routeModel.count > 0

                                    property real routeDist: routeModel.status === RouteModel.Ready && routeModel.count > 0
                                        ? routeModel.get(0).distance : 0
                                    property real routeTime: routeModel.status === RouteModel.Ready && routeModel.count > 0
                                        ? routeModel.get(0).travelTime : 0

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 10

                                        Text {
                                            text: parent.parent.routeDist > 0
                                                ? (parent.parent.routeDist / 1000).toFixed(1) + " km"
                                                : ""
                                            color: root.eGreen
                                            font.pointSize: 8
                                        }

                                        Text {
                                            text: parent.parent.routeTime > 0
                                                ? Math.ceil(parent.parent.routeTime / 60) + " min"
                                                : ""
                                            color: root.eLightGrey
                                            font.pointSize: 8
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    z: 0
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                                    property point startPos
                                    property var startCenter
                                    property real startTilt
                                    property real startBearing
                                    property bool isRightButton: false

                                    onPressed: function (mouse) {
                                        startPos = Qt.point(mouse.x, mouse.y)
                                        startCenter = theMap.center
                                        startTilt = theMap.tilt
                                        startBearing = theMap.bearing
                                        isRightButton = (mouse.button === Qt.RightButton)
                                    }

                                    onPositionChanged: function (mouse) {
                                        if (pressed) {
                                            if (isRightButton) {
                                                // Right-click drag: vertical = tilt, horizontal = bearing
                                                var dy = mouse.y - startPos.y
                                                var dx = mouse.x - startPos.x
                                                var newTilt = startTilt - dy * 0.5
                                                newTilt = Math.max(theMap.minimumTilt, Math.min(theMap.maximumTilt, newTilt))
                                                theMap.tilt = newTilt
                                                var newBearing = startBearing + dx * 0.5
                                                newBearing = ((newBearing % 360) + 360) % 360
                                                theMap.bearing = newBearing
                                            } else {
                                                // Left-click drag: pan
                                                var startCoord = theMap.toCoordinate(startPos)
                                                var currentCoord = theMap.toCoordinate(Qt.point(mouse.x, mouse.y))
                                                var latDiff = startCoord.latitude - currentCoord.latitude
                                                var lonDiff = startCoord.longitude - currentCoord.longitude
                                                theMap.center = QtPositioning.coordinate(
                                                    startCenter.latitude + latDiff,
                                                    startCenter.longitude + lonDiff)
                                            }
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

                                // Tilt / Bearing controls (bottom-left)
                                Column {
                                    anchors.left: parent.left
                                    anchors.bottom: starJourney.top
                                    anchors.leftMargin: 6
                                    anchors.bottomMargin: 6
                                    spacing: 3
                                    z: 10

                                    // Tilt Up
                                    Rectangle {
                                        width: 26; height: 26; radius: 6
                                        color: "#bb222222"
                                        Text { anchors.centerIn: parent; text: "▲"; color: root.eLightGrey; font.pointSize: 9 }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: theMap.tilt = Math.min(theMap.tilt + 10, theMap.maximumTilt)
                                        }
                                    }
                                    // Tilt Down
                                    Rectangle {
                                        width: 26; height: 26; radius: 6
                                        color: "#bb222222"
                                        Text { anchors.centerIn: parent; text: "▼"; color: root.eLightGrey; font.pointSize: 9 }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: theMap.tilt = Math.max(theMap.tilt - 10, theMap.minimumTilt)
                                        }
                                    }
                                    // Reset tilt/bearing
                                    Rectangle {
                                        width: 26; height: 26; radius: 6
                                        color: "#bb222222"
                                        Text { anchors.centerIn: parent; text: "⟲"; color: root.eGreen; font.pointSize: 11 }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: { theMap.tilt = 0; theMap.bearing = 0 }
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
                                                // Pass route from RouteModel to C++ before starting
                                                if (!root.dashboardData.isRiding && routeModel.count > 0) {
                                                    var route = routeModel.get(0)
                                                    var path = route.path
                                                    console.log("Passing route with", path.length, "points to simulator")
                                                    root.routeSimulator.setRoute(path)
                                                }
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

    // Statistics View
    Rectangle {
        id: statsView
        anchors.fill: parent
        color: root.bgColor
        visible: root.statsViewOpen
        z: 97

        Text {
            anchors.centerIn: parent
            text: "Statistics View"
            color: root.eGreen
            font.pointSize: 24
            font.bold: true
        }

        // Back button
        Rectangle {
            width: 40
            height: 40
            color: "#111111"
            radius: 10
            border.color: "#222222"
            border.width: 2
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 15

            Text {
                anchors.centerIn: parent
                text: "✕"
                color: root.eGreen
                font.pointSize: 16
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.statsViewOpen = false
            }
        }
    }

    // Dim overlay when menu is open
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: root.menuOpen ? 0.4 : 0.0
        visible: opacity > 0
        z: 98

        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }

        // MouseArea {
        //     anchors.fill: parent
        //     onClicked: root.menuOpen = false
        // }
    }

    // Sliding menu panel
    Rectangle {
        id: menuPanel
        width: root.width / 3
        height: root.height
        color: root.eGreen
        radius: 10
        z: 99
        y: 0
        x: root.menuOpen ? 0 : -width

        Behavior on x {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 20

            // Close button row
            Row {
                anchors.right: parent.right
                Rectangle {
                    id: closeButton
                    width: 30
                    height: 30
                    color: "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: "#000000"
                        font.pointSize: 16
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: closeButton
                        onClicked: root.menuOpen = false
                    }
                }
            }

            Text {
                text: "MENU"
                color: "#000000"
                font.pointSize: 18
                font.bold: true
            }
        }
    }
}
