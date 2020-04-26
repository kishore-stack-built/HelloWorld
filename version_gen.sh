#! /bin/bash

pre_version=$1
lastValue=${pre_version##*.}
lastValue=$((lastValue+1))
new_version=${pre_version%.*}
new_version="$new_version.$lastValue"
echo $new_version

