
<img align="left" alt="Listas Negras IP - hackingyseguridad.com" src="https://github.com/hackingyseguridad/listanegra/blob/main/blacklist.png" style="margin-bottom: 20px;">

## Listanegra

### BlackList IP:

listas negras de IP / Blacklist IP,  son herramientas técnicas  para filtrar y evitar IP o dominios utilizados para: 

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

**(zen.spamhaus.org)[https://www.spamhaus.org/blocklists/]** (ZEN): Lista combinada que reúne la SBL, XBL y PBL en una sola consulta.  Es la principal fuente de reputación para Microsoft (Outlook/Hotmail), Google (Gmail), y miles de empresas.

(SBL) Spamhaus Blocklist: lista de IP de spam o que albergan contenido malicioso. Incluye tanto IP individuales como rangos completos

(XBL) Exploits Blocklist: Lista IP de equipos que han sido comprometidos y se utilizan para enviar spam o malware. 

(PBL) Policy Blocklist : lista de IP que no deberían enviar correo directamente a un servidor de correo.

(CSS): Combined Spam Sources: lista IP que envían correo de baja reputación, sin verificaciones SPF, DKIM, DMARK

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

https://check.spamhaus.org/query/ip/<IP>

<img align="left" alt="Listas Negras IP https://check.spamhaus.org/query/ip/" src="https://github.com/hackingyseguridad/listanegra/blob/main/spamhaus.png" style="margin-bottom: 20px;">

https://www.spamhaus.org/xbl/

https://www.abuseat.org/

https://www.abuseipdb.com/

https://otx.alienvault.com/

https://www.shodan.io/

https://whatismyipaddress.com/blacklist-check

https://blacklistalert.org/

https://www.dnsbl.info/

https://check.spamhaus.org/query/ip/$IP

https://mxtoolbox.com/

https://multirbl.valli.org/lookup/$IP.html

## Instalar Git

```bash
git clone https://github.com/hackingyseguridad/listanegra.git
cd listanegra
chmod +x *.sh
```

### Consulta IPs en listas negras, blacklist IP

./listanegra.sh     consulta mi IP actual

./listanegra2.sh    consulta IPv4 o IPv6

./checkip.sh        consulta una IP

./check2.sh         consulta desde fichero  ip.txt


#

http://www.hackingyseguridad.com/

#



