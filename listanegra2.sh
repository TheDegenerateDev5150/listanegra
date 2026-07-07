#!/bin/bash

# Script de consulta Spamhaus para Bash 1.0.x
# Lee listas negras desde listas.txt
# Lee IPs desde ip.txt
# Uso: sh listanegra.sh
# Ejemplo: sh listanegra.sh

# Variables
INPUT_DNS="dns.txt"
INPUT_LISTAS="listas.txt"
INPUT_IPS="ip.txt"
OUTPUT_FILE="resultado.txt"
CACHE_FILE="/tmp/cache_spamhaus.txt"

# Contadores globales
TOTAL_IPS=0
TOTAL_LISTAS=0
TOTAL_LISTADAS=0
TOTAL_LIMPIAS=0
TOTAL_ERRORES=0

# Verificar que existe el archivo de DNS
if [ ! -f "$INPUT_DNS" ]; then
  echo "ERROR: No se encuentra el archivo $INPUT_DNS"
  echo "Crea un archivo con un servidor DNS por línea"
  exit 1
fi

# Verificar que existe el archivo de listas negras
if [ ! -f "$INPUT_LISTAS" ]; then
  echo "ERROR: No se encuentra el archivo $INPUT_LISTAS"
  echo "Crea un archivo con el formato: nombre|dominio|descripcion"
  echo "Ejemplo: SBL|sbl.spamhaus.org|Spamhaus Blocklist"
  exit 1
fi

# Verificar que existe el archivo de IPs
if [ ! -f "$INPUT_IPS" ]; then
  echo "ERROR: No se encuentra el archivo $INPUT_IPS"
  echo "Crea un archivo con una IP por línea"
  echo "Ejemplo:"
  echo "  1.1.1.1"
  echo "  8.8.8.8"
  exit 1
fi

# Crear directorio de caché si no existe
CACHE_DIR=`echo "$CACHE_FILE" | sed 's/\/[^/]*$//'`
if [ ! -d "$CACHE_DIR" ]; then
  mkdir -p "$CACHE_DIR"
fi

# Vaciar archivo de resultados anterior
> "$OUTPUT_FILE"

# Contar servidores DNS disponibles
TOTAL_DNS=`grep -v '^$' "$INPUT_DNS" | wc -l`
if [ "x$TOTAL_DNS" = "x" ] || [ $TOTAL_DNS -eq 0 ]; then
  echo "ERROR: No hay servidores DNS válidos en $INPUT_DNS"
  exit 1
fi

# Contar total de listas
TOTAL_LISTAS=`grep -v '^$' "$INPUT_LISTAS" | wc -l`
if [ "x$TOTAL_LISTAS" = "x" ] || [ $TOTAL_LISTAS -eq 0 ]; then
  echo "ERROR: No hay listas definidas en $INPUT_LISTAS"
  exit 1
fi

# Contar total de IPs
TOTAL_IPS=`grep -v '^$' "$INPUT_IPS" | wc -l`
if [ "x$TOTAL_IPS" = "x" ] || [ $TOTAL_IPS -eq 0 ]; then
  echo "ERROR: No hay IPs definidas en $INPUT_IPS"
  exit 1
fi

# Cabecera en pantalla y archivo
echo "============================================================"
echo "   SCRIPT DE CONSULTA SPAMHAUS (Bash 1.0.x)"
echo "   Consulta múltiples IPs contra listas negras"
echo "============================================================"
echo "Archivo de DNS:    $INPUT_DNS"
echo "Archivo de listas: $INPUT_LISTAS"
echo "Archivo de IPs:    $INPUT_IPS"
echo "Archivo de salida: $OUTPUT_FILE"
echo "Total de IPs a consultar: $TOTAL_IPS"
echo "Total de listas a consultar: $TOTAL_LISTAS"
echo "============================================================"
echo ""

# Mostrar listas cargadas
echo "Listas cargadas:"
grep -v '^$' "$INPUT_LISTAS" | while IFS='|' read NOMBRE DOMINIO DESCRIPCION; do
  echo "  - $NOMBRE ($DOMINIO)"
done
echo "============================================================"
echo ""

# Mostrar IPs a consultar
echo "IPs a consultar:"
grep -v '^$' "$INPUT_IPS" | while read IP; do
  echo "  - $IP"
done
echo "============================================================"
echo ""

# Escribir cabecera en el archivo de resultados
echo "============================================================" >> "$OUTPUT_FILE"
echo "   SCRIPT DE CONSULTA SPAMHAUS (Bash 1.0.x)" >> "$OUTPUT_FILE"
echo "   Consulta múltiples IPs contra listas negras" >> "$OUTPUT_FILE"
echo "   Fecha: `date`" >> "$OUTPUT_FILE"
echo "============================================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Escribir listas usadas en el archivo
echo "Listas consultadas:" >> "$OUTPUT_FILE"
grep -v '^$' "$INPUT_LISTAS" | while IFS='|' read NOMBRE DOMINIO DESCRIPCION; do
  echo "  - $NOMBRE ($DOMINIO) $DESCRIPCION" >> "$OUTPUT_FILE"
