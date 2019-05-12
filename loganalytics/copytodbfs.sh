#!/bin/bash
# Replace required variables
STAGE_DIR="dbfs:/databricks/loganalytics"
LOG_ANALYTICS_WORKSPACE_ID="154df9a593f5dba93a3f144992fb379"
LOG_ANALYTICS_WORKSPACE_KEY="kYzRRKgMWHA7AnzuIgYRDNmyCPjMuum3XFy2zx8GvFWAoKoTrQtOnGDC5u5VG2j3s0w+98Azaymkzok0EYyCGQ=="

# Get Init script from github repo
curl https://raw.githubusercontent.com/mspnp/spark-monitoring/master/src/spark-listeners/scripts/listeners.sh  -O -L -s
curl https://raw.githubusercontent.com/mspnp/spark-monitoring/master/src/spark-listeners/scripts/metrics.properties -O -L -s

LogAnalyticsJar1="./spark-listeners-1.0-SNAPSHOT.jar"
LogAnalyticsJar2="./spark-listeners-loganalytics-1.0-SNAPSHOT.jar"
if [ ! -f $LogAnalyticsJar1 ] || [ ! -f $LogAnalyticsJar2 ]; then
  echo "***Required Jar files not found, Please build the Jar files from  https://github.com/mspnp/spark-monitoring and copy into current folder***"
  echo "Files spark-listeners-1.0-SNAPSHOT.jar and spark-listeners-loganalytics-1.0-SNAPSHOT.jar are required"
fi

#Replace in Init scripts
STAGE_DIR_INTERNAL=$(echo $STAGE_DIR | cut -d':' -f 2 | sed -r 's/\//\\\//g')
sed -i "s/^STAGE_DIR=.*/STAGE_DIR=\"\/dbfs$STAGE_DIR_INTERNAL\"/g" ./listeners.sh 
sed -i 's/^LOG_ANALYTICS_WORKSPACE_ID=.*/LOG_ANALYTICS_WORKSPACE_ID=${LOG_ANALYTICS_WORKSPACE_ID}/g' ./listeners.sh
sed -i 's/^LOG_ANALYTICS_WORKSPACE_KEY=.*/LOG_ANALYTICS_WORKSPACE_KEY=${LOG_ANALYTICS_WORKSPACE_KEY}/g' ./listeners.sh
sed -i 's/^LOG_ANALYTICS_WORKSPACE_ID=.*/LOG_ANALYTICS_WORKSPACE_ID=${LOG_ANALYTICS_WORKSPACE_ID}/g' ./loganalytics_linuxagent.sh
sed -i 's/^LOG_ANALYTICS_WORKSPACE_KEY=.*/LOG_ANALYTICS_WORKSPACE_KEY=${LOG_ANALYTICS_WORKSPACE_KEY}/g' ./loganalytics_linuxagent.sh


# Check installation of databricks  cli
databricks fs ls dbfs:/ >> /dev/null
dbcliinstall=$?
if [ $dbcliinstall -ne 0 ]; then
    echo "Databricks CLI not installed or configured correctly.. See : https://docs.databricks.com/user-guide/dev-tools/databricks-cli.html#install-the-cli";
    exit 1;
fi

echo "Creating DBFS direcrtory"
databricks fs mkdirs $STAGE_DIR

echo "Uploading cluster init script"
databricks fs cp listeners.sh  $STAGE_DIR/listeners.sh --overwrite
databricks fs cp loganalytics_linuxagent.sh  $STAGE_DIR/loganalytics_linuxagent.sh --overwrite
databricks fs cp metrics.properties  $STAGE_DIR/metrics.properties --overwrite
databricks fs cp spark-listeners-1.0-SNAPSHOT.jar $STAGE_DIR/spark-listeners-1.0-SNAPSHOT.jar --overwrite
databricks fs cp spark-listeners-loganalytics-1.0-SNAPSHOT.jar $STAGE_DIR/spark-listeners-loganalytics-1.0-SNAPSHOT.jar --overwrite

echo "Listing DBFS directory"
dbfs ls $STAGE_DIR

