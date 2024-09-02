# witw-chart

Helm chart for Posthog WITW

## Overview

There are three charts in this repository:

- `caddy`, which is used to deploy a stateful (just for certs) reverse-proxy for our services
- `postgis`, which is used to deploy a stateful postgresql instance with the postgis extension
- `witw`, which is used to deploy stateless services based on the "whereintheworld" image

## Deploying it

To deploy the full application, these steps should be followed (in order, DB first):

**Postgres**

1. First, `cd` into `postgis` and run `helm template .`
1. Does it look "correct enough" to you, all the environment variables, etc? If so, continue
1. Then, run `helm install postgis .`
1. This will render and upload the resource YAMLs to Kubernetes
1. After a minute, run `kubectl get pods` and make sure you see the `postgis-0` pod in `Running`

**Whereintheworld**

1. First, `cd` into `witw` and run `helm template . -f values/backend.yaml`
1. (The `-f values/backend.yaml` tells it to use the "backend" values file and settings)
1. Does it look "correct enough" to you, all the environment variables, etc? If so, continue
1. Then, run `helm install witw-backend .`
1. This will render and upload the resource YAMLs to Kubernetes
1. After a minute, run `kubectl get pods` and make sure you see a `witw-backend` pod in `Running`
1. Then, follow the same steps but with `-f values/frontend.yaml` for the frontend!

**Migrations**

1. Run `kubectl get pods` and find the name of a `witw-backend` pod
1. Run `kubectl exec -it $WITW_POD -- sh` to get a shell into the running pod above
1. Run `python manage.py migrate` in that shell to kick off the migrations
1. If it tells you "No migrations to apply", then you're all up to date!

**Caddy**

1. First, `cd` into `caddy` and run `helm template .`
1. Does it look "correct enough" to you? If so, continue
1. Then, run `helm install caddy .`
1. This will render and upload the resource YAMLs to Kubernetes
1. After a minute, run `kubectl get pods` and make sure you see the `caddy-0` pod in `Running`
1. You can also run `kubectl logs caddy-0` to see how the TLS cert process went

## Testing it out

After all of the above steps have been taken, try running:

```
curl -v https://hog.willett.io/_health
```

You should get a 200 response with `server: gunicorn` in the headers (and a 300 if you try with `http`). Additionally, if you try with a path looking like `/api/foo`, you should get a 400 error with "unauthorized".

## Modifying it

For both of the charts mentioned above, the process for deploying changes is the same:

1. Make any changes to the chart you like
1. Run `helm diff upgrade $RELEASE_NAME .` to see what Helm would do if you actually applied it
1. Make a PR with your changes, include the diff if you like, get it approved
1. Run `helm upgrade $RELEASE_NAME .` to actually execute your update, make sure it works
1. Merge your PR right after

## Poking around

Here are a few tools you might need when poking around the cluster:

* To get a (dangerous!) postgres shell: `kubectl exec -it postgis-0 -- psql -U whereintheworld`
* To run Django scripts: `kubectl get pods` then `kubectl exec -it $WITW_POD -- python manage.py foo`
* To hit the API from your laptop: `kubectl port-forward svc/witw-backend 8000:8000` (then `curl`)
