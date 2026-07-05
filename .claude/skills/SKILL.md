---
name: blacklist-ip
description: >
  Usar esta skill SIEMPRE que el usuario quiera comprobar si una IP, rango de IPs o dominio
  está en una lista negra (blacklist), RBL o DNSBL (Spamhaus, SORBS, Barracuda, UCEPROTECT, etc.).
  Activar cuando se mencionen: lista negra, blacklist, DNSBL, RBL, IP listada/bloqueada, reputación
  de IP, spam blacklist, comprobar reputación de dominio/correo, deliverability de email, servidor
  SMTP bloqueado, o IP marcada como spam/phishing/malware/botnet/proxy abierto. También activar
  cuando el usuario proporcione una IP o fichero de IPs y pida: auditar reputación, verificar
  blacklisting, sacar de lista negra (delisting), o análisis forense de por qué un servidor de
  correo rebota. Repositorio de referencia: https://github.com/hackingyseguridad/listanegra
---


# Blacklist IP Skill — hackingyseguridad/listanegra

Skill de auditoría de reputación IP basada en 6 scripts DNS (`sh`/`bash`, sin dependencias
externas más allá de `dig`) que consultan contra Spamhaus y ~190 RBL/DNSBL adicionales, más
paneles web de verificación cruzada y delisting. Documentación reconstruida a partir del código
fuente real de cada script (no solo del README/LEEME, cuya tabla de scripts contiene descripciones
que no coinciden exactamente con el comportamiento real — ver **Discrepancias conocidas** al final).

Motivo por el que una IP acaba en lista negra (contexto para el análisis):

1. Spam de correo electrónico, phishing, scam, bulletproof hosting, spambots.
2. Sitios de phishing / suplantación de identidad.
3. Distribución de malware / equipos infectados.
4. Command & Control de botnets / equipos zombis.
5. Proxies abiertos HTTP/SOCKS comprometidos.

**Umbral crítico a nivel de AS:** si ~20% de las IPs activas de un proveedor están listadas, o si
ese AS aparece en el Top 10 peores ASN de Spamhaus, los filtros más estrictos (Spamhaus, UCEPROTECT
Nivel 3) bloquean el rango completo de forma preventiva — dato útil para justificar severidad en
informes de organizaciones con IP compartida/hosting.

---

## FASE 0 — Preparación del entorno

```bash
git clone https://github.com/hackingyseguridad/listanegra
cd listanegra
chmod +x *.sh
```

**Única dependencia real de los 6 scripts: `dig` (paquete `dnsutils`/`bind-utils`).** Ningún
script del repositorio invoca `whois`, `nmap`, `curl`, `traceroute` ni `jq` — no son necesarios
para esta skill.

```bash
sudo apt install -y dnsutils
```

**Ficheros de configuración (compartidos por varios scripts):**

| Fichero | Contenido | Usado por |
|---|---|---|
| `ip.txt` | Una IP por línea (**no viene en el repo, hay que crearlo**) | `listanegra2.sh`, `spamhaus2.sh` |
| `listas.txt` | ~190 dominios RBL, uno por línea (formato plano, **no** `nombre\|dominio\|descripcion` pese a lo que dicen los comentarios de cabecera de `listanegra.sh`/`listanegra2.sh`) | `listanegra.sh`, `listanegra2.sh` |
| `dns.txt` | Servidores DNS a usar, uno por línea. **La primera línea es `127.0.0.1`** — si la máquina no tiene resolver local escuchando ahí, las consultas que caigan en esa línea fallarán. Conviene editar el fichero y quitar/mover esa línea antes de auditar desde una máquina sin resolver local. | `listanegra.sh`, `listanegra2.sh`, `spamhaus.sh`, `spamhaus2.sh` |
| `resultado.txt` | Fichero de salida — **todos los scripts escriben en el mismo nombre** y lo truncan al empezar. Renombrar/copiar el resultado entre ejecuciones si se quieren conservar varias auditorías. | Todos |

