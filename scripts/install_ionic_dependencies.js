const helpers = require('./helpers');
const DEST_PATH = process.argv[2];

const shouldInstallIonicDependencies = function () {
    const fs = require('fs');
    const packageFilePath = `${process.cwd()}/../../../package.json`;
    if (!helpers.fileExists(packageFilePath)) {
        helpers.logWarning('package.json was not found.');
        helpers.logWarning('Ionic dependencies omission cannot be safely skipped.');
        return true;
    }
    let packageDataString;
    try {
        packageDataString = fs.readFileSync(packageFilePath);
    } catch (e) {
        helpers.logWarning('package.json found is unreadable.', e);
        helpers.logWarning('Ionic dependencies omission cannot be safely skipped.');
        return true;
    }
    let packageData;
    try {
        packageData = JSON.parse(packageDataString);
    } catch (e) {
        helpers.logWarning('package.json could not be parsed.', e);
        helpers.logWarning('Ionic dependencies omission cannot be safely skipped.');
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
    const fullDestPath = `${path.dirname(process.cwd())}/${DEST_PATH}`;
    try {
        process.chdir(fullDestPath);
    } catch (error) {
        helpers.logError(`Failed change directory to ${fullDestPath}!`, error);
        helpers.logError(
            `Please run \`cd node_modules/cordova-plugin-fcm-with-dependecy-updated/${DEST_PATH}; npm install\` manually`
        );
        return;
    }

    const npm = process.platform === 'win32' ? 'npm.cmd' : 'npm';
    helpers
        .execute(npm, ['install', '--loglevel', 'error', '--no-progress'])
        .catch(function (e) {
            helpers.logError('Failed to auto install Ionic dependencies!', e);
            helpers.logError(
                `Please run \`cd node_modules/cordova-plugin-fcm-with-dependecy-updated/${DEST_PATH}; npm install\` manually`
            );
        })
        .then(function (output) {
            console.log(`Ionic dependencies installed for ${DEST_PATH}:`);
            console.log(output);
        });
};

if (shouldInstallIonicDependencies()) {
    installIonicDependencies();
} else {
    console.log(`Ionic dependencies install skipped for ${DEST_PATH}`);
}
