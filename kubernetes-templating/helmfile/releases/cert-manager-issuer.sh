#!/bin/bash
kubectl get crd issuers.cert-manager.io > /dev/null 2>&1
if [[ $? == 0 ]]
then
  kubectl apply -f releases/hooks/cert-manager-issuer.yaml
else
  kubectl delete -f releases/hooks/cert-manager-issuer.yaml
fi