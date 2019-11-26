#!/bin/sh
terraform output kubeconfig > ~/.kube/config
terraform output config_map_aws_auth | kubectl apply -f -
# echo $config_map_aws_auth
