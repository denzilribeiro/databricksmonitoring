#!/bin/bash
STAGE_DIR="/dbfs/databricks/monitoring-staging"
LOG_ANALYTICS_WORKSPACE_ID="Enter Log analytics Workspace ID"
LOG_ANALYTICS_WORKSPACE_KEY="Enter Log analytics workspace Key"

echo "BEGIN: Copying listener jar"
cp -f "$STAGE_DIR/spark-listeners-1.0-SNAPSHOT.jar" /mnt/driver-daemon/jars || { echo "Error copying file"; exit 1;}
cp -f "$STAGE_DIR/spark-listeners-loganalytics-1.0-SNAPSHOT.jar" /mnt/driver-daemon/jars || { echo "Error copying file"; exit 1;}
echo "END: Copied listener jar successfully"


echo "BEGIN: Setting Environment variables"
sudo echo LOG_ANALYTICS_WORKSPACE_ID=$LOG_ANALYTICS_WORKSPACE_ID >> /etc/environment
sudo echo LOG_ANALYTICS_WORKSPACE_KEY=$LOG_ANALYTICS_WORKSPACE_KEY >> /etc/environment

echo "BEGIN: Updating Executor log4j properties file with Log analytics appender"
sed -i 's/log4j.rootCategory=.*/&, logAnalyticsAppender/g' $conf_file /home/ubuntu/databricks/spark/dbconf/log4j/executor/log4j.properties
tee -a /databricks/spark/dbconf/log4j/executor/log4j.properties << EOF
# logAnalytics
log4j.appender.logAnalyticsAppender=com.microsoft.pnp.logging.loganalytics.LogAnalyticsAppender
log4j.appender.logAnalyticsAppender.layout=com.microsoft.pnp.logging.JSONLayout
log4j.appender.logAnalyticsAppender.layout.LocationInfo=false
EOF
echo "END: Updating Executor log4j properties file with Log analytics appender"

echo "BEGIN: Updating Driver log4j properties file with Log analytics appender"
sed -i 's/log4j.rootCategory=.*/&, logAnalyticsAppender/g' /home/ubuntu/databricks/spark/dbconf/log4j/driver/log4j.properties
tee -a /databricks/spark/dbconf/log4j/driver/log4j.properties << EOF
# logAnalytics
log4j.appender.logAnalyticsAppender=com.microsoft.pnp.logging.loganalytics.LogAnalyticsAppender
log4j.appender.logAnalyticsAppender.layout=com.microsoft.pnp.logging.JSONLayout
log4j.appender.logAnalyticsAppender.layout.LocationInfo=false
EOF
echo "BEGIN: Updating Driver log4j properties file with Log analytics appender"
