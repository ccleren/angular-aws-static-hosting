# 🧭 Guía paso a paso — construir la infraestructura a mano en AWS

Esta guía reproduce lo que los módulos de
este repositorio automatizan: un bucket S3 privado, una distribución de
CloudFront con Origin Access Control, un certificado SSL y el DNS en
Route 53. Cada paso trae dos opciones — elige una:

- **🖱️ Por consola** — clic a clic en la consola web de AWS.
- **⌨️ Por CLI** — el comando `aws` equivalente.

No incluye nada de Git/GitHub ni CI/CD: es solo AWS, de principio a fin.

> Requisito: tener [AWS CLI v2](https://aws.amazon.com/cli/) instalado y
> configurado (`aws configure`) si vas a usar la opción CLI, y una cuenta
> de AWS con permisos de administrador para seguir la consola.

---

## 0️⃣ Compilar la app Angular

Necesitas los archivos estáticos antes de subir nada. Desde la carpeta `app/`:

```bash
npm install
npm run build
```

Esto genera `app/dist/app/browser/` — es lo que se sube a S3 más adelante.

---

## 1️⃣ Crear el bucket S3 (privado)

### 🖱️ Por consola
1. Consola de AWS → busca **S3** → **Create bucket**.
2. **Bucket name**: algo único en todo S3, ej. `tudominio-com-site`.
3. **AWS Region**: la que prefieras, ej. `eu-west-1`.
4. **Object Ownership**: déjalo en *ACLs disabled*.
5. **Block Public Access settings**: deja las **4 casillas marcadas** (bloqueo total — así debe quedar).
6. **Bucket Versioning**: **Enable**.
7. **Default encryption**: **Server-side encryption with Amazon S3 managed keys (SSE-S3)**, y activa **Bucket Key**.
8. **Create bucket**.

### ⌨️ Por CLI
```bash
aws s3api create-bucket \
  --bucket TU-BUCKET \
  --region eu-west-1 \
  --create-bucket-configuration LocationConstraint=eu-west-1

aws s3api put-public-access-block \
  --bucket TU-BUCKET \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

aws s3api put-bucket-versioning \
  --bucket TU-BUCKET \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket TU-BUCKET \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"},"BucketKeyEnabled":true}]}'
```

> Si tu región es `us-east-1`, quita `--create-bucket-configuration` (esa región no lo acepta).

No subas nada al bucket todavía — la política que lo protege depende de la
distribución de CloudFront, que aún no existe (paso 6).

---

## 2️⃣ Crear la hosted zone en Route 53

### 🖱️ Por consola
1. Consola de AWS → **Route 53** → **Hosted zones** → **Create hosted zone**.
2. **Domain name**: `tudominio.com`.
3. **Type**: *Public hosted zone* → **Create hosted zone**.
4. Anota los 4 valores del registro tipo **NS** que se crea automáticamente — los necesitas ahora.
5. Ve al panel de tu **registrador de dominios** (donde lo compraste) → sección de **Nameservers** → sustitúyelos por esos 4 valores. La propagación puede tardar hasta 48h.

### ⌨️ Por CLI
```bash
aws route53 create-hosted-zone \
  --name tudominio.com \
  --caller-reference "$(date +%s)"
```
El campo `DelegationSet.NameServers` de la respuesta trae los 4 nameservers
— configúralos en tu registrador igual que en la opción de consola.

Guarda el `Id` de la hosted zone (algo como `/hostedzone/Z0123456789`) —
lo necesitas en los pasos 3 y 8.

---

## 3️⃣ Solicitar el certificado SSL en ACM (⚠️ región `us-east-1`)

CloudFront exige que el certificado exista en `us-east-1`, sin importar en
qué región esté el resto. Si usas la consola, **cambia de región arriba a
la derecha a "N. Virginia (us-east-1)"** antes de continuar.

### 🖱️ Por consola
1. Consola de AWS (región **us-east-1**) → **Certificate Manager** → **Request certificate** → **Request a public certificate**.
2. **Fully qualified domain name**: `tudominio.com`. **Add another name to this certificate** → `www.tudominio.com` (si lo quieres también).
3. **Validation method**: **DNS validation**.
4. **Request**.
5. Entra al certificado creado (estado *Pending validation*) → en la tabla de dominios, para cada uno pulsa **Create records in Route 53** → **Create records**. AWS crea automáticamente el CNAME de validación en tu hosted zone.
6. Espera unos minutos y recarga: el estado pasa a **Issued**.

### ⌨️ Por CLI
```bash
aws acm request-certificate \
  --domain-name tudominio.com \
  --subject-alternative-names www.tudominio.com \
  --validation-method DNS \
  --region us-east-1
```

Copia el `CertificateArn` de la respuesta. Consulta los registros CNAME de validación que pide:

```bash
aws acm describe-certificate \
  --certificate-arn TU-CERTIFICATE-ARN \
  --region us-east-1 \
  --query 'Certificate.DomainValidationOptions[].ResourceRecord'
```

Por cada entrada (`Name`, `Type`, `Value`), crea el registro en Route 53:

```bash
aws route53 change-resource-record-sets \
  --hosted-zone-id TU-HOSTED-ZONE-ID \
  --change-batch '{
    "Changes": [{
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "NOMBRE-DEL-CNAME",
        "Type": "CNAME",
        "TTL": 60,
        "ResourceRecords": [{"Value": "VALOR-DEL-CNAME"}]
      }
    }]
  }'
```

Espera a que valide (puede tardar varios minutos):

```bash
aws acm wait certificate-validated \
  --certificate-arn TU-CERTIFICATE-ARN \
  --region us-east-1
```

---

## 4️⃣ Crear el Origin Access Control (OAC)

Es lo que permite a CloudFront leer el bucket privado sin hacerlo público.

### 🖱️ Por consola
1. Consola de AWS → **CloudFront** → menú izquierdo **Origin access** → pestaña **Origin access control settings** → **Create control setting**.
2. **Name**: `tudominio-oac`. **Signing behavior**: *Sign requests (recommended)*. **Origin type**: *S3*.
3. **Create**.

(También puedes crearlo directamente al añadir el origin S3 al crear la distribución, en el paso 6 — la consola te lo ofrece ahí mismo.)

### ⌨️ Por CLI
```bash
aws cloudfront create-origin-access-control \
  --origin-access-control-config \
  Name=tudominio-oac,SigningProtocol=sigv4,SigningBehavior=always,OriginAccessControlOriginType=s3
```
Copia el `Id` del OAC de la respuesta.

---

## 5️⃣ Crear la Response Headers Policy (cabeceras de seguridad)

### 🖱️ Por consola
1. **CloudFront** → menú izquierdo **Policies** → pestaña **Response headers** → **Create response headers policy**.
2. **Name**: `tudominio-security-headers`.
3. En **Security headers**, activa y configura:
   - **Strict-Transport-Security**: Override ✔, Max-age `63072000`, Include subdomains ✔, Preload ✔.
   - **X-Content-Type-Options**: Override ✔ (nosniff).
   - **X-Frame-Options**: Override ✔, valor `DENY`.
   - **Referrer-Policy**: Override ✔, valor `strict-origin-when-cross-origin`.
   - **Content-Security-Policy**: Override ✔, valor:
     ```
     default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data:; connect-src 'self'; object-src 'none'; base-uri 'self'; frame-ancestors 'none'
     ```
4. **Create**.

### ⌨️ Por CLI
Crea un archivo `response-headers-policy.json`:
```json
{
  "Name": "tudominio-security-headers",
  "SecurityHeadersConfig": {
    "StrictTransportSecurity": {
      "Override": true,
      "IncludeSubdomains": true,
      "Preload": true,
      "AccessControlMaxAgeSec": 63072000
    },
    "ContentTypeOptions": { "Override": true },
    "FrameOptions": { "Override": true, "FrameOption": "DENY" },
    "ReferrerPolicy": { "Override": true, "ReferrerPolicy": "strict-origin-when-cross-origin" },
    "ContentSecurityPolicy": {
      "Override": true,
      "ContentSecurityPolicy": "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data:; connect-src 'self'; object-src 'none'; base-uri 'self'; frame-ancestors 'none'"
    }
  }
}
```
```bash
aws cloudfront create-response-headers-policy \
  --response-headers-policy-config file://response-headers-policy.json
```
Copia el `Id` de la policy creada.

---

## 6️⃣ Crear la distribución de CloudFront

### 🖱️ Por consola
1. **CloudFront** → **Distributions** → **Create distribution**.
2. **Origin domain**: selecciona tu bucket S3 (aparece en el desplegador).
3. **Origin access**: *Origin access control settings* → selecciona el OAC del paso 4 (o créalo aquí mismo). La consola te ofrecerá copiar la política de bucket necesaria — **cópiala y guárdala**, la aplicamos en el paso 7.
4. **Viewer protocol policy**: *Redirect HTTP to HTTPS*.
5. **Allowed HTTP methods**: *GET, HEAD*.
6. **Cache policy**: *CachingOptimized*.
7. **Compress objects automatically**: *Yes*.
8. **Response headers policy**: selecciona la del paso 5.
9. **Alternate domain name (CNAME)**: `tudominio.com` (y `www.tudominio.com` si aplica).
10. **Custom SSL certificate**: selecciona el certificado del paso 3.
11. **Security policy**: `TLSv1.2_2021`.
12. **Default root object**: `index.html`.
13. Baja hasta **Custom error responses** → **Create custom error response** dos veces:
    - HTTP error code `403` → Customize error response: Yes → Response page path `/index.html` → HTTP Response code `200`.
    - HTTP error code `404` → mismo `/index.html` → `200`.
14. **Create distribution**. Tarda varios minutos en desplegarse (estado pasa de *Deploying* a *Enabled*).
15. Copia el **Distribution ID** y el **Distribution domain name** (`dXXXXXXXXXXXXX.cloudfront.net`).

### ⌨️ Por CLI
Crea `distribution-config.json` (sustituye los `TU-...` por tus valores):
```json
{
  "CallerReference": "tudominio-manual-2026",
  "Aliases": { "Quantity": 1, "Items": ["tudominio.com"] },
  "DefaultRootObject": "index.html",
  "Origins": {
    "Quantity": 1,
    "Items": [
      {
        "Id": "s3-origin",
        "DomainName": "TU-BUCKET.s3.eu-west-1.amazonaws.com",
        "OriginAccessControlId": "TU-OAC-ID",
        "S3OriginConfig": { "OriginAccessIdentity": "" }
      }
    ]
  },
  "DefaultCacheBehavior": {
    "TargetOriginId": "s3-origin",
    "ViewerProtocolPolicy": "redirect-to-https",
    "AllowedMethods": {
      "Quantity": 2,
      "Items": ["GET", "HEAD"],
      "CachedMethods": { "Quantity": 2, "Items": ["GET", "HEAD"] }
    },
    "Compress": true,
    "CachePolicyId": "658327ea-f89d-4fab-a63d-7e88639e58f6",
    "ResponseHeadersPolicyId": "TU-RESPONSE-HEADERS-POLICY-ID"
  },
  "CustomErrorResponses": {
    "Quantity": 2,
    "Items": [
      { "ErrorCode": 403, "ResponsePagePath": "/index.html", "ResponseCode": "200", "ErrorCachingMinTTL": 10 },
      { "ErrorCode": 404, "ResponsePagePath": "/index.html", "ResponseCode": "200", "ErrorCachingMinTTL": 10 }
    ]
  },
  "Comment": "Sitio estatico Angular",
  "Enabled": true,
  "ViewerCertificate": {
    "ACMCertificateArn": "TU-CERTIFICATE-ARN",
    "SSLSupportMethod": "sni-only",
    "MinimumProtocolVersion": "TLSv1.2_2021"
  },
  "PriceClass": "PriceClass_100"
}
```
```bash
aws cloudfront create-distribution \
  --distribution-config file://distribution-config.json
```
Copia `Distribution.Id` y `Distribution.DomainName` de la respuesta.
Comprueba cuándo termina de desplegarse con:
```bash
aws cloudfront get-distribution --id TU-DISTRIBUTION-ID --query 'Distribution.Status'
```
(pasa de `InProgress` a `Deployed`).

---

## 7️⃣ Aplicar la política del bucket (solo CloudFront puede leerlo)

### 🖱️ Por consola
1. **S3** → tu bucket → pestaña **Permissions** → **Bucket policy** → **Edit**.
2. Pega la política (usa la que te ofreció la consola en el paso 6, o esta, sustituyendo los valores):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCloudFrontServicePrincipalReadOnly",
      "Effect": "Allow",
      "Principal": { "Service": "cloudfront.amazonaws.com" },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::TU-BUCKET/*",
      "Condition": {
        "StringEquals": { "AWS:SourceArn": "arn:aws:cloudfront::TU-ACCOUNT-ID:distribution/TU-DISTRIBUTION-ID" }
      }
    }
  ]
}
```
3. **Save changes**.

### ⌨️ Por CLI
Guarda el JSON de arriba como `bucket-policy.json` y aplícalo:
```bash
aws s3api put-bucket-policy \
  --bucket TU-BUCKET \
  --policy file://bucket-policy.json
```

Tu `Account ID` lo obtienes con:
```bash
aws sts get-caller-identity --query Account --output text
```

---

## 8️⃣ Apuntar el dominio a CloudFront (registro A alias)

### 🖱️ Por consola
1. **Route 53** → **Hosted zones** → tu dominio → **Create record**.
2. **Record name**: vacío (para el dominio raíz).
3. **Record type**: `A`.
4. Activa **Alias**. **Route traffic to** → *Alias to CloudFront distribution* → selecciona tu distribución.
5. **Create records**.
6. Repite para `www` si quieres ese subdominio también (Record name: `www`).

### ⌨️ Por CLI
```bash
aws route53 change-resource-record-sets \
  --hosted-zone-id TU-HOSTED-ZONE-ID \
  --change-batch '{
    "Changes": [{
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "tudominio.com",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "Z2FDTNDATAQYW2",
          "DNSName": "TU-DISTRIBUTION-DOMAIN-NAME.cloudfront.net",
          "EvaluateTargetHealth": false
        }
      }
    }]
  }'
```
> `Z2FDTNDATAQYW2` es el hosted zone ID fijo de CloudFront (siempre el mismo, para cualquier distribución).

---

## 9️⃣ Subir la app a S3

```bash
cd app
npm run build
aws s3 sync dist/app/browser s3://TU-BUCKET --delete
```

Cada vez que vuelvas a compilar y subir cambios, invalida la caché para
que CloudFront sirva la versión nueva:

```bash
aws cloudfront create-invalidation \
  --distribution-id TU-DISTRIBUTION-ID \
  --paths "/*"
```

---

## 🔟 Verificar

Visita `https://tudominio.com`. Si el DNS aún no ha propagado (puede
tardar hasta 48h desde el paso 2), prueba primero con la URL directa de
CloudFront: `https://TU-DISTRIBUTION-DOMAIN-NAME.cloudfront.net`.

---

## 🧹 Borrar todo (evitar costes)

En este orden (algunos recursos no se pueden borrar si otros dependen de ellos):

1. **Route 53**: borra los registros `A` que creaste (no borres los `NS`/`SOA` si vas a seguir usando la hosted zone).
2. **CloudFront**: la distribución primero hay que **Disable** (consola, o `aws cloudfront update-distribution` con `Enabled: false`), esperar a que despliegue el cambio, y luego **Delete** (consola, o `aws cloudfront delete-distribution --id TU-ID --if-match TU-ETAG`).
3. **S3**: vacía el bucket (**Empty**, o `aws s3 rm s3://TU-BUCKET --recursive`) y luego bórralo (**Delete bucket**, o `aws s3api delete-bucket --bucket TU-BUCKET`).
4. **ACM**: borra el certificado (consola, o `aws acm delete-certificate --certificate-arn TU-ARN --region us-east-1`).
5. **Route 53**: si ya no la necesitas, borra la hosted zone (consola, o `aws route53 delete-hosted-zone --id TU-HOSTED-ZONE-ID`). Recuerda que si tu dominio sigue con esos nameservers, dejará de resolver.
