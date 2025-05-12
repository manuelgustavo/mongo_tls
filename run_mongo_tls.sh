#!/bin/bash
set -euo pipefail

script_path=$(realpath "$(dirname "$0")")
pushd "${script_path}"

if which docker >/dev/null
then
    export DOCKER_EXE=docker
elif which podman >/dev/null
then
    export DOCKER_EXE=podman
else
    echo cannot use containers : neither docker nor podman found
    exit 1
fi

docker_exe=${DOCKER_EXE}

# As user (1st argument) execute a command (2nd argument) in the container.
docker_user_bash_exec()
{
    ${docker_exe} exec -it --user "$1" --workdir "${container_workdir}" "${docker_container}" /bin/bash -c "$2"
}

# Execute a command (1st argument) in the container as "root"
docker_bash_exec()
{
    docker_user_bash_exec root "$1"
}

echoerr() { echo "$@" 1>&2; }

admin_password=""
path_to_pem=""
port=""
name=""

usage="$(basename "$0") [-h | -p password] -- Creates / runs a mongodb container instance with tls.

where:
    -h            : show this help text.
    -s            : password to be set for the user admin.
    -n            : container name
    -p            : inbound port
    -c [optional] : path to PEM file. If not provided, a self-signed certificate will be generated"

do_arguments()
{
    local OPTIND OPTARG
    while getopts ':hs:n:p:c:' option; do
    case "$option" in
        h) echo "$usage"
        exit
        ;;
        s) admin_password="$OPTARG"; echo "-s=$OPTARG"
        ;;
        n) name="$OPTARG"; echo "-n=$OPTARG"
        ;;
        p) port="$OPTARG"; echo "-p=$OPTARG"
        ;;
        c) path_to_pem="$OPTARG"; echo "-c=$OPTARG"
        ;;
        :) printf "missing argument for -%s\n" "$OPTARG" >&2
           echo "$usage" >&2
           exit 1
        ;;
        \?) printf "illegal option: -%s\n" "$OPTARG" >&2
        echo "$usage" >&2
        exit 1
        ;;
    esac
    done
    shift $((OPTIND - 1))

    if [[ -z "$admin_password" ]]
    then
        echoerr "-s must be set!"
        echo "$usage" >&2
        exit 1
    fi

    if [[ -z "$name" ]]
    then
        echoerr "-n must be set!!"
        echo "$usage" >&2
        exit 1
    fi

    if [[ -z "$port" ]]
    then
        echo "Using default port 27017."
    fi
}

main()
{
    do_arguments "$@"

    existing_container=$(${docker_exe} ps -q -a -f name="^${name}\$")
    if [[ -n "$existing_container" ]]
    then
        echo -e "Container ${name} alreadyu exists, starting it if not running."
        return 0
    fi
    
    if [[ -z "$path_to_pem" ]]
    then
        echo "Creating self-signed certificate"
        path_to_pem=${path_to_pem:-"ssl"}
        rm -fr ssl
        mkdir -p ssl
        cd ssl
        openssl req -newkey rsa:2048 -nodes -keyout mongodbkey.key -x509 -days 365 -out mongodbkey.crt -subj "/C=US/ST=New Sweden/L=Stockholm /O=.../OU=.../CN=.../emailAddress=..."
        cat mongodbkey.key mongodbkey.crt > mongodb.pem
        cd ..
    fi

    ${docker_exe} build .\
        -t "$name" \
        --build-arg pem_dir="$path_to_pem"

    echo ${docker_exe} run -d -p ${port:-27017}:27017 --name "$name" -e "ADMIN_PASSWORD=$admin_password" "$name":latest

    ${docker_exe} run -d -p ${port:-27017}:27017 --name "$name" -e "ADMIN_PASSWORD=$admin_password" "$name":latest
    echo "Started ${name}..."
}

main "$@"