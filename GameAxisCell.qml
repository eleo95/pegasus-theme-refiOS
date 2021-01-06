// Pegasus Frontend - Flixnet theme
// Copyright (C) 2017  Mátyás Mustoha
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.


import QtQuick 2.7
import QtGraphicalEffects 1.0

Item {
    property var game

    property bool selected: false
    property var selectedRow: false
   
    scale: selected  && selectedRow ? 1.20 : 1.0
    z: selected  && selectedRow ? 3 : 1
    
    //selected border
    Rectangle {
        id: selec
        width: selected  && selectedRow ? parent.width+parent.width*0.03: 0
        height: parent.height+parent.height*0.08
        color:"white"
        opacity: 0.2
        anchors.centerIn: parent
        z:0
    }
     Rectangle {
        id: shadow
        width: selec.width * 0.95
        height: selec.height * 0.65
        anchors.centerIn: selec
        visible: false
    }
    RectangularGlow {
        id: effect
        anchors.fill: shadow
        glowRadius: 30
        spread: 0.2
        visible: selectedRow && selected
        color: "black"
        opacity: 0.4
         anchors.centerIn: parent
        cornerRadius: rect.radius + glowRadius
        z:-1
    }

    Behavior on scale { PropertyAnimation { duration: 150 } }

    //fallback tile
    Rectangle {
        anchors.fill: parent
        color: "#333"
        visible: image.status !== Image.Ready
        Image {
            anchors.centerIn: parent

            visible: image.status === Image.Loading
            source: "assets/loading-spinner.png"

            RotationAnimator on rotation {
                loops: Animator.Infinite
                from: 0; to: 360
                duration: 500
            }
        }

        Text {
            text: model.title

            width: parent.width * 0.8
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap

            anchors.centerIn: parent
            visible: !model.assets.gridicon

            color: "#eee"
            font {
                pixelSize: vpx(16)
                family: globalFonts.sans
            }
        }
    }

    Item {
        id: delegateContainer
        anchors.fill: parent

        //screenshot
        Image {
            id: screenshot
            width: parent.width
            height: parent.height
            
            asynchronous: true
            smooth: true
            source: modelData.assets.screenshots[0] ? modelData.assets.screenshots[0] : ""
            sourceSize { width: 256; height: 256 }
            fillMode: Image.PreserveAspectCrop
            
        }

        //dark mask
        Rectangle 
        {
            width: parent.width
            height: parent.height
            color: "black"
            opacity: 0.5
            visible: screenshot.source != ""
        }

        // Logo
        Image {
            id: image

            width: screenshot.width
            height: screenshot.height
            anchors {
                fill: parent
                margins: vpx(6)
            }
            asynchronous: true
            source: modelData.assets.logo ? modelData.assets.logo : ""
            sourceSize { width: 256; height: 256 }
            fillMode: Image.PreserveAspectFit
            smooth: true
            visible: modelData.assets.logo ? modelData.assets.logo : ""
            z:8
        }
    }
}
