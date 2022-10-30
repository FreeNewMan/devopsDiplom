# Дипломный практикум в Yandex.Cloud
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
     * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
     * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
     * [Создание тестового приложения](#создание-тестового-приложения)
     * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
- Следует использовать последнюю стабильную версию [Terraform](https://www.terraform.io/).

```
> terraform -v
Terraform v1.3.2
on linux_amd64
```

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя

![Сервисный аккаунт](/images/svc_acc.png)

3. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: [Terraform Cloud](https://app.terraform.io/)  
   б. Альтернативный вариант: S3 bucket в созданном ЯО аккаунте
4. Настройте [workspaces](https://www.terraform.io/docs/language/state/workspaces.html)  
   а. Рекомендуемый вариант: создайте два workspace: *stage* и *prod*. В случае выбора этого варианта все последующие шаги должны учитывать факт существования нескольких workspace.  

```
terraform workspace new stage
terraform workspace new prod

>  terraform workspace list
  default
* prod
  stage
```

   б. Альтернативный вариант: используйте один workspace, назвав его *stage*. Пожалуйста, не используйте workspace, создаваемый Terraform-ом по-умолчанию (*default*).
5. Создайте VPC с подсетями в разных зонах доступности.
6. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
7. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

**Репозиторий**
```
https://github.com/FreeNewMan/tfmdiplom.git
```

**Terraform cloud**

![Виртуальные машины](/images/tf-cloud.png)
![Виртуальные машины](/images/tf-cloud1.png)



**VMs**
![Виртуальные машины](/images/yc_vms.png)

---
### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать региональный мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.


**Установка c помощью Kubespay**

Клонируем репозиторий, устанавливаем зависимости, создаем шаблон настроек
```
git clone https://github.com/kubernetes-sigs/kubespray

sudo pip3 install -r requirements.txt

cp -rfp inventory/sample inventory/mycluster

```
Обновление Ansible inventory с помощью билдера 

```
declare -a IPS=(51.250.64.33 130.193.48.89 51.250.22.62)
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
```

Итоговый файл

```
#inventory/mycluster/hosts.yaml

all:
  hosts:
    cp1:
      ansible_host: 51.250.64.33
      ansible_user: devuser
    node1:
      ansible_host: 130.193.48.89
      ansible_user: devuser
    node2:
      ansible_host: 51.250.22.62
      ansible_user: devuser      
  children:
    kube_control_plane:
      hosts:
        cp1:
    kube_node:
      hosts:
        node1:
        node2:
    etcd:
      hosts:
        cp1:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
```

Редактируем файл inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml
Для доступа извне к мастер ноде
```
supplementary_addresses_in_ssl_keys: [51.250.64.33]

```

Установка кластера
```
ansible-playbook -i inventory/mycluster/hosts.yaml cluster.yml -b -v
```

Подключаемся к мастер ноде, запускаем код для возможности работы под обычным пользователем

```
{  mkdir -p $HOME/.kube
     sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
     sudo chown $(id -u):$(id -g) $HOME/.kube/config
 }
```

На локальной машине ставим kubectl и настраиваем .kube/config используя параметры подключения с мастер ноды  $HOME/.kube/config

```
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: <сертивикат>
    server: https://51.250.64.33:6443
  name: diplomcloud
contexts:
- context:
    cluster: diplomcloud
    namespace: diplom-stage
    user: diplomcloud-user
  name: diplomcloud
current-context: diplomcloud
kind: Config
preferences: {}
users:
- name: diplomcloud-user
  user:
    client-certificate-data: <Сертификат>
    client-key-data: <ключ>

```

**Итог**

```
> kubectl get pods --all-namespaces
NAMESPACE      NAME                                       READY   STATUS    RESTARTS        AGE
kube-system    calico-kube-controllers-7c4bb79c56-lbzw6   1/1     Running   1 (5d15h ago)   5d15h
kube-system    calico-node-rxkv5                          1/1     Running   1 (5d15h ago)   5d15h
kube-system    calico-node-x4f58                          1/1     Running   0               5d15h
kube-system    calico-node-zlkqw                          1/1     Running   1 (5d15h ago)   5d15h
kube-system    coredns-69dfc8446-52tvx                    1/1     Running   0               5d15h
kube-system    coredns-69dfc8446-pv85n                    1/1     Running   0               5d15h
kube-system    dns-autoscaler-5b9959d7fc-cs7rf            1/1     Running   0               5d15h
kube-system    kube-apiserver-cp1                         1/1     Running   0               5d15h
kube-system    kube-controller-manager-cp1                1/1     Running   2 (5d15h ago)   5d15h
kube-system    kube-proxy-9rl82                           1/1     Running   0               5d15h
kube-system    kube-proxy-d7jlb                           1/1     Running   0               5d15h
kube-system    kube-proxy-nrxzn                           1/1     Running   0               5d15h
kube-system    kube-scheduler-cp1                         1/1     Running   2 (5d15h ago)   5d15h
kube-system    nginx-proxy-node1                          1/1     Running   0               5d15h
kube-system    nginx-proxy-node2                          1/1     Running   0               5d15h
kube-system    nodelocaldns-7hpqn                         1/1     Running   0               5d15h
kube-system    nodelocaldns-8d7rr                         1/1     Running   0               5d15h
kube-system    nodelocaldns-dzbt6                         1/1     Running   0               5d15h
```


---
### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистр с собранным docker image. В качестве регистра может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.


**Репозиторий демо приложения**

```
https://github.com/FreeNewMan/demoapp.git
```

---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Рекомендуемый способ выполнения:
1. Воспользовать пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). При желании можете собрать все эти приложения отдельно.
2. Для организации конфигурации использовать [qbec](https://qbec.io/), основанный на [jsonnet](https://jsonnet.org/). Обратите внимание на имеющиеся функции для интеграции helm конфигов и [helm charts](https://helm.sh/)
3. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте в кластер [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры.

Альтернативный вариант:
1. Для организации конфигурации можно использовать [helm charts](https://helm.sh/)

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ к тестовому приложению.

---


**Деплой системы мониторинга с помощью пакета kube-prometheus**

```
git clone https://github.com/prometheus-operator/kube-prometheus.git
```

```
kubectl apply --server-side -f manifests/setup
kubectl wait \
	--for condition=Established \
	--all CustomResourceDefinition \
	--namespace=monitoring
kubectl apply -f manifests/
```

**Доступ снаружи кластера**
Создадим сервис типа NodePort и внесем изменения в networkPolicy для сервиса grafana:
[code/monitoring/grafana_nodeport/](code/monitoring/grafana_nodeport/)

```
#grafana-service.yaml

apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/component: grafana
    app.kubernetes.io/name: grafana
    app.kubernetes.io/part-of: kube-prometheus
    app.kubernetes.io/version: 9.1.7
  name: grafana-np
  namespace: monitoring
spec:
  type: NodePort
  ports:
  - name: http
    port: 3000
    targetPort: http
    nodePort: 30111
  selector:
    app.kubernetes.io/component: grafana
    app.kubernetes.io/name: grafana
    app.kubernetes.io/part-of: kube-prometheus
    
```

```
#grafana-networkPolicy.yaml

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  labels:
    app.kubernetes.io/component: grafana
    app.kubernetes.io/name: grafana
    app.kubernetes.io/part-of: kube-prometheus
    app.kubernetes.io/version: 9.1.7
  name: grafana
  namespace: monitoring
spec:
  egress:
  - {}
  ingress:
  - from:
    #- podSelector:
    #    matchLabels:
    #      app.kubernetes.io/name: prometheus
    ports:
    - port: 3000
      protocol: TCP
  podSelector:
    matchLabels:
      app.kubernetes.io/component: grafana
      app.kubernetes.io/name: grafana
      app.kubernetes.io/part-of: kube-prometheus
  policyTypes:
  - Egress
  - Ingress
```

После apply сервис доступен по адресу: 
http://51.250.64.33:30111/

admin/adm123

**Деплой приложения с помощью qbec**

[code/deploy/demoapp/](code/deploy/demoapp/)


```
qbec apply diplom-stage
```

Приложение доступно по адресу:
http://51.250.64.33:30585/

### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/) либо [gitlab ci](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/)


Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистр, а также деплой соответствующего Docker образа в кластер Kubernetes.



**Установка и настройка Jenkins**
Сервис доступен по адресу: 

http://51.250.95.125:8080/

admin/TGra6vWV

Создаем отдельные машины и разворачиваем jenkins с помощью Ansible

[code/CICD/jenkins/infrastructure/](code/CICD/jenkins/infrastructure/)


1. Создание пользователя для подключения и деплоя с Jenkins с ограниченными правами (все права на namespace diplom-stage) на мастер ноде kubernetes:

```
useradd usrdip && cd /home/usrdip

openssl genrsa -out usrdip.key 2048


openssl req -new -key usrdip.key \
-out usrdip.csr \
-subj "/CN=usrdip"

openssl x509 -req -in usrdip.csr \
-CA /etc/kubernetes/pki/ca.crt \
-CAkey /etc/kubernetes/pki/ca.key \
-CAcreateserial \
-out usrdip.crt -days 500


mkdir .certs && mv usrdip.crt usrdip.key .certs

chown -R usrdip: /home/usrdip/


kubectl config set-credentials usrdip \
--client-certificate=/home/usrdip/.certs/usrdip.crt \
--client-key=/home/usrdip/.certs/usrdip.key


kubectl config set-context usrdip-context \
--cluster=kubernetes --user=usrdip

```

Создадим роль в кластере и привяжем ее к пользователю:

```
#role.yml

apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: demoapp-deploy
  namespace: diplom-stage
rules:
  - apiGroups: ["*"]
    resources: ["*"]
    verbs: ["*"]
```

```
#role-bind.yml

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: usrdip
  namespace: diplom-stage
subjects:
- kind: User
  name: usrdip
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: demoapp-deploy
  apiGroup: rbac.authorization.k8s.io
```


2. На jenkins agent устанавливаем Kubectl и настраиваем ~/.kube/config под пользователем jenkins. 
   Сертификат и ключ грузим в папку  /home/jenkins/.certs/

```
apiVersion: v1
clusters:
- cluster:
   certificate-authority-data: <сертивифкат>
   server: https://51.250.64.33:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: k8usrdip
    namespace: diplom-stage
  name: usrdip-context
current-context: usrdip-context
kind: Config
preferences: {}
users:
- name: k8usrdip
  user:
    client-certificate: /home/jenkins/.certs/usrdip.crt
    client-key: /home/jenkins/.certs/usrdip.key
```

1. тестируем коннект с кластером
   
```
kubectl get po 
```

Настройка guthub-webhook (запуск pipline при push на git)
На сервере и агенте jenkins генерим ключи:
```
ssh-keygen -t rsa
```

В репозитории по пути https://github.com/FreeNewMan/demoapp/settings/keys добавляем сгенеренные  публичные ключи из id_rsa.pub


![Github webhook](/images/github-webhook.png)


Проверяем коннект из jenkins хостов:

```
ssh -T git@github.com
```

При ошибке, помогает выполнение команды
```
ssh-keyscan github.com >> ~/.ssh/known_hosts
```

В Jenkins настраиваем Credentials, доступ к Docker hub и Git репозиторию

При настройки pipline указываем репозиторий приложения (там же лежит jenkins файл и манифест для деплоя в кластер) и ставим отметку GitHub hook trigger for GITScm polling.


---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.


2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

---
