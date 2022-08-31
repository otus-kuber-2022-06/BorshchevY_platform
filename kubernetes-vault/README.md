# BorshchevY_platform
BorshchevY Platform repository

## Инсталляция hashicorp vault HA в k8s
Consul был задеплоен в namespace `vault`
Vault был задеплоен в namespace `vault`

### Вывод helm status vault
```
NAME: vault
LAST DEPLOYED: Sat Aug 27 21:24:18 2022
NAMESPACE: vault
STATUS: deployed
REVISION: 1
NOTES:
Thank you for installing HashiCorp Vault!

Now that you have deployed Vault, you should look over the docs on using
Vault with Kubernetes available here:

https://www.vaultproject.io/docs/


Your release is named vault. To learn more about the release, try:

  $ helm status vault
  $ helm get manifest vault
```
### Инициализируем vault (вывод результатов)
```
key-threshold=1
Unseal Key 1: g0h8akeZ1DhK23r6F7Y177039M+JT9f9ztazxORq32U=

Initial Root Token: hvs.n5fUpW6FfO4QPNO4q6Et6ibV

Vault initialized with 1 key shares and a key threshold of 1. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 1 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated root key. Without at least 1 keys to
reconstruct the root key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.
```

### Добавьте выдачу vault status в README.md
```
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    1
Threshold       1
Version         1.11.2
Build Date      2022-07-29T09:48:47Z
Storage Type    consul
Cluster Name    vault-cluster-62ccaf26
Cluster ID      016566f8-3d8d-b69e-30d6-2d7c22fe4df3
HA Enabled      true
HA Cluster      https://vault-0.vault-internal:8201
HA Mode         active
Active Since    2022-08-27T18:55:08.25182925Z
```

### Залогинимся в vault
```
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                hvs.n5fUpW6FfO4QPNO4q6Et6ibV
token_accessor       skBJ034FupzdEhXnkbfOXUUY
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
```

### Повторно запросим список авторизаций
```
Path      Type     Accessor               Description
----      ----     --------               -----------
token/    token    auth_token_8d2aeec2    token based credentials
```
### Вывод команды чтения секрета
kubectl exec -it vault-0 -n vault -- vault read otus/otus-ro/config
```
Key                 Value
---                 -----
refresh_interval    768h
password            asajkjkahs
username            otus
```

kubectl exec -it vault-0 -n vault -- vault kv get otus/otus-rw/config
```
====== Data ======
Key         Value
---         -----
password    asajkjkahs
username    otus
```

### Обновленный список авторизаций после включения авторизации через k8s 
```
Path           Type          Accessor                    Description
----           ----          --------                    -----------
kubernetes/    kubernetes    auth_kubernetes_51071e58    n/a
token/         token         auth_token_8d2aeec2         token based credentials
```

### Что делает конструкция sed 's/\x1b\[[0-9;]*m//g'
Выражение `kubectl cluster-info | grep 'Kubernetes control plane' |  awk '/https/ {print $NF}'` выделяет  URL-адрес control plane кубернетеса. Но в выводе остаются цветовый коды, которые не дадут нам использовать полученный результат для присвоения значения переменной. Используя `sed`, мы на последнем этапе пайпа удаляем все цветовый коды из полученной строки.

### Почему мы смогли записать otus-rw/config1 но не смогли otus-rw/config
Потому что первоначальный вариант политики для otus-rw содержит только возможность `read`, `list` и `create` для key-value пар.
Для решения проблемы добавим в политику "verb" - `update`.


