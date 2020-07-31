EKS Module

This module creates the resources required to spin up a kubernetes cluster on
EKS with joor's assumptions and semantics

Using the supplied configuration, we'll create:
- a VPC
- an EKS Cluster in a specific AZ
- N auto-scaling worker pools
- user based access
