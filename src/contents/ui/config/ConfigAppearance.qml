/*
    SPDX-FileCopyrightText: 2020-2022 Łukasz Wojniłowicz <lukasz.wojnilowicz@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2

ColumnLayout {
  id: main
  spacing : 6

  property alias cfg_iconEnabled: iconEnabled.checked
  property alias cfg_iconHeightPercentage: iconHeightPercentage.value

  property alias cfg_progressBarEnabled: progressBarEnabled.checked
  property alias cfg_progressBarNormalBackground: normalBackground.chosenColor
  property alias cfg_progressBarOverdueBackground: overdueBackground.chosenColor
  property alias cfg_progressBarNormalForeground: normalForeground.chosenColor
  property alias cfg_progressBarRestingElapsedForeground: restingElapsedForeground.chosenColor
  property alias cfg_progressBarRestingForeground: restingForeground.chosenColor
  property alias cfg_progressBarHeightPercentage: progressBarHeightPercentage.value

  property alias cfg_labelEnabled: labelEnabled.checked
  property alias cfg_useCustomFont: useCustomFont.checked
  property alias cfg_customFont: fontDialog.font
  property alias cfg_fontColor: fontColor.chosenColor
  property alias cfg_showOnlyTheMostSignificantTimerPart: showOnlyTheMostSignificantTimerPart.checked
  property alias cfg_showTimeUnits: showTimeUnits.checked
  property alias cfg_showMinusSign: showMinusSign.checked

  property alias cfg_timersExtraWidth: timersExtraWidth.value
  property alias cfg_timersExtraHeight: timersExtraHeight.value
  property alias cfg_timersSpacing: timersSpacing.value

  GroupBox {
    Layout.fillWidth: true
    label: CheckBox {
      id: iconEnabled
      text: i18n("Display icon")
      enabled: labelEnabled.checked
    }

    RowLayout {
      anchors.fill: parent
      spacing : main.spacing

      SpinBox {
        id: iconHeightPercentage
        from: 5
        to: 100
        stepSize: 1
        inputMethodHints: Qt.ImhDigitsOnly
      }

      Label {
        Layout.fillWidth: true
        text: i18n("Height percentage")
      }
    }

  }
  GroupBox {
    Layout.fillWidth: true
    label: CheckBox {
      id: progressBarEnabled
      text: i18n("Display progress bar")
      enabled: labelEnabled.checked
    }

    ColumnLayout {
      anchors.fill: parent
      spacing : main.spacing
      enabled: progressBarEnabled.checked

      ColorPicker {
        id: normalBackground
        Layout.fillWidth: true
        colorLabel: i18n("Background in normal state")
      }

      ColorPicker {
        id: overdueBackground
        Layout.fillWidth: true
        colorLabel: i18n("Background in overdue state")
      }

      ColorPicker {
        id: normalForeground
        Layout.fillWidth: true
        colorLabel: i18n("Foreground in activity state")
      }

      ColorPicker {
        id: restingElapsedForeground
        Layout.fillWidth: true
        colorLabel: i18n("Foreground at idle time in elapsed time")
      }

      ColorPicker {
        id: restingForeground
        Layout.fillWidth: true
        colorLabel: i18n("Foreground at idle time")
      }

      RowLayout {
        Layout.fillWidth: true
        spacing : main.spacing

        SpinBox {
          id: progressBarHeightPercentage
          from: 5
          to: 100
          stepSize: 1
          inputMethodHints: Qt.ImhDigitsOnly
        }

        Label {
          Layout.fillWidth: true
          text: i18n("Height percentage")
        }
      }

    }
  }

  SystemPalette {
    id: activePalette
    colorGroup: SystemPalette.Active
  }

  GroupBox {
    Layout.fillWidth: true
    label: CheckBox {
      id: labelEnabled
      text: i18n("Display label")
      enabled: progressBarEnabled.checked
    }

    ColumnLayout {
      anchors.fill: parent
      spacing : main.spacing
      enabled: labelEnabled.checked

      GroupBox {
        Layout.fillWidth: true
        label: CheckBox {
          id: useCustomFont
          text: i18n("Use custom font")
        }

        ColumnLayout {
          anchors.fill: parent
          spacing : main.spacing
          enabled: useCustomFont.checked

          RowLayout {
            Layout.fillWidth: true
            spacing : main.spacing
            Button {
              Layout.fillWidth: true
              id: customFontButton
              text: i18n("Custom font...")
              onClicked: {
                if (!fontDialog.font.family.length)
                  fontDialog.font = theme.defaultFont
                fontDialog.open()
              }
            }

            Button {
              Layout.fillWidth: true
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

      CheckBox {
        id: showOnlyTheMostSignificantTimerPart
        text: i18n("Show only the most significant timer part")
        ToolTip {
          text: i18n("Check this if you want to hide e.g. seconds left when there are still some minutes left.")
        }
      }

      CheckBox {
        id: showTimeUnits
        enabled: showOnlyTheMostSignificantTimerPart.checked
        text: i18n("Show time units")
        ToolTip {
          text: i18n("Check this if you want to show time units like: h, m, s in a timer.")
        }
      }

      CheckBox {
        id: showMinusSign
        text: i18n("Show minus sign")
        ToolTip {
          text: i18n("Check this if you want to show a minus sign if a timer is overdue.")
        }
      }
    }
  }

  GroupBox {
    Layout.fillWidth: true
    title: i18n("Misc")

    ColumnLayout {
      anchors.fill: parent
      Layout.fillWidth: true
      spacing : main.spacing

      RowLayout {
        Layout.fillWidth: true
        spacing : main.spacing

        SpinBox {
          id: timersExtraWidth
          from: 0
          stepSize: 1
          inputMethodHints: Qt.ImhDigitsOnly
        }

        Label {
          Layout.fillWidth: true
          text: i18n("Extra width per timer")
        }
      }

      RowLayout {
        Layout.fillWidth: true
        spacing : main.spacing

        SpinBox {
          id: timersExtraHeight
          from: 0
          stepSize: 1
          inputMethodHints: Qt.ImhDigitsOnly
        }

        Label {
          Layout.fillWidth: true
          text: i18n("Extra height per timer")
        }
      }

      RowLayout {
        Layout.fillWidth: true
        spacing : main.spacing
        SpinBox {
          id: timersSpacing
          from: 0
          stepSize: 1
          inputMethodHints: Qt.ImhDigitsOnly
        }

        Label {
          Layout.fillWidth: true
          text: i18n("Spacing between timers")
        }
      }

      RowLayout {
        Layout.fillWidth: true
        spacing: main.spacing
        Button {
          Layout.fillWidth: true
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
          Layout.fillWidth: true
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
