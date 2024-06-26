
# My Cool Service

## Setup Instructions

### Prerequisites

- Terraform installed
- Ansible installed
- AWS CLI configured
- kubectl installed and configured

### Steps

1. **Provision the infrastructure:**
   ```sh
   cd terraform
   terraform init
   terraform apply
   ```

2. **Run the Ansible playbook:**
   ```sh
   cd ansible
   ansible-playbook -i 'your-ec2-public-ip,' playbook.yml
   ```

3. **Deploy OPA and the policy:**
   ```sh
   kubectl apply -f fastapi_service/opa-configmap.yaml
   kubectl apply -f fastapi_service/opa-config.yaml
   kubectl apply -f fastapi_service/opa-deployment.yaml
   kubectl apply -f fastapi_service/service-deployment.yaml
   kubectl apply -f fastapi_service/service.yaml
   ```

4. **Access the service:**
   Use the public IP or the Route53 domain to access the service:
   ```sh
   curl http://my-cool-service.climacs.net:30001/api/users
   ```

### Cleanup

To destroy the infrastructure:
```sh
cd terraform
terraform destroy
```
