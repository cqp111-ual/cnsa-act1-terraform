# cnsa-act1-terraform

Proyecto Terraform para desplegar la infraestructura requerida para la Actividad 1 de CNSA en el proveedor cloud Azure.

## Antes de desplegarlo

- Copiar la clave SSH pública de tu usuario en la carpeta `keys/`.

- Crear el archivo `terraform.tfvars` basado en el de ejemplo, pero rellenando las credenciales `azure-tenant` y `azure-subscription`. Se pueden obtener con el comando (requiere `azure-cli` instalado):
  
```bash
az account show
```

## Despliegue

Tras crear los archivos, se puede proceder a levantar la infraestructura con los siguientes comandos:

```bash
terraform init
terraform plan
terraform apply
```
