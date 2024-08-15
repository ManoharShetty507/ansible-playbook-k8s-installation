# K8S Cert Manager

Installs the cert-manager Kubernetes add-on to handle SSL/TLS Certificate
requests from Let's Encrypt. This role is reponsible for only the cert-manager
installation. Individual certificates still need to be set with the
appropriate configurations. You can find more information on that [here](https://gitlab.triumf.ca/docs/kubernetes/blob/master/kubernetes-letsencrypt.md#create-certificates).

## Helm

This role uses 'helm' to do the initial install of cert-manager. The role will
try to use the helm binary located the path defined by the _helm\_path_
variable. If no helm binary is found at that path, the role will try to download
and install the version specified by the _helm\_ver_ value. If you want to avoid
having this role download an extra copy of helm if you have one already installed,
be sure to set the _helm\_path_ value to the correct location. Otherwise, a new
copy of the helm binary will wind up in the default _helm\_path_ (/usr/local/bin).

# Variables

## Required

No variables are required since this role mainly uses kubectl to
do all of its work due to limitations of the Kubernetes module for
Ansible. This means that a working $HOME/.kube/config that gives appropriate
access credentials is required for this role to work.

## Optional

* helm\_path: Directory path of the helm binary (default: /usr/local/bin).

* helm\_owner: If the helm binary gets downloaded and installed, the resulting
helm binary will be owned by helm\_owner (default: root).

* helm\_group: Like the _helm\_owner_ value, but for groups (default: root).

* helm\_ver: The version specified here will be downloaded if the helm binary
is missing (default: 2.7.2).

* issuer\_type: This is the type of Issuer to use for your issuer objects.
Your options are "Issuer" (w/o quotes) which is restricted to a single
namespace, or "ClusterIssuer" which is applied to the entire cluster. 

* kube\_config: Kube config file used by kubectl (defualt: $HOME/.kube/config).

# Testing

Due to the difficulty in spinning up a Kubernetes cluster to test this role
against, it's mostly manually tested, so your mileage may vary.