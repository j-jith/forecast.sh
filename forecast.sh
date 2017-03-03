#!/bin/bash

display_help() {
    echo "Usage: $(basename "$0") -l location -p period-offset"
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
    case "${option}" in
        l)
            LOCATION=${OPTARG}
            ;;
        p)
            PERIOD_OFFSET=${OPTARG}
            ;;
        h)
            display_help
            ;;
        *)
            echo "Invalid option ${OPTARG}."
            display_help
            ;;
    esac
done
shift "$((OPTIND-1))"

if [ -z "$LOCATION" ]; then
    echo "Please provide a location."
    display_help
fi

YR_NO_URL="http://www.yr.no/place/"$LOCATION"/forecast.xml"

STYLESHEET="<xsl:stylesheet xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\" version=\"1.0\"> <xsl:output method=\"text\" /> <!-- strip whitespace --> <xsl:strip-space elements=\"*\" /> <xsl:param name=\"period-offset\" select=\"0\" /> <xsl:template match=\"weatherdata\"> <xsl:apply-templates select=\"location\" /> <xsl:apply-templates select=\"sun\" /> <xsl:apply-templates select=\"forecast\" /> </xsl:template> <xsl:template match=\"location\"> <xsl:value-of select=\"name\" /> <xsl:text>&#44;&#160;</xsl:text> <xsl:value-of select=\"country\" /> <xsl:text>&#10;</xsl:text> </xsl:template> <xsl:template match=\"sun\"> <xsl:text>Sunrise:&#160;</xsl:text> <xsl:value-of select=\"substring(substring-after(./@rise, 'T'), 1, 5)\" /> <xsl:text>&#160;&#160;</xsl:text> <xsl:text>Sunset:&#160;</xsl:text> <xsl:value-of select=\"substring(substring-after(./@set, 'T'), 1, 5)\" /> <xsl:text>&#10;</xsl:text> </xsl:template> <xsl:template match=\"forecast\"> <xsl:text>Forecast:&#10;</xsl:text> <xsl:for-each select=\"tabular/time[@period][\$period-offset + 1]\"> <xsl:call-template name=\"time-read\" /> </xsl:for-each> </xsl:template> <xsl:template name=\"time-read\"> <xsl:text>From&#160;</xsl:text> <xsl:value-of select=\"substring-before(./@from, 'T')\" /> <xsl:text>&#160;</xsl:text> <xsl:value-of select=\"substring(substring-after(./@from, 'T'), 1, 5)\" /> <xsl:text>&#160;</xsl:text> <xsl:text>to&#160;</xsl:text> <xsl:if test=\"./@period=0\"> <xsl:value-of select=\"substring-before(./@to, 'T')\" /> <xsl:text>&#160;</xsl:text> </xsl:if> <xsl:value-of select=\"substring(substring-after(./@to, 'T'), 1, 5)\" /> <xsl:text>&#10;</xsl:text> <xsl:text>Outlook:&#160;</xsl:text> <xsl:apply-templates select=\"symbol\" /> <xsl:text>&#160;</xsl:text> <xsl:apply-templates select=\"temperature\" /> <xsl:text>&#10;</xsl:text> <xsl:text>Wind:&#160;</xsl:text> <xsl:apply-templates select=\"windSpeed\" /> <xsl:text>&#160;</xsl:text> <xsl:apply-templates select=\"windDirection\" /> <xsl:text>&#10;</xsl:text> <xsl:text>Precipitation:&#160;</xsl:text> <xsl:apply-templates select=\"precipitation\" /> <xsl:text>&#10;</xsl:text> <xsl:text>Pressure:&#160;</xsl:text> <xsl:apply-templates select=\"pressure\" /> <xsl:text>&#10;</xsl:text> </xsl:template> <xsl:template match=\"symbol\"> <xsl:value-of select=\"./@name\" /> </xsl:template> <xsl:template match=\"precipitation\"> <xsl:value-of select=\"./@value\" /> <xsl:text>&#160;mm</xsl:text> </xsl:template> <xsl:template match=\"windDirection\"> <!--<xsl:value-of select=\"./@deg\" /> <xsl:text>&#176;&#160;</xsl:text>--> <xsl:value-of select=\"./@code\" /> </xsl:template> <xsl:template match=\"windSpeed\"> <xsl:value-of select=\"./@name\" /> <xsl:text>&#160;</xsl:text> <xsl:value-of select=\"./@mps\" /> <xsl:text>&#160;m&#47;s</xsl:text> </xsl:template> <xsl:template match=\"temperature\"> <xsl:value-of select=\"./@value\" /> <xsl:text>&#176;C</xsl:text> </xsl:template> <xsl:template match=\"pressure\"> <xsl:value-of select=\"./@value\" /> <xsl:text>&#160;hPa</xsl:text> </xsl:template> </xsl:stylesheet>"

# check for xsltproc
command -v xsltproc >/dev/null 2>&1 || { echo "This scripts requires xsltproc but it's not installed.  Aborting." >&2; exit 1; }

# check for curl
command -v curl >/dev/null 2>&1 || { echo "This scripts requires curl but it's not installed.  Aborting." >&2; exit 1; }

# fetch data
xsltproc --param period-offset $PERIOD_OFFSET <(echo $STYLESHEET) <(curl -s "$YR_NO_URL")

