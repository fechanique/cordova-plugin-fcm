#!/usr/bin/env node
'use strict';

var fs = require('fs');

var config = fs.readFileSync('config.xml').toString();
var name = getValue(config, 'name');

var IOS_DIR = 'platforms/ios';
var ANDROID_DIR = 'platforms/android';

var PLATFORM = {
    IOS: {
        googleServiceDestinations: [
            IOS_DIR + '/' + name + '/Resources/GoogleService-Info.plist',
            IOS_DIR + '/' + name + '/Resources/Resources/GoogleService-Info.plist'
        ],
        googleServiceSources: [
            'GoogleService-Info.plist',
            IOS_DIR + '/www/GoogleService-Info.plist',
            'www/GoogleService-Info.plist'
        ]
    },
    ANDROID: {
        googleServiceDestinations: [
            ANDROID_DIR + '/google-services.json',
            ANDROID_DIR + '/app/google-services.json'
        ],
        googleServiceSources: [
            ANDROID_DIR + '/google-services.json',
            ANDROID_DIR + '/assets/www/google-services.json',
            'www/google-services.json',
            'google-services.json'
        ],
        stringsXmls: [
            ANDROID_DIR + '/res/values/strings.xml',
            ANDROID_DIR + '/app/src/main/res/values/strings.xml'
        ]
    }
};

if (directoryExists(IOS_DIR)) {
    copyGoogleServiceFile(PLATFORM.IOS);
}
if (directoryExists(ANDROID_DIR)) {
    copyGoogleServiceFile(PLATFORM.ANDROID, updateAndroidStringsXml);
}

function updateAndroidStringsXml(contents) {
    var stringXmlPath = findExistingFilePath(PLATFORM.ANDROID.stringsXmls);
    if (!stringXmlPath) {
        logWarning('Android-specific strings.xml file not found!');
        return;
    }

    // Current string values
    var strings = fs.readFileSync(stringXmlPath).toString();

    // Read Google Service app id and key
    var googleServiceClient;
    try {
        googleServiceClient = JSON.parse(contents).client[0];
    } catch (error) {
        logError('google-services.json found was not a valid JSON', error);
    }

    var entries = [
        {
            name: 'google_app_id',
            value: googleServiceClient.client_info.mobilesdk_app_id
        },
        {
            name: 'google_api_key',
            value: googleServiceClient.api_key[0].current_key
        }
    ];

    entries.forEach(function (entry) {
        // If found, remove old entry
        strings = strings.replace(
            new RegExp('<string name="' + entry.name + '">([^<]+?)</string>', 'i'),
            '\n'
        );

        var newEntryStartPosition = strings.indexOf('</resources>');
        if (newEntryStartPosition === -1) {
            logError('string.xml unrecognizable!', strings);
            return;
        }

        strings =
            strings.substr(0, newEntryStartPosition) +
            '    <string name="' +
            entry.name +
            '">' +
            entry.value +
            '</string>\n' +
            strings.substr(newEntryStartPosition);
    });

    // strip empty lines
    strings = strings.replace(new RegExp('(\r\n|\n|\r)[ \t]*(\r\n|\n|\r)', 'gm'), '');

    fs.writeFileSync(stringXmlPath, strings);
}

function copyGoogleServiceFile(platform, callback) {
    var googleServiceSourcePath = findExistingFilePath(platform.googleServiceSources);
    if (!googleServiceSourcePath) {
        if (platform === PLATFORM.ANDROID) {
            logWarning('Android-specific google-services.json file not found!');
        } else {
            logWarning('iOS-specific GoogleService-Info.plist file not found!');
        }
        return;
    }

    var contents;
    try {
        contents = fs.readFileSync(googleServiceSourcePath).toString();
    } catch (error) {
        logError('Error on trying to read ' + googleServiceSourcePath, error);
        return;
    }
    platform.googleServiceDestinations.forEach(function (destinationPath) {
        try {
            ensureFileDirExistance(destinationPath);
            fs.writeFileSync(destinationPath, contents);
        } catch (error) {
            logError('Error on trying to write ' + destinationPath, error);
            return;
        }
    });

    if (callback) {
        callback(contents);
    }
}

function findExistingFilePath(paths) {
    for (var i = paths.length - 1; i > -1; i--) {
        if (fileExists(paths[i])) {
            return paths[i];
        }
    }
}

function getValue(config, name) {
    var value = config.match(new RegExp('<' + name + '>(.*?)</' + name + '>', 'i'));
    if (value && value[1]) {
        return value[1];
    } else {
        return null;
    }
}

function fileExists(path) {
    try {
        return fs.statSync(path).isFile();
    } catch (e) {
        return false;
    }
}

function directoryExists(path) {
    try {
        return fs.statSync(path).isDirectory();
    } catch (e) {
        return false;
    }
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

function logError(message, obj) {
    if (obj) {
        console.error('\x1b[1m\x1b[31m%s\n%O\x1b[0m', message, obj);
    } else {
        console.error('\x1b[1m\x1b[31m%s\x1b[0m', message);
    }
}

function logWarning(message) {
    console.warn('\x1b[1m\x1b[33m%s\x1b[0m', message);
}
