#!/bin/bash

#In GKE, nodes are assigned internal IP addresses from a private subnet in your 
#VPC and don't have an external IP address by default. 

#This script will use the kubectl get nodes command to retrieve the names 
#of all nodes in the cluster, and then loop through the names to retrieve 
#the internal IP address of each node using the kubectl describe node command. 
#The internal IP addresses are displayed alongside the node names.

# Get the names of all nodes in the cluster
nodes=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}')

# Loop through the names of all nodes
for node in $nodes; do
  # Get the internal IP address of the node
  internal_ip=$(kubectl describe node $node | grep InternalIP | awk '{print $2}')
  # Print the node name and its internal IP address
  echo "Node: $node, Internal IP: $internal_ip"
done
