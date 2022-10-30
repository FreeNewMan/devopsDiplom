local p = import '../params.libsonnet';
local params = p.components.app;

[
{
  "apiVersion": "apps/v1",
  "kind": "Deployment",
  "metadata": {
    "labels": {
      "app": "demoapp"
    },
    "name": params.deploymentName
  },
  "spec": {
    "replicas": params.replicaCount,
    "selector": {
      "matchLabels": {
        "app": "demoapp"
      }
    },
    "template": {
      "metadata": {
        "labels": {
          "app": "demoapp"
        }
      },
      "spec": {
        "containers": [
          {
            "image":  params.image.repository+':'+params.image.tag,
            "imagePullPolicy": "Always",
            "name": "demoapp",
            "ports": [
              {
                "containerPort": params.port
              }
            ]              
          }
        ]
      }
    }
  }
},
{
  "apiVersion": "v1",
  "kind": "Service",
  "metadata": {
    "name": params.serviceName
  },
  "spec": {
    "ports": [
      {
        "name": "web",
        "port": params.port,
        "targetPort": params.targetPort,
        "nodePort": params.nodePort,         
      }
    ],
    "selector": {
      "app": "demoapp"
    },
    "type": "NodePort"
  }
}

]
