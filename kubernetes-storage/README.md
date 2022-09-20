# BorshchevY_platform
BorshchevY Platform repository

### Установка csi hostpath plugin
Для выполнения основного ДЗ, склонируем [репозиторий](https://github.com/kubernetes-csi/csi-driver-host-path)
Установку hostpath CSI driver выполним в соответствии с [мануалом](https://github.com/kubernetes-csi/csi-driver-host-path/blob/master/docs/deploy-1.17-and-later.md)

### Проверим, что все развернулось 
`kubectl get po csi-hostpathplugin-0 -o=jsonpath='{range .spec.containers[*]}{.name}{"\n"}{end}'`
```bash
hostpath
csi-external-health-monitor-controller
node-driver-registrar
liveness-probe
csi-attacher
csi-provisioner
csi-resizer
csi-snapshotter
```

### Proof of concept
Подготовим манифесты для `storagecalss`, `pvc` и `pod`-а.
#### Storage class
```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: csi-hostpath
provisioner: hostpath.csi.k8s.io
volumeBindingMode: Immediate
```
#### PVC
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-hostpath
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: csi-hostpath
```
#### POD
```yaml
kind: Pod
apiVersion: v1
metadata:
  name: csi-hostpath-test
spec:
  containers:
    - name: nginx
      image: nginx
      volumeMounts:
      - mountPath: "/data"
        name: csi-hostpath-volume
  volumes:
    - name: csi-hostpath-volume
      persistentVolumeClaim:
        claimName: pvc-hostpath
```
### Проверим, что объект `VolumeAttachment` создан
`kubectl describe volumeattachment csi-8d7cda66fe50425c8edb5a8e3bc7d13115fca227152a5482fa641b3cee4dee22`

```yaml
Name:         csi-8d7cda66fe50425c8edb5a8e3bc7d13115fca227152a5482fa641b3cee4dee22
Namespace:
Labels:       <none>
Annotations:  <none>
API Version:  storage.k8s.io/v1
Kind:         VolumeAttachment
Metadata:
  Creation Timestamp:  2022-09-20T13:57:19Z
  Managed Fields:
    API Version:  storage.k8s.io/v1
    Fields Type:  FieldsV1
    fieldsV1:
      f:status:
        f:attached:
    Manager:      csi-attacher
    Operation:    Update
    Time:         2022-09-20T13:57:19Z
    API Version:  storage.k8s.io/v1
    Fields Type:  FieldsV1
    fieldsV1:
      f:spec:
        f:attacher:
        f:nodeName:
        f:source:
          f:persistentVolumeName:
    Manager:         kube-controller-manager
    Operation:       Update
    Time:            2022-09-20T13:57:19Z
  Resource Version:  5302005
  UID:               26b332e3-d14c-4207-94bd-4223fdbcb358
Spec:
  Attacher:   hostpath.csi.k8s.io
  Node Name:  cl1eakbl630ovvp6sgp8-ekos
  Source:
    Persistent Volume Name:  pvc-13132568-4d40-4c8f-b9e9-50cf86e82d5c
Status:
  Attached:  true
Events:      <none>
```