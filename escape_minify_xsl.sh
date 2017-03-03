#!/bin/sh
# escape single quotes
sed 's/\"/\\\"/g' "$1" | \
     # escape dollar signs
     sed 's/\$/\\\$/g' | \
     # escape leading spaces
     sed 's/^[ \t]*//' | \
     # delete empty lines
     sed '/^[ \t]*$/d' | \
     # delete newlines
     sed ':a;N;$!ba;s/\n/ /g' > "$1.escmini"
