retriveJSDocFromFileClass() {
    filePath="$1"
    className="$2"
    buffer=""
    bufferEnabled=""
    while IFS= read -r fileLine; do
        if [[ "$fileLine" == *"class $className "* ]]; then
            echo "$buffer"
        fi
        if [[ "$fileLine" == *"/**"* ]]; then
            bufferEnabled="TRUE"
            buffer=""
        fi
        if [[ ! "$bufferEnabled" ]]; then
            continue
        fi
        buffer+="$fileLine\n"
        if [[ "$fileLine" == *"*/"* ]]; then
            bufferEnabled=""
        fi
    done < "$filePath"
}

export -f retriveJSDocFromFileClass