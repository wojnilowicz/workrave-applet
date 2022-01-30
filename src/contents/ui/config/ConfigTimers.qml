/*
    SPDX-FileCopyrightText: 2020-2022 Łukasz Wojniłowicz <lukasz.wojnilowicz@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Column {
  property alias cfg_microTimer: microTimer.checked
  property alias cfg_restTimer: restTimer.checked
  property alias cfg_dailyTimer: dailyTimer.checked
  property alias cfg_detectWorkraveConfigurationChanges: detectWorkraveConfigurationChanges.checked
  property alias cfg_updateInterval: updateInterval.realValue

  id: main
  spacing: 6

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

  CheckBox {
    id: detectWorkraveConfigurationChanges
    text: i18n("Detect Workrave configuration changes")
    ToolTip {
      text: i18nc("The Applet can synchronize its settings with Workrave automatically, at certain time intervals, which will be using some CPU resources. The alternative is letting the user to do it manually only when needed.", "Disable if performance is of concern, and you want to update it manually in context menu.")
    }
  }

  DoubleSpinBox {
    id: updateInterval

    realText: i18n("Update interval in seconds")


    tooltipText: i18nc("Timers can report their status e.g. every 5 seconds (instead of every 1 second) and thus need less CPU resources.", "Set higher if performance is of concern, and you don't need frequent timer readings.")

    decimals: 1
    realStepSize: 0.1
    realFrom: 1.0
  }
}