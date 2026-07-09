


<img align="left" alt="Listas Negras IP - hackingyseguridad.com" src="https://github.com/hackingyseguridad/listanegra/blob/main/blacklist.png" style="margin-bottom: 20px;">

## Listanegra

### BlackList IP:

[listas negras](LISTAS.md) de IP / Blacklist IP,  son herramientas técnicas  para filtrar y evitar IP o dominios utilizados para: 

1º.- Spam de correo electronico, Phissing email, SCAM. Spam distribuido en múltiples IPs. Spam support services. Servidores de bulletproof hosting. Spambots	Equipos enviando spam localmente

2º.- Phishing sites. Sitios de suplantación de identidad. 

3º.- Malware distribution. Sitios que distribuyen malware. IPs infectadas	PCs/equipos con malware

4º.- Botnet C&C. Servidores de control de botnets. Botnet zombies	Equipos parte de botnets.

5º.- Proxy abiertos	Proxies HTTP/SOCKS comprometidos.

**actividades consideradas  maliciosas por las que podria ser reportada / sancionada la IP e incluida en listas negras (BlackList IP):** SPAM, fuerza bruta, DDoS attack, DNS compromise, web malicioso con malware, envenenamiento de DNS, host explotado, fraude en VoIP, fuerza bruta sobre FTP, Hacking Hackeo (o Intrusión informática), ataque dirigido a IoT (internet de las cosas), Open Proxy, Phishing, ping de la muerte, escaneo de puertos, Inyección SQL, SSH (ataque sobre el protocolo SSH), Spoofing Suplantación (o falsificación), IP de VPN, Ataque a aplicación web, Spam web,..

###  Impacto IP listada:

estar listado en Blacklist lista negra podría tener alguna consecuencia por bloqueos y reputación en listas 
usadas por algunos firewall y tecnologías de seguridad:

1º.- correo-email: Los servidores de destino rechazarán automáticamente emails o los enviarán directo a la carpeta de spam.

2º.- La IP o el rango, aparecemos como no confiables, ante los proveedores de servicios de internet (ISPs).

3º.-. Bloqueos/filtros: en algunos casos, se puede bloquear el acceso a servicios en la nube que validan la seguridad de la IP, si estas aparecen listadas; algunas listas negras, especialmente las más agresivas, pueden optar por listar rangos CIDR (por ejemplo, 192.0.2.0/24) si consideran que toda una red es problemática 

por ejemplo :

**(ZEN) Spamhaus Blocklist**: Lista combinada que reúne la SBL, XBL y PBL en una sola consulta.  Es la principal fuente de reputación para Microsoft (Outlook/Hotmail), Google (Gmail), y miles de empresas. https://www.spamhaus.org/blocklists/ 

**(SBL) Spamhous Blocklist**: lista de IP de spam o que albergan contenido malicioso. Incluye tanto IP individuales como rangos completos

**(XBL) Spamhous Exploits Blocklist**: Lista IP de equipos que han sido comprometidos y se utilizan para enviar spam o malware. 

**(PBL) Spamhous Policy Blocklist** : lista de IP que no deberían enviar correo directamente a un servidor de correo.

**(CSS): Spamhous Combined Spam Sources**: lista IP que envían correo de baja reputación, sin verificaciones SPF, DKIM, DMARK

**bl.spamcop.net** SpamCop es una de las bases de datos de spam más respetadas. 

