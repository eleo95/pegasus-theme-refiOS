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
import QtGraphicalEffects 1.12


FocusScope {
    focus: true
    FontLoader { id: roboto_light; source: "assets/fonts/Roboto-Light.ttf"}
    FontLoader { id: roboto_thin; source: "assets/fonts/Roboto-Thin.ttf"}

    // grid icons
    readonly property real cellRatio: 16 / 9
    readonly property int cellHeight: vpx(130)
    readonly property int cellWidth: cellHeight * cellRatio
    readonly property int cellSpacing: vpx(10)
    readonly property int cellPaddedWidth: cellWidth + cellSpacing

    // category labels of rows
    readonly property int labelFontSize: vpx(18)
    readonly property int labelHeight: labelFontSize * 2.5

    // layout
    readonly property int leftGuideline: vpx(100)

    Rectangle {
        width: parent.width
        height: parent.height
        RadialGradient {
            anchors.fill: parent
            horizontalOffset: vpx(-450)
            verticalOffset: vpx(-250)
            gradient: Gradient {         
                GradientStop { position: 0.1; color: "#051720" }
                GradientStop { position: 0.5; color: "#07131d" }
                GradientStop { position: 1; color: "#00050f" }
            }
        }
        Screenshot {
            game: collectionAxis.currentItem.currentGame
            anchors {
                top: parent.top
                left: parent.horizontalCenter
                right: parent.right
                bottom: collectionAxis.top
                bottomMargin: -labelHeight
            }
        }

        Details {
            game: collectionAxis.currentItem.currentGame
            anchors {
                top: parent.top
                left: parent.left; leftMargin: leftGuideline
                bottom: collectionAxis.top
                bottomMargin: labelHeight * 2
                right: parent.horizontalCenter
            }
        }    

        PathView {
            id: collectionAxis
            
            width: parent.width
            height: 2 * (labelHeight + cellHeight) + vpx(5)
            // height: 3 * (labelHeight + cellHeight)
            anchors.bottom: parent.bottom

            model: api.collections
            delegate: collectionAxisDelegate

            // FIXME: this was increased to 4 to avoid seeing the scrolling
            // animation when a new game axis is created
            pathItemCount: 4
            readonly property int pathLength: (labelHeight + cellHeight) * 4
            path: Path {
                startX: collectionAxis.width * 0.5
                startY: (labelHeight + cellHeight) * -0.5
                PathLine {
                    x: collectionAxis.path.startX
                    y: collectionAxis.path.startY + collectionAxis.pathLength
                }
            }

            snapMode: PathView.SnapOneItem
            highlightRangeMode: PathView.StrictlyEnforceRange
            movementDirection: PathView.Positive
            clip: true

            preferredHighlightBegin: 1 / 4
            preferredHighlightEnd: preferredHighlightBegin

            focus: true
            Keys.onUpPressed: decrementCurrentIndex()
            Keys.onDownPressed: incrementCurrentIndex()
            Keys.onLeftPressed: currentItem.axis.decrementCurrentIndex()
            Keys.onRightPressed: currentItem.axis.incrementCurrentIndex()
            Keys.onPressed: {
                if (!event.isAutoRepeat && api.keys.isAccept(event))
                    currentItem.currentGame.launch();
            }
        }

        Component {
            id: collectionAxisDelegate

            Item {
                property alias axis: gameAxis
                readonly property var currentGame: axis.currentGame
                readonly property bool currentRow: PathView.isCurrentItem

                width: PathView.view.width
                height: labelHeight + cellHeight

                visible: PathView.onPath
                opacity: PathView.isCurrentItem ? 1.0 : 0.6
                Behavior on opacity { NumberAnimation { duration: 150 } }
                
                Text {
                    text: modelData.name || modelData.shortName

                    height: labelHeight
                    verticalAlignment: Text.AlignVCenter

                    anchors.left: parent.left
                    anchors.leftMargin: leftGuideline

                    color: "white"
                    font {
                        pixelSize: labelFontSize
                        family: globalFonts.sans
                        bold: true
                        capitalization:  Font.AllUppercase
                    }
                }

                PathView {
                    id: gameAxis

                    width: parent.width
                    height: cellHeight
                    anchors.bottom: parent.bottom
                    
                    model: games
                    delegate: GameAxisCell {
                    
                        game: modelData
                        width:cellWidth *0.98
                        height: cellHeight * 0.78
                        selected: PathView.isCurrentItem
                        selectedRow: currentRow 
                    }
                    readonly property var currentGame: games.get(currentIndex)
                    
                    readonly property int maxItemCount: 2 + Math.ceil(width / cellPaddedWidth)
                    pathItemCount: Math.min(maxItemCount, model.count)

                    property int fullPathWidth: pathItemCount * cellPaddedWidth
                    path: Path {
                        startX: (gameAxis.model.count >= gameAxis.maxItemCount)
                            ? leftGuideline - cellPaddedWidth * 1.5
                            : leftGuideline + (cellPaddedWidth * 0.5  - cellSpacing * 0.5);
                        startY: cellHeight * 0.5
                        PathLine {
                            x: gameAxis.path.startX + gameAxis.fullPathWidth
                            y: gameAxis.path.startY
                        }
                    }

                    snapMode: PathView.SnapOneItem
                    highlightRangeMode: PathView.StrictlyEnforceRange
                    clip: true

                    preferredHighlightBegin: (gameAxis.model.count >= gameAxis.maxItemCount)
                        ? (2 * cellPaddedWidth - cellSpacing / 2) / fullPathWidth
                        : 0;
                    preferredHighlightEnd: preferredHighlightBegin
                }
            }
        }
    }
}
