/*
    SPDX-FileCopyrightText: 2020 Łukasz Wojniłowicz <lukasz.wojnilowicz@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.7
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
         name: i18n("Timers")
         icon: 'preferences-system-time'
         source: 'config/ConfigTimers.qml'
    }

    ConfigCategory {
         name: i18n("Appearance")
         icon: 'preferences-desktop-color'
         source: 'config/ConfigAppearance.qml'
    }
}
