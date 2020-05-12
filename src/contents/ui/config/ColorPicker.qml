/*
 * Copyright 2020  Łukasz Wojniłowicz <lukasz.wojnilowicz@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2

Item {
    id: colorPicker

    property alias chosenColor: colorDialog.color
    property alias colorLabel: labelElement.text

    width: childrenRect.width
    height: childrenRect.height

  Row {
    spacing : 6
      Rectangle {
        id: progressBarNormalBackground
        color: colorDialog.color
        height: 20
        width: height

        ColorDialog {
            id: colorDialog
        }

        MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            colorDialog.open()
        }
    }
    }
    Label {
      id: labelElement
    }
}
}
