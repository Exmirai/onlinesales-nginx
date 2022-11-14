#!/bin/sh

#ENVIRONMENT_VARIABLES:

#Construction gateways
#GATEWAYDOMAIN[1..N]
#GATEWATARGETHOST[1..N]
#GATEWAYTARGETPORT[1..N]

#SSL Settings
#LETSENCRYPTPATH
#DHPEMPATH

i=1

#Acquire SSL settings
if [[ -z "${LETSENCRYPTPATH}" ]]; then
    echo 'Error: Failed to construct nginx configuration files. ${LETSENCRYPTPATH} not found'
    exit
else
    letsEncryptPath="${LETSENCRYPTPATH}"
fi
if [[ -z "${DHPEMPATH}" ]]; then
    echo 'Error: Failed to construct nginx configuration files. ${DHPEMPATH} not found'
    exit
else
    dmPemPath="${DHPEMPATH}"
fi

echo $letsEncryptPath
echo $dmPemPath

#Setup SSL
sslTemplateFile=$(cat /etc/nginx/sslparams.template)
sslTemplateFile=$(echo "$sslTemplateFile" | sed "s~%dmpempath%~${dmPemPath}~g")

echo "$sslTemplateFile" > "/etc/nginx/ssl_params"
#Setup gateways
while true
do
 # Need to set GATEWAYDOMAIN[...] , GATEWAYTARGETHOST[...], GATEWAYTARGETPORT[...]
 # loop unit reach end of GATEWAYDOMAIN[1,2,3,4]
if [[ -z $(eval "echo \${GATEWAYDOMAIN_$i}") ]]; then
    echo "Not Found ${i} host"
    break
else
    echo "Found ${i} host"
    gatewayDomain=$(eval "echo \${GATEWAYDOMAIN_$i}")
fi
if [[ -z $(eval "echo \${GATEWAYTARGETHOST_$i}") ]]; then
    echo 'Error: Failed to construct nginx configuration files. GATEWAYTARGETHOST${i} not found'
    break
else
    gatewayTargetHost=$(eval "echo \${GATEWAYTARGETHOST_$i}")
fi
if [[ -z $(eval "echo \${GATEWAYTARGETPORT_$i}") ]]; then
    echo 'Error: Failed to construct nginx configuration files. GATEWAYTARGETPORT${i} not found'
    break
else
    gatewayTargetPort=$(eval "echo \${GATEWAYTARGETPORT_$i}")

fi
configTemplateFile=$(cat /etc/nginx/conf.d/gatewaytemplate.template)

configTemplateFile=$(echo "$configTemplateFile" | sed "s~%letsencryptpath%~${letsEncryptPath}~g")
configTemplateFile=$(echo "$configTemplateFile" | sed "s~%gatewaydomain%~${gatewayDomain}~g")
configTemplateFile=$(echo "$configTemplateFile" | sed "s~%gatewaytargethost%~${gatewayTargetHost}~g")
configTemplateFile=$(echo "$configTemplateFile" | sed "s~%gatewaytargetport%~${gatewayTargetPort}~g")

echo "$configTemplateFile" > "/etc/nginx/conf.d/${gatewayDomain}.conf"
i=$((i+1))
done

#Run nginx in foreground mode
nginx -g 'daemon off;'