### Выдача при создании сертификата для домена test.example.ru
```
Key                 Value
---                 -----
ca_chain            [-----BEGIN CERTIFICATE-----
MIIDnDCCAoSgAwIBAgIUS2TqLqJnxY2g3RKFAEfwZCWqTcYwDQYJKoZIhvcNAQEL
BQAwFTETMBEGA1UEAxMKZXhtYXBsZS5ydTAeFw0yMjA4MzExMzIyNDhaFw0yNzA4
MzAxMzIzMThaMCwxKjAoBgNVBAMTIWV4YW1wbGUucnUgSW50ZXJtZWRpYXRlIEF1
dGhvcml0eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAK6GqSMkAQgp
l59v+kd73oX3lufUWmO/dHegBzitNqa5uohHjujcU5w5s+5zWtKC0ndTtfcj5+2u
UhAyVxR5AVMQOuRl/eO/N8gZ3FVCrCi9NWahWqIGfoZHLcM/iq3j9+HipNAADH7Y
+ah7car97XynyHClDQsJCsR5kj1MSlVDX+vB2Jp5EHDdEBvIiweHXzOUgsT3MVQd
AR0K6BOi5imwtqzUEP2XmZjVTFXLBm1kYeCQ0i/ZtsZnC0baZbmFOfcQFGmmYm34
u+7dIvHG8swsx8cUD7un1/XjT8vM0cbIHYoQuN7sUYna5OsqV0Jrdoq2vWCQ2J3v
rH69Cx+PwJECAwEAAaOBzDCByTAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUw
AwEB/zAdBgNVHQ4EFgQUkqZO41b/5luCvAMLpexqu8YrDYcwHwYDVR0jBBgwFoAU
Tfx/P7wn1m/c+hWeEh0otgrk+8QwNwYIKwYBBQUHAQEEKzApMCcGCCsGAQUFBzAC
hhtodHRwOi8vdmF1bHQ6ODIwMC92MS9wa2kvY2EwLQYDVR0fBCYwJDAioCCgHoYc
aHR0cDovL3ZhdWx0OjgyMDAvdjEvcGtpL2NybDANBgkqhkiG9w0BAQsFAAOCAQEA
frrTRw4Lrf5Cp0nTEOrgVLGObGhsKs034rL+FJutXa2TGJeFodqjsUM8ThoFQaIp
ufBBucLgtGOs39L0C76Ctd8MGe4X5SvrxR8IIJ3pwhzBmYNuWsnvU7FIIbr/MeWf
bphry1akzM8YAlZ9s22/RP9JfrBUINSTn2xiDlR+iJvYfwL/TDNn00hCDSh5Dwx7
UnRQVv+xM+eQ5BD7ed6fjK5JsJ80ChPi4WFrdYWfXjd00p2yEpJVjBlL9U353YjO
79340R1hRJyZ4z6sqfHOh8Jxnh43w2aOcLRfrjMxqj3izAaknX0CZAMXmtaUiFYl
BqycYkIKRqjGFsYnhD3mxA==
-----END CERTIFICATE----- -----BEGIN CERTIFICATE-----
MIIDMjCCAhqgAwIBAgIUen61vgW/Nlsxjag9N9x8mHrp7nIwDQYJKoZIhvcNAQEL
BQAwFTETMBEGA1UEAxMKZXhtYXBsZS5ydTAeFw0yMjA4MzExMzEzMzFaFw0zMjA4
MjgxMzE0MDFaMBUxEzARBgNVBAMTCmV4bWFwbGUucnUwggEiMA0GCSqGSIb3DQEB
AQUAA4IBDwAwggEKAoIBAQC3/EwX1dNGwEPpvezkTr6IqO4Zs2YwJN+Ak6LjSrlP
NfNnbe6AoBueVnVXl+7VLHvCMy5sjpmgXqU0Dy2UjmCfxr70+TAeH9MyuqabMmwG
i0rgDmjiEoxk0WQvZY4VRFssKCzGzO5O2fsKOODqXTpuiSCKl7IUebtbpv3eQgfW
cTzLgqcww849XzCiuHcsqFXWpl3fMlGTGGW6luY5HtUG0+LpxKOEz2ljQKwaWg7O
hIhx264/N7CIFke7LBEmmE7FN+2svMxvxZlPejz3NbjC4uVLX31VBfzCkXH2JZiv
t0CEh8Vm28n4w+7OjOK2N3nx5MTFEt/4IxFFfgfHOTcDAgMBAAGjejB4MA4GA1Ud
DwEB/wQEAwIBBjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBRN/H8/vCfWb9z6
FZ4SHSi2CuT7xDAfBgNVHSMEGDAWgBRN/H8/vCfWb9z6FZ4SHSi2CuT7xDAVBgNV
HREEDjAMggpleG1hcGxlLnJ1MA0GCSqGSIb3DQEBCwUAA4IBAQBcY8B8lzcsUsTa
OAUuYJxIyv2RO7thyfh15c4OQdGzZPSsUVDrvLBDChrxMVSGWXa9IrRlFADZyE/z
RipNwcmpbpERK27i5CaHbnolqt6BOKM76Dl3Lc7o0cJNnjpZ3ELPwkutH8P+rBgh
a5Xyyb71Xc3qzWF+2it48kYYSmSw1+BoK2PTFNO7v4Vsqyp+FfQCj5HjnoraXDjx
te0OzV7H8loXRg8w4Mx89gs8TLVkZlfLf7iVlkz35AosOr6zII7BcCe+skBWODiS
BSI4Cy26jcxEgVGfi2NP9H6xZHmg+YmeOIVwOXhn4USCYYH2HObYk2PVbRoiY5yK
yU3VMp8r
-----END CERTIFICATE-----]
certificate         -----BEGIN CERTIFICATE-----
MIIDYzCCAkugAwIBAgIUenissZ8Pj6Gs7cm/GcgGsRiJWbowDQYJKoZIhvcNAQEL
BQAwLDEqMCgGA1UEAxMhZXhhbXBsZS5ydSBJbnRlcm1lZGlhdGUgQXV0aG9yaXR5
MB4XDTIyMDgzMTEzNDgwOFoXDTIyMDkwMTEzNDgzOFowGjEYMBYGA1UEAxMPdGVz
dC5leGFtcGxlLnJ1MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvbUX
G0OQB/Ode73MIv5wntw1cGUm5rqO1ovGuMmuLOU/f8ezXcOX3auL4ZGc5DDDQUTi
LUzUGc3fuua7RGgH9XgiG3vKa9DOYYUd31qbxHWGkJA7JshaRgMk6XKNbmxTt+AX
3PEIj8cmqRSjL7eD1LCGq6j+0/qPMg6E1eVC7sgBs9yMjCSyWECy2aWW4UkeNNJQ
VZY8JSrYDqUROpjxWqViIvtV8NJgV8anRv5DhPPkuKJaHJ6AvQgnMddYzvhyMpO/
svO+ixufUDOkdTi7IqUUeSrG0hXB1oKELIz1bGOMN4kwyWm0RNHTCnQtHtMLu0kj
BwMstNodGbWwuzdPXwIDAQABo4GOMIGLMA4GA1UdDwEB/wQEAwIDqDAdBgNVHSUE
FjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwHQYDVR0OBBYEFHrd2DqCuiKw9egufpOt
ecV7uP4LMB8GA1UdIwQYMBaAFJKmTuNW/+ZbgrwDC6XsarvGKw2HMBoGA1UdEQQT
MBGCD3Rlc3QuZXhhbXBsZS5ydTANBgkqhkiG9w0BAQsFAAOCAQEADdx9GM6/EaZ9
mq/w5zW1Cyh9pRrpeAJehfTvIPRBdDzRrSO9VnKBnyq18V/gTOxA57LZdRtCHuYD
hnh4LJPfKGrqczOuoTmXXU8ahWqYaiELttis/UAaZfKfnqWemzJXRo+rF1yza8sa
DBPWN7aDkaOiu1PsCad/19rA9utzFeal1N4qkjBNBGOK+VKGKf5Wbg5zf7rvLPyO
+IuJpy+hFLKbs/0kJnvUwqINlKjE0MADZcCGkC4zSTiRYkcsB+tvti/77QAvfmJ3
WdWWLiILyZEmbtR2R4Vl1gDq3HcLKQwRU/CtiX28DR15Q7CdP46OdS2zQMGBa689
kwETXCmcZg==
-----END CERTIFICATE-----
expiration          1662040118
issuing_ca          -----BEGIN CERTIFICATE-----
MIIDnDCCAoSgAwIBAgIUS2TqLqJnxY2g3RKFAEfwZCWqTcYwDQYJKoZIhvcNAQEL
BQAwFTETMBEGA1UEAxMKZXhtYXBsZS5ydTAeFw0yMjA4MzExMzIyNDhaFw0yNzA4
MzAxMzIzMThaMCwxKjAoBgNVBAMTIWV4YW1wbGUucnUgSW50ZXJtZWRpYXRlIEF1
dGhvcml0eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAK6GqSMkAQgp
l59v+kd73oX3lufUWmO/dHegBzitNqa5uohHjujcU5w5s+5zWtKC0ndTtfcj5+2u
UhAyVxR5AVMQOuRl/eO/N8gZ3FVCrCi9NWahWqIGfoZHLcM/iq3j9+HipNAADH7Y
+ah7car97XynyHClDQsJCsR5kj1MSlVDX+vB2Jp5EHDdEBvIiweHXzOUgsT3MVQd
AR0K6BOi5imwtqzUEP2XmZjVTFXLBm1kYeCQ0i/ZtsZnC0baZbmFOfcQFGmmYm34
u+7dIvHG8swsx8cUD7un1/XjT8vM0cbIHYoQuN7sUYna5OsqV0Jrdoq2vWCQ2J3v
rH69Cx+PwJECAwEAAaOBzDCByTAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUw
AwEB/zAdBgNVHQ4EFgQUkqZO41b/5luCvAMLpexqu8YrDYcwHwYDVR0jBBgwFoAU
Tfx/P7wn1m/c+hWeEh0otgrk+8QwNwYIKwYBBQUHAQEEKzApMCcGCCsGAQUFBzAC
hhtodHRwOi8vdmF1bHQ6ODIwMC92MS9wa2kvY2EwLQYDVR0fBCYwJDAioCCgHoYc
aHR0cDovL3ZhdWx0OjgyMDAvdjEvcGtpL2NybDANBgkqhkiG9w0BAQsFAAOCAQEA
frrTRw4Lrf5Cp0nTEOrgVLGObGhsKs034rL+FJutXa2TGJeFodqjsUM8ThoFQaIp
ufBBucLgtGOs39L0C76Ctd8MGe4X5SvrxR8IIJ3pwhzBmYNuWsnvU7FIIbr/MeWf
bphry1akzM8YAlZ9s22/RP9JfrBUINSTn2xiDlR+iJvYfwL/TDNn00hCDSh5Dwx7
UnRQVv+xM+eQ5BD7ed6fjK5JsJ80ChPi4WFrdYWfXjd00p2yEpJVjBlL9U353YjO
79340R1hRJyZ4z6sqfHOh8Jxnh43w2aOcLRfrjMxqj3izAaknX0CZAMXmtaUiFYl
BqycYkIKRqjGFsYnhD3mxA==
-----END CERTIFICATE-----
private_key         -----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAvbUXG0OQB/Ode73MIv5wntw1cGUm5rqO1ovGuMmuLOU/f8ez
XcOX3auL4ZGc5DDDQUTiLUzUGc3fuua7RGgH9XgiG3vKa9DOYYUd31qbxHWGkJA7
JshaRgMk6XKNbmxTt+AX3PEIj8cmqRSjL7eD1LCGq6j+0/qPMg6E1eVC7sgBs9yM
jCSyWECy2aWW4UkeNNJQVZY8JSrYDqUROpjxWqViIvtV8NJgV8anRv5DhPPkuKJa
HJ6AvQgnMddYzvhyMpO/svO+ixufUDOkdTi7IqUUeSrG0hXB1oKELIz1bGOMN4kw
yWm0RNHTCnQtHtMLu0kjBwMstNodGbWwuzdPXwIDAQABAoIBAC8kd0+BJKO1OGdt
rPLtQ9NWabk6icZAigpqxcFZ7PyfI35/g+VDG9QsMyCk7NYQABWSJpqXQwX+kSCD
Afpn18J6Tg+CXbUZOJAnYlsEyzyw7/WwweJLW5OWaG/S1a6hINTKzWNMSpJgLQ1L
YZoUAqCyFWVHI7xNwZPw47W7uTxY7bZQbU715gNwyLY9sXfaQfe14tHEI/KHIt6o
x/u4ROUcFk0XYqODUKUYj1fDmo18hsiNASmjObCfrvPmxNeYMO+B6nAWMW0933LQ
jlyAohf573iujTKdyFauaF9s5MDitM5q4tIwl35fahALlBE8QkxiPhxWXRlbqeI3
+mBWXoECgYEA7Hvpqa8txBMkKT6RowI1UT9R0dedskUCm2+J9t08mgZ7LDbGnZOK
aRl2aT+AgQkTEiwBkAc3GrufFEGwraOQsbRsZ2SZ4blsiSgDf/pOh5CzBZHGE11f
nacwEEP3AGT54XjMZLzDYXDT3QMqDgei8kzss0nn9a36S0+56x47WaECgYEAzVzy
/Ia2Bv2b2/UUJVSg5buQXKuShtDMYmG+ig5iZiVWlDfh2o4K0PoS7mRAAqnKz8QO
gz5ckBp59n5BYRiGtcbzaP/nNzZcDD5B6v6n873FDDDE91f+PsYueJhuJ11fdFbv
FBan/qc9zgw7H6zT7imI4dF4gB/rHh9XBvfMCP8CgYEAtl18PMF9roYATdoVXzp1
uVj2FLeMwYvcTdd+8iN7919mHxuCoMPFafUbzmANDfTcgxfygIo/4Vqse2eJAu5u
x8tWCYmX7W0bmM2FnWx+oKZil7npoMdR0/a45uIymVhFJq4MGOdEWGE00Gv/Q2B6
NRZDNqOYwGnQ6cDqo7jlleECgYAH//vzPGgw44ZDzktHnQFbka/w/DoMCGw91OLw
S9knc4Lo6ThiJDBlrag5IyyfLfAZoeCS2kYO0wk3QfnYB3WP9T0cNQPT0clKLM6y
kdMHGrhnXir+G65q0ZuT1RRNckS6qnxLwwouUGOG+FEBTeE/oNyVN2zDSPsGxF/G
hLatDwKBgCnBgxJ2TO39q6hOr90EmPEYKJyv6kNwVdMvVGHL2UKSRb+iJ4c3JMfo
zbLcEab6Eq38KQlSpzFvOOLojQ+eumWosY8G+a8A3iawfbVIrA7wIAtrBdvmHAui
7434e9z10bg+V/GgTNZfZ8qkYRA88ijS66ZkEMfSM4pNLqPVIqtp
-----END RSA PRIVATE KEY-----
private_key_type    rsa
serial_number       7a:78:ac:b1:9f:0f:8f:a1:ac:ed:c9:bf:19:c8:06:b1:18:89:59:ba
```