done
echo "" >> "$OUTPUT_FILE"

# Escribir IPs consultadas en el archivo
echo "IPs consultadas:" >> "$OUTPUT_FILE"
grep -v '^$' "$INPUT_IPS" | while read IP; do
  echo "  - $IP" >> "$OUTPUT_FILE"
done
echo "" >> "$OUTPUT_FILE"
echo "============================================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Cargar servidores DNS en un archivo temporal
TEMP_DNS="/tmp/dns_list_$$.txt"
grep -v '^$' "$INPUT_DNS" > "$TEMP_DNS"

# Cargar listas en un archivo temporal
TEMP_LISTAS="/tmp/listas_$$.txt"
grep -v '^$' "$INPUT_LISTAS" > "$TEMP_LISTAS"

# Cargar IPs en un archivo temporal
TEMP_IPS="/tmp/ips_$$.txt"
grep -v '^$' "$INPUT_IPS" > "$TEMP_IPS"

# Seleccionar servidor DNS (usamos el primero para consistencia)
DNS_SERVER=`head -1 "$TEMP_DNS"`

# Variable para el contador de IPs procesadas
IP_INDEX=1

# Procesar cada IP del archivo
while [ $IP_INDEX -le $TOTAL_IPS ]; do
  IP=`sed -n "${IP_INDEX}p" "$TEMP_IPS"`
  
  # Validar formato de IP (básico)
  VALIDAR_IP=`echo "$IP" | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'`
  if [ "x$VALIDAR_IP" = "x" ]; then
    echo "ERROR: IP no válida: $IP (saltando...)"
    echo "ERROR: IP no válida: $IP (saltando...)" >> "$OUTPUT_FILE"
    IP_INDEX=`expr $IP_INDEX + 1`
    continue
  fi

  echo ""
  echo "============================================================"
  echo "[$IP_INDEX/$TOTAL_IPS] Procesando IP: $IP"
  echo "============================================================"
  echo ""

  # Escribir IP en el archivo de resultados
  echo "============================================================" >> "$OUTPUT_FILE"
  echo "IP: $IP" >> "$OUTPUT_FILE"
  echo "============================================================" >> "$OUTPUT_FILE"

  # Invertir la IP para DNSBL
  REV=`echo "$IP" | awk -F "." '{print $4"."$3"."$2"."$1}'`

  # Variables para almacenar resultados de todas las listas
  LISTAS_POSITIVAS=""
  ENCONTRADA=0
  LISTADAS_IP=0

  # Iterar sobre cada lista
  LISTA_INDEX=1
  while [ $LISTA_INDEX -le $TOTAL_LISTAS ]; do
    LINEA_LISTA=`sed -n "${LISTA_INDEX}p" "$TEMP_LISTAS"`
    
    # Extraer campos de la línea (formato: nombre|dominio|descripcion)
    NOMBRE_LISTA=`echo "$LINEA_LISTA" | cut -d'|' -f1`
    DOMINIO_LISTA=`echo "$LINEA_LISTA" | cut -d'|' -f2`
    DESCRIPCION_LISTA=`echo "$LINEA_LISTA" | cut -d'|' -f3-`
    
    # Verificar que tenemos todos los campos
    if [ "x$NOMBRE_LISTA" != "x" ] && [ "x$DOMINIO_LISTA" != "x" ]; then
      echo "  Consultando $NOMBRE_LISTA ($DOMINIO_LISTA) ..."
      
      # Consultar la lista
      RESULTADO=`dig +short "@$DNS_SERVER" "${REV}.${DOMINIO_LISTA}" A 2>/dev/null | head -1`
      
      if [ ! -z "$RESULTADO" ]; then
        echo "    Respuesta: $RESULTADO"
        
        # Verificar si es código de error
        ERROR_PREFIX=`echo "$RESULTADO" | awk -F "." '{print $1"."$2"."$3}'`
        if [ "$ERROR_PREFIX" != "127.255.255" ]; then
          # Esta IP está listada en esta lista
          ENCONTRADA=1
          LISTADAS_IP=`expr $LISTADAS_IP + 1`
          MENSAJE_LISTA="  LISTADA: $NOMBRE_LISTA ($DOMINIO_LISTA) - Código: $RESULTADO"
          if [ "x$DESCRIPCION_LISTA" != "x" ]; then
            MENSAJE_LISTA="$MENSAJE_LISTA - $DESCRIPCION_LISTA"
          fi
          LISTAS_POSITIVAS="$LISTAS_POSITIVAS\n$MENSAJE_LISTA"
          TOTAL_LISTADAS=`expr $TOTAL_LISTADAS + 1`
        fi
      else
        echo "    Sin respuesta (no listada)"
      fi
    fi
    
    LISTA_INDEX=`expr $LISTA_INDEX + 1`
  done

  # -----------------------------------------------------------------
  # Mostrar resultado final para esta IP
  # -----------------------------------------------------------------
  echo ""
  echo "============================================================"
  if [ $ENCONTRADA -eq 1 ]; then
    echo "RESULTADO: IP LISTADA EN $LISTADAS_IP LISTA(S) NEGRA(S)"
    echo "IP: $IP"
    echo "Listas donde aparece:"
    echo -e "$LISTAS_POSITIVAS" | while read LINEA; do
      if [ ! -z "$LINEA" ]; then
        echo "$LINEA"
        echo "$LINEA" >> "$OUTPUT_FILE"
      fi
    done
    echo "LISTED $IP -> $LISTADAS_IP lista(s)" >> "$CACHE_FILE"
  else
    # Verificar si hubo errores en las consultas
    HUBO_ERROR=0
    MENSAJE_ERROR=""
    
    # Revisar cada lista para ver si hubo error
    LISTA_INDEX=1
    while [ $LISTA_INDEX -le $TOTAL_LISTAS ]; do
      LINEA_LISTA=`sed -n "${LISTA_INDEX}p" "$TEMP_LISTAS"`
      DOMINIO_LISTA=`echo "$LINEA_LISTA" | cut -d'|' -f2`
      
      if [ "x$DOMINIO_LISTA" != "x" ]; then
        RESULTADO=`dig +short "@$DNS_SERVER" "${REV}.${DOMINIO_LISTA}" A 2>/dev/null | head -1`
        if [ ! -z "$RESULTADO" ]; then
          ERROR_PREFIX=`echo "$RESULTADO" | awk -F "." '{print $1"."$2"."$3}'`
          if [ "$ERROR_PREFIX" = "127.255.255" ]; then
            HUBO_ERROR=1
            NOMBRE_LISTA=`echo "$LINEA_LISTA" | cut -d'|' -f1`
            MENSAJE_ERROR="ERROR en $NOMBRE_LISTA: $RESULTADO"
            break
          fi
        fi
      fi
      LISTA_INDEX=`expr $LISTA_INDEX + 1`
    done

    if [ $HUBO_ERROR -eq 1 ]; then
      TOTAL_ERRORES=`expr $TOTAL_ERRORES + 1`
      echo "RESULTADO: $MENSAJE_ERROR"
      echo "$MENSAJE_ERROR" >> "$OUTPUT_FILE"
      echo "ERROR $IP -> $MENSAJE_ERROR" >> "$CACHE_FILE"
    else
      TOTAL_LIMPIAS=`expr $TOTAL_LIMPIAS + 1`
      MENSAJE="LIMPI  : $IP -> No listada en ninguna lista negra"
      echo "RESULTADO: $MENSAJE"
      echo "$MENSAJE" >> "$OUTPUT_FILE"
      echo "CLEAN $IP" >> "$CACHE_FILE"
    fi
  fi
  echo "============================================================"
  echo ""

  # Escribir separador en el archivo de resultados
  echo "" >> "$OUTPUT_FILE"
  
  IP_INDEX=`expr $IP_INDEX + 1`
