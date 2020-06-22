source "src/ionic/scripts/retriveJSDocFromFileClass.helper.sh"
source "src/ionic/scripts/retriveJSDocFromFileClassMethod.helper.sh"

replaceCopyFromOnFile() {
    filePath="$1"
    fileTextOut=""
    SAFE_IFS=IFS
    while IFS= read -r fileLine; do
        if [[ ! "$fileLine" == *"/** @copyFrom "* ]]; then
            fileTextOut+="$fileLine\n"
            continue
        fi
        targetFilePath=$(echo "$fileLine" | xargs | cut -d ' ' -f 3)
        className=$(echo "$fileLine" | xargs | cut -d ' ' -f 4)
        methodName=$(echo "$fileLine" | xargs | cut -d ' ' -f 5)
        if [[ "$methodName" == "*/" ]]; then
            fileTextOut+=$(retriveJSDocFromFileClass "$targetFilePath" "$className")"\n"
        else
            fileTextOut+=$(retriveJSDocFromFileClassMethod "$targetFilePath" "$className" "$methodName")"\n"
        fi
    done < "$filePath"
    IFS=SAFE_IFS
    echo "$fileTextOut" > "$filePath.tmp"
    mv "$filePath.tmp" "$filePath"
}

export -f replaceCopyFromOnFile