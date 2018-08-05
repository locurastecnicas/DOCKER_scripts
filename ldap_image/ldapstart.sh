#!/usr/bin/bash

## Script de configuracion y arranque de servicio OpenLDAP.

## Variables de entorno para configurar el servicio:
##  REQUERIDAS
##   LDAPsuffix
##   LDAProotdn
##   LDAProotpw
##  OPCIONALES
##   LDAPschema
##   LDAPmaxsize
##   LDAPdirectory
##   LDAPindex

## Valores por defecto para variables opcionales.
if [ -z "${LDAPmaxsize}" ]
then
  LDAPmaxsize=1073741824
fi
if [ -z "${LDAPdirectory}" ]
then
  LDAPdirectory="/ldap/var/openldap-data"
fi

## Comprobacion de variables requeridas.
if [ -z "${LDAPsuffix}" ] || [ -z "${LDAProotdn}" ] || [ -z "${LDAProotpw}" ]
then
  /bin/echo "Error, falta una de las variables requeridas de configuracion."
  /bin/echo "Las variables requeridas son: LDAPsuffix, LDAProotdn, LDAProotpw."
  exit 1
fi

## Sustitucion en el fichero slapd.conf.PRE de las variables inyectadas en el contendor.
/usr/bin/sed -e s/LDAPsuffix/${LDAPsuffix}/ \
             -e s/LDAProotdn/${LDAProotdn}/ \
             -e s/LDAProotpw/${LDAProotpw}/ \
             -e s/LDAPmaxsize/${LDAPmaxsize}/ \
             -e 's#LDAPdirectory#'${LDAPdirectory}'#' ./slapd.conf.PRE
