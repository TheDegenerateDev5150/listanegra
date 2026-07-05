<img align="left" alt="Listas Negras IP - hackingyseguridad.com" src="https://github.com/hackingyseguridad/listanegra/blob/main/blacklist.png" style="margin-bottom: 20px;">

## Listanegra

### BlackList IP:

[listas negras](LISTAS.md) de IP / Blacklist IP,  son herramientas técnicas  para filtrar y evitar IP o dominios utilizados para: 

1º.- Spam de correo electronico, Phissing email, SCAM. Spam distribuido en múltiples IPs. Spam support services. Servidores de bulletproof hosting. Spambots	Equipos enviando spam localmente

2º.- Phishing sites. Sitios de suplantación de identidad. 

3º.- Malware distribution. Sitios que distribuyen malware. IPs infectadas	PCs/equipos con malware

4º.- Botnet C&C. Servidores de control de botnets. Botnet zombies	Equipos parte de botnets.

5º.- Proxy abiertos	Proxies HTTP/SOCKS comprometidos.

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

**dnsbl.sorbs.net** y dnsbl-1.uceprotect.net Son listas muy estrictas. Muchos servidores de correo las 
usan para puntuar negativamente el correo entrante (lo que hace que tus emails vayan a la carpeta 
de SPAM).

**barracudacentral.org** Es el sistema de reputación de Barracuda Networks, uno de los firewalls de 
email más vendidos del mundo.

### El umbral crítico: 20 % de IP Listadas de un AS (BGP sistema autonomo)

Las listas negras más estrictas a nivel de red (como UCEPROTECT Nivel 3 o los sistemas de reputación de Spamhaus) automatizan el bloqueo de un AS completo bajo estas condiciones:

**20% de sus IPs activas listadas:** Si una de cada cinco IPs de un proveedor está listada, los filtros consideran que el AS está ***"fuera de control"***.

Aparecer en el Top de los Peores (Top 10 Worst ASNs): Organizaciones como Spamhaus publican diariamente una lista de los  **10 AS Sistemas Autónomos** con peor comportamiento del mundo. Si un ISP entra ahí, cientos de miles de servidores de correo en todo el planeta activan automáticamente una regla de bloqueo preventivo de todo su rango.

### Consulta manual IP o dominio en lista negra ( blacklist )

Por ejemplo.:  https://check.spamhaus.org/query/ip/80.58.71.71

<img align="left" alt="Listas Negras IP https://check.spamhaus.org/query/ip/" src="https://github.com/hackingyseguridad/listanegra/blob/main/spamhaus.png" style="margin-bottom: 20px;">

###

| **URL** | **Descripción breve** |
| :--- | :--- |
| https://check.spamhaus.org/query/ip/ | **Verificador oficial de Spamhaus**. Consulta el estado de una IP en sus listas (SBL, XBL, PBL, CSS). |
| https://multirbl.valli.org/lookup/$IP.html | **Verificador múltiple**. Comprueba una IP en más de 120 listas RBL/DNSBL diferentes. |
| https://whatismyipaddress.com/blacklist-check | **Herramienta de verificación**. Consulta el estado de tu IP en unas 50 bases de datos antispam. |
| https://blacklistalert.org/ | **Servicio de monitorización**. Permite verificar IPs/dominios y recibir alertas sobre listados. |
| https://www.dnsbl.info/ | **Buscador de DNSBL**. Consulta el estado de una IP en más de 100 listas negras basadas en DNS. |
| https://mxtoolbox.com/ | **Conjunto de herramientas de red**. Incluye un verificador que chequea IPs contra 105 listas DNSBL. |
| https://www.abuseipdb.com/ | **Base de datos colaborativa**. Permite consultar y reportar IPs que han realizado actividades maliciosas. |
| https://www.abuseat.org/ | **Sitio web oficial de la CBL (Composite Blocking List)**. Informativo sobre esta lista negra específica. |

## Instalar Git

```bash
git clone https://github.com/hackingyseguridad/listanegra.git
cd listanegra
chmod +x *.sh
```


### 📜 Scripts 

| Script | Función Principal | Modo de Uso | Descripción / Características |
| :--- | :--- | :--- | :--- |
| **`consulta.sh`** | **Lista múltiples RBLs desde archivo**: Lee las listas negras a consultar desde `listas.txt` y las IPs desde `ip.txt`, con rotación de DNS desde `dns.txt`. | `./consulta.sh` | Este script es el más completo. Permite personalizar tanto las listas negras (FQDNs) como los servidores DNS, y consulta **todas** las listas para cada IP. Guarda los resultados en `resultado.txt`. |
| **`listanegra.sh`** | Consulta la IP pública actual del equipo y la verifica en listas negras. | `./listanegra.sh` | Útil para un chequeo rápido de tu propia IP de salida. No requiere argumentos. |
| **`listanegra2.sh`** | Consulta una dirección IPv4 o IPv6 específica. | `./listanegra2.sh <IP>` | Permite consultar una IP arbitraria (pública o privada). Soporta IPv4 e IPv6. |
| **`spamhaus.sh`** | Consulta las listas de Spamhaus (SBL, XBL, PBL, CSS) para las IPs en `ip.txt` de forma secuencial. | `./spamhaus.sh` | Versión dedicada a Spamhaus. Identifica el nombre exacto de la lista en la que está la IP (ej. `SBL`, `XBL`) para las IPs de `ip.txt`. |
| **`spamhaus2.sh`** | Consulta las listas de Spamhaus desde `ip.txt` mostrando el nombre exacto de la lista. | `./spamhaus2.sh` | Similar a `spamhaus.sh`, probablemente con alguna variación en la salida o en el manejo de errores. |

### 🔧 Archivos de Configuración (de entrada/salida)

| Archivo | Propósito | Formato |
| :--- | :--- | :--- |
| **`ip.txt`** | Archivo de entrada para la mayoría de scripts . Contiene las IPs a verificar, una por línea. | Ejemplo: `8.8.8.8` <br> `1.1.1.1` |
| **`listas.txt`** | Archivo de configuración para `consulta.sh`. Contiene un FQDN de lista negra por línea. | Ejemplo: `zen.spamhaus.org` <br> `bl.spamcop.net` |
| **`dns.txt`** | Archivo de configuración para `consulta.sh`. Contiene un servidor DNS por línea, que se rotan para distribuir las consultas. | Ejemplo: `8.8.8.8` <br> `1.1.1.1` |
| **`resultado.txt`** | Archivo de salida generado por `consulta.sh`. Almacena los resultados de las consultas para cada IP. | (Generado automáticamente) |


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