---

## Tabla de scripts (comportamiento verificado en el código)

| Script | Entrada | Listas consultadas | Comportamiento clave |
|---|---|---|---|
| `consulta.sh` | IP(s) por argumento, `-f fichero` o stdin (`-`) | Solo `zen.spamhaus.org` | El más simple. Valida formato IP, colorea en TTY, guarda en `resultado.txt`, resumen con contadores. Exit code 1 si alguna IP está listada. |
| `consulta2.sh` | Igual que `consulta.sh` (argumento/`-f`/stdin) | 7 listas **fijas en el código**: `zen.spamhaus.org`, `b.barracudacentral.org`, `bl.spamcop.net`, `dyna.spamrats.com`, `noptr.spamrats.com`, `spam.spamrats.com`, `dnsbl.sorbs.net` | Copia casi idéntica de `consulta.sh` con más listas hardcodeadas. **No lee `listas.txt` ni `dns.txt`** pese a lo que indica la tabla de scripts del README/LEEME del repo. |
| `listanegra.sh` | Una IP por argumento: `./listanegra.sh <IP>` | Las ~190 de `listas.txt` | Recorre `listas.txt` en orden y **se detiene en el primer match** (`break`) — si la IP está listada en varias RBL solo se informa de la primera encontrada, no de todas. Usa siempre la primera línea de `dns.txt` como servidor DNS (sin rotación real). Puede tardar si tiene que recorrer las ~190 listas sin encontrar coincidencia. |
| `listanegra2.sh` | Fichero `ip.txt` (una IP por línea, **no admite IP por argumento**) | Las ~190 de `listas.txt`, para cada IP del fichero | Rota el servidor DNS de `dns.txt` según el número de IP procesada (`nº_ip % total_dns`). Igual que `listanegra.sh`, se detiene en el primer match por IP. Pese al nombre y a los comentarios de cabecera, **no hay soporte real de IPv6**: la inversión de octetos usa `awk -F.`, que no funciona con direcciones IPv6. |
| `spamhaus.sh` | Una IP por argumento: `./spamhaus.sh <IP>` | Solo Spamhaus: `sbl` → `xbl` → `pbl` → `css`, en ese orden, **cortocircuito** (se detiene en el primer match) | Identifica la lista exacta y el código de retorno. Selecciona el DNS de `dns.txt` según el último octeto de la IP `% total_dns`. **No lee `ip.txt`**, pese a lo que indica el README/LEEME. |
| `spamhaus2.sh` | Fichero `ip.txt` (una IP por línea) | Igual que `spamhaus.sh` (SBL→XBL→PBL→CSS, cortocircuito) para cada IP del fichero | Versión batch de `spamhaus.sh`. |

> Los scripts `checkip.sh` y `check2.sh` mencionados en versiones anteriores de esta skill
> **no existen** en el repositorio actual; han sido sustituidos por `consulta.sh`/`consulta2.sh`
> y `listanegra.sh`/`listanegra2.sh`.

---

## FASE 1 — Triage rápido (una o varias IPs sueltas)

`consulta.sh` es la opción recomendada para un primer vistazo — rápida porque solo consulta ZEN:

```bash
./consulta.sh 81.41.255.99
./consulta.sh 81.41.255.99 213.4.212.1 5.205.0.1
./consulta.sh -f ip.txt
cat ip.txt | ./consulta.sh -
```

Salida: `[LISTADA]`, `[LIMPIA]` o `[INVÁLIDA]` por IP, más resumen final en `resultado.txt`.

Si el triage con ZEN sale limpio pero se quiere algo más de cobertura sin pagar el coste de las
~190 listas, usar `consulta2.sh` con la misma sintaxis (7 listas: Spamhaus ZEN, Barracuda,
SpamCop, SpamRATS x3, SORBS).

---

