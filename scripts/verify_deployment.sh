#!/bin/bash

set -e

# Verify retail-app deployment
# Check pods status
echo "Checking pods in retail-app namespace..."
kubectl get pods -n retail-app

echo ""
echo "Expected healthy output:"
echo "NAME                           READY   STATUS    RESTARTS   AGE"
echo "retail-store-ui-xxx            1/1     Running   0          Xm"
echo "retail-store-catalog-xxx       1/1     Running   0          Xm"
echo "retail-store-orders-xxx        1/1     Running   0          Xm"
echo "retail-store-cart-xxx          1/1     Running   0          Xm"
echo "retail-store-checkout-xxx      1/1     Running   0          Xm"
echo "retail-store-product-api-xxx   1/1     Running   0          Xm"
echo "mysql-xxx                      1/1     Running   0          Xm"
echo "postgres-xxx                   1/1     Running   0          Xm"
echo "rabbitmq-xxx                   1/1     Running   0          Xm"
echo "redis-xxx                      1/1     Running   0          Xm"

echo ""
echo "=========================================="
echo "Setting up port-forward to retail-store-ui"
echo "=========================================="
echo "Port-forwarding svc/retail-store-ui to localhost:8080"
echo ""
echo "Press Ctrl+C to stop port-forward when done"
echo ""
echo "Open http://localhost:8080 in your browser"
echo ""

kubectl port-forward svc/retail-store-ui 8080:80 -n retail-app
