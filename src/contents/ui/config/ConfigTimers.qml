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
      text: i18n("Disable if performance is of concern, and you want to update it manually in context menu.")
    }
  }

  DoubleSpinBox {
    id: updateInterval

    realText: i18n("Update interval in seconds")


    tooltipText: i18n("Set higher if performance is of concern, and you don't need frequent timer readings.")

    decimals: 1
    realStepSize: 0.1
    realFrom: 1.0
  }
}