# witw-chart

Helm chart for Posthog WITW

## Overview

There are two charts in this repository:

- `postgis`, which is used to deploy a stateful postgresql instance with the postgis extension
- `witw`, which is used to deploy stateless services based on the "whereintheworld" image

## Deploying it

To deploy the full application, these steps should be followed (in order, DB first):

**Postgres**

1. First, `cd` into `postgis` and run `helm template .`
1. Does it look right to you, all the right environment variables, etc? If so, continue
1. Then, run `helm install postgis .`
1. This will render and upload the resource YAMLs to Kubernetes
1. After a minute, run `kubectl get pods` and make sure you see the `postgis-0` pod in `Running`

**Whereintheworld**

1. First, `cd` into `witw` and run `helm template . -f values/backend.yaml`
1. (The `-f values/backend.yaml` tells it to use the "backend" values file and settings)
1. Does it look right to you, all the right environment variables, etc? If so, continue
1. Then, run `helm install witw-backend .`
1. This will render and upload the resource YAMLs to Kubernetes
1. After a minute, run `kubectl get pods` and make sure you see a `witw-backend` pod in `Running`

**Migrations**

1. Run `kubectl get pods` and find the name of a `witw-backend` pod
1. Run `kubectl exec -it $POD_NAME -- sh` to get a shell into the running pod above
1. Run `python manage.py migrate` in that shell to kick off the migrations
1. If it tells you "No migrations to apply", then you're all up to date!

## Modifying it



## Poking it
