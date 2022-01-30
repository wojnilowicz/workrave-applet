cmake_minimum_required(VERSION 3.16.0)

project("Workrave Applet" LANGUAGES C)

find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} )

find_package(KF5 REQUIRED COMPONENTS Plasma)

plasma_install_package(src org.kde.workraveApplet)
