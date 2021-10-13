'use strict';

var fs = require('fs');

exports.fileExists = function (path) {
    try {
        return fs.statSync(path).isFile();
    } catch (e) {
        return false;
    }
};

exports.directoryExists = function (path) {
    try {
        return fs.statSync(path).isDirectory();
    } catch (e) {
        return false;
    }
};

exports.findExistingFilePath = function (paths) {
    for (var i = paths.length - 1; i > -1; i--) {
        if (exports.fileExists(paths[i])) {
            return paths[i];
        }
    }
};

exports.logError = function (message, obj) {
    if (obj) {
        console.error('\x1b[1m\x1b[31m%s\n%O\x1b[0m', message, obj);
    } else {
        console.error('\x1b[1m\x1b[31m%s\x1b[0m', message);
    }
};

exports.logWarning = function (message) {
    console.warn('\x1b[1m\x1b[33m%s\x1b[0m', message);
};

exports.getValueFromXml = function (xmlFilePath, name, errorMessage) {
    var config = fs.readFileSync(xmlFilePath).toString();
    var value = config.match(new RegExp('<' + name + '[^>]*>(.*?)</' + name + '>', 'i'));
    if (value && value[1]) {
        return value[1];
    } else {
        exports.logWarning(errorMessage);
        return null;
    }
};

exports.getGoogleServiceContent = function (platform) {
    var googleServiceSourcePath = exports.findExistingFilePath(platform.googleServiceSources);
    if (!googleServiceSourcePath) {
        if (platform.label === 'android') {
            exports.logWarning('Android-specific google-services.json file not found!');
        } else {
            exports.logWarning('iOS-specific GoogleService-Info.plist file not found!');
        }
        return null;
    }

    try {
        return fs.readFileSync(googleServiceSourcePath).toString();
    } catch (error) {
        exports.logError('Error on trying to read ' + googleServiceSourcePath, error);
        return null;
    }
};

exports.execute = function (command, args) {
    return new Promise(function (resolve, reject) {
        try {
            const spawn = require('child_process').spawn;
            const child = spawn(command, args);
            const stdout = [];
            child.stdout.on('data', function (buffer) {
                const lines = buffer.toString().split('\n');
                for (const line of lines) {
                    if (line !== '') {
                        stdout.push(line);
                    }
                }
            });
            child.stdout.on('end', function () {
                resolve(stdout.join('\n'));
            });
        } catch (e) {
            reject(e);
        }
    });
};
