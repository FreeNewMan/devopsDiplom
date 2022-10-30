local base = import './base.libsonnet';

 base {
   components +: {
     app +: {
       "replicaCount": 1,
       "deploymentName": "demoapp",
       "serviceName": "demoapp",
       "port": 8585,
       "targetPort": 80,
       "nodePort": 30585
     },          
  }
 }