## FASE 2 — Verificación específica en Spamhaus (SBL/XBL/PBL/CSS por separado)

Útil cuando se necesita saber **en cuál** de las listas de Spamhaus aparece exactamente la IP
(distinto impacto en el informe según sea SBL, XBL, PBL o CSS):

```bash
# Una IP
./spamhaus.sh <IP>

# Lote desde ip.txt
cat > ip.txt << 'EOF'
203.0.113.10
198.51.100.25
EOF
./spamhaus2.sh
```

**Interpretación (recordar que ambos scripts paran en el primer match, orden SBL→XBL→PBL→CSS):**
- `SBL` → IP involucrada en spam, phishing o hosting malicioso.
- `XBL` → equipo comprometido (botnet/malware) enviando spam.
- `PBL` → red residencial/dinámica que no debería enviar correo directo (no implica compromiso).
- `CSS` → correo de baja reputación / sin SPF-DKIM-DMARC.
- Si el script informa "LIMPIA", solo significa que no está en la primera lista comprobada de la
  cadena que dé positivo — pero al pararse en el primer match, un resultado limpio sí es
  fiable (comprobó las 4 sin encontrar nada).

---

## FASE 3 — Auditoría completa contra ~190 RBL/DNSBL

Para una auditoría exhaustiva (recomendado cuando el triage de FASE 1 ya dio positivo, o para
línea base de reputación de un cliente):

```bash
# Una IP
./listanegra.sh <IP>

# Lote desde ip.txt (rota servidores DNS de dns.txt entre IPs)
./listanegra2.sh
```

**Importante:** ambos scripts se detienen en el **primer** RBL que dé positivo — para saber
en *cuántas* listas distintas aparece una IP concreta (dato relevante para el informe: una sola
lista secundaria pesa poco, estar en 10+ indica reputación gravemente comprometida) hay que
consultarla adicionalmente con `multirbl.valli.org` (FASE 4) o iterar manualmente sobre
`listas.txt` con `dig`.

Referencia de las ~190 listas incluidas, agrupadas por tipo de amenaza (combinada, spam,
malware/botnet, proxy/Tor, phishing, política/whitelist), en `LISTAS.md` del repositorio.
Las más relevantes para priorizar hallazgos: `zen.spamhaus.org`, `cbl.abuseat.org`,
`dnsbl.sorbs.net`, `b.barracudacentral.org`, `bl.spamcop.net`, `dnsbl-3.uceprotect.net`,
`drone.abuse.ch`, `dyna.spamrats.com`.

---

## FASE 4 — Consulta manual / verificación cruzada (web)

Cuando se requiera confirmación visual, evidencia para el informe, o el enlace directo de delisting:

| Servicio | URL |
|---|---|
| Spamhaus (consulta directa) | https://check.spamhaus.org/query/ip/$IP |
| MultiRBL (Valli) — >120 RBL | https://multirbl.valli.org/lookup/$IP.html |
| MXToolbox — 105 DNSBL | https://mxtoolbox.com/ |
| DNSBL.info — >100 listas | https://www.dnsbl.info/ |
| WhatIsMyIPAddress Blacklist Check — ~50 BD | https://whatismyipaddress.com/blacklist-check |
| BlacklistAlert (monitorización) | https://blacklistalert.org/ |
| AbuseIPDB (colaborativa) | https://www.abuseipdb.com/ |
| CBL / abuseat.org | https://www.abuseat.org/ |

Estos paneles suelen incluir el enlace directo de **delisting/removal request** cuando la IP figura
listada, dato imprescindible para la sección de remediación del informe.

---

## FASE 5 — Decisión: siguiente paso según resultado

