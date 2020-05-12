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