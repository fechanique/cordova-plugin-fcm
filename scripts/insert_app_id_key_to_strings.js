#!/usr/bin/env node
'use strict';

var fs = require('fs');
var helpers = require('./helpers');
var configurations = require(`./configuration`);

var PLATFORM = configurations.PLATFORM;

function updateAndroidStringsXml() {
    var googleServiceContent = helpers.getGoogleServiceContent(PLATFORM.ANDROID);
    if (!googleServiceContent) {
        return;
    }
    var stringXmlPath = helpers.findExistingFilePath(PLATFORM.ANDROID.stringsXmls);
    if (!stringXmlPath) {
        helpers.logWarning('Android-specific strings.xml file not found!');
        return;
    }

    // Current string values
    var strings = fs.readFileSync(stringXmlPath).toString();

    // Read Google Service app id and key
    var googleServiceClient;
    try {
        googleServiceClient = JSON.parse(googleServiceContent).client[0];
    } catch (error) {
        helpers.logError('google-services.json found was not a valid JSON', error);
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
            helpers.logError('string.xml unrecognizable!', strings);
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

if (directoryExists(PLATFORM.ANDROID.dir)) {
    updateAndroidStringsXml();
}
