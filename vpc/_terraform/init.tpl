# #!/bin/bash -e
# set -xe

# echo "${ id_phenix_pub }" > /home/ubuntu/.ssh/id_phenix.pub
# echo "${ id_phenix_priv }" > /home/ubuntu/.ssh/id_phenix
# chmod 600 /home/ubuntu/.ssh/id_phenix
# chown ubuntu:ubuntu /home/ubuntu/.ssh/id_phenix*
# echo "${ db_script }" > /opt/db-import.sh
# chmod 755 /opt/db-import.sh

# # datadog agent config
# sed -i -- "s#__DATADOG_API_KEY__#${ datadog_api_key }#" /etc/datadog-agent/datadog.yaml
# sed -i -- "s#__DATADOG_TAG_ENV__#${ datadog_tag_env }#" /etc/datadog-agent/datadog.yaml

# if [[ ${ datadog_agent_enabled } == true ]]; then
#   systemctl enable datadog-agent
#   systemctl restart datadog-agent
# else
#   systemctl stop datadog-agent
#   systemctl disable datadog-agent
# fi