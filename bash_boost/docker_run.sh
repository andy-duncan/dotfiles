
# dr <app/service> <version> <command>

bearer="Authorization: Bearer $DOCKER_RUN_KUBERNAUT_BEARER_TOKEN"

_test_connection()
{
  connection=$(curl --write-out %{http_code} --max-time 5 -s -H "$bearer" https://kubernaut.tescloud.com/api/services?limit=1)

  if [[ "$connection" = "000" ]]; then
    echo "connection timed out: please ensure you're connected to the vpn and try again"
    return
  fi
}

_dr_completions()
{
  _test_connection

  if [ ${COMP_CWORD} -eq 1 ]; then
    # Kube services to get services
    services=`curl -s -H "$bearer" https://kubernaut.tescloud.com/api/services?limit=1000000 | jq '.items[].name'`

    COMPREPLY=($(compgen -W "$services" "${COMP_WORDS[1]}"))
  fi

  if [ ${COMP_CWORD} -eq 2 ]; then
    # Kube releases to get versions.
    releases=`curl -s -H "$bearer" "https://kubernaut.tescloud.com/api/releases?limit=500&offset=0&service=${COMP_WORDS[1]}&version=value:${COMP_WORDS[2]},not:false,exact:false&order=desc&sort=created" | jq -r '.items[].version' `

    COMPREPLY=(${releases[@]})
  fi
}

docker_run()
{
  _test_connection

  # Kube get the specific release to get the id
  id=`curl -s -H "$bearer" "https://kubernaut.tescloud.com/api/releases?limit=50&offset=0&service=$1&version=$2" | jq  -r '.items[].id'`

  # Kube get the release by id to get the image
  image=`curl -s -H "$bearer" https://kubernaut.tescloud.com/api/releases/${id} | jq -r '.attributes.image'`

  echo running \`${*:3}\` on docker container \`$image:$2\`

  docker run --rm -ti $image:$2 bash -c "${*:3}"
}

alias dr=docker_run

complete -o nosort -F _dr_completions dr
