/*
    SPDX-FileCopyrightText: 2020 Łukasz Wojniłowicz <lukasz.wojnilowicz@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
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
