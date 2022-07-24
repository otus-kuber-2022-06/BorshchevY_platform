# BorshchevY_platform
BorshchevY Platform repository

Созданы и задеплоены `CR` и `CRD`.

### Вопрос: почему объект создался, хотя мы создали CR, до того, как запустили контроллер?
Контроллер периодечески сравнивает текущее состояние ресурсов, за которыми он следит, с желаемым сосотоянием.
В случае несоответствия - пытается восстановить состояние наблюдаемых ресурсов в соответсвии с информацией, сохраненной в `etcd`

```bash
> kubectl get jobs
NAME                         COMPLETIONS   DURATION   AGE
backup-mysql-instance-job    1/1           7s         6m50s
restore-mysql-instance-job   1/1           49s        66s
```

```bash
> kubectl exec -it $Env:MYSQLPOD -- mysql -potuspassword -e "select * from test;" otus-database
mysql: [Warning] Using a password on the command line interface can be insecure.
+----+-------------+
| id | name        |
+----+-------------+
|  1 | some data   |
|  2 | some data-2 |
+----+-------------+
```