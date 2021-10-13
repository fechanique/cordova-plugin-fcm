## Generate .d.ts files
cp ./*.d.ts ../../typings
tsc -p . --declaration true --declarationDir ../../typings --removeComments false

## Simplify imports
simplifyImports() {
    importOrExport="$1"
    filePath="$2"
    sed "s/$importOrExport type /$importOrExport /g" "$filePath" > "$filePath.tmp"
    mv "$filePath.tmp" "$filePath"
}
simplifyImports import ../../typings/FCMPlugin.d.ts
simplifyImports import ../../typings/eventAsDisposable.d.ts
simplifyImports export ../../typings/index.d.ts