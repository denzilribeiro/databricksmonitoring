#!/bin/bash
SUBSCRIPTION_NAME="Enter Subscription Name"
APPNAME="Enter App name"
LOG_ANALYTICS_RESOURCE_GROUP="Enter Resource Group of Log Analytics resource"
LOG_ANALYTICS_WORKSPACE="ENTER LOG ANALYTICS WORKSPACE NAME"

az login
az account set -s "$SUBSCRIPTION_NAME"
subscriptionId=$(az account show --query id -o tsv)


az ad sp create-for-rbac \
        --name $APPNAME  \
        --role "Log Analytics Reader"  \
        --scopes /subscriptions/$subscriptionId/resourceGroups/$LOG_ANALYTICS_RESOURCE_GROUP/providers/Microsoft.OperationalInsights/workspaces/$LOG_ANALYTICS_WORKSPACE


