#!/bin/sh
OUT_NAME="../forecast.sh"
cat > "$OUT_NAME" << EOF
#!/bin/bash

display_help() {
    echo "Usage: \$(basename "\$0") -l location -p period-offset"
    echo ""
    echo "Location:"
    echo "---------"
    echo "Country/State/City (Visit http://www.yr.no to find your location)."
    echo "eg: India/Tamil_Nadu/Chennai"
    echo ""
    echo "period-offset (optional):"
    echo "-------------------------"
    echo "Forecast is available for the following time periods:"
    echo "(0) 23:30-05:30, (1) 05:30-11:30,"
    echo "(2) 11:30-17:30, (3) 17:30-23:30."
    echo "period-offset of 0 (default) gives the forecast for the current"
    echo "period. A value of 1 gives the forecast for the next period and"
    echo "so on."
    exit 1;
}

PERIOD_OFFSET=0

while getopts ":l:p:h:" option; do
    case "\${option}" in
        l)
            LOCATION=\${OPTARG}
            ;;
        p)
            PERIOD_OFFSET=\${OPTARG}
            ;;
        h)
            display_help
            ;;
        *)
            echo "Invalid option \${OPTARG}."
            display_help
            ;;
    esac
done
shift "\$((OPTIND-1))"

if [ -z "\$LOCATION" ]; then
    echo "Please provide a location."
    display_help
fi

YR_NO_URL="http://www.yr.no/place/"\$LOCATION"/forecast.xml"

STYLESHEET="$(sed 's/\"/\\\"/g' stylesheet.xsl | sed 's/\$/\\\$/g' | sed 's/^[ \t]*//' | sed '/^[ \t]*$/d' | sed ':a;N;$!ba;s/\n/ /g')"

# check for xsltproc
command -v xsltproc >/dev/null 2>&1 || { echo "This scripts requires xsltproc but it's not installed.  Aborting." >&2; exit 1; }

# check for curl
command -v curl >/dev/null 2>&1 || { echo "This scripts requires curl but it's not installed.  Aborting." >&2; exit 1; }

# fetch data
xsltproc --param period-offset \$PERIOD_OFFSET <(echo \$STYLESHEET) <(curl -s "\$YR_NO_URL")

EOF

chmod a+x "$OUT_NAME"
