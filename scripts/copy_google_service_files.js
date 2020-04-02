#!/usr/bin/env node
'use strict';

var fs = require('fs');
var helpers = require('./helpers');
var configurations = require(`./configuration`);

var PLATFORM = configurations.PLATFORM;

function copyGoogleServiceFile(platform) {
    var googleServiceContent = helpers.getGoogleServiceContent(platform);
    if (!googleServiceContent) {
        return;
    }
    platform.googleServiceDestinations.forEach(function (destinationPath) {
        try {
            ensureFileDirExistance(destinationPath);
            fs.writeFileSync(destinationPath, googleServiceContent);
        } catch (error) {
            helpers.logError('Error on trying to write ' + destinationPath, error);
            return;
        }
    });
}

function ensureFileDirExistance(filePath) {
    var dirPath = filePath.substring(0, filePath.lastIndexOf('/'));
    ensureDirExistance(dirPath);
}

function ensureDirExistance(dirPath) {
    if (!fs.existsSync(dirPath)) {
        dirPath.split('/').reduce(function (currentPath, folder) {
            currentPath += folder + '/';
            if (!fs.existsSync(currentPath)) {
                fs.mkdirSync(currentPath);
            }
            return currentPath;
        }, '');
    }
}

if (helpers.directoryExists(PLATFORM.ANDROID.dir)) {
    copyGoogleServiceFile(PLATFORM.ANDROID);
}
if (helpers.directoryExists(PLATFORM.IOS.dir)) {
    copyGoogleServiceFile(PLATFORM.IOS);
}