| Resultado | Acción recomendada |
|---|---|
| No listada en ninguna RBL | Documentar como OK / baseline de reputación limpia |
| Listada solo en RBL secundarias/experimentales | Riesgo bajo, monitorizar, revisar SPF/DKIM/DMARC |
| Listada en Spamhaus PBL | Verificar si la IP es dinámica/residencial y no debería enviar correo directo (usar smarthost/relay del ISP) |
| Listada en Spamhaus SBL/XBL/CSS/ZEN, SORBS, Barracuda o UCEPROTECT | Riesgo alto: iniciar investigación de compromiso (malware, relay abierto, cuenta comprometida) antes de solicitar delisting |
| IP forma parte de un AS con ≥20% de rango listado o en el Top 10 peores ASN de Spamhaus | Riesgo de bloqueo preventivo de todo el rango — escalar a nivel de proveedor, no solo de IP |

---

## FASE 6 — Remediación / Delisting (checklist)

1. Confirmar y **corregir la causa raíz** (limpiar malware, cerrar relay/proxy abierto, rotar
   credenciales SMTP comprometidas, filtrar salida SMTP con firewall).
2. Verificar registros de autenticación de correo: SPF, DKIM y DMARC correctamente publicados.
3. Solicitar el delisting en cada RBL donde aparezca (cada proveedor tiene su propio formulario;
   Spamhaus: https://check.spamhaus.org/query/ip/$IP incluye el enlace de "Remove me from this list").
4. Volver a ejecutar `consulta.sh`/`listanegra.sh` transcurridas 24–72h para confirmar la baja.
5. Monitorización continua recomendada (cron diario con `consulta.sh -f ip.txt` sobre las IPs de
   salida SMTP de la organización).

---

## Tabla de códigos de retorno de Spamhaus

| Código | Lista | Significado | Acción |
|:---:|:---|:---|:---|
| `127.0.0.2` | SBL | IP involucrada en spam, phishing o alojamiento malicioso | Bloquear / Marcar |
| `127.0.0.3` | CSS | Fuente de spam detectada automáticamente | Bloquear / Marcar |
| `127.0.0.4` | XBL | Equipo comprometido (botnet, malware) enviando spam | Bloquear / Marcar |
| `127.0.0.9` | DROP | Rango usado por ciberdelincuentes (siempre viene además de otro código) | Bloquear / Marcar |
| `127.0.0.10` | PBL (ISP) | Red que no debería enviar correo directo | Bloquear con precaución |
| `127.0.0.11` | PBL (Spamhaus) | Red que no debería enviar correo directo | Bloquear con precaución |
| `127.0.0.30` | BCL | Servidor C&C de botnet | Bloquear / Marcar |
| `127.0.1.2` | DBL | Dominio de baja reputación (spam) | Bloquear / Marcar |
| `127.0.1.4` | DBL | Dominio relacionado con phishing | Bloquear / Marcar |
| `127.0.1.5` | DBL | Dominio relacionado con malware | Bloquear / Marcar |
| `127.0.1.6` | DBL | Dominio usado como C&C de botnet | Bloquear / Marcar |
| `127.0.1.102–106` | DBL (abused-legit) | Dominio legítimo comprometido (spam/phishing/malware/C&C) | Bloquear / Marcar |
| `127.0.2.2–24` | ZRD | Dominio de reputación cero, visto por primera vez hace 2–24h | Marcar con precaución |
| `127.255.255.252` | ERROR | FQDN de la lista mal escrito | **No bloquear** — revisar ortografía |
| `127.255.255.254` | ERROR | Consulta vía resolver público (8.8.8.8, etc.) | **No bloquear** — usar DNS local |
| `127.255.255.255` | ERROR | Límite de uso justo superado | **No bloquear** — reducir velocidad o usar DQS |
| `127.0.1.255` | ERROR | Consulta a DBL con IP en vez de dominio | **No bloquear** — DBL solo admite dominios |

Nota: `zen.spamhaus.org` combina SBL+XBL+PBL+CSS en una sola consulta — el código de retorno
indica la lista de origen, pero si se necesita saber explícitamente cuál es sin ambigüedad, usar
`spamhaus.sh`/`spamhaus2.sh`, que consultan cada lista por separado.

---

## Discrepancias conocidas entre el README/LEEME del repo y el código real

Documentado aquí porque puede inducir a error si se sigue la tabla de scripts del README/LEEME
al pie de la letra:

1. **`consulta2.sh`**: el README dice que lee `listas.txt`/`dns.txt` con rotación de DNS; el
   código real usa 7 listas fijas y la misma interfaz CLI que `consulta.sh` (sin leer esos ficheros).
2. **`spamhaus.sh`**: el README dice que consulta IPs desde `ip.txt`; el código real toma la IP
   como argumento único (`./spamhaus.sh <IP>`), no lee `ip.txt`. Es `spamhaus2.sh` el que usa `ip.txt`.
3. **`listanegra2.sh`**: pese al nombre y a los comentarios que sugieren soporte IPv4/IPv6, la
   inversión de octetos con `awk -F.` no procesa IPv6 — solo funciona con IPv4.
4. **`listanegra.sh`/`listanegra2.sh`**: los comentarios de cabecera describen `listas.txt` con
   formato `nombre|dominio|descripcion`, pero el fichero real solo tiene el dominio por línea. El
   `cut -d'|'` sin delimitador devuelve la línea completa en cada campo, así que el script sigue
   funcionando (consulta el dominio correctamente), pero el nombre/descripción mostrados en pantalla
   son el propio dominio repetido, no una etiqueta descriptiva.

---

## PLANTILLA DE HALLAZGO PARA INFORME

```
HALLAZGO: IP en lista negra (Blacklist / DNSBL)
IP/Rango:  [objetivo]
PTR:       [resultado de dig -x, si se ha comprobado aparte]
ASN/Whois: [organización propietaria, si se ha comprobado aparte]
CVSS v3.1: N/A (hallazgo operativo, no vulnerabilidad técnica clásica) — clasificar como
           Informativo/Medio/Alto según impacto en entregabilidad de correo

LISTAS EN LAS QUE APARECE:
- zen.spamhaus.org (SBL/XBL/PBL/CSS) -> [SI/NO — código de retorno]
- [otras RBL detectadas por listanegra.sh / consulta2.sh / multirbl.valli.org]

DESCRIPCIÓN:
[Contexto: motivo probable — spam, phishing, malware, botnet C&C, proxy abierto]

EVIDENCIA:
$ ./consulta.sh <IP>
[output recortado]
$ ./spamhaus.sh <IP>
[output recortado]

IMPACTO:
[Correo rebotado/marcado como spam, reputación de dominio afectada, posible indicador de compromiso]

REMEDIACIÓN:
- Identificar y neutralizar la causa raíz (ver FASE 6)
- Publicar/corregir SPF, DKIM, DMARC
- Solicitar delisting en cada RBL afectada
- Monitorización periódica de reputación

REFERENCIAS:
- https://github.com/hackingyseguridad/listanegra
- https://check.spamhaus.org/query/ip/[IP]
```

---

## REFERENCIAS

- Repositorio: https://github.com/hackingyseguridad/listanegra
- Scripts: `consulta.sh` / `consulta2.sh` (triage rápido, CLI/fichero/stdin), `listanegra.sh` /
  `listanegra2.sh` (auditoría completa ~190 RBL, IP única / lote), `spamhaus.sh` / `spamhaus2.sh`
  (Spamhaus SBL/XBL/PBL/CSS por separado, IP única / lote)
- Ficheros de datos: `ip.txt` (a crear), `listas.txt`, `dns.txt`, `LISTAS.md` (catálogo de RBL
  categorizado), `resultado.txt` (salida compartida)
- Spamhaus DNSBL: https://www.spamhaus.org/ — códigos de respuesta: https://www.spamhaus.org/faq/
- www.hackingyseguridad.com
