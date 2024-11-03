/*
    SPDX-FileCopyrightText: 2020-2024 Łukasz Wojniłowicz <lukasz.wojnilowicz@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 6.0
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Item {
    id: colorPicker

    property alias chosenColor: colorDialog.selectedColor
    property alias colorLabel: labelElement.text

    width: childrenRect.width
    height: childrenRect.height

  Row {
    spacing : 6
      Rectangle {
        id: progressBarNormalBackground
        color: colorDialog.selectedColor
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
