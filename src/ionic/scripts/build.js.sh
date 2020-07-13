## Build JS files
tsc -p . --declaration false --removeComments true

## Move files to the correct directories
cd ../../ionic
mv ionic/*.js .
mv ionic/ngx/*.js ./ngx/
mv ionic/v4/*.js ./v4/

## Simplify main build
sed 's/var FCMPluginOnIonic = (function () {//' FCM.js > FCM.js.tmp
sed 's/}());//' FCM.js.tmp > FCM.js
sed 's/return FCMPluginOnIonic;//' FCM.js > FCM.js.tmp
mv FCM.js.tmp FCM.js
npx prettier FCM.js --write

## Simplify v4 build
sed 's/var FCM = (function () {//' v4/FCM.js > v4/FCM.js.tmp
sed 's/}());//' v4/FCM.js.tmp > v4/FCM.js
sed 's/return FCM;//' v4/FCM.js > v4/FCM.js.tmp
mv v4/FCM.js.tmp v4/FCM.js
npx prettier v4/FCM.js --write

## Simplify ngx build
sed 's/var FCM = (function () {//' ngx/FCM.js > ngx/FCM.js.tmp
sed 's/}());//' ngx/FCM.js.tmp > ngx/FCM.js
sed 's/return FCM;//' ngx/FCM.js > ngx/FCM.js.tmp
mv ngx/FCM.js.tmp ngx/FCM.js
npx prettier ngx/FCM.js --write
