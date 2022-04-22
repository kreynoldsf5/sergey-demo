# sergey-demo

Minimalistic demo to show:
    - automated application enrolling with a default policy
    - automated update to existing web applications

## Components

- Origin Pool
- App Firewall
- HTTP Load Balancer

### Origin Pool 
This targets an existing URL.

### App Firewall
WAAP policy in blocking mode.

### HTTP Load Balancer
LB exposed to the internet. Object where WAAP is applied.

## Deploy
GitOps using Terraform Cloud. Push a change to ``main`` and this will deployed to the F5xc tenant.
