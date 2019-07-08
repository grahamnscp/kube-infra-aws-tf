#!/bin/bash

source ./params.sh

# sed -i has extra param in OSX
SEDBAK=""

UNAME_OUT="$(uname -s)"
case "${UNAME_OUT}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac
                SEDBAK=".bak"
                ;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    *)          MACHINE="UNKNOWN:${UNAME_OUT}"
esac
echo OS is ${MACHINE}




# Subsitute terraform variables to generate variables.tf
echo ">>> Generating Terraform variables.tf file from variables.template.."
cp variables.tf.template variables.tf

# Subsitiute tokens "##TOKEN_NAME##"
sed -i $SEDBAK "s/##TF_AWS_OWNER_TAG##/$TF_AWS_OWNER_TAG/" variables.tf
sed -i $SEDBAK "s/##TF_AWS_EXPIRATION_TAG##/$TF_AWS_EXPIRATION_TAG/" variables.tf
sed -i $SEDBAK "s/##TF_AWS_PURPOSE_TAG##/$TF_AWS_PURPOSE_TAG/" variables.tf
sed -i $SEDBAK "s/##TF_AWS_KEY_NAME##/$TF_AWS_KEY_NAME/" variables.tf
sed -i $SEDBAK "s/##TF_AWS_INSTANCE_PREFIX##/$TF_AWS_INSTANCE_PREFIX/" variables.tf
sed -i $SEDBAK "s/##TF_AWS_DOMAINNAME##/$TF_AWS_DOMAINNAME/" variables.tf
sed -i $SEDBAK "s/##TF_AWS_ROUTE53_ZONE_ID##/$TF_AWS_ROUTE53_ZONE_ID/" variables.tf
sed -i $SEDBAK "s/##TF_AWS_REGION##/$TF_AWS_REGION/" variables.tf
sed -i $SEDBAK "s/##TF_AWS_AVAILABILITY_ZONES##/$TF_AWS_AVAILABILITY_ZONES/" variables.tf
sed -i $SEDBAK "s/##TF_AWS_CENTOS_AMI##/$TF_AWS_CENTOS_AMI/" variables.tf
sed -i $SEDBAK "s/##TF_AWS_MASTER_COUNT##/$TF_AWS_MASTER_COUNT/" variables.tf
sed -i $SEDBAK "s/##TF_AWS_NODE_COUNT##/$TF_AWS_NODE_COUNT/" variables.tf
sed -i $SEDBAK "s/##TF_AWS_DOCKER_VOLUME_SIZE##/$TF_AWS_DOCKER_VOLUME_SIZE/" variables.tf
sed -i $SEDBAK "s/##TF_AWS_BOOTSTRAP_INSTANCE_TYPE##/$TF_AWS_BOOTSTRAP_INSTANCE_TYPE/" variables.tf
sed -i $SEDBAK "s/##TF_AWS_MASTER_INSTANCE_TYPE##/$TF_AWS_MASTER_INSTANCE_TYPE/" variables.tf
sed -i $SEDBAK "s/##TF_AWS_NODE_INSTANCE_TYPE##/$TF_AWS_NODE_INSTANCE_TYPE/" variables.tf

rm ./variables.tf.bak

exit 0

