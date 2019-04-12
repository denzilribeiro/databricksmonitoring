#!/bin/bash
STAGE_DIR="/dbfs/databricks/appinsights"
APPINSIGHTS_INSTRUMENTATION_KEY="ENTER INSTRUMENTATION KEY"

echo "BEGIN: Upload App Insights JARs"
cp -f "$STAGE_DIR/applicationinsights-core-2.3.1.jar" /mnt/driver-daemon/jars
cp -f "$STAGE_DIR/applicationinsights-logging-log4j1_2-2.3.1.jar" /mnt/driver-daemon/jars
echo "END: Upload App Insights JARs"

echo "BEGIN: Setting Environment variables"
sudo echo APPINSIGHTS_INSTRUMENTATIONKEY=$APPINSIGHTS_INSTRUMENTATION_KEY >> /etc/environment

echo "BEGIN: Updating Executor log4j properties file"
sed -i 's/log4j.rootCategory=INFO, console/log4j.rootCategory=INFO, console, aiAppender/g' /home/ubuntu/databricks/spark/dbconf/log4j/executor/log4j.properties
tee -a /databricks/spark/dbconf/log4j/executor/log4j.properties << EOF
# appInsights
log4j.appender.aiAppender=com.microsoft.applicationinsights.log4j.v1_2.ApplicationInsightsAppender
log4j.appender.aiAppender.DatePattern='.'yyyy-MM-dd
log4j.appender.aiAppender.layout=org.apache.log4j.PatternLayout
log4j.appender.aiAppender.layout.ConversionPattern=[%p] %d %c %M - %m%n
EOF
echo "END: Updating Executor log4j properties file"

echo "BEGIN: Updating Driver log4j properties file"
sed -i 's/log4j.rootCategory=INFO, publicFile/log4j.rootCategory=INFO, publicFile, aiAppender/g' /home/ubuntu/databricks/spark/dbconf/log4j/driver/log4j.properties
tee -a /databricks/spark/dbconf/log4j/driver/log4j.properties << EOF
# appInsights
log4j.appender.aiAppender=com.microsoft.applicationinsights.log4j.v1_2.ApplicationInsightsAppender
log4j.appender.aiAppender.DatePattern='.'yyyy-MM-dd
log4j.appender.aiAppender.layout=org.apache.log4j.PatternLayout
log4j.appender.aiAppender.layout.ConversionPattern=[%p] %d %c %M - %m%n
EOF
echo "BEGIN: Updating Driver log4j properties file"

