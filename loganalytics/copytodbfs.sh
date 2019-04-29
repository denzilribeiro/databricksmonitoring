#!/bin/bash
STAGE_DIR="dbfs:/databricks/loganalytics"
STAGE_DIR_INTERNAL=$(echo $STAGE_DIR | cut -d':' -f 2 | sed -r 's/\//\\\//g')
echo $STAGE_DIR
echo $STAGE_DIR_INTERNAL
sed -i "s/^STAGE_DIR=.*/STAGE_DIR=\"\/dbfs$STAGE_DIR_INTERNAL\"/g" ./listeners.sh

# REPLACE KEYS in one place.
LOG_ANALYTICS_WORKSPACE_ID="Enter Log analytics Workspace ID"
LOG_ANALYTICS_WORKSPACE_KEY="Enter Log analytics Workspace Key"
sed -i "s/^LOG_ANALYTICS_WORKSPACE_ID=.*/LOG_ANALYTICS_WORKSPACE_ID=\"$LOG_ANALYTICS_WORKSPACE_ID\"/g" ./listeners.sh
sed -i "s/^LOG_ANALYTICS_WORKSPACE_KEY=.*/LOG_ANALYTICS_WORKSPACE_KEY=\"$LOG_ANALYTICS_WORKSPACE_KEY\"/g" ./listeners.sh
sed -i "s/^LOG_ANALYTICS_WORKSPACE_ID=.*/LOG_ANALYTICS_WORKSPACE_ID=\"$LOG_ANALYTICS_WORKSPACE_ID\"/g" ./loganalytics_linuxagent.sh
sed -i "s/^LOG_ANALYTICS_WORKSPACE_KEY=.*/LOG_ANALYTICS_WORKSPACE_KEY=\"$LOG_ANALYTICS_WORKSPACE_KEY\"/g" ./loganalytics_linuxagent.sh


# Check installation of databricks  cli
databricks fs ls dbfs:/ >> /dev/null
dbcliinstall=$?
if [ $dbcliinstall -ne 0 ]; then
    echo "Databricks CLI not installed or configured correctly.. See : https://docs.databricks.com/user-guide/dev-tools/databricks-cli.html#install-the-cli";
    exit 1;
fi

echo "Creating DBFS direcrtory"
dbfs mkdirs $STAGE_DIR

echo "Uploading cluster init script"
dbfs cp listeners.sh  $STAGE_DIR/listeners.sh --overwrite
dbfs cp loganalytics_linuxagent.sh  $STAGE_DIR/loganalytics_linuxagent.sh --overwrite
dbfs cp metrics.properties $STAGE_DIR/metrics.properties  --overwrite
dbfs cp spark-listeners-1.0-SNAPSHOT.jar $STAGE_DIR/spark-listeners-1.0-SNAPSHOT.jar --overwrite
dbfs cp spark-listeners-loganalytics-1.0-SNAPSHOT.jar $STAGE_DIR/spark-listeners-loganalytics-1.0-SNAPSHOT.jar --overwrite


echo "Listing DBFS directory"
dbfs ls $STAGE_DIR

