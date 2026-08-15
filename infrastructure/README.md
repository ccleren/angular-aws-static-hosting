# 🌍 Infraestructura — Terraform

Infraestructura como código para desplegar una SPA de Angular en AWS:
**S3 + CloudFront + ACM + Route 53**, con remote state en S3 y locking en
DynamoDB. Ver el [README general](../README.md) para la arquitectura y el
diagrama completos.

---

## 📁 Estructura

```
infrastructure/
├── bootstrap/              # 🧱 Crea el backend remoto (S3 + DynamoDB). Se aplica una sola vez, con state local.
├── environments/
│   └── prod/                 # 🚀 Entorno de producción: conecta los 5 módulos
└── modules/
    ├── s3-static-site/        # 🪣 Bucket privado del build de Angular
    ├── cloudfront/            # 🚀 CDN + OAC + cabeceras de seguridad
    ├── acm-certificate/       # 🔒 Certificado SSL validado por DNS (us-east-1)
    ├── route53/               # 🌐 Hosted zone + registro alias hacia CloudFront
    └── github-oidc/           # 🔑 Rol IAM para GitHub Actions vía OIDC (CI/CD sin credenciales estáticas)
```

`environments/prod` reutiliza estos módulos para añadir un entorno
`staging` o `dev` en el futuro, se crea una carpeta hermana en
`environments/` que instancia los mismos módulos con otras variables —
sin duplicar lógica.

---

## ✅ Requisitos previos

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.6
- Una cuenta de AWS y credenciales configuradas (`aws configure` o variables de entorno)
- Un dominio propio (puedes gestionarlo íntegramente desde Route 53, o solo delegar los nameservers)

---

## 1️⃣ Bootstrap del backend remoto

Se aplica **una sola vez**, con state local.

```bash
cd infrastructure/bootstrap
terraform init
terraform apply -var="state_bucket_name=TU-BUCKET-UNICO-DE-STATE"
```

Anota los outputs (`state_bucket_name`, `lock_table_name`): los necesitarás
en el siguiente paso.

---

## 2️⃣ Configurar el backend remoto de `prod`

Edita `environments/prod/backend.tf` y sustituye `bucket` (y `region`/`dynamodb_table`
si los cambiaste) por los valores del paso anterior:

```hcl
terraform {
  backend "s3" {
    bucket         = "TU-BUCKET-UNICO-DE-STATE"
    key            = "prod/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
```

---

## 3️⃣ Variables del entorno `prod`

```bash
cd infrastructure/environments/prod
cp terraform.tfvars.example terraform.tfvars
```

Edita `terraform.tfvars` con tu dominio y un nombre de bucket único:

| Variable | Descripción |
|---|---|
| `domain_name` | Tu dominio raíz, ej. `example.com` |
| `additional_subdomains` | Subdominios adicionales, ej. `["www"]` |
| `create_route53_zone` | `true` si Route 53 debe crear la hosted zone, `false` si ya existe |
| `bucket_name` | Nombre único del bucket S3 para el build de Angular |
| `cloudfront_price_class` | Cobertura de edge locations (`PriceClass_100` por defecto, la más económica) |
| `github_org` / `github_repo` | Dueño y nombre del repo de GitHub, para restringir qué workflow puede asumir el rol de CI/CD |
| `state_bucket_name` / `lock_table_name` | Deben coincidir con los outputs del bootstrap (paso 1) |

---

## 4️⃣ Desplegar la infraestructura

```bash
terraform init
terraform plan
terraform apply
```

Si `create_route53_zone = true`, Terraform crea la hosted zone pero **no
puede activarla por ti**: copia el output `route53_name_servers` y
configúralos en el registrador de tu dominio. Hasta que el DNS propague
(puede tardar hasta 48h), la app ya es accesible en la URL de CloudFront
(`output cloudfront_url`).

---

## 5️⃣ Subir el build de Angular

Con la infraestructura desplegada, compila la app y sincronízala al bucket:

```bash
cd ../../../app
npm ci
npm run build

aws s3 sync dist/app/browser s3://TU-BUCKET-NAME --delete

aws cloudfront create-invalidation \
  --distribution-id TU-DISTRIBUTION-ID \
  --paths "/*"
```

`TU-BUCKET-NAME` y `TU-DISTRIBUTION-ID` son los outputs `bucket_name` y
`cloudfront_distribution_id` de `terraform apply`. Este paso lo automatiza
el workflow de GitHub Actions en `.github/workflows/deploy.yml`.

---

## 6️⃣ Activar el CI/CD (GitHub Actions + OIDC)

El `apply` del paso 4 ya crea el rol IAM que usa el workflow — pero antes
de que GitHub Actions pueda desplegar solo, necesitas dos cosas:

1. **Copiar el ARN del rol.** Es el output `github_actions_role_arn` de
   `terraform apply` (paso 4, hecho en local con tus propias credenciales
   de AWS — es la única vez que hace falta).
2. **Configurar las "Repository variables"** en GitHub
   (`Settings → Secrets and variables → Actions → Variables`). Ninguna es
   secreta: no hay credenciales de AWS entre ellas, solo el ARN de un rol
   con permisos acotados.

| Variable | Valor |
|---|---|
| `AWS_ROLE_ARN` | Output `github_actions_role_arn` |
| `AWS_REGION` | La misma región que `aws_region` en `terraform.tfvars` |
| `DOMAIN_NAME` | El mismo valor que `domain_name` |
| `BUCKET_NAME` | El mismo valor que `bucket_name` |
| `TF_STATE_BUCKET_NAME` | El mismo valor que `state_bucket_name` |
| `TF_LOCK_TABLE_NAME` | El mismo valor que `lock_table_name` |

A partir de aquí, cada push a `main` que toque `app/` o `infrastructure/`
dispara el workflow: build de Angular, `terraform apply`, sync a S3 e
invalidación de CloudFront — sin volver a tocar `terraform apply` en local.

---

## 🔐 Notas de seguridad

- El bucket S3 **nunca** es público: todo el acceso pasa por CloudFront a través de OAC.
- La bucket policy se restringe al ARN exacto de la distribución (`AWS:SourceArn`), no a "cualquier CloudFront".
- El certificado ACM se valida por DNS de forma automática — no requiere aprobación manual por email.
- El remote state de Terraform está cifrado (SSE-S3) y bloqueado con DynamoDB para evitar applies concurrentes.

---

## 🧹 Destruir la infraestructura

```bash
cd infrastructure/environments/prod
terraform destroy
```

El backend remoto (bootstrap) no se destruye con este comando: si quieres
eliminarlo también, hazlo por separado desde `infrastructure/bootstrap`
(recuerda que borra el propio state — solo tiene sentido si ya no vas a
reutilizar este backend).
