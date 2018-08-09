#!/usr/bin/bash

## Script de configuracion y arranque de servicio OpenLDAP.

## Variables de entorno para configurar el servicio:
##  REQUERIDAS
##   LDAPsuffix
##   LDAProotdn
##   LDAProotpw
##  OPCIONALES
##   LDAPschema - Formato de entrada: "RUTA_FICHERO1.schema|RUTA_FICHERO2.schema|..."
##   LDAPmaxsize
##   LDAPdirectory
##   LDAPindex - Formato de entrada: "NOMBRE|TipoIndice1,TipoIndice2,...:NOMBRE|TipoIndice1,TipoIndice2,...:..."

## Inicio de la ejecucion, registro en STDOUT.
/usr/bin/echo "Inicio de servicio OpenLDAP. Comprobacion de variables de configuracion." >> /proc/self/fd/1

## Valores por defecto para variables opcionales.
if [ -z "${LDAPschema}" ]
then
  LDAPschema="include /ldap/etc/openldap/schema/core.schema"
else
  LDAPschema=`/usr/bin/echo -e "include\t${LDAPschema}" | /usr/bin/sed 's/|/\ninclude\t/g'`
fi
## Registro STDOUT LDAPschema.
/usr/bin/echo "Variable LDAPschema - ${LDAPschema}" >> /proc/self/fd/1

if [ -z "${LDAPmaxsize}" ]
then
  LDAPmaxsize=1073741824
fi
## Registro STDOUT LDAPmaxsize.
/usr/bin/echo "Variable LDAPmaxsize - ${LDAPmaxsize}" >> /proc/self/fd/1

if [ -z "${LDAPdirectory}" ]
then
  LDAPdirectory="/ldap/var/openldap-data"
fi
## Registro STDOUT LDAPdirectory.
/usr/bin/echo "Variable LDAPdirectory - ${LDAPdirectory}" >> /proc/self/fd/1

if [ -z "${LDAPindex}" ]
then
  LDAPindex="objectClass\teq"
else
  LDAPindex=`/usr/bin/echo ${LDAPindex} | /usr/bin/sed 's/|/\t/g' | /usr/bin/sed 's/:/\nindex\t/g'`
fi
## Registro STDOUT LDAPindex.
/usr/bin/echo "Variable LDAPindex - ${LDAPindex}" >> /proc/self/fd/1

## Comprobacion de variables requeridas.
if [ -z "${LDAPsuffix}" ] || [ -z "${LDAProotdn}" ] || [ -z "${LDAProotpw}" ]
then
  /usr/bin/echo "Error, falta una de las variables requeridas de configuracion." >> /proc/self/fd/2
  /usr/bin/echo "Las variables requeridas son: LDAPsuffix, LDAProotdn, LDAProotpw." >> /proc/self/fd/2
  exit 1
fi
## Registro STDOUT variables requeridas.
/usr/bin/echo "Variable LDAPsuffix - ${LDAPsuffix}" >> /proc/self/fd/1
/usr/bin/echo "Variable LDAProotdn - ${LDAProotdn}" >> /proc/self/fd/1
/usr/bin/echo "Variable LDAProotpw - ${LDAProotpw}" >> /proc/self/fd/1

## Creacion del fichero de configuracion con la especificacion de schema.
/usr/bin/echo "# Ficheros de schema." > ./slapd.conf
/usr/bin/echo -e "${LDAPschema}" >> ./slapd.conf
/usr/bin/echo ""  >> ./slapd.conf

## Sustitucion en el fichero slapd.conf.PRE de las variables inyectadas en el contendor.
/usr/bin/sed -e s/LDAPsuffix/${LDAPsuffix}/ \
             -e s/LDAProotdn/${LDAProotdn}/ \
             -e s/LDAProotpw/${LDAProotpw}/ \
             -e s/LDAPmaxsize/${LDAPmaxsize}/ \
             -e 's#LDAPdirectory#'${LDAPdirectory}'#' ./slapd.conf.PRE >> ./slapd.conf

## Finalizacion del archivo con la definicion de indices.
/usr/bin/echo -e "index\t${LDAPindex}" >> ./slapd.conf

