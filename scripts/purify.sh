#!/bin/bash
#
# Runs purifycss over the by Parcel generated main css file

cssFile=$(find dist -name 'main*css')
purify=./node_modules/.bin/purifycss
if command -v "$purify" >/dev/null 2>&1; then
  if [ -f "$cssFile" ]; then
    "$purify" "$cssFile" dist/src.*.js \ --min --info --out dist/temp.css \
      && mv dist/temp.css "$cssFile"
  fi
fi

