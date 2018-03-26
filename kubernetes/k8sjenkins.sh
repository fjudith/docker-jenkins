#!/bin/bash

while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        v="${1/--/}"
        declare $v="$2"
   fi

  shift
done

# Create
if [ -z create ] ; then
  kubectl create namespace jenkins

  #tr --delete '\n' <jenkins.postgres.password.txt >.strippedpassword.txt && mv .strippedpassword.txt jenkins.postgres.password.txt
  #kubectl create secret generic jenkins-pass --from-file=jenkins.postgres.password.txt
  
  kubectl apply -f ./local-volumes.yaml
  
  kubectl apply -n jenkins -f ./jenkins-deployment.yaml

  kubectl get svc nginx -n default

# Create using Conduit service mesh
elif [ -v create ] && [ "$create" == "conduit" ]; then
  kubectl create namespace jenkins

  #tr --delete '\n' <jenkins.postgres.password.txt >.strippedpassword.txt && mv .strippedpassword.txt jenkins.postgres.password.txt
  #kubectl create secret generic jenkins-pass --from-file=jenkins.postgres.password.txt
  
  kubectl apply -f ./local-volumes.yaml
  
  cat ./jenkins-deployment.yaml | conduit inject --skip-outbound-ports=5432,8100 --skip-inbound-ports=5432,8100 - | kubectl apply -n jenkins -f -

  kubectl get svc nginx -n jenkins -o jsonpath="{.status.loadBalancer.ingress[0].*}"

  kubectl get svc nginx -n jenkins

# Create using Istio service mesh with automatic sidecar
elif [ -v create ] && [ "$create" == "istio" ]; then
  kubectl create namespace jenkins
  kubectl label namespace jenkins istio-injection=enabled

  #tr --delete '\n' <jenkins.postgres.password.txt >.strippedpassword.txt && mv .strippedpassword.txt jenkins.postgres.password.txt
  #kubectl create secret generic -n jenkins jenkins-pass --from-file=jenkins.postgres.password.txt
  
  kubectl apply -f ./local-volumes.yaml
  
  kubectl apply -n jenkins -f ./jenkins-deployment.yaml
  
  kubectl apply -n jenkins -f ./jenkins-ingress.yaml

  export GATEWAY_URL=$(kubectl get po -l istio=ingress -n istio-system -o 'jsonpath={.items[0].status.hostIP}'):$(kubectl get svc istio-ingress -n istio-system -o 'jsonpath={.spec.ports[0].nodePort}')

  printf "Istio Gateway: $GATEWAY_URL"
fi


# Delete
if [ -z delete ] || [ "$delete" == "conduit" ]; then
  kubectl delete -n jenkins -f ./jenkins-deployment.yaml
  kubectl delete -n jenkins -f ./local-volumes.yaml
  #kubectl delete -n jenkins secret jenkins-pass

  kubectl delete namespace jenkins
fi

if [ -v delete ] && [ "$delete" == "istio" ]; then
  kubectl delete -n jenkins -f ./jenkins-ingress.yaml
  kubectl delete -n jenkins -f ./jenkins-deployment.yaml
  kubectl delete -n jenkins -f ./local-volumes.yaml
  #kubectl delete secret jenkins-passs
  
  kubectl delete namespace jenkins
fi