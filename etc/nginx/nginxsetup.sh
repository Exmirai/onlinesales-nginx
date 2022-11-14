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
    letsEncryptPath=${LETSENCRYPTPATH}
else
    echo 'Error: Failed to construct nginx configuration files. ${LETSENCRYPTPATH} not found'
    break
fi
if [[ -z "${DHPEMPATH}" ]]; then
    dmPemPath=${DHPEMPATH}
else
    echo 'Error: Failed to construct nginx configuration files. ${DHPEMPATH} not found'
    break
fi


#Setup gateways
while true
 # Need to set GATEWAYDOMAIN[...] , GATEWAYTARGETHOST[...], GATEWAYTARGETPORT[...]

 # loop unit reach end of GATEWAYDOMAIN[1,2,3,4]
if [[ -z "${GATEWAYDOMAIN}${i}" ]]; then
    gatewayDomain=${GATEWAYDOMAIN}${i}
else
    break
fi
if [[ -z "${GATEWAYTARGETHOST}${i}" ]]; then
    gatewayTargetHost=${GATEWAYTARGETHOST}${i}
else
    echo 'Error: Failed to construct nginx configuration files. ${GATEWAYTARGETHOST}${i} not found'
    break
fi
if [[ -z "${GATEWAYTARGETPORT}${i}" ]]; then
    gatewayTargetPort=${GATEWAYTARGETPORT}${i}
else
    echo 'Error: Failed to construct nginx configuration files. ${GATEWAYTARGETPORT}${i} not found'
    break
fi
configTemplateFile=`cat /etc/nginx/conf.d/gatewayTemplate.template`

configTemplateFile="${configTemplateFile/%letsencryptpath%}"$letsEncryptPath""
configTemplateFile="${configTemplateFile//%gatewaydomain%}"$gatewayDomain""
configTemplateFile="${configTemplateFile//%gatewaytargethost%}"$gatewayTargetHost""
configTemplateFile="${configTemplateFile//%gatewaytargetport%}"$gatewayTargetPort""
$ echo "$configTemplateFile" > "/etc/nginx/conf.d/${gatewayDomain}.conf"
done

#Setup SSL
sslTemplateFile="cat /etc/nginx/sslparams.template"
sslTemplateFile="${sslTemplateFile/%dmpempath%}"$dmPemPath""
