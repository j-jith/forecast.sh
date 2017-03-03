forecast.sh
===========

Bash script for obtaining weather forecast from `yr.no <http://www.yr.no>`_.

Prerequisites
-------------

- `curl <https://curl.haxx.se/>`_
- `xsltproc <http://xmlsoft.org/XSLT/xsltproc2.html>`_

Usage
-----

Copy the script ``forecast.sh`` to a location in your ``$PATH`` and run

.. code:: bash

    forecast.sh -l location -p period-offset

location
~~~~~~~~

Country/State/City (Visit http://www.yr.no to find your ``location``).

**Example**

.. code:: bash

    forecast.sh -l India/Tamil_Nadu/Chennai

period-offset (optional)
~~~~~~~~~~~~~~~~~~~~~~~~

Forecast is available for the following time periods:

1. 23:30-05:30
2. 05:30-11:30
3. 11:30-17:30
4. 17:30-23:30.

``period-offset`` of 0 (default) gives the forecast for the current period. A
value of 1 gives the forecast for the next period and so on.

**Example**

.. code:: bash

    forecast.sh -l India/Tamil_Nadu/Chennai -p 1

Sample output
~~~~~~~~~~~~~

.. code:: bash

    [user@host]$ forecast.sh -l India/Tamil_Nadu/Chennai
    Chennai, India
    Sunrise: 06:23  Sunset: 18:17
    Forecast:
    From 2017-03-03 23:30 to 2017-03-04 05:30
    Outlook: Cloudy 27°C
    Wind: Light breeze 2.9 m/s SE
    Precipitation: 0 mm
    Pressure: 1010.1 hPa
