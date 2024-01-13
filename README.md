# Simple App Test
### Fade Rosyad

## Flowchart
```mermaid
flowchart LR;
    DC[Discord Client];
    DI[Discord Integrator];
    CP[GCloud Proxy];
    WC[Web Client];
    API[GCloudAPI];

    DC --> |Send slash command|DI;
    DI --> |Forward request|CP;
    CP -->|Get information about current infra|WC;
    CP <-- Send request to manage infra --> API;
```

## Tech Stack
1. Node Js for Discord Integrator base on 
2. Go for Gcloud Proxy base on
3. Terraform for provisioning Infrastructure
4. Google Cloud Platform
5. Kubernetes

