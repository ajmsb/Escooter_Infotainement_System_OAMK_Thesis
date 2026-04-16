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
    // Theme toggle
    property bool darkTheme: true

    // Colors properties (theme-aware)
    property string eGreen: "#caff00"
    property string eDark: "#222222"
    property string eGrey: darkTheme ? "#3d3d3d" : "#e8e8e8"
    property string eLightGrey: darkTheme ? "#e8e8e8" : "#e8e8e8"
    property string bgColor: darkTheme ? "#0a0a0a" : "#ffffff"
    property string cardColor: darkTheme ? "#161616" : "#e8e8e8"
    property string borderColor: darkTheme ? "#3d3d3d" : "transparent"
    property string statsCardColor: darkTheme ? "#161616" : "#f0f0f0"
    property string textPrimary: darkTheme ? "#caff00" : "#161616"
    property string textSecondary: darkTheme ? "#161616" : "#161616"

    property bool menuOpen: false
    property bool statsViewOpen: false
    property var dashboardData
    property var routeSimulator
    property bool routeChanged: false
    property var musicFileList: []
    property real currentTemperature: 0
    property string currentTime: new Date().toLocaleTimeString(Qt.locale(), "h:mm")

    // --- Ride statistics tracking ---
    property int rideElapsedSeconds: 0
    property real rideSpeedSum: 0.0
    property int rideSpeedSamples: 0
    property int rideStartBattery: 100
    property real rideDistanceTraveled: 0.0
    property var speedHistory: []
    property var batteryHistory: []

    // Timer to track ride statistics every second while riding
    Timer {
        id: rideStatsTimer
        interval: 1000
        running: root.dashboardData ? root.dashboardData.isRiding : false
        repeat: true
        onTriggered: {
            root.rideElapsedSeconds += 1
            var spd = root.dashboardData ? root.dashboardData.speed : 0
            if (spd > 0) {
                root.rideSpeedSum += spd
                root.rideSpeedSamples += 1
            }
            root.rideDistanceTraveled = root.dashboardData ? root.dashboardData.distance : 0

            // Store chart data in arrays (charts are lazily loaded)
            var batt = root.dashboardData ? root.dashboardData.batteryPercent : 100
            root.speedHistory = root.speedHistory.concat([{x: root.rideElapsedSeconds, y: spd}])
            root.batteryHistory = root.batteryHistory.concat([{x: root.rideElapsedSeconds, y: batt}])
        }
        onRunningChanged: {
            if (running && root.rideElapsedSeconds === 0) {
                // Ride just started — capture initial battery
                root.rideStartBattery = root.dashboardData ? root.dashboardData.batteryPercent : 100
                root.rideSpeedSum = 0.0
                root.rideSpeedSamples = 0
                root.rideDistanceTraveled = 0.0
                root.speedHistory = []
                root.batteryHistory = []
            }
        }
    }

    // Timer to update current time every second
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

    // Main layout
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
                    color: root.cardColor
                    radius: 10
                    border.color: root.borderColor
                    border.width: 1

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
                    color: root.cardColor
                    radius: 10
                    border.color: root.borderColor
                    border.width: 1

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
                    color: root.cardColor
                    radius: 10
                    border.color: root.borderColor
                    border.width: 1

                    Image {
                        id: lockOn
                        source: "qrc:/assets/icons/boxiconslock.png"
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        fillMode: Image.PreserveAspectFit
                        visible: false
                    }
                    Image {
                        id: lockOff
                        source: "qrc:/assets/icons/boxiconslockopen.png"
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        fillMode: Image.PreserveAspectFit
                        visible: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            // Toggle lock state (this is just a visual toggle for now)
                            if (lockOn.visible) {
                                lockOn.visible = false
                                lockOff.visible = true
                                lockControl.color = root.cardColor

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
                    color: root.cardColor
                    radius: 10
                    border.color: root.borderColor
                    border.width: 1

                    Image {
                        id: headlightOn
                        source: "qrc:/assets/icons/Head_light.png"
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        fillMode: Image.PreserveAspectFit
                        visible: false
                    }
                    Image {
                        id: headlightOff
                        source: "qrc:/assets/icons/Head_light_off.png"
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        fillMode: Image.PreserveAspectFit
                        visible: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            // Toggle headlight state (this is just a visual toggle for now)
                            if (headlightOn.visible) {
                                headlightOn.visible = false
                                headlightOff.visible = true
                                headlightControl.color = root.cardColor

                                

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
                    color: root.cardColor
                    radius: 10
                    border.color: root.borderColor
                    border.width: 1
                    clip: true

                    // Volume fill (grows from bottom)
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: parent.height * audioOutput.volume
                        color: root.textPrimary
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
                        z: 4
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
        // Display / Media Column
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
                        color: root.cardColor
                        radius: 10
                        border.color: root.borderColor
                        border.width: 1

                        Column {
                            spacing: -10
                            anchors.centerIn: parent
                            Text {
                                id: tempText

                                anchors.horizontalCenter: parent.horizontalCenter
                                text: new Date().toLocaleDateString(
                                          Qt.locale(),
                                          "dddd") + " " + root.currentTemperature.toFixed(1) + "°C"
                                color: root.textPrimary
                                font.pointSize: 11
                                font.bold: false
                                //horizontalAlignment: Text.AlignHCenter
                                //verticalAlignment: Text.AlignVCenter
                            }
                            Text {
                                //anchors.top: tempText.bottom
                                anchors.horizontalCenter: parent.horizontalCenter

                                text: root.currentTime
                                color: root.textPrimary
                                font.pointSize: 34
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

                property string currentMode: root.dashboardData ? root.dashboardData.ridingMode : "ECO"

                Rectangle {
                    width: 68
                    height: 40
                    color: parent.currentMode === "ECO" ? "#caff00" : root.cardColor
                    radius: 10
                    border.color: parent.currentMode === "ECO" ? "#caff00" : root.borderColor
                    border.width: parent.currentMode === "ECO" ? 0 : 1
                    Text {
                        anchors.centerIn: parent
                        text: "ECO"
                        color: parent.parent.currentMode === "ECO" ? "#000000" : root.textPrimary
                        font.pointSize: 12
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.dashboardData)
                                root.dashboardData.ridingMode = "ECO"
                        }
                    }
                }
                Rectangle {
                    width: 68
                    height: 40
                    color: parent.currentMode === "TRB" ? "#caff00" : root.cardColor
                    radius: 10
                    border.color: parent.currentMode === "TRB" ? "#caff00" : root.borderColor
                    border.width: parent.currentMode === "TRB" ? 0 : 1
                    Text {
                        anchors.centerIn: parent
                        text: "TRB"
                        color: parent.parent.currentMode === "TRB" ? "#000000" : root.textPrimary
                        font.pointSize: 12
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.dashboardData)
                                root.dashboardData.ridingMode = "TRB"
                        }
                    }
                }
            }
            // Media Player Row
            Row {
                id: mediaPlayerRow
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter

                // Playlist — auto-loaded from assets/media/ (just drop .mp3 files in the folder)
                property var songList: root.musicFileList
                property int currentSongIndex: 0

                // Media player backend
                MediaPlayer {
                    id: audioPlayer
                    source: mediaPlayerRow.songList.length > 0
                            ? mediaPlayerRow.songList[mediaPlayerRow.currentSongIndex]
                            : ""
                    audioOutput: AudioOutput {
                        id: audioOutput
                        volume: 0.5
                    }

                    // Auto-advance logic
                    onMediaStatusChanged: {
                        // Auto-advance to next song when current one finishes
                        if (mediaStatus === MediaPlayer.EndOfMedia) {
                            mediaPlayerRow.currentSongIndex =
                                (mediaPlayerRow.currentSongIndex + 1) % mediaPlayerRow.songList.length
                            audioPlayer.play()
                        }
                    }
                    
                    // Log playback state changes
                    onPlaybackStateChanged: {
                        console.log("Playback state:", playbackState)
                    }
                }
                
                //media player UI
                Rectangle {
                    id: mediaPlayerUI
                    width: 140
                    height: 140
                    color: "transparent"
                    radius: 10
                    border.color: root.borderColor
                    border.width: 1
                    clip: true
                    
                    // Album art
                    Image {
                        id: albumArt
                        anchors.fill: mediaPlayerUI
                        source: "qrc:/assets/media/cover.jpg"
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        Rectangle {
                            anchors.fill: parent
                            color: "#000000"
                            opacity: 0.7
                            radius: 10
                            border.color: root.borderColor
                            border.width: 1
                        }
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: mediaPlayerUI.width
                                height: mediaPlayerUI.height
                                radius: 10
                            }
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
                            color: root.textPrimary
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
                            color: root.textSecondary
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
                                width: 15
                                height: 15
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
                                width: 15
                                height: 15
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
                        color: root.textPrimary
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
                                color: "#000000"
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
                        color: root.textPrimary
                        font.pointSize: 12
                        verticalAlignment: Text.AlignVCenter
                    }

                    // Smooth remaining time - updates once per second
                    property string remainingTimeText: "--:--"
                    property real avgSpeed: 0.0
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
                            // Smooth speed with exponential moving average (alpha = 0.15)
                            var currentSpeed = root.dashboardData ? root.dashboardData.speed : 0
                            if (parent.avgSpeed < 0.5) {
                                // Initialize on first reading
                                parent.avgSpeed = currentSpeed > 0.5 ? currentSpeed : 20.0
                            } else {
                                parent.avgSpeed = 0.15 * currentSpeed + 0.85 * parent.avgSpeed
                            }
                            var speedForEta = parent.avgSpeed > 1.0 ? parent.avgSpeed : 20.0
                            var hours = remaining / speedForEta
                            parent.remainingTimeText = formatTime(hours * 3600 * 1000)
                        }
                        onRunningChanged: {
                            if (!running) {
                                parent.remainingTimeText = "--:--"
                                parent.avgSpeed = 0.0
                            }
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
                        text: "DISTANCE LEFT"
                        color: root.textPrimary
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
                    id:mapPlaceholder
                    width: 200
                    height: 320
                    color: root.cardColor
                    radius: 10
                    //border.color: "#222222"
                    //border.width: 1

                    // Map Loader - attempts to load the map plugin, but falls back to placeholder if it fails (e.g. missing QtLocation)
                    Loader {
                        id: mapLoader
                        anchors.fill: parent
                        anchors.margins: 0
                        sourceComponent: mapComponent
                        onStatusChanged: {
                            if (status === Loader.Error) {
                                console.warn("Map failed to load - using placeholder")
                                sourceComponent = null
                            }
                        }
                    }

                    // Actual map component with OSM plugin and routing
                    Component {
                        id: mapComponent

                        Item {
                            anchors.fill: parent

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

                                // When geocode results are ready, center map on first result and update route
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
                                    if (status === RouteModel.Ready && count > 0) {
                                        root.routeChanged = true
                                    }
                                }
                            }

                            // The Map itself
                            Map {
                                id: theMap
                                anchors.fill: parent
                                plugin: mapPlugin
                                center: QtPositioning.coordinate(65.06086919646035, 25.467637259998213)
                                zoomLevel: 70
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
                                // Smooth animations for map movements
                                Behavior on bearing {
                                    RotationAnimation {
                                        duration: 200
                                        direction: RotationAnimation.Shortest
                                    }
                                }

                                // Smooth animation for map center changes
                                Behavior on center {
                                    CoordinateAnimation { duration: 150 }
                                }

                                // Update map center and bearing based on DashboardData when riding
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

                                // route display from routemodel
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

                            // Mask for rounded corners on the map
                            Rectangle {
                                id: maskRect
                                anchors.fill: parent
                                radius: 10
                                visible: false
                            }

                            // Opacity mask for rounded corners on the map
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
                                    color: root.eLightGrey
                                    //border.color: root.borderColor
                                    //border.width: 1
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
                                            color: root.textSecondary
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
                                            color: root.textPrimary
                                            font.pointSize: 8
                                        }

                                        Text {
                                            text: parent.parent.routeTime > 0
                                                ? Math.ceil(parent.parent.routeTime / 60) + " min"
                                                : ""
                                            color: root.textSecondary
                                            font.pointSize: 8
                                        }
                                    }
                                }

                                // Map interaction area - handles panning, zooming, tilt, and bearing
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
                                        color: root.eGreen
                                        Text { anchors.centerIn: parent; text: "▲"; color: root.eDark; font.pointSize: 9 }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: theMap.tilt = Math.min(theMap.tilt + 10, theMap.maximumTilt)
                                        }
                                    }
                                    // Tilt Down
                                    Rectangle {
                                        width: 26; height: 26; radius: 6
                                        color: root.eGreen
                                        Text { anchors.centerIn: parent; text: "▼"; color: root.eDark; font.pointSize: 9 }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: theMap.tilt = Math.max(theMap.tilt - 10, theMap.minimumTilt)
                                        }
                                    }
                                    // Reset tilt/bearing
                                    Rectangle {
                                        width: 26; height: 26; radius: 6
                                        color: root.eDark
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
                                                // Pass route if it's a fresh start or route has changed
                                                if (!root.dashboardData.isRiding && routeModel.count > 0
                                                    && (root.dashboardData.distance < 0.001 || root.routeChanged)) {
                                                    var route = routeModel.get(0)
                                                    var path = route.path
                                                    console.log("Passing route with", path.length, "points to simulator")
                                                    root.routeSimulator.setRoute(path)
                                                    root.routeChanged = false
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

        // Helper function for duration formatting
        function fmtDuration(secs) {
            if (secs <= 0) return "0m 0s"
            var h = Math.floor(secs / 3600)
            var m = Math.floor((secs % 3600) / 60)
            var s = secs % 60
            if (h > 0)
                return h + "h " + m + "m " + s + "s"
            return m + "m " + s + "s"
        }

        // Back button
        Rectangle {
            id: statsBackBtn
            width: 40
            height: 40
            color: root.cardColor
            radius: 10
            border.color: root.borderColor
            border.width: 2
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 15
            z: 2

            Text {
                anchors.centerIn: parent
                text: "✕"
                color: root.textPrimary
                font.pointSize: 16
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.statsViewOpen = false
            }
        }

        // Title
        Text {
            id: statsTitle
            text: "Ride Statistics"
            color: root.textPrimary
            font.pointSize: 18
            font.bold: true
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 22
            z: 2
        }

        // Charts drawn with QML Canvas (avoids ChartView segfault on Qt 6.9 MinGW)
        Row {
            anchors.top: statsTitle.bottom
            anchors.topMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            // ── Left column: Speed Over Time (Canvas) ──
            Rectangle {
                width: 315
                height: 285
                color: root.statsCardColor
                radius: 14
                border.color: root.borderColor
                border.width: 1
                clip: true

                Text {
                    id: speedChartTitle
                    text: "Speed Over Time"
                    color: root.darkTheme ? "#aaaaaa" : "#555555"
                    font.pointSize: 9
                    font.bold: true
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 6
                    z: 2
                }

                Canvas {
                    id: speedCanvas
                    anchors.fill: parent
                    anchors.topMargin: 22
                    anchors.margins: 4

                    property var dataPoints: root.speedHistory
                    onDataPointsChanged: requestPaint()

                    Connections {
                        target: root
                        function onDarkThemeChanged() { speedCanvas.requestPaint() }
                    }

                    onPaint: {
                        var ctx = getContext("2d");
                        var w = width, h = height;
                        ctx.clearRect(0, 0, w, h);

                        var pad = { left: 38, right: 12, top: 8, bottom: 24 };
                        var gw = w - pad.left - pad.right;
                        var gh = h - pad.top - pad.bottom;

                        // Determine axis ranges
                        var pts = dataPoints;
                        var maxT = 60, maxV = 30;
                        if (pts.length > 0) {
                            var lastT = pts[pts.length - 1].x;
                            if (lastT > maxT - 10) maxT = lastT + 30;
                            for (var k = 0; k < pts.length; k++) {
                                if (pts[k].y > maxV - 3) maxV = pts[k].y + 5;
                            }
                        }

                        var gridColor = root.darkTheme ? "#2a2a2a" : "#dddddd";
                        var labelColor = root.darkTheme ? "#888888" : "#666666";

                        // Grid lines (5 horizontal, 5 vertical)
                        ctx.strokeStyle = gridColor;
                        ctx.lineWidth = 1;
                        for (var gi = 0; gi <= 5; gi++) {
                            var gy = pad.top + gh * gi / 5;
                            ctx.beginPath(); ctx.moveTo(pad.left, gy); ctx.lineTo(pad.left + gw, gy); ctx.stroke();
                            var gx = pad.left + gw * gi / 5;
                            ctx.beginPath(); ctx.moveTo(gx, pad.top); ctx.lineTo(gx, pad.top + gh); ctx.stroke();
                        }

                        // Y-axis labels
                        ctx.fillStyle = labelColor;
                        ctx.font = "9px sans-serif";
                        ctx.textAlign = "right";
                        ctx.textBaseline = "middle";
                        for (var yi = 0; yi <= 5; yi++) {
                            var valY = maxV - (maxV * yi / 5);
                            var posY = pad.top + gh * yi / 5;
                            ctx.fillText(Math.round(valY).toString(), pad.left - 4, posY);
                        }

                        // X-axis labels
                        ctx.textAlign = "center";
                        ctx.textBaseline = "top";
                        for (var xi = 0; xi <= 5; xi++) {
                            var valX = maxT * xi / 5;
                            var posX = pad.left + gw * xi / 5;
                            ctx.fillText(Math.round(valX) + "s", posX, pad.top + gh + 4);
                        }

                        // Axis labels
                        ctx.fillStyle = labelColor;
                        ctx.font = "8px sans-serif";
                        ctx.textAlign = "center";
                        ctx.fillText("km/h", pad.left / 2, pad.top - 2);

                        if (pts.length < 2) {
                            ctx.fillStyle = labelColor;
                            ctx.font = "12px sans-serif";
                            ctx.textAlign = "center";
                            ctx.textBaseline = "middle";
                            ctx.fillText("No ride data yet", w / 2, h / 2);
                            return;
                        }

                        // Draw filled area + line
                        function tx(v) { return pad.left + (v / maxT) * gw; }
                        function ty(v) { return pad.top + gh - (v / maxV) * gh; }

                        // Fill
                        ctx.beginPath();
                        ctx.moveTo(tx(pts[0].x), pad.top + gh);
                        for (var fi = 0; fi < pts.length; fi++)
                            ctx.lineTo(tx(pts[fi].x), ty(pts[fi].y));
                        ctx.lineTo(tx(pts[pts.length-1].x), pad.top + gh);
                        ctx.closePath();
                        ctx.fillStyle = root.darkTheme ? "rgba(0,206,209,0.15)" : "rgba(0,206,209,0.10)";
                        ctx.fill();

                        // Line
                        ctx.beginPath();
                        ctx.moveTo(tx(pts[0].x), ty(pts[0].y));
                        for (var li = 1; li < pts.length; li++)
                            ctx.lineTo(tx(pts[li].x), ty(pts[li].y));
                        ctx.strokeStyle = root.eGreen;
                        ctx.lineWidth = 2;
                        ctx.stroke();
                    }
                }
            }

            // ── Right column: Battery chart + summary cards ──
            Column {
                spacing: 6
                
                Rectangle {
                    width: 290
                    height: 165
                    color: root.statsCardColor
                    radius: 14
                    border.color: root.borderColor
                    border.width: 1
                    clip: true

                    Text {
                        id: batteryChartTitle
                        text: "Battery Level"
                        color: root.darkTheme ? "#aaaaaa" : "#555555"
                        font.pointSize: 9
                        font.bold: true
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: 6
                        z: 2
                    }

                    Canvas {
                        id: batteryCanvas
                        anchors.fill: parent
                        anchors.topMargin: 22
                        anchors.margins: 4

                        property var dataPoints: root.batteryHistory
                        onDataPointsChanged: requestPaint()

                        Connections {
                            target: root
                            function onDarkThemeChanged() { batteryCanvas.requestPaint() }
                        }

                        onPaint: {
                            var ctx = getContext("2d");
                            var w = width, h = height;
                            ctx.clearRect(0, 0, w, h);

                            var pad = { left: 34, right: 12, top: 8, bottom: 24 };
                            var gw = w - pad.left - pad.right;
                            var gh = h - pad.top - pad.bottom;

                            var pts = dataPoints;
                            var maxT = 60;
                            if (pts.length > 0) {
                                var lastT = pts[pts.length - 1].x;
                                if (lastT > maxT - 10) maxT = lastT + 30;
                            }
                            var maxV = 100; // battery always 0-100

                            var gridColor = root.darkTheme ? "#2a2a2a" : "#dddddd";
                            var labelColor = root.darkTheme ? "#888888" : "#666666";

                            // Grid
                            ctx.strokeStyle = gridColor;
                            ctx.lineWidth = 1;
                            for (var gi = 0; gi <= 4; gi++) {
                                var gy = pad.top + gh * gi / 4;
                                ctx.beginPath(); ctx.moveTo(pad.left, gy); ctx.lineTo(pad.left + gw, gy); ctx.stroke();
                                var gx = pad.left + gw * gi / 4;
                                ctx.beginPath(); ctx.moveTo(gx, pad.top); ctx.lineTo(gx, pad.top + gh); ctx.stroke();
                            }

                            // Y-axis labels
                            ctx.fillStyle = labelColor;
                            ctx.font = "9px sans-serif";
                            ctx.textAlign = "right";
                            ctx.textBaseline = "middle";
                            for (var yi = 0; yi <= 4; yi++) {
                                var valY = maxV - (maxV * yi / 4);
                                var posY = pad.top + gh * yi / 4;
                                ctx.fillText(Math.round(valY) + "%", pad.left - 4, posY);
                            }

                            // X-axis labels
                            ctx.textAlign = "center";
                            ctx.textBaseline = "top";
                            for (var xi = 0; xi <= 4; xi++) {
                                var valX = maxT * xi / 4;
                                var posX = pad.left + gw * xi / 4;
                                ctx.fillText(Math.round(valX) + "s", posX, pad.top + gh + 4);
                            }

                            if (pts.length < 2) {
                                ctx.fillStyle = labelColor;
                                ctx.font = "11px sans-serif";
                                ctx.textAlign = "center";
                                ctx.textBaseline = "middle";
                                ctx.fillText("No ride data yet", w / 2, h / 2);
                                return;
                            }

                            function tx(v) { return pad.left + (v / maxT) * gw; }
                            function ty(v) { return pad.top + gh - (v / maxV) * gh; }

                            // Fill
                            ctx.beginPath();
                            ctx.moveTo(tx(pts[0].x), pad.top + gh);
                            for (var fi = 0; fi < pts.length; fi++)
                                ctx.lineTo(tx(pts[fi].x), ty(pts[fi].y));
                            ctx.lineTo(tx(pts[pts.length-1].x), pad.top + gh);
                            ctx.closePath();
                            ctx.fillStyle = root.darkTheme ? "rgba(0,206,209,0.15)" : "rgba(0,206,209,0.10)";
                            ctx.fill();

                            // Line
                            ctx.beginPath();
                            ctx.moveTo(tx(pts[0].x), ty(pts[0].y));
                            for (var li = 1; li < pts.length; li++)
                                ctx.lineTo(tx(pts[li].x), ty(pts[li].y));
                            ctx.strokeStyle = root.eGreen;
                            ctx.lineWidth = 2;
                            ctx.stroke();
                        }
                    }
                }

                // Summary stats mini-cards
                Grid {
                    columns: 2
                    spacing: 8

                    Rectangle {
                        width: 141; height: 54
                        color: root.statsCardColor; radius: 10
                        border.color: root.borderColor; border.width: 1
                        Column {
                            anchors.centerIn: parent; spacing: 2
                            Text { text: "Distance"; color: root.darkTheme ? "#aaaaaa" : "#555555"; font.pointSize: 8; anchors.horizontalCenter: parent.horizontalCenter }
                            Text { text: root.rideDistanceTraveled.toFixed(2) + " km"; color: root.textPrimary; font.pointSize: 14; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                        }
                    }

                    Rectangle {
                        width: 141; height: 54
                        color: root.statsCardColor; radius: 10
                        border.color: root.borderColor; border.width: 1
                        Column {
                            anchors.centerIn: parent; spacing: 2
                            Text { text: "Avg Speed"; color: root.darkTheme ? "#aaaaaa" : "#555555"; font.pointSize: 8; anchors.horizontalCenter: parent.horizontalCenter }
                            Text { text: (root.rideSpeedSamples > 0 ? (root.rideSpeedSum / root.rideSpeedSamples).toFixed(1) : "0.0") + " km/h"; color: root.textPrimary; font.pointSize: 14; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                        }
                    }

                    Rectangle {
                        width: 141; height: 54
                        color: root.statsCardColor; radius: 10
                        border.color: root.borderColor; border.width: 1
                        Column {
                            anchors.centerIn: parent; spacing: 2
                            Text { text: "Duration"; color: root.darkTheme ? "#aaaaaa" : "#555555"; font.pointSize: 8; anchors.horizontalCenter: parent.horizontalCenter }
                            Text { text: statsView.fmtDuration(root.rideElapsedSeconds); color: root.textPrimary; font.pointSize: 14; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                        }
                    }

                    Rectangle {
                        width: 141; height: 54
                        color: root.statsCardColor; radius: 10
                        border.color: root.borderColor; border.width: 1
                        Column {
                            anchors.centerIn: parent; spacing: 2
                            Text { text: "Batt Used"; color: root.darkTheme ? "#aaaaaa" : "#555555"; font.pointSize: 8; anchors.horizontalCenter: parent.horizontalCenter }
                            Text {
                                text: {
                                    var current = root.dashboardData ? root.dashboardData.batteryPercent : 0;
                                    var used = root.rideStartBattery - current;
                                    return (used > 0 ? used : 0) + " %";
                                }
                                color: root.textPrimary; font.pointSize: 14; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
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

            // Theme toggle setting
            Row {
                spacing: 10
                anchors.left: parent.left
                anchors.right: parent.right

                Text {
                    text: root.darkTheme ? "Dark Theme" : "Light Theme"
                    color: "#000000"
                    font.pointSize: 12
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Toggle switch
                Rectangle {
                    id: themeToggle
                    width: 50
                    height: 26
                    radius: 13
                    color: root.darkTheme ? "#555555" : root.eGreen
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }

                    // Toggle knob
                    Rectangle {
                        id: themeKnob
                        width: 22
                        height: 22
                        radius: 11
                        color: "#ffffff"
                        anchors.verticalCenter: parent.verticalCenter
                        x: root.darkTheme ? 2 : parent.width - width - 2

                        Behavior on x {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.darkTheme = !root.darkTheme
                    }
                }
            }
        }
    }
}
