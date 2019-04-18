#!/bin/bash
STAGE_DIR="/dbfs/databricks/loganalytics"
LOG_ANALYTICS_WORKSPACE_ID="Enter Log analytics Workspace ID"
LOG_ANALYTICS_WORKSPACE_KEY="Enter Log analytics workspace Key"

echo "BEGIN: Copying spark metrics jar"
if [ ! -f /mnt/driver-daemon/jars/spark-listeners-loganalytics-1.0-SNAPSHOT.jar ]; then
 cp -f "$STAGE_DIR/spark-listeners-loganalytics-1.0-SNAPSHOT.jar" /mnt/driver-daemon/jars || { echo "Error copying file"; exit 1;}
fi
echo "END: Copied spark metrics jar successfully"

workspace_id=`sudo grep -i LOG_ANALYTICS_WORKSPACE_ID /etc/environment | wc -l`
workspace_key=`sudo grep -i LOG_ANALYTICS_WORKSPACE_KEY /etc/environment | wc -l`
echo "BEGIN: Setting Environment variables"
if [ $workspace_id -eq 0 ] ; then
 sudo echo LOG_ANALYTICS_WORKSPACE_ID=$LOG_ANALYTICS_WORKSPACE_ID >> /etc/environment
fi
if [ $workspace_key -eq 0 ] ; then
sudo echo LOG_ANALYTICS_WORKSPACE_KEY=$LOG_ANALYTICS_WORKSPACE_KEY >> /etc/environment
fi

cat << 'EOF' > /databricks/driver/conf/00-custom-spark-driver-defaults.conf
[driver] {
"spark.metrics.namespace" = "${spark.databricks.clusterUsageTags.clusterId}"
}
EOF

echo "Merging metrics.properties"
cat "$STAGE_DIR/metrics.properties" <(echo) /databricks/spark/conf/metrics.properties > /databricks/spark/conf/tmp.metrics.properties || { echo "Error merging metrics.properties"; exit 1; }
mv /databricks/spark/conf/tmp.metrics.properties /databricks/spark/conf/metrics.properties || { echo "Error writing metrics.properties"; exit 1; }
cat /databricks/spark/conf/metrics.properties
echo "Merged metrics.properties successfully"



