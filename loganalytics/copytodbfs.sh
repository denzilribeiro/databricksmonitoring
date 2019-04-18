#!/bin/bash
STAGE_DIR="dbfs:/databricks/loganalytics"
sed -i 's/^STAGE_DIR="dbfs:.*/STAGE_DIR="/dbfs/${STAGE_DIR}"/g' ./loganalytics_logging_init.sh
sed -i 's/^STAGE_DIR="dbfs:.*/STAGE_DIR="/dbfs/${STAGE_DIR}"/g' ./loganalytics_sparkmetrics.sh

# REPLACE KEYS in one place.
LOG_ANALYTICS_WORKSPACE_ID="Enter Log analytics Workspace ID"
LOG_ANALYTICS_WORKSPACE_KEY="Enter Log analytics workspace Key"
sed -i 's/^LOG_ANALYTICS_WORKSPACE_ID=.*/LOG_ANALYTICS_WORKSPACE_ID=${LOG_ANALYTICS_WORKSPACE_ID}/g' ./loganalytics_logging_init.sh
sed -i 's/^LOG_ANALYTICS_WORKSPACE_KEY=.*/LOG_ANALYTICS_WORKSPACE_KEY=${LOG_ANALYTICS_WORKSPACE_KEY}/g' ./loganalytics_logging_init.sh
sed -i 's/^LOG_ANALYTICS_WORKSPACE_ID=.*/LOG_ANALYTICS_WORKSPACE_ID=${LOG_ANALYTICS_WORKSPACE_ID}/g' ./loganalytics_sparkmetrics.sh
sed -i 's/^LOG_ANALYTICS_WORKSPACE_KEY=.*/LOG_ANALYTICS_WORKSPACE_KEY=${LOG_ANALYTICS_WORKSPACE_KEY}/g' ./loganalytics_sparkmetrics.sh
sed -i 's/^LOG_ANALYTICS_WORKSPACE_ID=.*/LOG_ANALYTICS_WORKSPACE_ID=${LOG_ANALYTICS_WORKSPACE_ID}/g' ./loganalytics_linuxagent_init.sh
sed -i 's/^LOG_ANALYTICS_WORKSPACE_KEY=.*/LOG_ANALYTICS_WORKSPACE_KEY=${LOG_ANALYTICS_WORKSPACE_KEY}/g' ./loganalytics_linuxagent_init.sh

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
dbfs cp loganalytics_linuxagent_init.sh  $STAGE_DIR/loganalytics_linuxagent_init.sh --overwrite
dbfs cp loganalytics_linuxagent_init.sh  $STAGE_DIR/loganalytics_logging_init.sh --overwrite
dbfs cp loganalytics_linuxagent_init.sh  $STAGE_DIR/loganalytics_sparkmetrics.sh --overwrite
dbfs cp loganalytics_linuxagent_init.sh  $STAGE_DIR/metrics.properties --overwrite

echo "Listing DBFS directory"
dbfs ls $STAGE_DIR

