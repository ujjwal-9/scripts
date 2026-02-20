#!/bin/bash

echo "Logi Plugin Service uninstall script:"

# Delete LogiPluginService.app only if Loupedeck.app is NOT installed
if [ ! -d "/Applications/Loupedeck.app" ]; then
    # Kill any processes that are active
    kill -9 $(pgrep "LogiPluginService")

    #putting to sleep
    sleep 2

    echo "Removing LogiPluginService.app..."
    rm -rf "/Applications/Utilities/LogiPluginService.app"

    echo "Removing com.logi.pluginservice.launch.plist..."
    rm -f "$HOME/Library/LaunchAgents/com.logi.pluginservice.launch.plist"

else
    echo "Loupedeck.app is installed. LogiPluginService.app will not be removed."
fi%
