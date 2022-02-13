Workrave Applet
---------------
KDE Plasma 5 applet for displaying [Workrave](https://workrave.org/) timers.

![](images/demo.png)

## HOW TO GET

### 1. Using [kpackagetool5](https://techbase.kde.org/Development/Tutorials/Plasma5/QML2/GettingStarted#Kpackagetool5)
#### Installation
```sh
$ git clone --depth=1 https://github.com/wojnilowicz/workrave-applet
$ cd workrave-applet
$ kpackagetool5 -t Plasma/Applet --install src
```

#### Uninstallation
```sh
$ cd workrave-applet
$ kpackagetool5 -t Plasma/Applet --remove src
```

### 2. From [KDE Store](https://store.kde.org/)
Follow the [Installing Plasmoids](https://userbase.kde.org/Plasma/Installing_Plasmoids) guide.

## LICENSE
This program is free software; you can redistribute it and/or
modify it under the terms of the [GNU General Public License](https://www.gnu.org/licenses/gpl-2.0.html)
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

Files named "workrave-sheep.svg", "timer-daily-large.png", "timer-micro-break-large.png", "timer-rest-break-large.png" are a part of [Workrave](https://github.com/rcaelers/workrave) application and must be licensed in accordance with that application's license.
