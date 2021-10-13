retriveJSDocFromFileClassMethod() {
    filePath="$1"
    className="$2"
    methodName="$3"
    classFound=""
    buffer=""
    bufferEnabled=""
    while IFS= read -r fileLine; do
        if [[ "$fileLine" == *"class $className "* ]]; then
            classFound="TRUE"
        fi
        if [[ ! "$classFound" ]]; then
            continue
        fi
        if [[ "$fileLine" == *"$methodName"* ]]; then
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

export -f retriveJSDocFromFileClassMethod