#!/usr/bin/env bash

# https://kind.sigs.k8s.io/docs/user/ingress/
kind delete cluster
kind get clusters
kind create cluster --config=config.yaml

echo 'start'
echo 'some info'
kind version
kubectl version
kubectl get pods
echo 'before applying ingress'
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
echo 'after applying ingress'
sleep 2
until kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s; do sleep 1; done
echo $?

echo 'after ingress comes online'
kubectl get pods
kubectl get pods --namespace ingress-nginx
echo 'before applying usage'
kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/usage.yaml
echo 'after applying usage'
kubectl get pods
kubectl wait --for=condition=ready pod --selector=app=foo --timeout=90s
echo 'after usage foo comes online'
kubectl get pods
kubectl wait --for=condition=ready pod --selector=app=bar --timeout=90s
echo 'after usage bar comes online'
kubectl get pods
kubectl get pods -o wide
kubectl get svc -o wide
kubectl describe svc foo-service
kubectl describe svc bar-service
kubectl get ingress
kubectl describe ingress example-ingress
kubectl get ingress example-ingress -o yaml
echo 'before ingress gets assigned an address'
sleep 2
until kubectl wait ingress/example-ingress --for=jsonpath='status.loadBalancer.ingress[0].hostname'=localhost; do sleep 1; done
echo 'after ingress gets assigned an address'
echo 'before testing usage'
# should output "foo"
curl -iH 'Host: localhost' localhost/foo
sleep 2
# should output "bar"
curl -iH 'Host: localhost' localhost/bar
echo 'after testing usage'
