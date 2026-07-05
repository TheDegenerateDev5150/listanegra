#!/bin/sh

# Script simple para verificar IP publica listada
# Verifica si una IP esta en Lista Negra, por SPAM de email
# Las IPv4 suelen ser listadas tras el primer envio SPAM
# Las IPv6 raramente son las listadas en BlackList
# (R) hackingyseguridad.com 2026
# @antonio_taboada

# Adaptado para Bash 1.0.x
# Consulta TODAS las listas en 'listas.txt' para una IP
# Lee la IP desde la línea de comandos, DNS desde 'dns.txt'
# Guarda resultados en 'resultado.txt'

# Variables
INPUT_DNS="dns.txt"
INPUT_LISTAS="listas.txt"
OUTPUT_FILE="resultado.txt"
CACHE_FILE="/tmp/cache_multi_rbl_completo.txt"

# Contadores
TOTAL_LISTAS=0
LISTADAS=0
LIMPIAS=0
ERRORES=0
TOTAL_DNS=0

# Verificar argumento de IP
if [ -z "$1" ]; then
  echo "ERROR: Debes proporcionar una IP como argumento"
  echo "Uso: sh $0 <IP>"
  echo "Ejemplo: sh $0 1.1.1.1"
  exit 1
fi

IP="$1"

# Verificar archivos necesarios
if [ ! -f "$INPUT_DNS" ]; then
  echo "ERROR: No se encuentra el archivo $INPUT_DNS"
  echo "Crea un archivo con un servidor DNS por línea"
  exit 1
fi

if [ ! -f "$INPUT_LISTAS" ]; then
  echo "ERROR: No se encuentra el archivo $INPUT_LISTAS"
  echo "Crea un archivo con un FQDN de lista negra por línea (ej. zen.spamhaus.org)"
  exit 1
fi

# Crear directorio de caché
CACHE_DIR=`echo "$CACHE_FILE" | sed 's/\/[^/]*$//'`
if [ ! -d "$CACHE_DIR" ]; then
  mkdir -p "$CACHE_DIR"
fi

# Vaciar archivo de resultados anterior
> "$OUTPUT_FILE"

# Contar servidores DNS
TOTAL_DNS=`grep -v '^$' "$INPUT_DNS" | wc -l`
if [ "x$TOTAL_DNS" = "x" ] || [ $TOTAL_DNS -eq 0 ]; then
  echo "ERROR: No hay servidores DNS válidos en $INPUT_DNS"
  exit 1
fi

# Contar listas a consultar
TOTAL_LISTAS=`grep -v '^$' "$INPUT_LISTAS" | wc -l`
if [ "x$TOTAL_LISTAS" = "x" ] || [ $TOTAL_LISTAS -eq 0 ]; then
  echo "ERROR: No hay listas válidas en $INPUT_LISTAS"
  exit 1
fi

# Cabecera
echo "============================================================"
echo "   SCRIPT DE CONSULTA MÚLTIPLE RBL COMPLETO (Bash 1.0.x)"
echo "   Consulta TODAS las listas para una IP"
echo "============================================================"
echo "IP a consultar:     $IP"
echo "Archivo de DNS:     $INPUT_DNS"
echo "Archivo de listas:  $INPUT_LISTAS ($TOTAL_LISTAS listas)"
echo "Archivo de salida:  $OUTPUT_FILE"
echo "============================================================"
echo ""

# Escribir cabecera en resultado
echo "============================================================" >> "$OUTPUT_FILE"
echo "   SCRIPT DE CONSULTA MÚLTIPLE RBL COMPLETO (Bash 1.0.x)" >> "$OUTPUT_FILE"
echo "   Fecha: `date`" >> "$OUTPUT_FILE"
echo "============================================================" >> "$OUTPUT_FILE"
echo "IP consultada: $IP" >> "$OUTPUT_FILE"
echo "Archivo de listas: $INPUT_LISTAS" >> "$OUTPUT_FILE"
echo "Total de listas: $TOTAL_LISTAS" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Cargar servidores DNS
TEMP_DNS="/tmp/dns_list_$$.txt"
grep -v '^$' "$INPUT_DNS" > "$TEMP_DNS"
TOTAL_DNS=`wc -l < "$TEMP_DNS"`

# Cargar listas a consultar en un archivo temporal
TEMP_LISTAS="/tmp/listas_$$.txt"
grep -v '^$' "$INPUT_LISTAS" > "$TEMP_LISTAS"
TOTAL_LISTAS=`wc -l < "$TEMP_LISTAS"`

