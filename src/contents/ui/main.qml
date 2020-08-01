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
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
  id: main
  anchors.fill: parent
  Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation

  property var workraveConfigKeys: [ "limit", "auto_reset" ]
  property var workraveTimerMethods: [ "GetTimerElapsed", "GetTimerOverdue", "GetTimerIdle" ]

  property var propertyNameFromMethod : {
    "GetTimerElapsed" : "elapsed",
    "GetTimerOverdue" : "overdue",
    "GetTimerIdle" : "idle"
  }

  property var configTimerNamesFromTimerNames : {
    "microbreak" : "micro_pause",
    "restbreak" : "rest_break",
    "dailylimit" : "daily_limit"
  }

  property var updateIntervalInMilliseconds: plasmoid.configuration.updateInterval * 1000
  property bool isKF5_5_70_0: false

  property bool isWorkraveInstalled: false

  property var sizeConfiguration: plasmoid.configuration.timersExtraWidth | plasmoid.configuration.fontHeightMultiplier | plasmoid.configuration.timersSpacing
  onSizeConfigurationChanged: slotSizeConfigurationChanged()

  property var timersConfiguration: plasmoid.configuration.microTimer | plasmoid.configuration.restTimer | plasmoid.configuration.dailyTimer
  onTimersConfigurationChanged: slotTimersConfigurationChanged()

  property var fontConfiguration: plasmoid.configuration.useCustomFont | plasmoid.configuration.customFont | plasmoid.configuration.fontHeightMultiplier
  onFontConfigurationChanged: slotFontConfigurationChanged()

  property var dataSourceConfiguration : plasmoid.configuration.detectWorkraveConfigurationChanges | plasmoid.configuration.updateInterval
  onDataSourceConfigurationChanged: slotDataSourceConfigurationChanged()


  function slotSizeConfigurationChanged() {
    if (isWorkraveInstalled)
      action_adjustSize()
  }

  function slotTimersConfigurationChanged() {
    if (isWorkraveInstalled)
      reloadAppletTimers()
  }

  function slotFontConfigurationChanged() {
    if (!plasmoid.configuration.useCustomFont)
      textMetrics.font = theme.defaultFont
    else
      textMetrics.font = plasmoid.configuration.customFont
    textMetrics.font.pointSize = textMetrics.font.pointSize * plasmoid.configuration.fontHeightMultiplier

    if (!isWorkraveInstalled)
      return

    action_adjustSize()
  }

  function slotDataSourceConfigurationChanged() {
    if (!isWorkraveInstalled)
      return

    workraveConfigDBus.interval = plasmoid.configuration.detectWorkraveConfigurationChanges ? updateIntervalInMilliseconds : 0
    workraveDataDBus.interval = updateIntervalInMilliseconds
  }

  property var widgetWidth : 0

