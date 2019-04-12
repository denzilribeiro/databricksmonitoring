#!/bin/bash

# Check installation of databricks  cli
databricks fs ls dbfs:/ >> /dev/null
dbcliinstall=$?
if [ $dbcliinstall -ne 0 ]; then
    echo "Databricks CLI not installed or configured correctly.. See : https://docs.databricks.com/user-guide/dev-tools/databricks-cli.html#install-the-cli";
    exit 1;
fi

echo "Creating DBFS direcrtory"
dbfs mkdirs dbfs:/databricks/loganalytics

echo "Uploading cluster init script"
dbfs cp loganalytics_linuxagent_init.sh  dbfs:/databricks/loganalytics/loganalytics_linuxagent_init.sh --overwrite

echo "Listing DBFS directory"
dbfs ls dbfs:/databricks/loganalytics

