/*
    SPDX-FileCopyrightText: 2020-2024 Łukasz Wojniłowicz <lukasz.wojnilowicz@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 6.0
import org.kde.plasma.configuration

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
