#!/bin/bash

#Copy the sample notebook
databricks workspace import -l SCALA  ./SampleJobNotebook.scala /Shared/SampleJobNotebook --overwrite
#run a job with the config specified in file samplejobconfig.json
databricks runs submit --json-file ./jobconfig_loganalytics.json 
