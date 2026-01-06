#!/bin/bash

echo "🚀 Desplegando Nginx con Ingress (versión simple)..."

# Desplegar Nginx con LoadBalancer directo
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
EOF

echo "✅ Despliegue completado!"
echo ""
echo "📋 Para verificar el estado:"
echo "kubectl get pods -l app=nginx"
echo "kubectl get svc nginx-service"
echo ""
echo "🌍 Para obtener la URL del Load Balancer:"
echo "kubectl get svc nginx-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
echo ""
echo "⏳ El Load Balancer puede tardar 2-3 minutos en estar disponible..."
echo ""
echo "🔍 Monitorear el progreso:"
echo "watch 'kubectl get svc nginx-service'"
