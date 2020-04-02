#!/usr/bin/env node
'use strict';

var child_process = require('child_process');
var helpers = require('./helpers');
var fs = require('fs');

var IOS_PLATFORM_PATH = 'platforms/ios';
var PODFILE_PATH = 'platforms/ios/Podfile';
var PLUGIN_DEFINITION_PATH = 'plugins/cordova-plugin-fcm-with-dependecy-updated/plugin.xml';

function isSupportedByCocoapods(callback) {
    // Verifies if installed version of cocoapods supports the cdn repo
    // 1.7.2
    var major = '1';
    var minor = '7';
    var patch = '2';
    child_process.exec('pod --version', (err, stdout) => {
        if (err) {
            callback(false);
        }
        var currentVersion = stdout.replace(/[^\.\d]/, '').split('.');
        if (currentVersion[0] < major) {
            callback(false);
        }
        if (currentVersion[0] === major) {
            if (currentVersion[1] < minor) {
                callback(false);
            }
            if (currentVersion[1] === minor && currentVersion[2] < patch) {
                callback(false);
            }
        }
        callback(true);
    });
}

function isPluginFileAvailable() {
    if (helpers.fileExists(PLUGIN_DEFINITION_PATH)) {
        return true;
    } else {
        helpers.logWarning('Plugin.xml not found as ' + PLUGIN_DEFINITION_PATH);
        return false;
    }
}

function isIOSPlatformInstalled() {
    return helpers.directoryExists(IOS_PLATFORM_PATH);
}

function replaceGithubHostedByCDN() {
    if (isIOSPlatformInstalled()) {
        replaceContentInFile(
            PODFILE_PATH,
            'Podfile',
            "source 'https://github.com/CocoaPods/Specs.git'",
            "source 'https://cdn.cocoapods.org/'"
        );
    }
    replaceContentInFile(
        PLUGIN_DEFINITION_PATH,
        'Plugin.xml',
        '<source url="https://github.com/CocoaPods/Specs.git"/>',
        '<source url="https://cdn.cocoapods.org"/>'
    );
}

function replaceContentInFile(filePath, fileName, from, to) {
    var currentContent;
    try {
        currentContent = fs.readFileSync(filePath).toString();
    } catch (e) {
        helpers.logWarning('Failed to read ' + fileName);
        return;
    }
    if (currentContent === '') {
        helpers.logWarning(fileName + ' found is completely empty');
        return;
    }
    var newContent = currentContent.replace(from, to);
    if (newContent === currentContent) {
        return;
    }
    try {
        fs.writeFileSync(filePath, newContent);
    } catch (e) {
        helpers.logWarning('Failed to write enhanced ' + fileName);
        return;
    }
}

function main() {
    isSupportedByCocoapods(function (isVersionSupported) {
        if (!isVersionSupported) {
            return;
        }
        if (!isPluginFileAvailable()) {
            return;
        }
        replaceGithubHostedByCDN();
    });
}

main();
