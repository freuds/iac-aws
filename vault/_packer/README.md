# How to build new Bastion Image

## Prerequisites

Virtualbox: ```>= 6.1.0```

Packer: ```>= 1.6.0```

## Test image  build process locally first

```
./_packer.sh -local
```

## Build a new Bastion AMI

```
./_packer.sh
```

**Note:**
You need to be authenticated to Phenix's QA AWS Account so as to be able to build a new AMI. 