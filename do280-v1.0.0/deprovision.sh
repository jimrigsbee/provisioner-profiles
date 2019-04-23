#!/bin/sh
GUID=$1
REGION=$2
ENV=$3
PROFILE=$4

pushd ~
if [ ! -d agnosticd ]; then
  git clone https://github.com/redhat-cop/agnosticd
  git checkout development
fi
popd

mkdir -p work/clusters/${GUID}
pushd ~/work/clusters/${GUID}
cp ~/provisioner-profiles/${PROFILE}/env_vars.yml .
popd

pushd ~/agnosticd
case "$ENV" in
prod) HOSTZONEID="ZY7XZ7UHGXN8K"
      ;;
dev)  HOSTZONEID="Z1T2DYD8FK0NW4"
      ;;
esac

ansible-playbook ansible/configs/ocp4-workshop/destroy_env.yml \
    -e "guid=${GUID}" \
    -e "env_type=ocp4-workshop" \
    -e "cloud_provider=ec2" \
    -e "aws_region=${REGION}" \
    -e "HostedZoneId=${HOSTZONEID}" \
    -e "key_name=gls${ENV}" \
    -e "env=${ENV}" \
    -e@~/${ENV}-secrets.yml \
    -e@~/work/clusters/${GUID}/env_vars.yml

popd
