#!/bin/bash
SERVICE=$1
NEW_WEIGHT=$2

cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: traffic-split1
  annotations:
    alb.ingress.kubernetes.io/group.name: traffic-split
    alb.ingress.kubernetes.io/load-balancer-name: traffic-split
    #alb.ingress.kubernetes.io/security-groups: sg-00f9cbfa237460027
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/actions.canary: |
      {
        "type": "forward",
        "forwardConfig": {
          "targetGroups": [
            {"serviceName": "app-v1", "servicePort": 80, "weight": $((100 - NEW_WEIGHT))},
            {"serviceName": "$SERVICE", "servicePort": 80, "weight": $NEW_WEIGHT}
          ]
        }
      }
spec:
  ingressClassName: alb
  rules:
    - http:
        paths:
          - backend:
              service:
                name: canary
                port:
                  name: use-annotation
            pathType: ImplementationSpecific
EOF
