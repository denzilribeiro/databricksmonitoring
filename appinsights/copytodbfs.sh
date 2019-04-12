#!/bin/bash

# Check installation of databricks  cli
databricks fs ls dbfs:/ >> /dev/null
dbcliinstall=$?
if [ $dbcliinstall -ne 0 ]; then
    echo "Databricks CLI not installed or configured correctly.. See : https://docs.databricks.com/user-guide/dev-tools/databricks-cli.html#install-the-cli";
    exit 1;
fi

echo "Creating DBFS direcrtory"
dbfs mkdirs dbfs:/databricks/appinsights

#If you need to change the version of App insights jars change it here.
echo "Downloading jars locally for version 2.3.1 App insights V1_2"
curl  https://github.com/Microsoft/ApplicationInsights-Java/releases/download/2.3.1/applicationinsights-logging-log4j1_2-2.3.1.jar  -O -L -s
curl  https://github.com/Microsoft/ApplicationInsights-Java/releases/download/2.3.1/applicationinsights-core-2.3.1.jar -O -L -s

echo "Uploading App Insights JAR files for Log4J verison 1.2 (Spark currenctly uses 1.2)"
dbfs cp applicationinsights-core-2.3.1.jar dbfs:/databricks/appinsights/applicationinsights-core-2.3.1.jar --overwrite
dbfs cp applicationinsights-logging-log4j1_2-2.3.1.jar  dbfs:/databricks/appinsights/applicationinsights-logging-log4j1_2-2.3.1.jar --overwrite

echo "Uploading cluster init script"
dbfs cp appinsights_logging_init.sh  dbfs:/databricks/appinsights/appinsights_logging_init.sh --overwrite

echo "Deleting jars downloaded locally"
rm -rf applicationinsights-logging-log4j1_2-2.3.1.jar
rm -rf applicationinsights-core-2.3.1.jar

echo "Listing DBFS directory"
dbfs ls dbfs:/databricks/appinsights

