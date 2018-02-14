#!/usr/bin/env node
'use strict';

var fs = require('fs');
var path = require('path');

fs.ensureDirSync = function (dir) {
    if (!fs.existsSync(dir)) {
        dir.split(path.sep).reduce(function (currentPath, folder) {
            currentPath += folder + path.sep;
            if (!fs.existsSync(currentPath)) {
                fs.mkdirSync(currentPath);
            }
            return currentPath;
        }, '');
    }
};

var config = fs.readFileSync('config.xml').toString();
var name = getValue(config, 'name');

var IOS_DIR = 'platforms/ios';
var ANDROID_DIR = 'platforms/android';

var PLATFORM = {
    IOS: {
        dest: [
            IOS_DIR + '/' + name + '/Resources/GoogleService-Info.plist',
            IOS_DIR + '/' + name + '/Resources/Resources/GoogleService-Info.plist'
        ],
        src: [
            'GoogleService-Info.plist',
            IOS_DIR + '/www/GoogleService-Info.plist',
            'www/GoogleService-Info.plist'
        ]
    },
    ANDROID: {
        dest: [
            ANDROID_DIR + '/google-services.json'
        ],
        src: [
            'google-services.json',
            ANDROID_DIR + '/assets/www/google-services.json',
            'www/google-services.json'
        ],
        stringsXml: [
            ANDROID_DIR + '/res/values/strings.xml',
            ANDROID_DIR + '/app/src/main/res/values/strings.xml'
        ]
    }
};

// Copy key files to their platform specific folders
if (directoryExists(IOS_DIR)) {
    copyKey(PLATFORM.IOS);
}
if (directoryExists(ANDROID_DIR)) {
    copyKey(PLATFORM.ANDROID, updateStringsXml)
}

function updateStringsXml(contents) {
    var json = JSON.parse(contents);
    var strings
    var path
    try {
        if (fileExists(PLATFORM.ANDROID.stringsXml[0])) {
            path = PLATFORM.ANDROID.stringsXml[0]
            strings = fs.readFileSync(PLATFORM.ANDROID.stringsXml[0]).toString();
        } else if (fileExists(PLATFORM.ANDROID.stringsXml[1])) {
            path = PLATFORM.ANDROID.stringsXml[1]
            strings = fs.readFileSync(PLATFORM.ANDROID.stringsXml[1]).toString()
        } else {
            throw new Error
        }

    } catch (e) {
        console.log('error in project, file not found')
    }

    const regexApp = new RegExp('<string name="google_app_id">([^\@<]+?)<\/string>', 'i')
    const regexApi = new RegExp('<string name="google_api_key">([^\@<]+?)<\/string>', 'i')

    // strip non-default value
    if (strings.match(regexApp)) {
        strings = strings.replace(regexApp, '');
    }

    // strip non-default value
    if (strings.match(regexApi)) {
        strings = strings.replace(regexApi, '');
    }

    // strip empty lines
    strings = strings.replace(new RegExp('(\r\n|\n|\r)[ \t]*(\r\n|\n|\r)', 'gm'), '$1');

    // replace the default value
    strings = strings.replace(new RegExp('<resources>', 'i'), '<resources> \n \t<string name="google_app_id">' + json.client[0].client_info.mobilesdk_app_id + '</string>');

    // replace the default value
    strings = strings.replace(new RegExp('<resources>', 'i'), '<resources> \n \t<string name="google_api_key">' + json.client[0].api_key[0].current_key + '</string>');

    fs.writeFileSync(path, strings);
}

function copyKey(platform, callback) {
    for (var i = 0; i < platform.src.length; i++) {
        var file = platform.src[i];
        if (fileExists(file)) {
            try {
                var contents = fs.readFileSync(file).toString();

                try {
                    platform.dest.forEach(function (destinationPath) {
                        var folder = destinationPath.substring(0, destinationPath.lastIndexOf('/'));
                        fs.ensureDirSync(folder);
                        fs.writeFileSync(destinationPath, contents);
                    });
                } catch (e) {
                    // skip
                }

                callback && callback(contents);
            } catch (err) {
                console.log(err)
            }

            break;
        }
    }
}

function getValue(config, name) {
    var value = config.match(new RegExp('<' + name + '>(.*?)</' + name + '>', 'i'));
    if (value && value[1]) {
        return value[1]
    } else {
        return null
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