## Generate .d.ts files
tsc -p . --declaration true --removeComments false

## Fix root .d.ts files
cd ../../ionic
sed 's/\.\.\/\.\.\/typings\//\.\.\/typings\//' ionic/FCM.d.ts > ionic/FCM.tmp.d.ts
sed 's/\.\.\/www\//\.\.\/typings\//' ionic/FCM.tmp.d.ts > FCM.d.ts
cp ../src/ionic/package.toCopy.json package.json

## Fix ngx .d.ts files
sed 's/\.\.\/www\//\.\.\/typings\//' ionic/ngx/FCM.d.ts > ngx/FCM.d.ts
cp ../src/ionic/package.toCopy.json ngx/package.json

## Fix v4 .d.ts files
mv ionic/v4/*.d.ts ./v4/
sed 's/\.\.\/\.\.\/typings\//\.\.\/typings\//' v4/FCM.d.ts > v4/FCM.tmp.d.ts
mv v4/FCM.tmp.d.ts v4/FCM.d.ts
cp ../src/ionic/package.toCopy.json v4/package.json

## Replace copyFrom with source value
cd ..
source "src/ionic/scripts/replaceCopyFromOnFile.helper.sh"
replaceCopyFromOnFile ionic/FCM.d.ts
replaceCopyFromOnFile ionic/ngx/FCM.d.ts
replaceCopyFromOnFile ionic/v4/FCM.d.ts

## Remove empty lines
sed '/^[[:space:]]*$/d' ionic/FCM.d.ts > ionic/FCM.d.ts.tmp
mv ionic/FCM.d.ts.tmp ionic/FCM.d.ts
sed '/^[[:space:]]*$/d' ionic/ngx/FCM.d.ts > ionic/ngx/FCM.d.ts.tmp
mv ionic/ngx/FCM.d.ts.tmp ionic/ngx/FCM.d.ts
sed '/^[[:space:]]*$/d' ionic/v4/FCM.d.ts > ionic/v4/FCM.d.ts.tmp
mv ionic/v4/FCM.d.ts.tmp ionic/v4/FCM.d.ts

## Simplify imports
simplifyImports() {
    filePath="$1"
    sed 's/import type /import /g' "$filePath" > "$filePath.tmp"
    mv "$filePath.tmp" "$filePath"
}
simplifyImports ionic/v4/FCM.d.ts
simplifyImports ionic/ngx/FCM.d.ts