## Build JS files
tsc -p . --declaration false --removeComments true

## Move files to the correct directories
cd ../../ionic
mv ionic/*.js .
mv ionic/ngx/*.js ./ngx/
mv ionic/v4/*.js ./v4/

## Simplify v4 build
sed 's/var FCM = (function () {//' v4/FCM.js > v4/FCM.js.tmp
sed 's/}());//' v4/FCM.js.tmp > v4/FCM.js
sed 's/return FCM;//' v4/FCM.js > v4/FCM.js.tmp
mv v4/FCM.js.tmp v4/FCM.js
npx prettier v4/FCM.js --write