**access.redhawk.org**, DNSBL (DNS Block List) mantenido por Redhawk.org a través de su producto SpamHawk® . Se utiliza para identificar direcciones IP que envían UBE (Unsolicited Bulk Email, spam 

**dnsbl.sorbs.net** y dnsbl-1.uceprotect.net Son listas muy estrictas. Muchos servidores de correo las 
usan para puntuar negativamente el correo entrante (lo que hace que tus emails vayan a la carpeta 
de SPAM).

**barracudacentral.org** Es el sistema de reputación de Barracuda Networks, uno de los firewalls de 
email más vendidos del mundo.

---

Las listas DNSBL tradicionales, como zen.spamhaus.org, funcionan a nivel de IP individual. Sin embargo, el bloqueo a nivel de ASN (Autonomous System Number) o de rango CIDR es una funcionalidad que ofrecen servicios de seguridad más avanzados, como AWS WAF o cortafuegos especializados.

AWS WAF: Permite crear reglas basadas en ASNs para bloquear o permitir todo el tráfico de un proveedor de servicios o una organización entera . Esto es mucho más eficiente que gestionar listas de IPs individuales, ya que los ASNs cambian con menos frecuencia .

WatchGuard XCS: Utiliza reglas de conexión que pueden bloquear clientes basados en su presencia en una o múltiples listas DNSBL, y también incluye reglas para identificación por nombre de dominio o patrones de tráfico .

Cortafuegos y otros dispositivos: La mayoría de los firewalls y sistemas de prevención de intrusiones pueden crear reglas para bloquear rangos de direcciones IP (CIDR) o países enteros, basándose en información que no proviene directamente de las listas DNSBL de spam.

El bloqueo de rangos y ASNs es una función que ofrecen las plataformas de seguridad por derecho propio, no directamente el DNSBL, pero se puede combinar con la información de las listas para crear estrategias de defensa más amplias y robustas.

---

### El umbral crítico: 20 % de IP Listadas de un AS (BGP sistema autonomo)

Las listas negras más estrictas a nivel de red (como UCEPROTECT Nivel 3 o los sistemas de reputación de Spamhaus) automatizan el bloqueo de un AS completo bajo estas condiciones:

**20% de sus IPs activas listadas:** Si una de cada cinco IPs de un proveedor está listada, los filtros consideran que el AS está ***"fuera de control"***.

Aparecer en el top de los peores (Top 10 Worst ASNs): Organizaciones como Spamhaus publican diariamente una lista de los  **10 AS Sistemas Autónomos** con peor comportamiento del mundo. Si un ISP entra ahí, cientos de miles de servidores de correo en todo el planeta activan automáticamente una regla de bloqueo preventivo de todo su rango.   [Como solicitar deslistasr con Spamhaus: ](https://github.com/hackingyseguridad/listanegra/blob/main/SPAMHAUS.md)

### Consulta manual IP o dominio en lista negra ( blacklist )

por ejemplo.:  https://check.spamhaus.org/query/ip/80.58.71.71

<img style="float:left"  alt="Listas Negras IP https://check.spamhaus.org/query/ip/" src="https://github.com/hackingyseguridad/listanegra/blob/main/spamhaus.png" style="margin-bottom: 20px;">

### -

| URL | Descripción |
| :--- | :--- |
| https://check.spamhaus.org/query/ip/ | **Verificador de Spamhaus**. Consulta el estado de una IP en sus listas (SBL, XBL, PBL, CSS). |
| https://multirbl.valli.org/lookup/$IP.html | **Verificador múltiple**. Comprueba una IP en más de 120 listas RBL/DNSBL diferentes. |
| https://whatismyipaddress.com/blacklist-check | **Herramienta de verificación**. Consulta el estado de tu IP en unas 50 bases de datos antispam. |
| https://blacklistalert.org/ | **Servicio de monitorización**. Permite verificar IPs/dominios y recibir alertas sobre listados. |
| https://www.dnsbl.info/ | **Buscador de DNSBL**. Consulta el estado de una IP en más de 100 listas negras basadas en DNS. |
| https://mxtoolbox.com/ | **Conjunto de herramientas de red**. Incluye un verificador que chequea IPs contra 105 listas DNSBL. |
| https://www.abuseipdb.com/ | **Base de datos colaborativa**. Permite consultar y reportar IPs que han realizado actividades maliciosas. |
| https://www.abuseat.org/ | **CBL (Composite Blocking List)**. Informativo sobre esta lista negra específica. |
| https://www.uceprotect.net/en/rblcheck.php | **Uce Protect**. Informativo sobre el estado de un AS o IP. |

## Instalar Git

```bash
git clone https://github.com/hackingyseguridad/listanegra.git
cd listanegra
chmod +x *.sh
```


### 📜 Scripts 

# Actualización de la tabla de scripts del repositorio listanegra

Basado en el análisis detallado del contenido actual de los scripts en el repositorio, aquí está la tabla actualizada con la información real:

| Script | Función Principal | Modo de Uso | Descripción / Características |
| :--- | :--- | :--- | :--- |
| **`consulta.sh`** | **Consulta múltiples IPs en listas negras mediante DNS** con soporte para argumentos, fichero o stdin. | `./consulta.sh <IP1> [IP2] ...`<br>`./consulta.sh -f <fichero>`<br>`cat ip.txt \| ./consulta.sh -` | **Script versátil** que permite consultar IPs de diversas formas. Por defecto usa `zen.spamhaus.org` como única lista. Guarda resultados en `resultado.txt` con colores en terminal. Incluye validación de IPs y resumen final. |
| **`consulta2.sh`** | **Versión extendida de consulta.sh** que utiliza múltiples listas negras desde archivo de configuración. | `./consulta2.sh` | Lee las listas desde `listas.txt` y las IPs desde `ip.txt`. Realiza rotación de DNS desde `dns.txt`. Es el script más completo para consultas masivas con múltiples RBLs. |
| **`listanegra.sh`** | **Consulta automática de IP pública** del equipo en listas negras. | `./listanegra.sh` | Obtiene la IP pública de salida y la verifica contra `zen.spamhaus.org`, `bl.spamcop.net`, `dnsbl.sorbs.net`, `b.barracudacentral.org` y `dnsbl-1.uceprotect.net`. Útil para chequeo rápido de reputación. |
| **`listanegra2.sh`** | **Consulta de IP específica** (IPv4 o IPv6) en listas negras. | `./listanegra2.sh <IP>` | Permite consultar una IP arbitraria con soporte para IPv4 e IPv6. Verifica contra `zen.spamhaus.org`, `bl.spamcop.net`, `dnsbl.sorbs.net`, `b.barracudacentral.org` y `dnsbl-1.uceprotect.net`. |
| **`spamhaus.sh`** | **Consulta dedicada a Spamhaus** para IPs en `ip.txt` con identificación de lista específica. | `./spamhaus.sh` | Versión especializada que consulta todas las listas de Spamhaus (SBL, XBL, PBL, CSS, ZEN, DBL) y muestra el nombre exacto de la lista donde aparece la IP. |
| **`spamhaus2.sh`** | **Consulta Spamhaus desde archivo** mostrando nombre exacto de la lista. | `./spamhaus2.sh` | Similar a `spamhaus.sh`, lee IPs desde `ip.txt` y muestra el nombre de la lista específica de Spamhaus donde está listada la IP. |

### 📝 Notas importantes actualizadas:

1. **`consulta.sh`** es el script más flexible, soportando:
   - IPs como argumentos: `./consulta.sh 8.8.8.8 1.1.1.1`
   - Fichero con `-f`: `./consulta.sh -f ip.txt`
   - Entrada estándar: `cat ip.txt | ./consulta.sh -`
   - Validación de formato de IP
   - Salida con colores en terminal
   - Resumen estadístico al final

2. **`consulta2.sh`** extiende la funcionalidad permitiendo:
   - Múltiples listas negras desde `listas.txt`
   - Rotación de servidores DNS desde `dns.txt`
   - Consulta masiva de IPs desde `ip.txt`

3. **Archivos de configuración:**
   - `ip.txt`: IPs a consultar (una por línea)
   - `listas.txt`: FQDNs de listas negras (ej. `zen.spamhaus.org`)
   - `dns.txt`: Servidores DNS para rotación (ej. `8.8.8.8`, `1.1.1.1`)
   - `resultado.txt`: Salida generada por `consulta.sh`

4. **Spamhaus códigos de respuesta** documentados en el repositorio para interpretar correctamente los resultados.

---

### Códigos de Respuesta de Spamhaus

| Código de Retorno | Lista / Tipo | Significado | Zona de Consulta | Acción Recomendada |
|:---:|:---|:---|:---|:---|
| **127.0.0.2** | SBL | Spamhaus Blocklist: IP involucrada en spam, phishing o alojamiento malicioso | `sbl`, `sbl-xbl`, `zen` | Bloquear / Marcar |
| **127.0.0.3** | CSS | Combined Spam Sources: IP detectada como fuente de spam de forma automática | `sbl`, `sbl-xbl`, `zen` | Bloquear / Marcar |
| **127.0.0.4** | XBL | Exploits Blocklist: Equipo comprometido (botnet, malware) que envía spam | `xbl`, `sbl-xbl`, `zen` | Bloquear / Marcar |
| **127.0.0.9** | DROP | Don't Route Or Peer: Rangos de IP utilizados por ciberdelincuentes (siempre se devuelve **además** de otro código) | `sbl`, `sbl-xbl`, `zen` | Bloquear / Marcar |
| **127.0.0.10** | PBL | Policy Blocklist: IP mantenida por el ISP, de una red que no debería enviar correo directamente | `pbl`, `zen` | Bloquear / Marcar (con precaución) |
| **127.0.0.11** | PBL | Policy Blocklist: IP mantenida por Spamhaus, de una red que no debería enviar correo directamente | `pbl`, `zen` | Bloquear / Marcar (con precaución) |
| **127.0.0.30** | BCL | Botnet Controller List: IP que aloja un servidor de Comando y Control (C&C) de una botnet | `sbl`, `sbl-xbl`, `zen` | Bloquear / Marcar |
| **127.0.1.2** | DBL | Domain Blocklist: Dominio de baja reputación (spam) | `dbl` | Bloquear / Marcar |
| **127.0.1.4** | DBL | Domain Blocklist: Dominio relacionado con phishing | `dbl` | Bloquear / Marcar |
| **127.0.1.5** | DBL | Domain Blocklist: Dominio relacionado con malware | `dbl` | Bloquear / Marcar |
| **127.0.1.6** | DBL | Domain Blocklist: Dominio usado como C&C de botnet | `dbl` | Bloquear / Marcar |
| **127.0.1.102** | DBL | Abused-legit: Dominio legítimo comprometido usado para spam | `dbl` | Bloquear / Marcar |
| **127.0.1.103** | DBL | Abused-legit: Dominio legítimo comprometido usado para phishing | `dbl` | Bloquear / Marcar |
| **127.0.1.104** | DBL | Abused-legit: Dominio legítimo comprometido usado para malware | `dbl` | Bloquear / Marcar |
| **127.0.1.105** | DBL | Abused-legit: Dominio legítimo comprometido usado para botnet C&C | `dbl` | Bloquear / Marcar |
| **127.0.1.106** | DBL | Abused-legit: Dominio legítimo comprometido (sin especificar) | `dbl` | Bloquear / Marcar |
| **127.0.2.2 - .24** | ZRD | Zero Reputation Domain: Dominios vistos por primera vez. El número indica antigüedad (2-24 horas) | `zrd` | Marcar (con precaución) |
| **127.255.255.252** | ERROR | Error tipográfico: El nombre de la lista negra está mal escrito | *cualquiera* | **NO BLOQUEAR**. Revisar ortografía del FQDN |
| **127.255.255.254** | ERROR | Consulta a través de resolver público (8.8.8.8, etc.) | *cualquiera* | **NO BLOQUEAR**. Configurar DNS local |
| **127.255.255.255** | ERROR | Exceso de consultas: Superado el límite de la política de uso justo | *cualquiera* | **NO BLOQUEAR**. Reducir velocidad o usar DQS |
| **127.0.1.255** | ERROR | Consulta a DBL con IP en lugar de dominio | `dbl` | **NO BLOQUEAR**. Usar dominio en lugar de IP |

---

### 📝 Notas: 

1. **Códigos de error (`127.255.255.x` y `127.0.1.255`)**  
   Estos códigos **NO** indican que la IP o dominio esté en una lista negra. Son problemas con tu consulta y **no debes bloquear el tráfico basándote en ellos**. Si los ves, revisa tu configuración de DNS o la frecuencia de tus consultas.

2. **`127.0.0.9` (DROP)**  
   Este código siempre se devuelve **además** de otro código de listado (ej. `127.0.0.2`). Indica que la IP pertenece a un rango completo que está en la lista DROP.

3. **`127.0.0.10` y `127.0.0.11` (PBL)**  
   Estas IPs son de redes residenciales o dinámicas que **no deberían enviar correo directamente**. Bloquearlas puede causar falsos positivos si el correo se envía a través del servidor del ISP.

4. **ZRD (`127.0.2.2 - .24`)**  
   El número final (ej. `.12`) indica la antigüedad del dominio en horas. Un dominio visto por primera vez no es necesariamente malicioso, pero merece un escrutinio adicional.

5. **DBL (`127.0.1.x`)**  
   La lista DBL solo funciona con **nombres de dominio**, no con IPs. Si consultas `dbl.spamhaus.org` con una IP invertida, obtendrás `127.0.1.255`.

6. **Uso de `zen.spamhaus.org`**  
   La lista ZEN combina SBL, XBL, PBL y CSS. Al consultar ZEN, recibirás el código de la lista que corresponda (ej. `127.0.0.2` para SBL). **No sabrás de qué lista específica proviene** a menos que consultes cada lista por separado.

---

### 🔧 Referencias:

- [Spamhaus Blocklists - Documentación Oficial](https://www.spamhaus.org/blocklists/)
- [Spamhaus FAQ - Códigos de Respuesta](https://www.spamhaus.org/faq/)
- [Política de Uso Justo (Fair Use Policy)](https://www.spamhaus.org/organization/dnsblusage/)

---



#

http://www.hackingyseguridad.com/

#





