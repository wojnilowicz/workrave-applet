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

Column {
  id: main
  property alias cfg_progressBarNormalBackground: normalBackground.chosenColor
  property alias cfg_progressBarOverdueBackground: overdueBackground.chosenColor
  property alias cfg_progressBarNormalForeground: normalForeground.chosenColor
  property alias cfg_progressBarRestingElapsedForeground: restingElapsedForeground.chosenColor
  property alias cfg_progressBarRestingForeground: restingForeground.chosenColor

  property alias cfg_useCustomFont: useCustomFont.checked
  property alias cfg_customFont: fontDialog.font
  property alias cfg_fontColor: fontColor.chosenColor

  property alias cfg_progressBarHeightMultiplier: progressBarHeightMultiplier.realValue
  property alias cfg_timersExtraWidth: timersExtraWidth.realValue
  property alias cfg_timersSpacing: timersSpacing.realValue
  property alias cfg_fontHeightMultiplier: fontHeightMultiplier.realValue
  property alias cfg_progressBarEnabled: progressBarEnabled.checked
  property alias cfg_labelEnabled: labelEnabled.checked


  spacing : 6
  GroupBox {
    label: CheckBox {
      id: progressBarEnabled
      text: i18n("Display progress bar")
      enabled: labelEnabled.checked
    }

    anchors.left: parent.left
    anchors.right: parent.right

    Column {
      spacing : main.spacing
      enabled: progressBarEnabled.checked

      ColorPicker {
        id: normalBackground
        colorLabel: i18n("Background in normal state")
      }

      ColorPicker {
        id: overdueBackground
        colorLabel: i18n("Background in overdue state")
      }

      ColorPicker {
        id: normalForeground
        colorLabel: i18n("Foreground in activity state")
      }

      ColorPicker {
        id: restingElapsedForeground
        colorLabel: i18n("Foreground at idle time in elapsed time")
      }

      ColorPicker {
        id: restingForeground
        colorLabel: i18n("Foreground at idle time")
      }

      DoubleSpinBox {
        id: progressBarHeightMultiplier

        realText: i18n("Height multiplier")
        decimals: 1
        realStepSize: 0.1
        realFrom: 0.1
        realTo: 1.0
      }

    }
  }

  SystemPalette {
    id: activePalette
    colorGroup: SystemPalette.Active
  }

  GroupBox {
    label: CheckBox {
      id: labelEnabled
      text: i18n("Display label")
      enabled: progressBarEnabled.checked
    }

    anchors.left: parent.left
    anchors.right: parent.right

    Column {
      spacing : main.spacing
      enabled: labelEnabled.checked


      GroupBox {
        label: CheckBox {
          id: useCustomFont
          text: i18n("Use custom font")
        }

        anchors.left: parent.left
        anchors.right: parent.right

        Column {
          spacing : main.spacing
          enabled: useCustomFont.checked


          Row {
            spacing : main.spacing
            Button {
              id: customFontButton
              text: i18n("Custom font...")
              onClicked: {
                if (!fontDialog.font.family.length)
                  fontDialog.font = theme.defaultFont
                fontDialog.open()
              }
            }

            Button {
              onClicked: {
                fontDialog.font = theme.defaultFont
              }

              ToolTip {
                text: i18n("Reset custom font to theme default.")
              }

              icon.name: "view-refresh"
            }
          }

          FontDialog {
            id: fontDialog
          }


        }
      }

      ColorPicker {
        id: fontColor
        colorLabel: i18n("Color")
      }
      DoubleSpinBox {
        id: fontHeightMultiplier

        realText: i18n("Height multiplier")
        decimals: 1
        realStepSize: 0.1
        realFrom: 1.0
        realTo: 2.0
      }

    }
  }

  GroupBox {
    title: i18n("Misc")
    anchors.left: parent.left
    anchors.right: parent.right

    Column {
      spacing : main.spacing

      DoubleSpinBox {
        id: timersExtraWidth

        realText: i18n("Extra width per timer")
        decimals: 0
        realStepSize: 1.0
        realFrom: 0.0
      }

      DoubleSpinBox {
        id: timersSpacing

        realText: i18n("Spacing between timers")
        decimals: 0
        realStepSize: 1.0
        realFrom: 0.0
      }

      Row {
        spacing: main.spacing
        Button {
          text: i18n("Use Workrave colors")
          onClicked: {
            normalBackground.chosenColor = "#F6F5F4"
            overdueBackground.chosenColor = "#FFA500"
            normalForeground.chosenColor = "#ADD8E6"
            restingElapsedForeground.chosenColor = "#00D4B2"
            restingForeground.chosenColor = "#90EE90"
            fontColor.chosenColor = "#000000"
          }
        }

        Button {
          text: i18n("Use system theme colors")
          onClicked: {

            normalBackground.chosenColor = activePalette.base
            overdueBackground.chosenColor = "#FFA500"
            normalForeground.chosenColor = activePalette.highlight
            restingElapsedForeground.chosenColor = activePalette.light
            restingForeground.chosenColor = "#90EE90"
            fontColor.chosenColor = activePalette.text
          }
        }
      }
    }
  }
}
