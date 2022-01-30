/*
    SPDX-FileCopyrightText: 2020-2022 Łukasz Wojniłowicz <lukasz.wojnilowicz@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

ColumnLayout {
  id: main
  spacing: 6

  property alias cfg_microTimer: microTimer.checked
  property alias cfg_restTimer: restTimer.checked
  property alias cfg_dailyTimer: dailyTimer.checked

  property alias cfg_timersOrientation: timersOrientation.currentIndex
  property alias cfg_singleTimerMode: singleTimerMode.checked

  property alias cfg_periodicalSwitch: periodicalSwitch.checked
  property alias cfg_periodicalSwitchInterval: periodicalSwitchInterval.value

  property alias cfg_conditionalSwitch: conditionalSwitch.checked
  property alias cfg_timeDifferenceSwitch: timeDifferenceSwitch.checked
  property alias cfg_timeDifferenceSwitchDifference: timeDifferenceSwitchDifference.value

  property alias cfg_detectWorkraveConfigurationChanges: detectWorkraveConfigurationChanges.checked
  property alias cfg_updateInterval: updateInterval.value

  GroupBox {
    Layout.fillWidth: true
    label: Label {
      text: i18nc("Breaks as in break from work.", "Breaks")
    }

    ColumnLayout {
      spacing: main.spacing

      CheckBox {
        id: microTimer
        text: i18n("Enable micro break timer")
      }

      CheckBox {
        id: restTimer
        text: i18n("Enable rest timer")
      }

      CheckBox {
        id: dailyTimer
        text: i18n("Enable daily limit timer")
      }
    }
  }

  GroupBox {
    Layout.fillWidth: true
    label: Label {
      text: i18n("Layout")
    }

    ColumnLayout {
      anchors.fill: parent
      spacing: main.spacing

      RowLayout {
        Layout.fillWidth: true
        spacing: main.spacing

        Label {
          id: timersOrientationLabel
          text: i18nc("Whether timers should be laid out horizontally/vertically/automatically", "Orientation")
        }

        ComboBox {
          id: timersOrientation
          Layout.fillWidth: true
          textRole: "text"
          valueRole: "value"
          model: [
            { value: "auto",        text: i18n("Auto") },
            { value: "horizontal",  text: i18n("Horizontal") },
            { value: "vertical",    text: i18n("Vertical") }
          ]
        }
      }

      GroupBox {
        label: CheckBox {
          id: singleTimerMode
          text: i18n("Single timer display mode")
          ToolTip {
            text: i18n("Check this if you want to display only a single timer at a time. Click or drag on it with a pointer if you want to switch to another timer.")
          }
        }
        Layout.fillWidth: true

        ColumnLayout {
          anchors.fill: parent
          spacing: main.spacing

          GroupBox {
            enabled: singleTimerMode.checked
            label: CheckBox {
              id: periodicalSwitch
              text: i18n("Switch timers periodically")
              ToolTip {
                text: i18n("Check this if you want to switch to another timer after given amount of seconds.")
              }
            }
            Layout.fillWidth: true

            ColumnLayout {
              anchors.fill: parent
              spacing: main.spacing

              RowLayout {
                spacing : main.spacing

                SpinBox {
                  id: periodicalSwitchInterval
                  from: 5
                  to: 999
                  stepSize: 1
                  inputMethodHints: Qt.ImhDigitsOnly
                }

                Label {
                  Layout.fillWidth: true
                  text: i18n("Periodical switching interval in seconds")
                }
              }
            }

          }

          GroupBox {
            enabled: singleTimerMode.checked
            label: CheckBox {
              id: conditionalSwitch
              text: i18n("Switch timers conditionally")
              ToolTip {
                text: i18n("Check this if you want to switch to another timer when a condition is met.")
              }
            }
            Layout.fillWidth: true

            ColumnLayout {
              anchors.fill: parent
              spacing: main.spacing

              CheckBox {
                id: timeDifferenceSwitch
                enabled: conditionalSwitch.checked
                text: i18n("Switch on a difference between elapsed and limit time")
                ToolTip {
                  text: i18n("Check this if you want to automatically switch to a timer closest to being overdue.")
                }
              }

              RowLayout {
                spacing : main.spacing

                SpinBox {
                  id: timeDifferenceSwitchDifference
                  enabled: timeDifferenceSwitch.checked
                  from: 0
                  to: 9999
                  stepSize: 1
                  inputMethodHints: Qt.ImhDigitsOnly
                }

                Label {
                  Layout.fillWidth: true
                  text: i18n("Difference between elapsed and limit time")
                }
              }

            }
          }
        }
      }
    }
  }

  GroupBox {
    Layout.fillWidth: true
    label: Label {
      text: i18n("Misc")
    }

    ColumnLayout {
      spacing: main.spacing

      CheckBox {
        id: detectWorkraveConfigurationChanges
        text: i18n("Detect Workrave configuration changes")
        ToolTip {
          text: i18nc("The Applet can synchronize its settings with Workrave automatically, at certain time intervals, which will be using some CPU resources. The alternative is letting the user to do it manually only when needed.", "Disable if performance is of concern, and you want to update it manually in context menu.")
        }
      }

      RowLayout {
        spacing : main.spacing

        SpinBox {
          id: updateInterval
          from: 1
          stepSize: 1
          inputMethodHints: Qt.ImhDigitsOnly
          ToolTip {
            text: i18nc("Timers can report their status e.g. every 5 seconds (instead of every 1 second) and thus need less CPU resources.", "Set higher if performance is of concern, and you don't need frequent timer readings.")
          }
        }

        Label {
          Layout.fillWidth: true
          text: i18n("Update interval in seconds")
        }
      }

    }
  }

  Item {Layout.fillHeight: true} // <-- filler here
}