echo ""
echo "Consultando IP: $IP ..."
echo "------------------------------------------------------------"

# Escribir cabecera de IP en el archivo de resultados
echo "" >> "$OUTPUT_FILE"
echo "------------------------------------------------------------" >> "$OUTPUT_FILE"
echo "IP: $IP" >> "$OUTPUT_FILE"
echo "------------------------------------------------------------" >> "$OUTPUT_FILE"

# Invertir la IP
REV=`echo "$IP" | awk -F "." '{print $4"."$3"."$2"."$1}'`

# Seleccionar servidor DNS (usamos el primero siempre, ya que es una sola IP)
DNS_SERVER=`head -1 "$TEMP_DNS"`
if [ "x$DNS_SERVER" = "x" ]; then
  DNS_SERVER=`head -1 "$TEMP_DNS"`
fi

# Variables para esta IP
ENCONTRADA=0
CONTADOR_LISTAS=0

# Recorrer TODAS las listas del archivo
exec 4< "$TEMP_LISTAS"
while read -r LISTA_FQDN <&4; do
  # Saltar líneas vacías
  if [ "x$LISTA_FQDN" = "x" ]; then
    continue
  fi

  CONTADOR_LISTAS=`expr $CONTADOR_LISTAS + 1`
  
  # Realizar consulta DNS
  RESULT=`dig +short "@$DNS_SERVER" "${REV}.${LISTA_FQDN}" A 2>/dev/null | head -1`

  if [ ! -z "$RESULT" ]; then
    # Verificar si es código de error (127.255.255.x)
    ERROR_PREFIX=`echo "$RESULT" | awk -F "." '{print $1"."$2"."$3}'`
    if [ "$ERROR_PREFIX" = "127.255.255" ]; then
      # Es un error
      MENSAJE="  ERROR en $LISTA_FQDN: $RESULT"
      echo "$MENSAJE"
      echo "$MENSAJE" >> "$OUTPUT_FILE"
      ERRORES=`expr $ERRORES + 1`
    else
      # Es un listado válido
      ENCONTRADA=1
      MENSAJE="  LISTADA en: $LISTA_FQDN (Código: $RESULT)"
      echo "$MENSAJE"
      echo "$MENSAJE" >> "$OUTPUT_FILE"
      echo "LISTED $IP -> $LISTA_FQDN ($RESULT)" >> "$CACHE_FILE"
      LISTADAS=`expr $LISTADAS + 1`
    fi
  else
    # No hay respuesta -> limpio en esta lista
    echo "  LIMPI  en: $LISTA_FQDN" | tee -a "$OUTPUT_FILE"
  fi
done
exec 4<&-

# Resumen por IP
if [ $ENCONTRADA -eq 0 ]; then
  LIMPIAS=`expr $LIMPIAS + 1`
  MENSAJE="RESUMEN: $IP -> LIMPIA (no listada en ninguna RBL)"
else
  MENSAJE="RESUMEN: $IP -> LISTADA en al menos una RBL"
fi
echo "$MENSAJE"
echo "$MENSAJE" >> "$OUTPUT_FILE"
echo "------------------------------------------------------------" >> "$OUTPUT_FILE"

# Limpiar archivos temporales
rm -f "$TEMP_DNS" "$TEMP_LISTAS"

# Resumen final
echo ""
echo "============================================================"
echo "   RESUMEN FINAL"
echo "============================================================"
echo "IP consultada: $IP"
echo "Total de listas consultadas: $TOTAL_LISTAS"
echo "Resultado: $MENSAJE"
echo "Errores de consulta: $ERRORES"
echo "============================================================"
echo ""
echo "Resultados guardados en: $OUTPUT_FILE"

# Escribir resumen en el archivo de resultados
echo "" >> "$OUTPUT_FILE"
echo "============================================================" >> "$OUTPUT_FILE"
echo "   RESUMEN FINAL" >> "$OUTPUT_FILE"
echo "============================================================" >> "$OUTPUT_FILE
echo "IP consultada: $IP" >> "$OUTPUT_FILE"
echo "Total de listas consultadas: $TOTAL_LISTAS" >> "$OUTPUT_FILE"
echo "Resultado: $MENSAJE" >> "$OUTPUT_FILE"
echo "Errores de consulta: $ERRORES" >> "$OUTPUT_FILE"
echo "============================================================" >> "$OUTPUT_FILE"
echo "Fecha de finalización: `date`" >> "$OUTPUT_FILE"
