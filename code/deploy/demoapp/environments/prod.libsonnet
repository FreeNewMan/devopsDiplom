local base = import './base.libsonnet';

 base {
   components +: {
     app +: {
       "replicaCount": 2,
       "deploymentName": "demoapp",
       "serviceName": "demoapp",
       "port": 8282,
       "targetPort": 80
       "nodePort": 30282
     },          
  }
 }