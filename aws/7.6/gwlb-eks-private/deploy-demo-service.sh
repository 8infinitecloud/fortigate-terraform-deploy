#!/bin/bash

# Cargar configuración
source ./ingress.config

# Configurar AWS profile si está definido
if [ -n "$AWS_PROFILE" ]; then
  export AWS_PROFILE=$AWS_PROFILE
  echo "🔑 Usando AWS Profile: $AWS_PROFILE"
fi

echo "🚀 Desplegando stack completo: Frontend + API + Backend..."
echo "📍 Usando subnets: $INGRESS_SUBNET_AZ1, $INGRESS_SUBNET_AZ2"

# 1. Crear ConfigMaps con contenido personalizado
echo "📄 Creando ConfigMaps..."

# Frontend HTML personalizado
kubectl create configmap custom-frontend-html --from-file=index.html=custom-frontend.html --dry-run=client -o yaml | kubectl apply -f -

# Configuración nginx
kubectl create configmap nginx-config --from-file=default.conf=nginx.conf --dry-run=client -o yaml | kubectl apply -f -

# 2. Backend Service (Base de datos de inteligencia)
echo "🕵️ Desplegando Backend Intelligence..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-app
  labels:
    app: backend
    tier: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
        tier: backend
    spec:
      containers:
      - name: backend
        image: hashicorp/http-echo:0.2.3
        args:
          - "-text={\"service\":\"Intelligence Database\",\"classification\":\"ULTRA SECRET\",\"pod\":\"\$(HOSTNAME)\",\"operation\":\"Libertad\",\"targets\":{\"captured\":[\"Nicolás Maduro\"],\"wanted\":[\"Diosdado Cabello\",\"Tareck El Aissami\"]},\"frozen_assets\":{\"total\":\"\$7.2B USD\",\"accounts\":347,\"crypto\":\"1,250.5 BTC\",\"properties\":89},\"status\":\"OPERATION ACTIVE\"}"
        ports:
        - containerPort: 5678
        env:
        - name: HOSTNAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        resources:
          requests:
            memory: "32Mi"
            cpu: "100m"
          limits:
            memory: "64Mi"
            cpu: "200m"
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  labels:
    app: backend
    tier: backend
spec:
  selector:
    app: backend
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5678
  type: ClusterIP
EOF

# 3. API Service (Operaciones financieras)
echo "💰 Desplegando API Financiera..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-app
  labels:
    app: api
    tier: api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
        tier: api
    spec:
      containers:
      - name: api
        image: hashicorp/http-echo:0.2.3
        args:
          - "-text={\"service\":\"API Financiera Venezuela\",\"version\":\"2.0\",\"endpoints\":[\"/accounts\",\"/transfer\",\"/crypto\",\"/sanctions\"],\"status\":\"active\",\"pod\":\"\$(HOSTNAME)\",\"data\":{\"usd_rate\":36245.50,\"btc_price\":42850.30,\"frozen_assets\":\"\$7.2B USD\",\"operations\":[\"asset_freeze\",\"sanctions_check\",\"crypto_portfolio\"]}}"
        ports:
        - containerPort: 5678
        env:
        - name: HOSTNAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        resources:
          requests:
            memory: "32Mi"
            cpu: "100m"
          limits:
            memory: "64Mi"
            cpu: "200m"
---
apiVersion: v1
kind: Service
metadata:
  name: api-service
  labels:
    app: api
    tier: api
spec:
  selector:
    app: api
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5678
  type: ClusterIP
EOF

# 4. Frontend Service (Página de noticias con imagen de Maduro)
echo "🎨 Desplegando Frontend con contenido personalizado..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-app
  labels:
    app: frontend
    tier: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
        tier: frontend
    spec:
      containers:
      - name: frontend
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: custom-html
          mountPath: /usr/share/nginx/html
          readOnly: true
        - name: nginx-config
          mountPath: /etc/nginx/conf.d
          readOnly: true
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
      volumes:
      - name: custom-html
        configMap:
          name: custom-frontend-html
      - name: nginx-config
        configMap:
          name: nginx-config
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  labels:
    app: frontend
    tier: frontend
spec:
  selector:
    app: frontend
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
EOF

# 5. Actualizar ingress existente para incluir todos los servicios
echo "🌐 Configurando rutas en ingress existente..."
kubectl patch ingress nginx-ingress --type='merge' -p='
{
  "spec": {
    "rules": [
      {
        "http": {
          "paths": [
            {
              "path": "/frontend",
              "pathType": "Prefix",
              "backend": {
                "service": {
                  "name": "frontend-service",
                  "port": {
                    "number": 80
                  }
                }
              }
            },
            {
              "path": "/api",
              "pathType": "Prefix", 
              "backend": {
                "service": {
                  "name": "api-service",
                  "port": {
                    "number": 80
                  }
                }
              }
            },
            {
              "path": "/backend",
              "pathType": "Prefix",
              "backend": {
                "service": {
                  "name": "backend-service", 
                  "port": {
                    "number": 80
                  }
                }
              }
            },
            {
              "path": "/",
              "pathType": "Prefix",
              "backend": {
                "service": {
                  "name": "nginx-service",
                  "port": {
                    "number": 80
                  }
                }
              }
            }
          ]
        }
      }
    ]
  }
}'

echo "✅ Stack completo desplegado!"
echo ""
echo "📋 Servicios desplegados:"
echo "  🎨 Frontend: /frontend (Página de noticias con imagen de Maduro)"
echo "  💰 API: /api (Operaciones financieras JSON)"
echo "  🕵️ Backend: /backend (Base de datos de inteligencia JSON)"
echo "  🌐 Nginx: / (Página básica)"
echo ""
echo "🔍 Verificar estado:"
echo "kubectl get pods -l 'tier in (frontend,api,backend)'"
echo "kubectl get svc -l 'tier in (frontend,api,backend)'"
echo "kubectl get ingress nginx-ingress"
echo ""
echo "🌍 Obtener URL del ALB:"
echo "ALB_URL=\$(kubectl get ingress nginx-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
echo "echo \"ALB URL: http://\$ALB_URL\""
echo ""
echo "🧪 Probar servicios:"
echo "curl http://\$ALB_URL/frontend   # Página con imagen de Maduro"
echo "curl http://\$ALB_URL/api        # API Financiera JSON"
echo "curl http://\$ALB_URL/backend    # Intelligence Database JSON"
echo "curl http://\$ALB_URL/           # Nginx básico"
echo ""
echo "⏳ Los servicios estarán disponibles en 1-2 minutos..."
