#!/usr/bin/bash

## Script de configuracion y arranque de servicio OpenLDAP.

## Variables de entorno para configurar el servicio:
##  REQUERIDAS
##   LDAPsuffix
##   LDAProotdn
##   LDAProotpw
##   LDAPdirectory
##  OPCIONALES
##   LDAPschema
##   LDAPmaxsize
##   LDAPindex

## Comprobacion de variables requeridas.
if [ -z "${LDAPsuffix}" ] || [ -z "${LDAProotdn} ] || [ -z "${LDAProotpw}" ] || [ -z "${LDAPdirectory}" ]
then
  /bin/echo "Error, falta una de las variables requeridas de configuracion."
  /bin/echo "Las variables requeridas son: LDAPsuffix, LDAProotdn, LDAProotpw, LDAPdirectory."
  exit 1
fi


