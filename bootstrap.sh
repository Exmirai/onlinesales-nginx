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
certBotDomainConcatenatedString=""

#Acquire SSL settings
if [[ -z "${DHPEMPATH}" ]]; then
    echo 'Warning: ${DHPEMPATH} not found. OnlineSales will generate dh.pem file using openssl package'
    openssl dhparam -out /etc/nginx/dh.pem 1024
    dmPemPath="etc/nginx/dh.pem"
else
    dmPemPath="${DHPEMPATH}"
fi

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
    break
else
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
certBotDomainConcatenatedString=$(echo "${certBotDomainConcatenatedString}${gatewayDomain},")
done

if [[ -z "${LETSENCRYPTPATH}" ]]; then
    #Check whether volume for /etc/liveencrypt was created so no need to retrieve certs
    if [ -n "$(ls -A /etc/letsencrypt/live 2>/dev/null)" ]; then
        letsEncryptPath="/etc/letsencrypt/live"
    else
        echo 'Warning: ${LETSENCRYPTPATH} not found and /etc/letsencrypt not found. OnlineSales will try to acquire certs using internal certbot'
        letsEncryptPath="/etc/letsencrypt/live"
        #Run certbot for acquire certificates
        #NOTE ${certBotDomainConcatenatedString%?} - %? strips latest ',' character from certBotDomainConcatenatedString variable
        certbot certonly --standalone --non-interactive --agree-tos -m boris@gmail.com --domains ${certBotDomainConcatenatedString%?}
    fi
else
    letsEncryptPath="${LETSENCRYPTPATH}"
fi

#Run nginx in foreground mode
nginx -g 'daemon off;'