//   Layout.preferredWidth: widgetWidth
  Layout.minimumWidth: widgetWidth

  Timer {
    id: adjustSizeTimer
        interval: updateIntervalInMilliseconds
        repeat: true
        running: false
        onTriggered: {
          for (let i = 0; i < timersModel.count; ++i) {
            let timer = timersModel.get(i)
            if (timer.elapsed >= timer.limit)
              break
            this.running = false
          }
          action_adjustSize()
        }
    }

  Component {
    id: timerComponent
    Rectangle {
      height: listView.height * plasmoid.configuration.progressBarHeightMultiplier
      width: (listView.width - (listView.count - 1) * listView.spacing) * model.width_ratio
      anchors.verticalCenter: parent.verticalCenter
      color: "transparent"

      Rectangle {
        anchors.fill : parent
        color : {
          if (model.elapsed >= model.limit) {
            adjustSizeTimer.running = true
            return plasmoid.configuration.progressBarOverdueBackground
          }
          return plasmoid.configuration.progressBarNormalBackground
        }
        visible: plasmoid.configuration.progressBarEnabled
      }

      Rectangle {
        id : elapsedTimeProgress
        height : parent.height
        width : model.elapsed >= model.limit ? 0 : parent.width * model.elapsed / model.limit
        color :  plasmoid.configuration.progressBarNormalForeground
        visible: plasmoid.configuration.progressBarEnabled
      }

      Rectangle {
        id : restInElapsedTimeProgress
        height : parent.height
        width : {
          if (model.idle && model.elapsed < model.limit) {
            if (model.idle <= model.auto_reset) {
              return Math.min(parent.width * model.idle / model.auto_reset, elapsedTimeProgress.width)
            }
            return elapsedTimeProgress.width
          }
          return 0
        }
        color : plasmoid.configuration.progressBarRestingElapsedForeground
        visible: plasmoid.configuration.progressBarEnabled
      }

      Rectangle {
        id : restProgress
        height : parent.height
        anchors.left: restInElapsedTimeProgress.right
        width : {
          if (model.idle >= model.auto_reset && model.auto_reset)
            return parent.width
          return (parent.width * model.idle / model.auto_reset) - restInElapsedTimeProgress.width
        }
        color : plasmoid.configuration.progressBarRestingForeground
        visible: plasmoid.configuration.progressBarEnabled
      }

      Label {
        color: plasmoid.configuration.fontColor
        anchors.centerIn: parent
        font: textMetrics.font
        text: secondsLeft(model)
        visible: plasmoid.configuration.labelEnabled
      }
    }
  }

  ListView {
    id: listView
    anchors.fill : parent
    spacing: plasmoid.configuration.timersSpacing
    orientation: ListView.Horizontal
    model: timersModel
    delegate: timerComponent
  }

  ListModel {
    id: timersModel
  }

  PlasmaCore.DataSource {
    id: workraveConfigDBus
    engine: 'executable'
    interval: plasmoid.configuration.detectWorkraveConfigurationChanges ? updateIntervalInMilliseconds : 0

    onNewData: {
      let isValueUnchanged = false
      for (let i = 0; i < timersModel.count; ++i) {
        let timer = timersModel.get(i)
        let configID = configTimerNamesFromTimerNames[timer.id]
        if (!sourceName.includes(configID))
          continue

        for (const key of workraveConfigKeys) {
          if (!sourceName.includes('/' + key))
            continue
          let value = parseInt(data.stdout.split('\n')[0])
          if (timer[key] == value && value) {
            isValueUnchanged = true
            continue
          }

          timersModel.setProperty(i, key, value)
        }
      }

      if (!isKF5_5_70_0)
        interval = plasmoid.configuration.detectWorkraveConfigurationChanges ? updateIntervalInMilliseconds : 0

      if (isValueUnchanged)
        return

      let limitsCount = 0
      for (let i = 0; i < timersModel.count; ++i)
        if (timersModel.get(i).limit)
          limitsCount += 1

      if (limitsCount == timersModel.count)
        action_adjustSize()
    }

  }

  PlasmaCore.DataSource {
    id: workraveDataDBus
    engine: 'executable'
    interval: updateIntervalInMilliseconds

    onNewData: {
      for (let workraveTimerMethod in propertyNameFromMethod) {
        if (!sourceName.includes(workraveTimerMethod))
          continue

        for (let i = 0; i < timersModel.count; ++i) {
          let id = timersModel.get(i).id
          if (!sourceName.includes(id))
            continue

          let key = propertyNameFromMethod[workraveTimerMethod]
          let value = parseInt(data.stdout.replace(/(\r\n|\n|\r)/gm, ""))

          timersModel.setProperty(i, key, value)
          break
        }
      }
    }

  }

  Image {
    id: placeholderIcon
    anchors.fill: parent
    scale: 0.8
    source: '../workrave-sheep.svg'
  }


  PlasmaCore.ToolTipArea {
    id: placeholderTooltip
    anchors.fill: parent
    icon: 'dialog-warning'
  }


  PlasmaCore.DataSource {
    id: workraveCheckDBus
    engine: 'executable'
    interval: 0
    connectedSources: ["qdbus org.workrave.Workrave"]
    onNewData: {
      if (!interval)
        return

      if (data.stdout.length) {
        isWorkraveInstalled = true
        workraveDataDBus.interval = updateIntervalInMilliseconds
        workraveConfigDBus.interval = plasmoid.configuration.detectWorkraveConfigurationChanges ? updateIntervalInMilliseconds : 0

        reloadAppletTimers()
        plasmoid.userConfiguringChanged.connect(userConfiguringChanged)
        plasmoid.setAction('reloadWorkraveConfiguration', i18n("Reload Workrave configuration"), 'view-refresh');
        plasmoid.setAction('adjustSize', i18n("Recalculate applet size"), 'zoom-fit-width');

        if (isKF5_5_70_0)
          interval = 36000
        else
          interval = 0
      } else {
        isWorkraveInstalled = false
        interval = 1000
        workraveDataDBus.interval = 0
        workraveConfigDBus.interval = 0

        placeholderIcon.visible = true
        placeholderTooltip.visible = true
        placeholderTooltip.mainText = i18n("Workrave not installed")
        placeholderTooltip.subText = i18n("Please install Workrave.")

      }

    }

  }

  PlasmaCore.DataSource {
    id: kdeFrameworksCheck
    engine: 'executable'
    interval: 0
    connectedSources: ["kf5-config --kde-version"]
    onNewData: {
      let kf5version = data.stdout.trim()
      switch (kf5version) {
        case "5.70.0":
          isKF5_5_70_0 = true
          console.warn("Running on buggy KF5 5.70.0. Expect deficiencies due to https://bugs.kde.org/show_bug.cgi?id=422973")
          break
        default:
          break;
      }
      workraveCheckDBus.interval = 1

    }
  }

  Component.onCompleted: {

  }

  function reloadAppletTimers() {

    let newTimerIds = []
    if (plasmoid.configuration.microTimer)
      newTimerIds.push("microbreak")

    if (plasmoid.configuration.restTimer)
      newTimerIds.push("restbreak")

    if (plasmoid.configuration.dailyTimer)
      newTimerIds.push("dailylimit")


    let oldTimerIds = []
    for (let i = 0; i < timersModel.count; ++i)
      oldTimerIds.push(timersModel.get(i).id)

    for (let oldTimerId of oldTimerIds) {
      if (newTimerIds.length && newTimerIds.includes(oldTimerId))
        continue
      removeDataSource(oldTimerId)
      removeConfigSource(oldTimerId)
      removeModelItem(oldTimerId)
    }

    for (const newTimerId of newTimerIds) {
      if (oldTimerIds.length && oldTimerIds.includes(newTimerId))
        continue

      addDataSource(newTimerId)
      addConfigSource(newTimerId)
      addModelItem(newTimerId)
    }

    action_reloadWorkraveConfiguration()

    if (!newTimerIds.length) {
      placeholderIcon.visible = true
      placeholderTooltip.visible = true
      placeholderTooltip.mainText = i18n("No Workrave timers added")
      placeholderTooltip.subText = i18n("Please add a timer in applet settings.")
    } else {
      placeholderIcon.visible = false
      placeholderTooltip.visible = false
    }

    // this ensures that the size is adjusted, if a timer is removed
    action_adjustSize()
  }

  function userConfiguringChanged() {
    if (plasmoid.userConfiguring)
      return
    action_adjustSize()
  }

  function action_reloadWorkraveConfiguration() {
    workraveConfigDBus.interval = 1
  }

  property string dbusDataCommand : 'qdbus org.workrave.Workrave  /org/workrave/Workrave/Core org.workrave.CoreInterface.{workraveTimerMethod} "{workraveTimerName}"'

  function addDataSource(timerId) {
    let workraveTimerName = timerId
    for (let workraveTimerMethod of workraveTimerMethods) {
      let dbusSpecificCommand = dbusDataCommand.replace('{workraveTimerMethod}', workraveTimerMethod).replace('{workraveTimerName}', workraveTimerName)
      workraveDataDBus.connectedSources.push(dbusSpecificCommand)
    }
  }

  function removeDataSource(timerId) {
    let workraveTimerName = timerId
    for (let workraveTimerMethod of workraveTimerMethods) {
      let dbusSpecificCommand = dbusDataCommand.replace('{workraveTimerMethod}', workraveTimerMethod).replace('{workraveTimerName}', workraveTimerName)

      let index = workraveDataDBus.connectedSources.indexOf(dbusSpecificCommand)
      if (index != -1) {
        // connectedSources is messed up if used splice directly on it, so workaround it
        let connectedSourcesCopy = JSON.parse(JSON.stringify( workraveDataDBus.connectedSources ))
        connectedSourcesCopy.splice(index, 1)
        workraveDataDBus.connectedSources = JSON.parse(JSON.stringify( connectedSourcesCopy ))
      }
    }
  }

  property string dbusConfigCommand : 'qdbus org.workrave.Workrave  /org/workrave/Workrave/Core org.workrave.ConfigInterface.GetInt /timers/{workraveConfigName}/{workraveConfigKey}'

  function addConfigSource(timerId) {
    let workraveConfigName = configTimerNamesFromTimerNames[timerId]
    for (let workraveConfigKey of workraveConfigKeys) {
      let dbusSpecificCommand = dbusConfigCommand.replace('{workraveConfigName}', workraveConfigName).replace('{workraveConfigKey}', workraveConfigKey)
      workraveConfigDBus.connectedSources.push(dbusSpecificCommand)
    }
  }

  function removeConfigSource(timerId) {

    let workraveConfigName = configTimerNamesFromTimerNames[timerId]
    for (let workraveConfigKey of workraveConfigKeys) {
      let dbusSpecificCommand = dbusConfigCommand.replace('{workraveConfigName}', workraveConfigName).replace('{workraveConfigKey}', workraveConfigKey)
      let index = workraveConfigDBus.connectedSources.indexOf(dbusSpecificCommand)
      if (index != -1) {
        // connectedSources is messed up if used splice directly on it, so workaround it
        let connectedSourcesCopy = JSON.parse(JSON.stringify( workraveConfigDBus.connectedSources ))
        connectedSourcesCopy.splice(index, 1)
        workraveConfigDBus.connectedSources = JSON.parse(JSON.stringify( connectedSourcesCopy ))
      }
    }
  }

  function appletTimer(timerID) {
    this.id = timerID
    this.elapsed = 0
    this.overdue = 0
    this.idle = 0
    this.limit = 0
    this.auto_reset = 0
    this.width_ratio = 0
  }

  function addModelItem(timerId) {
    let microItem = new appletTimer(timerId)
    timersModel.append(microItem)
  }

  function removeModelItem(timerId) {
    for (let i = 0; i < timersModel.count; ++i) {
      if (timersModel.get(i).id == timerId) {
        timersModel.remove(i)
        break
      }
    }
  }

  function secondsLeft(timersModelItem) {
    let seconds = timersModelItem.limit - timersModelItem.elapsed
    let date = new Date(0)
    date.setSeconds(Math.abs(seconds))
    let timerString = date.toISOString().substr(11, 8)
    timerString = timerString.replace(/^[0:]+/, "")

    if (!seconds)
      timerString = "0"
    else if (seconds < 0)
      timerString = "-" + timerString
    return timerString
  }

  function action_adjustSize() {
    let newWidth = 0
    let digitsSum = 0
    let timerStringLengths = []
    for (let i = 0; i < timersModel.count; ++i) {
      let timerValueToEstimateLength = timersModel.get(i).limit
      if (timersModel.get(i).elapsed - timersModel.get(i).limit > timersModel.get(i).limit)
        timerValueToEstimateLength = timersModel.get(i).elapsed

      let date = new Date(0)
      date.setSeconds(Math.abs(timerValueToEstimateLength))
      let timerString = date.toISOString().substr(11, 8)
      timerString = timerString.replace(/^[0:]+/, "")
      timerString = '-' + timerString

      let timerStringLength = timerString.length
      textMetrics.text = timerString
      let timerStringPixelLength = textMetrics.width

      digitsSum += timerStringLength
      timerStringLengths.push(timerStringLength)

      newWidth += timerStringPixelLength
      newWidth += plasmoid.configuration.timersExtraWidth
    }

    newWidth += timersModel.count * plasmoid.configuration.timersSpacing

    let timerStringLengthsSum = 0
    for (const timerStringLength of timerStringLengths)
      timerStringLengthsSum += timerStringLength

    for (let i = 0; i < timersModel.count; ++i)
      timersModel.setProperty(i, "width_ratio", timerStringLengths[i] / timerStringLengthsSum)

    // If one wants to resize Plasmoid from width 104 to 105 then it fails...
    // ...because the closest next width is 120.
    // Magic value ensures that we always have more width instead of less.
    let magicValue = 16

    // hack to successfully resize floating containment after first resize
//     if (plasmoid.location == PlasmaCore.Types.Floating)
//       plasmoid.parent.width = newWidth + magicValue
    if (timersModel.count)
      widgetWidth = newWidth + magicValue
    else
      widgetWidth = main.height * placeholderIcon.sourceSize.width / placeholderIcon.sourceSize.height
  }

  TextMetrics {
    id: textMetrics
  }
}
