#!/bin/bash

databricks workspace import ./jobnotebook /Shared/jobnotebook --overwrite
databricks runs submit --json-file ./samplejobconfig.json 
