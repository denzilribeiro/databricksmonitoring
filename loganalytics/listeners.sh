#!/bin/bash
LOG_ANALYTICS_WORKSPACE_ID="Enter Log Analytics Workspace ID"
LOG_ANALYTICS_WORKSPACE_KEY="Enter Log Analytics Workspace Key"

workspace_id=`sudo grep -i LOG_ANALYTICS_WORKSPACE_ID /etc/environment | wc -l`
workspace_key=`sudo grep -i LOG_ANALYTICS_WORKSPACE_KEY /etc/environment | wc -l`

echo "BEGIN: Setting Environment variables"
if [ $workspace_id -eq 0 ] ; then
   sudo echo LOG_ANALYTICS_WORKSPACE_ID=$LOG_ANALYTICS_WORKSPACE_ID >> /etc/environment
fi
if [ $workspace_key -eq 0 ] ; then
  sudo echo LOG_ANALYTICS_WORKSPACE_KEY=$LOG_ANALYTICS_WORKSPACE_KEY >> /etc/environment
fi

STAGE_DIR="/dbfs/databricks/loganalytics"
echo "Copying listener jar"
cp -f "$STAGE_DIR/spark-listeners-1.0-SNAPSHOT.jar" /mnt/driver-daemon/jars || { echo "Error copying file"; exit 1;}
cp -f "$STAGE_DIR/spark-listeners-loganalytics-1.0-SNAPSHOT.jar" /mnt/driver-daemon/jars || { echo "Error copying file"; exit 1;}
echo "Copied listener jar successfully"

echo "Merging metrics.properties"
cat "$STAGE_DIR/metrics.properties" <(echo) /databricks/spark/conf/metrics.properties > /databricks/spark/conf/tmp.metrics.properties || { echo "Error merging metrics.properties"; exit 1; }
mv /databricks/spark/conf/tmp.metrics.properties /databricks/spark/conf/metrics.properties || { echo "Error writing metrics.properties"; exit 1; }
echo "Merged metrics.properties successfully"

echo "BEGIN: Updating Executor log4j properties file with Log analytics appender"
sed -i 's/log4j.rootCategory=.*/&, logAnalyticsAppender/g' /databricks/spark/dbconf/log4j/executor/log4j.properties
tee -a /databricks/spark/dbconf/log4j/executor/log4j.properties << EOF
# logAnalytics
log4j.appender.logAnalyticsAppender=com.microsoft.pnp.logging.loganalytics.LogAnalyticsAppender
log4j.appender.logAnalyticsAppender.filter.spark=com.microsoft.pnp.logging.SparkPropertyEnricher
EOF
echo "END: Updating Executor log4j properties file with Log analytics appender"

echo "BEGIN: Updating Driver log4j properties file with Log analytics appender"
sed -i 's/log4j.rootCategory=.*/&, logAnalyticsAppender/g' /databricks/spark/dbconf/log4j/driver/log4j.properties
tee -a /databricks/spark/dbconf/log4j/driver/log4j.properties << EOF
# logAnalytics
log4j.appender.logAnalyticsAppender=com.microsoft.pnp.logging.loganalytics.LogAnalyticsAppender
log4j.appender.logAnalyticsAppender.filter.spark=com.microsoft.pnp.logging.SparkPropertyEnricher
EOF
echo "END: Updating Driver log4j properties file with Log analytics appender"

# Location of the driver configuration defaults file
driver_conf="$DB_HOME/driver/conf/00-custom-spark-driver-defaults.conf"

cat << EOF > $driver_conf
[driver] {
    "spark.metrics.namespace" = "${DB_CLUSTER_ID}"
    "spark.extraListeners" = "com.databricks.backend.daemon.driver.DBCEventLoggingListener,org.apache.spark.listeners.UnifiedSparkListener"
    "spark.unifiedListener.sink" = "org.apache.spark.listeners.sink.loganalytics.LogAnalyticsListenerSink"
}
EOF

# Uncomment the lines below and replace the placeholders with your Log Analytics Workspace information
# to allow all clusters to use the same Log Analytics Workspace
tee -a /databricks/spark/conf/spark-env.sh << EOF
export DB_CLUSTER_ID=$DB_CLUSTER_ID
EOF
