# Redis

**This is a fork of [stable/redis](https://github.com/kubernetes/charts/tree/master/stable/redis) version 0.10.1 which uses the official redis docker image.**

[Redis](http://redis.io/) is an advanced key-value cache and store. It is often referred to as a data structure server since keys can contain strings, hashes, lists, sets, sorted sets, bitmaps and hyperloglogs.

## TL;DR;

```bash
$ helm repo add kubes https://presslabs-kubes.github.io/charts/index.yaml
$ helm install kubes/redis
```

## Introduction

This chart bootstraps a [Redis](https://hub.docker.com/r/_/redis/) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.7+ with Beta APIs enabled
- PV provisioner support in the underlying infrastructure

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release kubes/redis
```

The command deploys Redis on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following tables lists the configurable parameters of the Redis chart and their default values.

| Parameter                  | Description                           | Default                                                   |
| -------------------------- | ------------------------------------- | --------------------------------------------------------- |
| `image`                    | Redis image                           | `docker.io/library/redis:{VERSION}`                       |
| `imagePullPolicy`          | Image pull policy                     | `IfNotPresent`                                            |
| `args`                     | Redis command-line args               | `[]`                                                      |
| `redisPassword`            | Redis password                        |                                                           |
| `redisConf`                | The default configuration to use      | `save 60 10000...`                                        |
| `persistence.enabled`      | Use a PVC to persist data             | `true`                                                    |
| `persistence.existingClaim`| Use an existing PVC to persist data   | `nil`                                                     |
| `persistence.storageClass` | Storage class of backing PVC          | `generic`                                                 |
| `persistence.accessMode`   | Use volume as ReadOnly or ReadWrite   | `ReadWriteOnce`                                           |
| `persistence.size`         | Size of data volume                   | `8Gi`                                                     |
| `resources`                | CPU/Memory resource requests/limits   | Memory: `256Mi`, CPU: `100m`                              |
| `metrics.enabled`          | Start a side-car prometheus exporter  | `false`                                                   |
| `metrics.image`            | Exporter image                        | `oliver006/redis_exporter:v0.11`                          |
| `metrics.imagePullPolicy`  | Exporter image pull policy            | `IfNotPresent`                                            |
| `metrics.resources`        | Exporter resource requests/limit      | Memory: `256Mi`, CPU: `100m`                              |
| `nodeSelector`             | Node labels for pod assignment        | {}                                                        |
| `tolerations`              | Toleration labels for pod assignment  | []                                                        |
| `networkPolicy.enabled`    | Enable NetworkPolicy                  | `false`                                                   |
| `networkPolicy.allowExternal` | Don't require client label for connections | `true`                                            |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install --name my-release \
  --set metrics.enabled=true \
    kubes/redis
```

## NetworkPolicy

To enable network policy for Redis, install
[a networking plugin that implements the Kubernetes NetworkPolicy spec](https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy#before-you-begin),
and set `networkPolicy.enabled` to `true`.

For Kubernetes v1.5 & v1.6, you must also turn on NetworkPolicy by setting
the DefaultDeny namespace annotation. Note: this will enforce policy for _all_ pods in the namespace:

    kubectl annotate namespace default "net.beta.kubernetes.io/network-policy={\"ingress\":{\"isolation\":\"DefaultDeny\"}}"

With NetworkPolicy enabled, only pods with the generated client label will be
able to connect to Redis. This label will be displayed in the output
after a successful install.

## Persistence

By default, the chart mounts a [Persistent Volume](http://kubernetes.io/docs/user-guide/persistent-volumes/) volume at `/data`. The volume is created using dynamic volume provisioning. If a Persistent Volume Claim already exists, specify it during installation.

### Existing PersistentVolumeClaim

1. Create the PersistentVolume
1. Create the PersistentVolumeClaim
1. Install the chart
```bash
$ helm install --set persistence.existingClaim=PVC_NAME redis
```

## Metrics
The chart optionally can start a metrics exporter for [prometheus](https://prometheus.io). The metrics endpoint (port 9121) is not exposed and it is expected that the metrics are collected from inside the k8s cluster using something similar as the described in the [example Prometheus scrape configuration](https://github.com/prometheus/prometheus/blob/master/documentation/examples/prometheus-kubernetes.yml).
