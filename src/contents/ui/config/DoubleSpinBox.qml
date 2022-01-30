/*
    SPDX-FileCopyrightText: 2020 Łukasz Wojniłowicz <lukasz.wojnilowicz@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// based on https://stackoverflow.com/questions/43406830/how-to-use-float-in-a-qml-spinbox
import QtQuick 2.7
import QtQuick.Controls 2.0

Row {
  id: main
  property int decimals: 2
  property real realValue: 0.0
  property real realFrom: 0.0
  property real realTo: 100.0
  property real realStepSize: 1.0
  property string realText: ""
  property string tooltipText: ""

  spacing: 6

  SpinBox{
    property real factor: Math.pow(10, decimals)
    id: spinbox
    editable: true
    stepSize: realStepSize*factor
    value: realValue*factor
    to : realTo*factor
    from : realFrom*factor
    validator: DoubleValidator {
      bottom: Math.min(spinbox.from, spinbox.to)*spinbox.factor
      top:  Math.max(spinbox.from, spinbox.to)*spinbox.factor
    }
    hoverEnabled: true

    ToolTip {
      visible: tooltipText.length ? parent.hovered : false
      text: tooltipText
    }

    textFromValue: function(value, locale) {
      main.realValue = parseFloat(value*1.0/factor).toFixed(decimals)
      return parseFloat(value*1.0/factor).toFixed(decimals);
    }
  }

  Label {
    anchors.verticalCenter: parent.verticalCenter
    text: realText
  }
}