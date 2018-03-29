# Triton Service Groups Infrastructure Management

This repository is the source of all of the pieces required to manage the TSG infrastructure for all of the data centers in SPC and JPC

TSG is made up of the following infrastructure:

* TSG Private network
* Bastion Node
* [Consul]() Server Cluster
* [Nomad]() Server Cluster
* Nomad Clients
* [Cockroach DB]() Cluster

## Requirements

In order to operate this infrastructure, the following environment variables are required:

* TRITON_ACCOUNT
* TRITON_KEY_ID
* TRITON_URL

This assumes that the private key associated with `TRITON_KEY_ID` is already added to your ssh-agent. If you need to do that,
you can do this as follows (on macOS):

```bash
ssh-add -K ~/.ssh/id_rsa
```

## Order of Operations

### Image Building with Packer

In order to start creating machines, there is a requirement that some pre-determined images are available in the specific environment
that you are interacting with. There are [Packer]() templates to roll out all of these images. These are all located in the `packer`
folder of this repository. 

We currently have the following packer templates: 

* TSG Base image
* Consul server
* Nomad server
* Nomad Client
* CockroachDB Server

To make life a little simple for the user, rather than interacting with packer directly, we have provided a Makefile that has all of
the correct targets for each of the configurations:

```bash
% make help
Usage: make <OPTIONS> ... <TARGETS>

Available targets are:

inspect-base                   Inspects the contents of the TSG Base template.
validate-base                  Validate the TSG Base template.
validate-consul                Validate the TSG Consul template.
validate-nomad-server          Validate the TSG Nomad Server template.
validate-nomad-client          Validate the TSG Nomad Client template.
validate-cockroach             Validate the TSG CockroachDB template.
base                           Build the TSG Base template.
consul                         Build the TSG Consul template.
nomad-server                   Build the TSG Nomad Server template.
nomad-client                   Build the TSG Nomad Client template.
cockroach                      Build the TSG CockroachDB template.
help                           Show this help screen.
```

As you can see, you can validate and build each of the template types. All of the infrastructure templates are based on
the `TSG Base` image.

In order to build that image, we should first validate that our environment is setup correctly:

```bash
% make validate-base
packer validate \
		-var "triton_account=stack72_joyent" \
		-var "triton_key_id=40:9d:d3:f9:0b:86:62:48:f4:2e:a5:8e:43:00:2a:9b" \
		-var "version="0.1.0"" \
		tsg-base.json
Template validated successfully.
```

As we can see that the validation was successful, we can now build the base image as it is the prerequisite for each of our images:

```bash
% make bash
packer build \
		-var "triton_account=stack72_joyent" \
		-var "triton_key_id=40:9d:d3:f9:0b:86:62:48:f4:2e:a5:8e:43:00:2a:9b" \
		-var "version="0.1.0"" \
		tsg-base.json
triton output will be in this color.

==> triton: Selecting an image based on search criteria
```

This image will take a few minutes to build, but when it is finished, we will see an output as follows:

```bash
==> Builds finished. The artifacts of successful builds are:
--> triton: Image was created: 8f899113-f7b2-426e-aeff-a381c49db1d5
```

This will then allow us to cycle through all of the other packer templates so we have base images in our environment.

Once all of the templates are made, then we can start to look at how the Terraform configurations are applied to that
specific environment



