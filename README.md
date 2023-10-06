# Create Cloud Run service
# Remember to populate `AUTHORIZED_KEYS` with your SSH Public Key and `PROXY_PASSWORD` with some password.

```
gcloud alpha run deploy cloudrun-shell-test \
   --image mattirantakomi/cloudrun-shell-test:latest \
   --update-env-vars AUTHORIZED_KEYS="$(cat ~/.ssh/id_ed25519.pub | tr -d '\n')" \
   --update-env-vars PROXY_USER="proxy" \
   --update-env-vars PROXY_PASSWORD="<your password>" \
   --no-allow-unauthenticated \
   --cpu 1 \
   --memory 512Mi \
   --min-instances 1 \
   --max-instances 1 \
   --execution-environment gen2 \
   --no-cpu-throttling \
   --region europe-north1 \
   --project <your gcp project id>
```

# Open Gcloud Proxy to Cloud Run service. 
It doesn't drop to background so you need to open another terminal for next command.
Optionally add `&` to the end of the command.
```
gcloud run services proxy cloudrun-shell-test \
  --port 1234 \
  --region europe-north1 \
  --project <your gcp project id>
```

# SSH to Cloud Run service container
```
ssh \
  -o 'ProxyCommand=huproxyclient -auth=proxy:<your password on PROXY_PASSWORD variable> ws://localhost:1234/proxy/localhost/22' \
  root@localhost
```

# Delete Cloud Run service
```
gcloud alpha run services delete cloudrun-shell-test \
  --region europe-north1 \
  --project <your gcp project id>
```
