const helpers = require('./helpers');

const shouldInstallIonicDependencies = function () {
    const fs = require('fs');
    const packageFilePath = `${process.cwd()}/../../../package.json`;
    if (!helpers.fileExists(packageFilePath)) {
        helpers.logWarning('package.json was not found.');
        helpers.logWarning('Ionic dependencies omission cannot be safelly skipped.');
        return true;
    }
    let packageDataString;
    try {
        packageDataString = fs.readFileSync(packageFilePath);
    } catch (e) {
        helpers.logWarning('package.json found is unreadable.', e);
        helpers.logWarning('Ionic dependencies omission cannot be safelly skipped.');
        return true;
    }
    let packageData;
    try {
        packageData = JSON.parse(packageDataString);
    } catch (e) {
        helpers.logWarning('package.json could not be parsed.', e);
        helpers.logWarning('Ionic dependencies omission cannot be safelly skipped.');
        return true;
    }
    return !!(
        packageData &&
        packageData.dependencies &&
        packageData.dependencies['@ionic-native/core']
    );
};

const installIonicDependencies = function () {
    const path = require('path');
    const destPath = process.argv[2];
    helpers
        .execute('npm', ['install', '--loglevel', 'error', '--no-progress'])
        .catch(function (e) {
            helpers.logError('Failed to auto install Ionic dependencies!', e);
            helpers.logError(
                `Please run \`cd node_modules/cordova-plugin-fcm-with-dependecy-updated/${destPath}; npm install\` manually`
            );
        })
        .then(function (output) {
            console.log(`Ionic dependencies installed for ${destPath}:`);
            console.log(output);
        });
};

if (shouldInstallIonicDependencies()) {
    installIonicDependencies();
} else {
    console.log('Ionic dependencies install skipped :)');
}
