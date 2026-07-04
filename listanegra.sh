#!/bin/bash
# check_multi_rbl_ip.sh — Adaptado para Bash 1.0.x
# Consulta TODAS las listas en 'listas.txt' para una IP dada como argumento
# Uso: sh check_multi_rbl_ip.sh IP
# Ejemplo: sh check_multi_rbl_ip.sh 8.8.8.8

# Variables
INPUT_DNS="dns.txt"
INPUT_LISTAS="listas.txt"
OUTPUT_FILE="resultado.txt"
CACHE_FILE="/tmp/cache_multi_rbl_ip.txt"

# Contadores
TOTAL_LISTAS=0
LISTADAS=0
LIMPIAS=0
ERRORES=0
TOTAL_DNS=0

# Verificar que se pasó un argumento (la IP)
if [ $# -ne 1 ]; then
  echo "ERROR: Debes especificar una IP"
  echo "Uso: sh $0 IP"
  echo "Ejemplo: sh $0 8.8.8.8"
  exit 1
fi

IP="$1"

# Validar formato básico de IP (4 números separados por puntos)
VALIDAR_IP=`echo "$IP" | awk -F. '{if (NF==4) print "valido"}'`
if [ "x$VALIDAR_IP" != "xvalido" ]; then
  echo "ERROR: Formato de IP inválido: $IP"
  echo "Debe tener formato: xxx.xxx.xxx.xxx"
  echo "Ejemplo: 8.8.8.8"
  exit 1
fi

# Verificar que existe el archivo de DNS
if [ ! -f "$INPUT_DNS" ]; then
  echo "ERROR: No se encuentra el archivo $INPUT_DNS"
  echo "Crea un archivo con un servidor DNS por línea"
  echo "Ejemplo:"
  echo "  8.8.8.8"
  echo "  1.1.1.1"
  exit 1
fi

# Verificar que existe el archivo de listas
if [ ! -f "$INPUT_LISTAS" ]; then
  echo "ERROR: No se encuentra el archivo $INPUT_LISTAS"
  echo "Crea un archivo con un FQDN de lista negra por línea"
  echo "Ejemplo:"
  echo "  zen.spamhaus.org"
  echo "  sbl.spamhaus.org"
  echo "  xbl.spamhaus.org"
  exit 1
fi

# Crear directorio de caché si no existe
CACHE_DIR=`echo "$CACHE_FILE" | sed 's/\/[^/]*$//'`
if [ ! -d "$CACHE_DIR" ]; then
  mkdir -p "$CACHE_DIR"
fi

# Contar servidores DNS disponibles
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

# Cargar servidores DNS en un archivo temporal
TEMP_DNS="/tmp/dns_list_$$.txt"
grep -v '^$' "$INPUT_DNS" > "$TEMP_DNS"
TOTAL_DNS=`wc -l < "$TEMP_DNS"`

# Cargar listas a consultar en un archivo temporal
TEMP_LISTAS="/tmp/listas_$$.txt"
grep -v '^$' "$INPUT_LISTAS" > "$TEMP_LISTAS"
TOTAL_LISTAS=`wc -l < "$TEMP_LISTAS"`

# Invertir la IP para DNSBL
REV=`echo "$IP" | awk -F "." '{print $4"."$3"."$2"."$1}'`

# Seleccionar servidor DNS (usamos el último octeto para rotar)
ULTIMO_OCTETO=`echo "$IP" | awk -F "." '{print $4}'`
MOD=`expr $ULTIMO_OCTETO % $TOTAL_DNS`
if [ $MOD -eq 0 ]; then
  MOD=$TOTAL_DNS
fi

# Obtener el DNS correspondiente al índice
DNS_SERVER=`sed -n "${MOD}p" "$TEMP_DNS"`

# Si no se pudo obtener, usar el primero
if [ "x$DNS_SERVER" = "x" ]; then
  DNS_SERVER=`head -1 "$TEMP_DNS"`
fi

# Mostrar cabecera
echo "============================================================"
echo "   SCRIPT DE CONSULTA MÚLTIPLE RBL (Bash 1.0.x)"
echo "   Consulta TODAS las listas para una IP"
echo "============================================================"
echo "IP consultada:     $IP"
echo "DNS utilizado:     $DNS_SERVER"
echo "Total de listas:   $TOTAL_LISTAS"
echo "Archivo de salida: $OUTPUT_FILE"
echo "============================================================"
echo ""

# Escribir cabecera en el archivo de resultados
echo "============================================================" >> "$OUTPUT_FILE"
echo "   SCRIPT DE CONSULTA MÚLTIPLE RBL (Bash 1.0.x)" >> "$OUTPUT_FILE"
echo "   Fecha: `date`" >> "$OUTPUT_FILE"
echo "============================================================" >> "$OUTPUT_FILE"
echo "IP consultada: $IP" >> "$OUTPUT_FILE"
echo "DNS utilizado: $DNS_SERVER" >> "$OUTPUT_FILE"
echo "Total de listas: $TOTAL_LISTAS" >> "$OUTPUT_FILE"
echo "============================================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

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
  
  # Mostrar progreso en pantalla
  echo "[$CONTADOR_LISTAS/$TOTAL_LISTAS] Consultando: $LISTA_FQDN ..."
  
  # Realizar consulta DNS
  RESULT=`dig +short "@$DNS_SERVER" "${REV}.${LISTA_FQDN}" A 2>/dev/null | head -1`

  if [ ! -z "$RESULT" ]; then
    # Verificar si es código de error (127.255.255.x)
    ERROR_PREFIX=`echo "$RESULT" | awk -F "." '{print $1"."$2"."$3}'`
    if [ "$ERROR_PREFIX" = "127.255.255" ]; then
      # Es un error
      MENSAJE="  ERROR en: $LISTA_FQDN (Código: $RESULT)"
      echo "$MENSAJE"
      echo "$MENSAJE" >> "$OUTPUT_FILE"
      ERRORES=`expr $ERRORES + 1`
    else
      # Es un listado válido
      ENCONTRADA=1
      MENSAJE="  >>> LISTADA en: $LISTA_FQDN (Código: $RESULT)"
      echo "$MENSAJE"
      echo "$MENSAJE" >> "$OUTPUT_FILE"
      echo "LISTED $IP -> $LISTA_FQDN ($RESULT)" >> "$CACHE_FILE"
      LISTADAS=`expr $LISTADAS + 1`
    fi
  else
    # No hay respuesta -> limpio en esta lista
    MENSAJE="  LIMPI  en: $LISTA_FQDN"
    echo "$MENSAJE"
    echo "$MENSAJE" >> "$OUTPUT_FILE"
  fi
done
exec 4<&-

# Limpiar archivos temporales
rm -f "$TEMP_DNS" "$TEMP_LISTAS"

# Resumen final
echo ""
echo "============================================================"
echo "   RESUMEN PARA IP: $IP"
echo "============================================================"
echo "Total de listas consultadas: $TOTAL_LISTAS"
echo "LISTADAS en: $LISTADAS lista(s)"
echo "LIMPIAS en:   `expr $TOTAL_LISTAS - $LISTADAS - $ERRORES` lista(s)"
echo "ERRORES en:   $ERRORES lista(s)"
echo "------------------------------------------------------------"
if [ $ENCONTRADA -eq 1 ]; then
  echo "RESULTADO: IP $IP -> LISTADA en lista negra"
else
  if [ $ERRORES -eq $TOTAL_LISTAS ]; then
    echo "RESULTADO: IP $IP -> ERROR en todas las consultas"
  else
    echo "RESULTADO: IP $IP -> LIMPIA (no listada en ninguna RBL)"
  fi
fi
echo "============================================================"
echo ""
echo "Resultados guardados en: $OUTPUT_FILE"

# Escribir resumen en el archivo de resultados
echo "" >> "$OUTPUT_FILE"
echo "============================================================" >> "$OUTPUT_FILE"
echo "   RESUMEN PARA IP: $IP" >> "$OUTPUT_FILE"
echo "============================================================" >> "$OUTPUT_FILE
echo "Total de listas consultadas: $TOTAL_LISTAS" >> "$OUTPUT_FILE"
echo "LISTADAS en: $LISTADAS lista(s)" >> "$OUTPUT_FILE"
echo "LIMPIAS en:   `expr $TOTAL_LISTAS - $LISTADAS - $ERRORES` lista(s)" >> "$OUTPUT_FILE"
echo "ERRORES en:   $ERRORES lista(s)" >> "$OUTPUT_FILE"
echo "------------------------------------------------------------" >> "$OUTPUT_FILE"
if [ $ENCONTRADA -eq 1 ]; then
  echo "RESULTADO: IP $IP -> LISTADA en lista negra" >> "$OUTPUT_FILE"
else
  if [ $ERRORES -eq $TOTAL_LISTAS ]; then
    echo "RESULTADO: IP $IP -> ERROR en todas las consultas" >> "$OUTPUT_FILE"
  else
    echo "RESULTADO: IP $IP -> LIMPIA (no listada en ninguna RBL)" >> "$OUTPUT_FILE"
  fi
fi
echo "============================================================" >> "$OUTPUT_FILE"
echo "Fecha de finalización: `date`" >> "$OUTPUT_FILE"
