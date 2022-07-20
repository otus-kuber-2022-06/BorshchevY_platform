# BorshchevY_platform
BorshchevY Platform repository

### Установка `nginx ingress controller`

_Устанавливал не из репозитория в ДЗ_

```bash
helm upgrade --install ingress-nginx ingress-nginx \
     --repo https://kubernetes.github.io/ingress-nginx \
     --namespace nginx-ingress
```

### Установка `cert-manager`

`helm upgrade --install cert-manager jetstack/cert-manager --wait --namespace=cert-manager --version v1.8.2 --set installCRDs=true`


После установки `cert-manager` необходимо усстановить ресурс Issuer (`Issuer` или `ClusterIssuer`), который будем использовать для выпуска сертификатов.  
Создал ресурс типа `ClusterIssuer` c именем `letsencrypt-production`.
`kubectl apply -f cert-manager-issuer.yaml`
### Установка `chartmuseum`

```bash
helm repo add chartmuseum https://chartmuseum.github.io/charts
helm upgrade --install chartmuseum chartmuseum/chartmuseum --wait \
     --namespace=chartmuseum --version=3.9.0 -f chartmuseum/values.yaml
```
### chartmuseum (Задание со *)

в деплойменте `chartmuseum` установил переменную окружения `DISABLE_API` в `false`, так как по умолчанию она установлена в `true` и из-за этого все запросы к /api возвращают 404 код. 

```bash
helm plugin install https://github.com/chartmuseum/helm-push
helm repo add my-chartmuseum https://chartmuseum.yab.dev.tap.telekom.de/
helm cm-push sysdig-1.7.16.tgz my-chartmuseum
helm repo update
helm search repo my-chartmuseum
helm upgrade --install sysdig my-chartmuseum/sysdig --version=1.7.16
```

### Установка harbor 

В файле harbor/values.yaml установлены значения, требуемые в рамках ДЗ.  

```bash
kubectl create ns harbor
helm repo add harbor https://helm.goharbor.io
helm upgrade --install harbor harbor/harbor --version=1.9.3 \
     -n=harbor --wait -f harbor/values.yaml
```

### Используем helmfile (*)

Созданы все необходимые манифесты и структура каталогов.  
Установлен плагин для helm - helm-diff.
`helm plugin install https://github.com/databus23/helm-diff`

`helmfile -e dev apply` - устанавливаем пакеты в окружении `dev`

### Создание своего helm чарта

Устанавливаем сервис frontend в namespace hipster-shop  
`helm upgrade --install frontend kubernetes-templating/frontend --namespace hipster-shop`

```bash
helm delete frontend -n hipster-shop
helm dep update kubernetes-templating/hipster-shop
helm upgrade --install hipster-shop kubernetes-templating/hipster-shop --namespace hipster-shop --create-namespace
```

### Создаем свой helm chart. Задание со *

Добавить сервис redis как внешняя зависимость через файл `requirements.yaml`.  
Удалил релиз `hipster-shop`  
`helm uninstall hipster-shop --namespace hipster-shop`  
Из файла манифеста `all-hipster-shop.yaml` удалил блок описания сервиса `redis`.
Файл `values.yaml` содержит конфигурацию сервиса `redis`.  
Файл `requirements.yaml` содержит конфигурацию сервиса `redis`.  
Обновляем зависимости:  
`helm dep update kubernetes-templating/hipster-shop`
`helm upgrade --install hipster-shop kubernetes-templating/hipster-shop --namespace hipster-shop --create-namespace`

### Kustomize | Самостоятельное задание

Сервис - `recommendationservice`

Деплоймента отличаются суффиксом в имени - `prod` в случае `hipster-shop-prod`, а также добавляется аннотация `createdBy: kustomize`.  

Установка в разные окружения:  
в `dev`  
`kubectl apply -k kubernetes-templating/kustomize/overrides/hipster-shop/`
в `prod` (kustomize предварительно создаст неймспейс из манифеста `recommendationservice-prod-ns.yaml`)    
`kubectl apply -k kubernetes-templating/kustomize/overrides/hipster-shop-prod/`

