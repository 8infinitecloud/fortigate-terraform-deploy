#!/bin/bash

echo "🧹 Limpiando despliegues anteriores..."

# 1. Eliminar ingress y servicios
echo "🗑️ Eliminando ingress y servicios..."
kubectl delete ingress nginx-ingress demo-ingress 2>/dev/null || true
kubectl delete service nginx-service demo-service 2>/dev/null || true
kubectl delete deployment nginx-deployment demo-app 2>/dev/null || true

# 2. Eliminar AWS Load Balancer Controller
echo "🗑️ Eliminando AWS Load Balancer Controller..."
helm uninstall aws-load-balancer-controller -n kube-system 2>/dev/null || true

# 3. Eliminar service account
echo "🗑️ Eliminando service account..."
kubectl delete serviceaccount aws-load-balancer-controller -n kube-system 2>/dev/null || true

# 4. Esperar a que se limpien los recursos
echo "⏳ Esperando a que se limpien los recursos..."
sleep 10

echo "✅ Limpieza completada!"
echo ""
echo "📋 Verificar que todo se eliminó:"
echo "kubectl get pods,svc,ingress -A | grep -E '(nginx|demo|aws-load-balancer)'"
echo ""
echo "🚀 Ahora puedes ejecutar el script completo:"
echo "AWS_PROFILE=develop-orion ./deploy-ingress-complete.sh"
