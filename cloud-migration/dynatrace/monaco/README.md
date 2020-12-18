# Welcome 

The repo contains the configuration files to support [Dynatrace Monitoring as Code](https://github.com/dynatrace-oss/dynatrace-monitoring-as-code) framework.

# Prereqs

* Tested with [Dynatrace monoco binary 1.0.1](https://github.com/dynatrace-oss/dynatrace-monitoring-as-code/releases/tag/v1.0.1)
    * copied binary, renamed to `monaco`, ran `chmod +x`, moved to `/usr/local/bin/monaco`, adjust mac security settings to trust `monaco`
* Set environment variables
    * WORKSHOP_DT_URL
    * WORKSHOP_DT_API_TOKEN