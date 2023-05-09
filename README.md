## What is this?

This repo's purpose is to create a new docker image that combines the following projects:
* https://github.com/mikefarah/yq: a lightweight and portable command-line YAML processor
* https://github.com/devshawn/kafka-gitops: an Apache Kafka resources-as-code tool which allows you to automate the management of your Apache Kafka topics and ACLs from version controlled code. It allows you to define topics and services through the use of a desired state file, much like Terraform and other infrastructure-as-code tools.

## Why?

While `kafka-gitops` is a very powerful tool, daily used to manage about a 1000 kafka topics at SupplyStack, it lacks support to split the state file into different, smaller and more manageable files. This is where `yq` comes into the picture.

## Usage

This docker image could be used in a GitHub action, for example:

```
name: Kafka-GitOps
on: [push, pull_request]
jobs:
  Kafka-GitOps:
    runs-on: [ubuntu-20.04]

    container:
      image: ghcr.io/supplystack/kafka-gitops:latest
      
    env:
      KAFKA_BOOTSTRAP_SERVERS: b-1.example.com,b-2.example.com,b-3.example.com
      KAFKA_SASL_MECHANISM: SCRAM-SHA-512
      KAFKA_SECURITY_PROTOCOL: SASL_SSL    
      KAFKA_SASL_JAAS_USERNAME: kafka-gitops
      KAFKA_SASL_JAAS_PASSWORD: ${{ secrets.KAFKA_SASL_JAAS_PASSWORD }}

    steps:
      - uses: actions/checkout@v2
      
      - name: Merge all YAML files to state.yaml
        run: yq ea '. as $item ireduce ({}; . *+ $item )' $(find . -type f -name "*.yaml") > state.yaml
        
      - name: Kafka GitOps Plan
        run: kafka-gitops plan
        
      - name: Kafka GitOps Apply
        if: github.ref == 'refs/heads/master' && github.event_name == 'push'
        run: kafka-gitops apply
```

This would allow you to use kafka-gitops with different YAML files, combined into a single state.yaml at runtime.

## Example

### Sample folder structure

```
.
├── other
│   ├── customServiceAcls.yaml
│   ├── customUserAcls.yaml
│   ├── customUsers.yaml
│   └── settings.yaml
├── services
│   ├── dev
│   │   ├── foo.yaml
│   │   └── bar.yaml
│   ├── prod
│   │   ├── foo.yaml
│   │   └── bar.yaml
│   ├── qa
│   │   ├── < SNIP >
│   │   ├── foo.yaml
│   │   └── bar.yaml
│   └── staging
│       ├── < SNIP >
│       ├── foo.yaml
│       └── bar.yaml
└── topics
    ├── dev
    │   ├── foo.yaml
    │   └── bar.yaml
    ├── prod
    │   ├── foo.yaml
    │   └── bar.yaml
    ├── qa
    │   ├── foo.yaml
    │   └── bar.yaml
    └── staging
        ├── foo.yaml
        └── bar.yaml
```

### Individual YAML files
Each individual YAML file needs to repeat the relevant key to merge on. For example, the `topics/dev/foo.yaml` and `topics/dev/bar.yaml` would look like this:

foo.yaml:
```
topics:
  dev.foo:
    partitions: 2
    replication: 3
```

bar.yaml:
```
topics:
  dev.bar:
    partitions: 2
    replication: 3
```

### Future plans
A GitHub Action which is even simpler to use might one day exist. Feel free to contribute.



