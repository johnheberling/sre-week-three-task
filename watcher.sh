#!/usr/bin/bash
# watcher.sh - Monitor health of deployment pod

# Define Variables: Set the namespace, deployment name, and maximum number of restarts allowed before scaling down the deployment
namespace="sre"
deployment="swype-app"
max_restarts=3

# Loop until maximum restarts is exceeded
while true; do

    # Note date and time in log
    date

    # Check that the pod exists
    if [ `kubectl get pods -n $namespace | grep -c $deployment` -gt 0 ]; then

        # Check pod restarts
        current_restarts=`kubectl get pods -n $namespace | grep $deployment | awk '{print $4}'`
        echo "$deployment restarts:  $current_restarts"

        if [ $current_restarts -gt $max_restarts ]; then
            echo "ERROR:  restarts exceed maximum of $max_restarts"
            # Scale down the deployment to zero replicas
            kubectl scale --replicas=0 deployment/$deployment -n $namespace
            break
        fi

    else

        echo "Pod for $deployment does not exist yet"

    fi

    # Pause for 60 seconds before the next check
    sleep 1m

    # Repeat indefinitely until the number of restarts exceeds the maximum allowed, at which point the deployment is scaled down 
    # and the loop is broken.
done

echo "watcher for $deployment in namespace $namespace ending"
exit