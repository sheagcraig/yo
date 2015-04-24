#!/bin/bash

if [[ $(who | grep console) ]]; then
	/Applications/Utilities/yo.app/Contents/MacOS/yo "$@"
fi
