#!/bin/bash

source ./params.sh

TMP_FILE=/tmp/generate-inventory-yaml.tmp.$$

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


# Collect output variables
echo
echo ">>> Collecting variables from terraform output.."
terraform output > $TMP_FILE

# Some parsing into shell variables and arrays
DATA=`cat $TMP_FILE |sed "s/'//g"|sed 's/\ =\ /=/g'`
DATA2=`echo $DATA |sed 's/\ *\[/\[/g'|sed 's/\[\ */\[/g'|sed 's/\ *\]/\]/g'|sed 's/\,\ */\,/g'`

for var in `echo $DATA2`
do
  var_name=`echo $var | awk -F"=" '{print $1}'`
  var_value=`echo $var | awk -F"=" '{print $2}'|sed 's/\]//g'|sed 's/\[//g'`

  #echo LINE:$var_name: $var_value

  case $var_name in
    "region")
      REGION="$var_value"
      #echo REGION=$REGION
      ;;
    "domain_name")
      DOMAIN_NAME="$var_value"
      #echo DOMAIN_NAME=$DOMAIN_NAME
      ;;

    "route53-admin")
      ADMIN_LB_FQDN="$var_value"
      #echo ADMIN_LB_FQDN=$ADMIN_LB_FQDN
      ;;

    # Bootstrap:
    "route53-bootstrap")
      BOOTSTRAP_NAME="$var_value"
      #echo BOOTSTRAP_NAME=$BOOTSTRAP_NAME
      ;;

    "bootstrap-public-name")
      BOOTSTRAP_PUBLIC_NAME=$var_value
      #echo BOOTSTRAP_PUBLIC_NAME=$BOOTSTRAP_PUBLIC_NAME
      ;;
    "bootstrap-public-ip")
      BOOTSTRAP_PUBLIC_IP=$var_value
      #echo BOOTSTRAP_PUBLIC_IP=$BOOTSTRAP_PUBLIC_IP
      ;;

    # Master:
    "master-primary-public-name")
      MASTER_PRIMARY_PUBLIC_NAME=$var_value
      #echo MASTER_PRIMARY_PUBLIC_NAME=$MASTER_PRIMARY_PUBLIC_NAME
      ;;
    "master-primary-public-ip")
      MASTER_PRIMARY_PUBLIC_IP=$var_value
      #echo MASTER_PRIMARY_PUBLIC_IP=$MASTER_PRIMARY_PUBLIC_IP
      ;;
    "route53-masters")
      MASTERS=$var_value
      #echo MASTERS=$MASTERS
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        MASTER_NAME[$COUNT]=$entry
        #echo MASTER_NAME[$COUNT]=${MASTER_NAME[$COUNT]}
      done
      NUM_MASTERS=$COUNT
      ;;
    "master-public-names")
      MASTER_PUBLIC_NAMES="$var_value"
      #echo MASTER_PUBLIC_NAMES=$MASTER_PUBLIC_NAMES
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        MASTER_PUBLIC_NAME[$COUNT]=$entry
        #echo MASTER_PUBLIC_NAME[$COUNT]=${MASTER_PUBLIC_NAME[$COUNT]}
      done
      ;;
    "master-public-ips")
      MASTER_PUBLIC_IPS="$var_value"
      #echo MASTER_PUBLIC_IPS=$MASTER_PUBLIC_IPS
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        MASTER_PUBLIC_IP[$COUNT]=$entry
        #echo MASTER_PUBLIC_IP[$COUNT]=${MASTER_PUBLIC_IP[$COUNT]}
      done
      ;;
    "master-private-ips")
      MASTER_PRIVATE_IPS="$var_value"
      #echo MASTER_PRIVATE_IPS=$MASTER_PUBLIC_IPS
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        MASTER_PRIVATE_IP[$COUNT]=$entry
        #echo MASTER_PRIVATE_IP[$COUNT]=${MASTER_PRIVATE_IP[$COUNT]}
      done
      ;;

    # nodes:
    "route53-nodes")
      NODES="$var_value"
      #echo NODES=$NODES
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        NODE_NAME[$COUNT]=$entry
        #echo NODE_NAME[$COUNT]=${NODE_NAME[$COUNT]}
      done
      NUM_NODES=$COUNT
      ;;
    "node-public-names")
      NODES_PUBLIC_NAMES="$var_value"
      #echo NODE_PUBLIC_NAMES=$NODE_PUBLIC_NAMES
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        NODE_PUBLIC_NAME[$COUNT]=$entry
        #echo NODE_PUBLIC_NAME[$COUNT]=${NODE_PUBLIC_NAME[$COUNT]}
      done
      ;;
    "node-public-ips")
      NODE_PUBLIC_IPS="$var_value"
      #echo NODE_PUBLIC_IPS=$NODE_PUBLIC_IPS
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        NODE_PUBLIC_IP[$COUNT]=$entry
        #echo NODE_PUBLIC_IP[$COUNT]=${NODE_PUBLIC_IP[$COUNT]}
      done
      ;;
    "node-private-ips")
      NODE_PRIVATE_IPS="$var_value"
      #echo NODE_PRIVATE_IPS=$NODE_PRIVATE_IPS
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        NODE_PRIVATE_IP[$COUNT]=$entry
        #echo NODE_PRIVATE_IP[$COUNT]=${NODE_PRIVATE_IP[$COUNT]}
      done
      ;;

  esac
done

echo ">>> done."

# Parse Ansible inventory.template to generate the Ansible inventory.ini file
#
echo
echo ">>> Generating Ansible inventory.ini file from inventory.template.."
cp ./inventory.yaml.template inventory.yaml

# Subsitiute tokens "##TOKEN_NAME##"
sed -i $SEDBAK "s/##REGION##/$REGION/" ./inventory.yaml
sed -i $SEDBAK "s/##DOMAIN_NAME##/$DOMAIN_NAME/" ./inventory.yaml
sed -i $SEDBAK "s/##ADMIN_EXTERNAL_FQDN##/$ADMIN_LB_FQDN/g" ./inventory.yaml
sed -i $SEDBAK "s/##ADMIN_USERNAME##/$ADMIN_USERNAME/g" ./inventory.yaml
sed -i $SEDBAK "s/##ADMIN_PASSWORD##/$ADMIN_PASSWORD/g" ./inventory.yaml

for (( COUNT=1; COUNT<=$NUM_MASTERS; COUNT++ ))
do
  sed -i $SEDBAK "s/##MASTER_NAME_${COUNT}##/${MASTER_NAME[$COUNT]}/" ./inventory.yaml
  sed -i $SEDBAK "s/##MASTER_PUBLIC_NAME_${COUNT}##/${MASTER_PUBLIC_NAME[$COUNT]}/" ./inventory.yaml
  sed -i $SEDBAK "s/##MASTER_IP_${COUNT}##/${MASTER_PRIVATE_IP[$COUNT]}/" ./inventory.yaml
done

# Append variable number of nodes to ansible inventory.yaml file
for (( COUNT=1; COUNT<=$NUM_NODES; COUNT++ ))
do
  echo "    ${NODE_PRIVATE_IP[$COUNT]}:" >> ./inventory.yaml
  echo "      ansible_host: ${NODE_NAME[$COUNT]}" >> ./inventory.yaml
  echo "      node_pool: worker" >> ./inventory.yaml
done
echo "" >> ./inventory.yaml
echo ">>> done."

/bin/rm $TMP_FILE
rm ./inventory.yaml.bak
exit 0

