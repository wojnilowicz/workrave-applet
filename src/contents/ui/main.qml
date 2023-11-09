/*
    SPDX-FileCopyrightText: 2020-2022 Łukasz Wojniłowicz <lukasz.wojnilowicz@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
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

  property var largeIconFileNamesFromTimerNames : {
    "microbreak" : "../images/timer-micro-break-large.png",
    "restbreak" : "../images/timer-rest-break-large.png",
    "dailylimit" : "../images/timer-daily-large.png"
  }

  property int periodicalSwitchInterval: plasmoid.configuration.periodicalSwitchInterval
  property int updateInterval: plasmoid.configuration.updateInterval
  onPeriodicalSwitchIntervalChanged: updatePlasmoidAfterConfiguration()
  onUpdateIntervalChanged: updatePlasmoidAfterConfiguration()

  property int switchIntervalInMilliseconds: plasmoid.configuration.periodicalSwitchInterval * 1000
  property int updateIntervalInMilliseconds: plasmoid.configuration.updateInterval * 1000

  property bool microTimerEnabled: plasmoid.configuration.microTimer
  property bool restTimerEnabled: plasmoid.configuration.restTimer
  property bool dailyTimerEnabled: plasmoid.configuration.dailyTimer
  onMicroTimerEnabledChanged: updatePlasmoidAfterConfiguration()
  onRestTimerEnabledChanged: updatePlasmoidAfterConfiguration()
  onDailyTimerEnabledChanged: updatePlasmoidAfterConfiguration()

  property int timersOrientationMode: plasmoid.configuration.timersOrientation
  property bool singleTimerModeEnabled: plasmoid.configuration.singleTimerMode
  property bool periodicalSwitchEnabled: plasmoid.configuration.periodicalSwitch
  property bool conditionalSwitchEnabled: plasmoid.configuration.conditionalSwitch
  property bool timeDifferenceSwitchEnabled: plasmoid.configuration.timeDifferenceSwitch
  property bool idleTimeSwitchEnabled: plasmoid.configuration.idleTimeSwitch
  property bool nonIdleTimeSwitchEnabled: plasmoid.configuration.nonIdleTimeSwitch
  onTimersOrientationModeChanged: updatePlasmoidAfterConfiguration()
  onSingleTimerModeEnabledChanged: updatePlasmoidAfterConfiguration()
  onPeriodicalSwitchEnabledChanged: updatePlasmoidAfterConfiguration()
  onConditionalSwitchEnabledChanged: updatePlasmoidAfterConfiguration()
  onTimeDifferenceSwitchEnabledChanged: updatePlasmoidAfterConfiguration()

  property bool detectWorkraveConfigurationChanges: plasmoid.configuration.detectWorkraveConfigurationChanges
  onDetectWorkraveConfigurationChanges: updatePlasmoidAfterConfiguration()

  property bool useCustomFont: plasmoid.configuration.useCustomFont
  property var customFont: plasmoid.configuration.customFont
  onUseCustomFontChanged: updatePlasmoidAfterConfiguration()
  onCustomFontChanged: updatePlasmoidAfterConfiguration()

  property bool timersExtraWidth: plasmoid.configuration.timersExtraWidth
  property bool timersExtraHeight: plasmoid.configuration.timersExtraHeight
  property bool timersSpacing: plasmoid.configuration.timersSpacing
  onTimersExtraWidthChanged: updatePlasmoidAfterConfiguration()
  onTimersExtraHeightChanged: updatePlasmoidAfterConfiguration()
  onTimersSpacingChanged: updatePlasmoidAfterConfiguration()

  property bool isKF5_5_70_0: false

  property bool isWorkraveInstalled: false
  property int widgetWidth : 0
  property int widgetHeight : 0
  property int widgetContentWidth : 0
  property int widgetContentHeight : 0

  Layout.minimumWidth: widgetWidth
  Layout.minimumHeight: widgetHeight

  property bool verticalOrientation: {
    switch (plasmoid.configuration.timersOrientation) {
    case 1: // horizontal
      return false
    case 2: // vertical
      return true
    default: // auto
      let isVertical = false

      switch (plasmoid.formFactor) {
      case PlasmaCore.Types.Vertical:
        return true
      default:
        switch (plasmoid.location) {
        case PlasmaCore.Types.LeftEdge:
        case PlasmaCore.Types.RightEdge:
          return true
        default:
          return false
        }
      }
    }
  }

  Connections {
    target: plasmoid
    onUserConfiguringChanged: {
      updatePlasmoidAfterConfiguration()
    }

    onLocationChanged: {
      updatePlasmoidAfterConfiguration()
    }

    onFormFactorChanged: {
      updatePlasmoidAfterConfiguration()
    }
  }

  function updatePlasmoidAfterConfiguration() {
    if (!isWorkraveInstalled)
      return

    if (!plasmoid.configuration.useCustomFont) {
      dynamicTextMetrics.font = PlasmaCore.Theme.defaultFont
      staticTextMetrics.font = PlasmaCore.Theme.defaultFont
    } else {
      dynamicTextMetrics.font = plasmoid.configuration.customFont
      staticTextMetrics.font = plasmoid.configuration.customFont
    }

    workraveConfigDBus.interval = plasmoid.configuration.detectWorkraveConfigurationChanges ? updateIntervalInMilliseconds : 0
    workraveDataDBus.interval = updateIntervalInMilliseconds

    reloadAppletTimers()
    action_adjustSize()

    periodicalSwitchTimerController()
  }

  function periodicalSwitchTimerController () {
    let areAtLeastTwoTimersPresent = timersModel.count > 1 ? true : false
    let isAnyTimerOverdue = false
    for (let i = 0; i < timersModel.count; ++i) {
      let timer = timersModel.get(i)
      if (timer.elapsed >= timer.limit) {
        isAnyTimerOverdue = true
        break
      }
    }

    if (areAtLeastTwoTimersPresent &&
        plasmoid.configuration.singleTimerMode &&
        plasmoid.configuration.periodicalSwitch &&
        // if time difference switch is disabled...
        (!(plasmoid.configuration.conditionalSwitch && plasmoid.configuration.timeDifferenceSwitch) ||
        // or it's enabled but no timer is overdue, so conditional switching musn't take control
         !isAnyTimerOverdue))
      periodicalSwitchTimer.running = true
    else
      periodicalSwitchTimer.running = false
  }

  Timer {
    id: periodicalSwitchTimer
    interval: switchIntervalInMilliseconds
    repeat: true
    running: false
    onTriggered: {
      listView.incrementCurrentIndex()
      listView.switchWithAnimation(listView.currentIndex, ListView.Contain)
    }
  }

  property int indexToSwitchWithDelay: -1 // timer to switch to with some delay
  Timer {
    id: switchTimerWithDelay
    interval: 0
    repeat: false
    running: false
    onTriggered: {
      listView.switchWithAnimation(indexToSwitchWithDelay, ListView.Contain)
    }
  }

  property int previousVisibleIndex: -1 // timer that was displayed before triggering a condition
  Timer {
    id: conditionalSwitchTimer
    interval: updateIntervalInMilliseconds
    repeat: true
    running: plasmoid.configuration.conditionalSwitch
    onTriggered: {
      let resetTimeForIndexDuringIdleTime = 0
      let resetTimeForIndexDuringNonIdleTime = 0
      let indexDuringIdleTime = -1
      let overdueTimeForIndexDuringIdleTime = 0
      let overdueTimeForIndexDuringNonIdleTime = 0
      let indexDuringNonIdleTime = -1
      for (let i = 0; i < timersModel.count; ++i) {
        let timer = timersModel.get(i)

        let overdueTime = timer.limit - timer.elapsed

        if (!timer.idle) {
          if (plasmoid.configuration.timeDifferenceSwitch &&
            overdueTime < plasmoid.configuration.timeDifferenceSwitchDifference &&
            (overdueTime < overdueTimeForIndexDuringNonIdleTime ||
            indexDuringNonIdleTime == -1)) {
            resetTimeForIndexDuringNonIdleTime = timer.auto_reset
            overdueTimeForIndexDuringNonIdleTime = overdueTime
            indexDuringNonIdleTime = i
          } else if (plasmoid.configuration.nonIdleTimeSwitch) {
            if (indexDuringNonIdleTime == -1 ||
                // pick a timer if it's overdue and the current one isn't
                (overdueTime <= 0 && overdueTimeForIndexDuringNonIdleTime > 0) ||
                /* pick a timer if the current one is also overdue
                   but it'll take less time to reset */
                (overdueTime <= 0 && overdueTimeForIndexDuringNonIdleTime <= 0 &&
                timer.auto_reset > resetTimeForIndexDuringNonIdleTime) ||
                // pick a timer that satisfies time difference
                (plasmoid.configuration.timeDifferenceSwitch &&
                overdueTime < plasmoid.configuration.timeDifferenceSwitchDifference &&
                overdueTime < overdueTimeForIndexDuringNonIdleTime) ||
                // pick the most overdue timer
                overdueTime < overdueTimeForIndexDuringNonIdleTime) {
              resetTimeForIndexDuringNonIdleTime = timer.auto_reset
              overdueTimeForIndexDuringNonIdleTime = overdueTime
              indexDuringNonIdleTime = i
            }
          }
        } else if (plasmoid.configuration.idleTimeSwitch) {
          // exclude fully reset timers
          if (timer.elapsed !== 0) {
            // pick any timer in order to have something for a comparison
            if (indexDuringIdleTime == -1 ||
                // pick a timer if it's overdue and the current one isn't
                (overdueTimeForIndexDuringIdleTime > 0 && overdueTime <= 0) ||
                /* pick a timer if the current one is also overdue
                   but it'll reset sooner */
                (overdueTimeForIndexDuringIdleTime <= 0 && overdueTime <= 0 &&
                 resetTimeForIndexDuringIdleTime <= timer.auto_reset) ||
                 /* pick a timer that'll be overdue sooner than current one
                    when fully reset */
                 resetTimeForIndexDuringIdleTime >= overdueTime ||
                 // pick a timer if it'll reset sooner
                 resetTimeForIndexDuringIdleTime >= timer.auto_reset) {
              resetTimeForIndexDuringIdleTime = timer.auto_reset
              overdueTimeForIndexDuringIdleTime = overdueTime
              indexDuringIdleTime = i
            }
          }
        }
      }

      if (indexDuringIdleTime != -1) {
        if (listView.currentVisibleIndex() !== indexDuringIdleTime) {
          listView.switchWithAnimation(indexDuringIdleTime, ListView.Contain)
          indexToSwitchWithDelay = -1
        }
      } else if (indexDuringNonIdleTime != -1) {
        periodicalSwitchTimer.running = false
        if (previousVisibleIndex == -1)
          previousVisibleIndex = listView.currentIndex

        if (listView.currentVisibleIndex() !== indexDuringNonIdleTime)  {
          // timer with the least remaining offset has been already switched to but...
          // the user switched it manually to some other timer for a while so...
          // switch to it back after 5000 milliseconds
          if (indexToSwitchWithDelay == indexDuringNonIdleTime) {
            switchTimerWithDelay.interval = 5000
          } else {
            switchTimerWithDelay.interval = 0
            indexToSwitchWithDelay = indexDuringNonIdleTime
          }

          switchTimerWithDelay.running = true
        } else {
          switchTimerWithDelay.running = false
        }
        // switch to a timer that was displayed before triggering a condition
      } else if (previousVisibleIndex !== -1) {
        listView.switchWithAnimation(previousVisibleIndex, ListView.Contain)
        previousVisibleIndex = -1
        periodicalSwitchTimerController()
      }

    }
  }

  Component {
    id: timerComponent
    RowLayout {
      id: timerComponentBackground
      spacing: 0
      height: {
        let referenceHeight = plasmoid.configuration.singleTimerMode ? listView.contentHeight : listView.height
        if (verticalOrientation)
          return (referenceHeight - (listView.spacing * (listView.count - 1))) * model.item_height_ratio
        return referenceHeight
      }
      width: {
        let referenceWidth = plasmoid.configuration.singleTimerMode ? listView.contentWidth : listView.width
        if (verticalOrientation)
          return referenceWidth
        return (referenceWidth - (listView.spacing * (listView.count - 1))) * model.item_width_ratio
      }

      Image {
        id: timerComponentIcon
        fillMode: Image.PreserveAspectCrop
        Layout.preferredWidth: Math.min(parent.width * model.icon_width_ratio, parent.height) * plasmoid.configuration.iconHeightPercentage / 100
        Layout.preferredHeight: Math.min(parent.width * model.icon_width_ratio, parent.height) * plasmoid.configuration.iconHeightPercentage / 100
        source: largeIconFileNamesFromTimerNames[model.id]
        visible: plasmoid.configuration.iconEnabled
      }

      Rectangle {
        id : timerComponentData
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.maximumHeight: {
          if (plasmoid.configuration.iconEnabled)
            return Math.min(parent.width * model.icon_width_ratio, parent.height)
          return -1
        }

        MouseArea {
          anchors.left: parent.left
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          width: parent.width / 2
          onClicked: listView.decrementCurrentIndex()
        }

        MouseArea {
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          width: parent.width / 2
          onClicked: listView.incrementCurrentIndex()
        }

        color: "transparent"

        Rectangle {
          id : progressBarBackground
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          height: parent.height * plasmoid.configuration.progressBarHeightPercentage / 100
          color : {
            if (model.elapsed >= model.limit) {
              let currentLabelWidth = secondsLabel.text.length
              if (currentLabelWidth < model.previous_label_width) {
                model.previous_label_width = currentLabelWidth
                action_adjustSize()
              }
              return plasmoid.configuration.progressBarOverdueBackground
            }
            return plasmoid.configuration.progressBarNormalBackground
          }
          visible: plasmoid.configuration.progressBarEnabled

          Rectangle {
            id : elapsedTimeProgress
            height : parent.height
            width : model.elapsed >= model.limit ? 0 : parent.width * model.elapsed / model.limit
            color :  plasmoid.configuration.progressBarNormalForeground
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
          }

          Rectangle {
            id : restProgress
            height : parent.height
            anchors.left: restInElapsedTimeProgress.right
            width : {
              if (model.idle >= model.auto_reset && model.auto_reset) {
                let currentLabelWidth = secondsLabel.text.length
                if (currentLabelWidth < model.previous_label_width) {
                  model.previous_label_width = currentLabelWidth
                  action_adjustSize()
                }
                return parent.width
              }
              return (parent.width * model.idle / model.auto_reset) - restInElapsedTimeProgress.width
            }
            color : plasmoid.configuration.progressBarRestingForeground
          }
        }

        Label {
          id: secondsLabel
          color: plasmoid.configuration.fontColor
          anchors.centerIn: parent
          font: {
            let fontHeightFromBarHeight = Math.floor(timerComponent.height * model.font_height_ratio)
            let fontHeightFromBarWidth = Math.floor(timerComponent.width * model.font_width_ratio)
            // calculated font size can be zero due to the progress bar having zero size at the begining
            let fontHeightFromBar = Math.min(fontHeightFromBarHeight, fontHeightFromBarWidth)
            if (!fontHeightFromBar)
              fontHeightFromBar = staticTextMetrics.font.pointSize
            dynamicTextMetrics.font.pointSize = fontHeightFromBar
            return dynamicTextMetrics.font
          }
          text: formatSeconds(model.limit - model.elapsed)
          visible: plasmoid.configuration.labelEnabled
        }
      }
    }
  }

  NumberAnimation {
    id: switchingAnimation
    target: listView
    property: !verticalOrientation ? "contentX" : "contentY"
    duration: {
      let defaultAnimationDuration = 1000
      if (switchIntervalInMilliseconds === 0)
        return defaultAnimationDuration
      Math.min (switchIntervalInMilliseconds * 0.5, defaultAnimationDuration)
    }
  }

  ListView {
    id: listView
    anchors.verticalCenter: parent.verticalCenter
    clip: plasmoid.configuration.singleTimerMode ? true : false
    snapMode: ListView.SnapToItem
    keyNavigationWraps: true
    width: parent.width
    height: Math.min(parent.height, parent.width * widgetHeight/widgetWidth)
    contentWidth: this.width * (widgetContentWidth / widgetWidth)
    contentHeight: this.height * (widgetContentHeight / widgetHeight)
    spacing: plasmoid.configuration.timersSpacing
    orientation: verticalOrientation ? ListView.Vertical : ListView.Horizontal
    model: timersModel
    delegate: timerComponent

    function currentVisibleIndex() {
      return indexAt(contentX, contentY)
    }

    function switchWithAnimation(index) {
      switchingAnimation.running = false;

      let sourcePosition = !verticalOrientation ? contentX : contentY;
      let destinationPosition;

      currentIndex = index
      positionViewAtIndex(index, ListView.Contain);
      destinationPosition = !verticalOrientation ? contentX : contentY;

      switchingAnimation.from = sourcePosition;
      switchingAnimation.to = destinationPosition;
      switchingAnimation.running = true;
    }
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
    fillMode: Image.PreserveAspectFit
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
        updatePlasmoidAfterConfiguration()
      } else {
        isWorkraveInstalled = false
        interval = 1000
        workraveDataDBus.interval = 0
        workraveConfigDBus.interval = 0

        placeholderIcon.visible = true
        placeholderTooltip.visible = true
        let mainText = ""
        let subText = ""
        if (data.stderr.includes("qdbus")) {
          mainText = i18n("Issue with qdbus")
          subText = i18n("Please make sure that the command `qdbus org.workrave.Workrave` works without issues in your terminal.")
        } else {
          mainText = i18n("Workrave not installed")
          subText = i18n("Please install Workrave.")
        }

        placeholderTooltip.mainText = mainText
        placeholderTooltip.subText = subText

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
    this.item_width_ratio = 0
    this.item_height_ratio = 0
    this.bar_width_ratio = 0
    this.icon_width_ratio = 0
    this.font_width_ratio = 0
    this.font_height_ratio = 0
    this.previous_label_width = 0
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

  function formatSeconds(inputSeconds) {
    let seconds = Math.abs(inputSeconds) % 60
    let minutes = Math.floor(Math.abs(inputSeconds) / 60)
    let hours = Math.floor(minutes / 60)
    minutes %= 60
    let formattedString = ""
    if (plasmoid.configuration.showOnlyTheMostSignificantTimerPart) {
      if (hours)
        formattedString += hours + (plasmoid.configuration.showTimeUnits ? "h" : "")
      else if (minutes)
        formattedString += minutes + (plasmoid.configuration.showTimeUnits ? "m" : "")
      else if (seconds)
        formattedString += seconds + (plasmoid.configuration.showTimeUnits ? "s" : "")
    } else {
      if (hours)
        formattedString += hours + ":"
      if (hours || minutes)
        formattedString += ("00"+minutes).slice(-2) + ":"
      if (hours || minutes || seconds)
        formattedString += ("00"+seconds).slice(-2)
      formattedString = formattedString.replace(/^[0:]+/, "")
    }
    if (inputSeconds < 0 && plasmoid.configuration.showMinusSign)
      formattedString = "-" + formattedString
    else if (!inputSeconds)
      formattedString = "0"

    return formattedString
  }

  function minimumPlasmoidSize() {
    switch (plasmoid.location) {
      case PlasmaCore.Types.Floating:
        let iconSizes = PlasmaCore.Units.iconSizes.small
        if (PlasmaCore.Units.devicePixelRatio == 1.25) {
          // this ensures that the mimimum size on 125 % scaling is 52x52 as tested during runtime
          iconSizes *= PlasmaCore.Units.devicePixelRatio
          console.warn("Working around minimum applet size calculation on 125% display scaling")
        }

        // got topPadding and bottomPadding from https://invent.kde.org/plasma/plasma-workspace/-/raw/master/components/containmentlayoutmanager/qml/BasicAppletContainer.qml
        // infered 4 * PlasmaCore.Units.iconSizes.small from https://invent.kde.org/plasma/plasma-desktop/-/blob/master/containments/desktop/package/contents/ui/FolderView.qml
        let minimumSize = 4 * iconSizes - Plasmoid.parent.topPadding - Plasmoid.parent.bottomPadding
        return Qt.size(minimumSize, minimumSize)
      case PlasmaCore.Types.TopEdge:
      case PlasmaCore.Types.BottomEdge:
        return Qt.size(0, Plasmoid.parent.height)
      case PlasmaCore.Types.LeftEdge:
      case PlasmaCore.Types.RightEdge:
        return Qt.size(Plasmoid.parent.width, 0)
      default:
        return Qt.size(0, 0)
    }
  }

  function widestDigit() {
    let digitIndex  = 0
    let digitWidth = -1
    for (let i = 0; i < 10; ++i) {
      staticTextMetrics.text = i
      if (staticTextMetrics.width > digitWidth) {
        digitWidth = staticTextMetrics.width
        digitIndex = i
      }
    }
    return digitIndex
  }

  function widestTimeUnit() {
    let returnedTimeUnit  = 0
    let timeUnitWidth = -1
    let timeUnits = ["h", "m", "s"]
    for (let i = 0; i < timeUnits.length; ++i) {
      staticTextMetrics.text = timeUnits[i]
      if (staticTextMetrics.width > timeUnitWidth) {
        timeUnitWidth = staticTextMetrics.width
        returnedTimeUnit = timeUnits[i]
      }
    }
    return returnedTimeUnit
  }

  function action_adjustSize() {
    if (!timersModel.count) {
      widgetWidth = main.height * placeholderIcon.sourceSize.width / placeholderIcon.sourceSize.height
      return
    }

    let minPlasmoidSize = minimumPlasmoidSize()

    let timerStringHeights = []
    let timerStringWidths = []
    let maximumTimerStringHeight = 0
    let maximumTimerStringWidth = 0
    for (let i = 0; i < timersModel.count; ++i) {
      let timerValueToEstimateWidth = 0
      if (plasmoid.configuration.showOnlyTheMostSignificantTimerPart) {
        timerValueToEstimateWidth = 59
      } else {
        timerValueToEstimateWidth = timersModel.get(i).limit
        if (timersModel.get(i).elapsed - timersModel.get(i).limit > timersModel.get(i).limit)
          timerValueToEstimateWidth = timersModel.get(i).elapsed
      }
      let timerString = formatSeconds(-timerValueToEstimateWidth)
      timerString = timerString.replace(/[hms]/g, widestTimeUnit)
      timerString = timerString.replace(/\d/g, widestDigit)

      staticTextMetrics.text = timerString
      let timerStringPixelWidth = staticTextMetrics.tightBoundingRect.width
      let timerStringPixelHeight = staticTextMetrics.tightBoundingRect.height

      timerStringWidths.push(timerStringPixelWidth)
      timerStringHeights.push(timerStringPixelHeight)

      if (maximumTimerStringHeight < timerStringPixelHeight)
        maximumTimerStringHeight = timerStringPixelHeight

      if (maximumTimerStringWidth < timerStringPixelWidth)
        maximumTimerStringWidth = timerStringPixelWidth
    }

    let totalSpacingBetweenItems = (timersModel.count - 1) * plasmoid.configuration.timersSpacing

    let newMinimumWidth = 0
    let newMinimumHeight = 0
    let maximumItemWidth = 0
    let widthFromTexts = 0
    let widthFromIcon = 0
    let pixelsNotFittingSizeResolution = 0
    let extraPixelsToFitSizeResolution = 0
    let pixelsOverMinimumSize = 0

    if (verticalOrientation) {
      let itemsHeight = 0
      let maximumItemHeight = 0

      for (let i = 0; i < timerStringHeights.length; ++i) {
        let itemHeight = timerStringHeights[i] + plasmoid.configuration.timersExtraHeight
        if (maximumItemHeight < itemHeight)
          maximumItemHeight = itemHeight
      }

      if (plasmoid.configuration.singleTimerMode) {
        // in the case of a small font, the minimum plasmoid height can be greater than its required height thus
        maximumItemHeight = Math.max(maximumItemHeight, minPlasmoidSize.height)
        pixelsOverMinimumSize = maximumItemHeight - minPlasmoidSize.height
        // If one wants to resize Plasmoid from height 104 to 105 then it fails...
        // ...because the closest next height is 120.
        // This is to ensure that we're always resizing to a valid height.
        pixelsNotFittingSizeResolution = pixelsOverMinimumSize % PlasmaCore.Units.iconSizes.small
        extraPixelsToFitSizeResolution = !pixelsNotFittingSizeResolution ? 0 : PlasmaCore.Units.iconSizes.small - pixelsNotFittingSizeResolution
        maximumItemHeight += extraPixelsToFitSizeResolution
        // doesn't have to fit the resolution because it's dedicated for the content height
        itemsHeight = maximumItemHeight * timerStringHeights.length
      } else {
        // if each item height is not equal...
        // ...and plasmoid height is less than the aspect ratio...
        // ...then the bar lenghts of the timers aren't equal in length showing offsets between them
        itemsHeight = maximumItemHeight * timerStringHeights.length
        pixelsOverMinimumSize = (itemsHeight + totalSpacingBetweenItems) - minPlasmoidSize.height

        if (pixelsOverMinimumSize < 0) {
          maximumItemHeight += Math.floor(Math.abs(pixelsOverMinimumSize) / timerStringHeights.length)
          itemsHeight += timerStringHeights.length * Math.floor(Math.abs(pixelsOverMinimumSize) / timerStringHeights.length)
          // remaining pixels are added to spacing in order to not produce items with differing heights
          totalSpacingBetweenItems += pixelsOverMinimumSize % timerStringHeights.length
          pixelsOverMinimumSize = 0
        }

        pixelsNotFittingSizeResolution = pixelsOverMinimumSize % PlasmaCore.Units.iconSizes.small
        extraPixelsToFitSizeResolution = !pixelsNotFittingSizeResolution ? 0 : PlasmaCore.Units.iconSizes.small - pixelsNotFittingSizeResolution

        if (extraPixelsToFitSizeResolution > 0) {
          maximumItemHeight += Math.floor(extraPixelsToFitSizeResolution / timerStringHeights.length)
          itemsHeight += timerStringHeights.length * Math.floor(extraPixelsToFitSizeResolution / timerStringHeights.length)
          totalSpacingBetweenItems += extraPixelsToFitSizeResolution % timerStringHeights.length
          extraPixelsToFitSizeResolution = 0
        }
      }

      if (plasmoid.configuration.iconEnabled)
        widthFromIcon = itemsHeight / timerStringHeights.length

      let itemBarWidth = maximumTimerStringWidth + plasmoid.configuration.timersExtraWidth
      maximumItemWidth = widthFromIcon + itemBarWidth
      pixelsOverMinimumSize = maximumItemWidth -  minPlasmoidSize.width
      if (pixelsOverMinimumSize < 0) {
        maximumItemWidth -= pixelsOverMinimumSize
        itemBarWidth -= pixelsOverMinimumSize
        pixelsOverMinimumSize = 0
      }

      pixelsNotFittingSizeResolution = pixelsOverMinimumSize % PlasmaCore.Units.iconSizes.small
      extraPixelsToFitSizeResolution = !pixelsNotFittingSizeResolution ? 0 : PlasmaCore.Units.iconSizes.small - pixelsNotFittingSizeResolution

      maximumItemWidth += extraPixelsToFitSizeResolution
      itemBarWidth += extraPixelsToFitSizeResolution
      for (let i = 0; i < timersModel.count; ++i) {
        timersModel.setProperty(i, "item_width_ratio", 1)
        timersModel.setProperty(i, "item_height_ratio", maximumItemHeight / itemsHeight)
        timersModel.setProperty(i, "bar_width_ratio", itemBarWidth / maximumItemWidth)
        timersModel.setProperty(i, "icon_width_ratio", widthFromIcon / maximumItemWidth)
        timersModel.setProperty(i, "font_height_ratio", staticTextMetrics.font.pointSize / maximumItemHeight)
        timersModel.setProperty(i, "font_width_ratio", staticTextMetrics.font.pointSize / itemBarWidth)
      }

      newMinimumWidth = maximumItemWidth
      newMinimumHeight = totalSpacingBetweenItems + itemsHeight

      widgetContentWidth = newMinimumWidth
      widgetContentHeight = newMinimumHeight
      widgetWidth = newMinimumWidth

      if (plasmoid.configuration.singleTimerMode)
        widgetHeight = maximumItemHeight
      else
        widgetHeight = newMinimumHeight
    } else {
      newMinimumHeight = Math.max(minPlasmoidSize.height, maximumTimerStringHeight) + plasmoid.configuration.timersExtraHeight

      // will never be negative so no need to check that
      pixelsOverMinimumSize = newMinimumHeight - minPlasmoidSize.height
      pixelsNotFittingSizeResolution = pixelsOverMinimumSize % PlasmaCore.Units.iconSizes.small
      extraPixelsToFitSizeResolution = !pixelsNotFittingSizeResolution ? 0 : PlasmaCore.Units.iconSizes.small - pixelsNotFittingSizeResolution
      newMinimumHeight += extraPixelsToFitSizeResolution

      widthFromIcon = newMinimumHeight

      let itemsWidth = 0
      let itemWidths = []
      let itemBarWidths = []
      let itemIconWidths = []

      for (let i = 0; i < timersModel.count; ++i) {
        itemIconWidths.push(plasmoid.configuration.iconEnabled ? widthFromIcon : 0)
        itemBarWidths.push(timerStringWidths[i] + plasmoid.configuration.timersExtraWidth)
        itemWidths.push(itemIconWidths[i] + itemBarWidths[i])
        itemsWidth += itemWidths[i]
        if (maximumItemWidth < itemWidths[i])
          maximumItemWidth = itemWidths[i]
      }

      if (plasmoid.configuration.singleTimerMode) {
        maximumItemWidth = Math.max(maximumItemWidth, minPlasmoidSize.width)
        // will never be negative so no need to check that
        pixelsOverMinimumSize = maximumItemWidth - minPlasmoidSize.width

        pixelsNotFittingSizeResolution = pixelsOverMinimumSize % PlasmaCore.Units.iconSizes.small
        extraPixelsToFitSizeResolution = !pixelsNotFittingSizeResolution ? 0 : PlasmaCore.Units.iconSizes.small - pixelsNotFittingSizeResolution

        maximumItemWidth += extraPixelsToFitSizeResolution
        for (let i = 0; i < itemWidths.length; ++i) {
          itemBarWidths[i] += maximumItemWidth - itemWidths[i]
          itemWidths[i] = maximumItemWidth
        }
        itemsWidth = maximumItemWidth * itemWidths.length
      } else {
        pixelsOverMinimumSize = (itemsWidth + totalSpacingBetweenItems) - minPlasmoidSize.width

        while (pixelsOverMinimumSize < 0) {
          for (let i = 0; i < timerStringWidths.length; ++i) {
            itemWidths[i] += 1
            itemsWidth += 1
            pixelsOverMinimumSize += 1
            if (!pixelsOverMinimumSize)
              break
          }
        }

        pixelsNotFittingSizeResolution = pixelsOverMinimumSize % PlasmaCore.Units.iconSizes.small
        extraPixelsToFitSizeResolution = !pixelsNotFittingSizeResolution ? 0 : PlasmaCore.Units.iconSizes.small - pixelsNotFittingSizeResolution
        itemsWidth += extraPixelsToFitSizeResolution

        while(extraPixelsToFitSizeResolution >0) {
          for (let i = 0; i < itemWidths.length; ++i) {
            itemWidths[i] += 1
            itemBarWidths[i] += 1
            extraPixelsToFitSizeResolution -= 1
            if (!extraPixelsToFitSizeResolution)
              break
          }
        }
      }

      for (let i = 0; i < timersModel.count; ++i) {
        timersModel.setProperty(i, "item_width_ratio", itemWidths[i] / itemsWidth)
        timersModel.setProperty(i, "item_height_ratio", 1)
        timersModel.setProperty(i, "bar_width_ratio", itemBarWidths[i] / itemWidths[i])
        timersModel.setProperty(i, "icon_width_ratio", itemIconWidths[i] / itemWidths[i])
        timersModel.setProperty(i, "font_height_ratio", staticTextMetrics.font.pointSize / newMinimumHeight)
        timersModel.setProperty(i, "font_width_ratio", staticTextMetrics.font.pointSize / itemBarWidths[i])
      }
      newMinimumWidth = totalSpacingBetweenItems + itemsWidth
      if (plasmoid.configuration.singleTimerMode)
        widgetWidth = maximumItemWidth
      else
        widgetWidth = newMinimumWidth

      widgetContentWidth = newMinimumWidth
      widgetContentHeight = newMinimumHeight
      widgetHeight = newMinimumHeight
    }
  }

  // for changing font size during execution
  TextMetrics {
    id: dynamicTextMetrics
  }

  // for calculating applet size during calculation
  TextMetrics {
    id: staticTextMetrics
  }
}
