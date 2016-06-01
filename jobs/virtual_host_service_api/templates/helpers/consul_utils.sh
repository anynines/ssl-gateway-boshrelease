set +e
register_at_consul() {

  service_name=$1
  service_port=$2
  consul_agent=$3
  connect_timeout=15

  echo "Attempting to register service node at consule agent ${consul_agent} ..."

  payload="{\"name\": \"${service_name}\", \"port\": ${service_port}}"
  endpoint="http://${consul_agent}/v1/agent/service/register"

  curl -X PUT --connect-timeout $connect_timeout -d "${payload}" $endpoint
  result=$?
  echo "curl result for node ${consul_agent} : $result"

  if [ $result == 0 ]; then
    echo "Successfully registered service node at consule agent ${consul_agent} ..."
    return 0
  fi

  echo "Failed to register the service node at any consul nodes!"
  return 1
}
