cmake_minimum_required(VERSION 3.16.0)

project("Workrave Applet" LANGUAGES CXX)

find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

find_package(Plasma)

plasma_install_package(src org.kde.workraveApplet)