done

# Limpiar archivos temporales
rm -f "$TEMP_DNS" "$TEMP_LISTAS" "$TEMP_IPS"

# Mostrar resumen final en pantalla
echo ""
echo "============================================================"
echo "   RESUMEN FINAL GLOBAL"
echo "============================================================"
echo "Total de IPs procesadas: $TOTAL_IPS"
echo "Total de listas consultadas por IP: $TOTAL_LISTAS"
echo "Total de LISTADAS (en listas negras): $TOTAL_LISTADAS"
echo "Total de IPs LIMPIAS (no listadas): $TOTAL_LIMPIAS"
echo "Total de IPs con ERROR en consulta: $TOTAL_ERRORES"
echo "============================================================"
echo ""
echo "Resultados guardados en: $OUTPUT_FILE"

# Escribir resumen en el archivo de resultados
echo "" >> "$OUTPUT_FILE"
echo "============================================================" >> "$OUTPUT_FILE"
echo "   RESUMEN FINAL GLOBAL" >> "$OUTPUT_FILE"
echo "============================================================" >> "$OUTPUT_FILE"
echo "Total de IPs procesadas: $TOTAL_IPS" >> "$OUTPUT_FILE"
echo "Total de listas consultadas por IP: $TOTAL_LISTAS" >> "$OUTPUT_FILE"
echo "Total de LISTADAS (en listas negras): $TOTAL_LISTADAS" >> "$OUTPUT_FILE"
echo "Total de IPs LIMPIAS (no listadas): $TOTAL_LIMPIAS" >> "$OUTPUT_FILE"
echo "Total de IPs con ERROR en consulta: $TOTAL_ERRORES" >> "$OUTPUT_FILE"
echo "============================================================" >> "$OUTPUT_FILE"
echo "Fecha de finalización: `date`" >> "$OUTPUT_FILE"
