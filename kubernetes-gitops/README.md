# BorshchevY_platform

В рамках ДЗ развернут кластер k8s в Yandex Cloud и установлены все необходимые инстурменты, требуемые в рамках ДЗ.
Подготовлен пайплайн (для Gitlab CI) для публикации образов. 
Пайплайн настроен на ручной запуск сборки микросервисов.
Пайплайн позволяет шаблонизировать сборки (заготовка репо шаблонов (пока только для билда образов) - https://gitlab.com/training-otus/pipelines/-/tree/main). 

### Обновление Helm chart

После изменения имени деплоймента на frontend-hipster в логах можно видеть события, вызванные коммитом [29e1a8ff] 
``` 
ts=2022-08-17T13:24:35.330188871Z caller=release.go:364 component=release release=frontend targetNamespace=microservices-demo resource=microservices-demo:helmrelease/frontend helmVersion=v3 info="upgrade succeeded" revision=29e1a8ffbd639f6138f8d47e30caa2a241703cd0 phase=upgrade
ts=2022-08-17T13:25:10.84121491Z caller=release.go:79 component=release release=frontend targetNamespace=microservices-demo resource=microservices-demo:helmrelease/frontend helmVersion=v3 info="starting sync run"
ts=2022-08-17T13:25:11.072277148Z caller=release.go:289 component=release release=frontend targetNamespace=microservices-demo resource=microservices-demo:helmrelease/frontend helmVersion=v3 info="running dry-run upgrade to compare with release version '5'" action=dry-run-compare
```
### Flugger и канареечный релиз

Вывод в процессе канареечного релиза:  
`kubectl get canaries -n microservices-demo`
```
NAME       STATUS        WEIGHT   LASTTRANSITIONTIME
frontend   Progressing   45       2022-08-23T07:53:20Z
```
Вывод после успешного окончания релиза и переключения на новую версию:
`kubectl get canaries -n microservices-demo`
```
NAME       STATUS      WEIGHT   LASTTRANSITIONTIME
frontend   Promoting   0        2022-08-23T07:53:50Z
```

`kubectl describe canary frontend -n microservices-demo`
<details><summary>Показать лог</summary>
Events:
  Type     Reason  Age                  From     Message
  ----     ------  ----                 ----     -------
  Normal   Synced  9m1s                 flagger  New revision detected! Scaling up frontend.microservices-demo
  Warning  Synced  8m31s                flagger  canary deployment frontend.microservices-demo not ready: waiting for rollout to finish: 0 of 1 (readyThreshold 100%) updated replicas are available
  Normal   Synced  8m1s                 flagger  Starting canary analysis for frontend.microservices-demo
  Normal   Synced  8m1s                 flagger  Advance frontend.microservices-demo canary weight 5
  Normal   Synced  7m31s                flagger  Advance frontend.microservices-demo canary weight 10
  Normal   Synced  7m1s                 flagger  Advance frontend.microservices-demo canary weight 15
  Normal   Synced  6m31s                flagger  Advance frontend.microservices-demo canary weight 20
  Normal   Synced  6m1s                 flagger  Advance frontend.microservices-demo canary weight 25
  Normal   Synced  5m31s                flagger  Advance frontend.microservices-demo canary weight 30
  Normal   Synced  5m1s                 flagger  Advance frontend.microservices-demo canary weight 35
  Warning  Synced  2m31s                flagger  frontend-primary.microservices-demo not ready: waiting for rollout to finish: 1 old replicas are pending termination
  Normal   Synced  91s (x6 over 4m31s)  flagger  (combined from similar events): Promotion completed! Scaling down frontend.microservices-demo
</details>