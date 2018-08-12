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
/usr/bin/echo -e "\tVariable LDAPschema - ${LDAPschema}" >> /proc/self/fd/1

if [ -z "${LDAPmaxsize}" ]
then
  LDAPmaxsize=1073741824
fi
## Registro STDOUT LDAPmaxsize.
/usr/bin/echo -e "\tVariable LDAPmaxsize - ${LDAPmaxsize}" >> /proc/self/fd/1

if [ -z "${LDAPdirectory}" ]
then
  LDAPdirectory="/ldap/var/openldap-data"
fi
## Registro STDOUT LDAPdirectory.
/usr/bin/echo -e "\tVariable LDAPdirectory - ${LDAPdirectory}" >> /proc/self/fd/1

if [ -z "${LDAPindex}" ]
then
  LDAPindex="objectClass\teq"
else
  LDAPindex=`/usr/bin/echo ${LDAPindex} | /usr/bin/sed 's/|/\t/g' | /usr/bin/sed 's/:/\nindex\t/g'`
fi
## Registro STDOUT LDAPindex.
/usr/bin/echo -e "\tVariable LDAPindex - ${LDAPindex}" >> /proc/self/fd/1

## Comprobacion de variables requeridas.
if [ -z "${LDAPsuffix}" ] || [ -z "${LDAProotdn}" ] || [ -z "${LDAProotpw}" ]
then
  /usr/bin/echo "Error, falta una de las variables requeridas de configuracion." >> /proc/self/fd/2
  /usr/bin/echo "Las variables requeridas son: LDAPsuffix, LDAProotdn, LDAProotpw." >> /proc/self/fd/2
  exit 1
fi
## Registro STDOUT variables requeridas.
/usr/bin/echo -e "\tVariable LDAPsuffix - ${LDAPsuffix}" >> /proc/self/fd/1
/usr/bin/echo -e "\tVariable LDAProotdn - ${LDAProotdn}" >> /proc/self/fd/1
/usr/bin/echo -e "\tVariable LDAProotpw - ${LDAProotpw}" >> /proc/self/fd/1

/usr/bin/echo "Comprobacion de variables de configuracion finalizadas." >> /proc/self/fd/1 
/usr/bin/echo "Aplicando cambios en fichero de configuracion." >> /proc/self/fd/1

## Creacion del fichero de configuracion con la especificacion de schema.
/usr/bin/echo "# Ficheros de schema." > /ldap/etc/openldap/slapd.conf
/usr/bin/echo -e "${LDAPschema}" >> /ldap/etc/openldap/slapd.conf
/usr/bin/echo ""  >> /ldap/etc/openldap/slapd.conf

## Sustitucion en el fichero slapd.conf.PRE de las variables inyectadas en el contendor.
/usr/bin/sed -e s/LDAPsuffix/${LDAPsuffix}/ \
             -e s/LDAProotdn/${LDAProotdn}/ \
             -e s/LDAProotpw/${LDAProotpw}/ \
             -e s/LDAPmaxsize/${LDAPmaxsize}/ \
             -e 's#LDAPdirectory#'${LDAPdirectory}'#' /ldap/scripts/slapd.conf.PRE >> /ldap/etc/openldap/slapd.conf

## Finalizacion del archivo con la definicion de indices.
/usr/bin/echo -e "index\t${LDAPindex}" >> /ldap/etc/openldap/slapd.conf

## Arranque del servidor OpenLDAP.
exec /ldap/libexec/slapd -f /ldap/etc/openldap/slapd.conf -h ldap:/// -d 0

