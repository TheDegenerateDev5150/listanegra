<img align="left" alt="Listas Negras IP - hackingyseguridad.com" src="https://github.com/hackingyseguridad/listanegra/blob/main/blacklist.png" style="margin-bottom: 20px;">

## Listanegra

### BlackList IP:

listas negras de IP / Blacklist IP,  son herramientas técnicas , para filtrar y evitar IP o dominios utilizados para: 

1º.- Spam de correo electronico, Phissing email, SCAM. Spam distribuido en múltiples IPs. Spam support services. Servidores de bulletproof hosting. Spambots	Equipos enviando spam localmente

2º.- Phishing sites. Sitios de suplantación de identidad. 

3º.- Malware distribution. Sitios que distribuyen malware. IPs infectadas	PCs/equipos con malware

4º.- Botnet C&C. Servidores de control de botnets. Botnet zombies	Equipos parte de botnets.

5º.- Proxy abiertos	Proxies HTTP/SOCKS comprometidos.

###  Impacto:

estar listado en Blacklist lista negra podría tener alguna consecuencia por bloqueos y reputación en listas 
usadas por algunos firewall y tecnologías de seguridad:

1. correo-email: Los servidores de destino rechazarán automáticamente emails o los enviarán directo a la carpeta de spam.

2. La IP o el rango, aparecemos como no confiables, ante los proveedores de servicios de internet (ISPs).

3. Bloqueos/filtros: en algunos casos, se puede bloquear el acceso a servicios en la nube que validan la seguridad de la IP, si estas aparecen listadas.

Por ejemplo :

**zen.spamhaus.org** Es la principal fuente de reputación para Microsoft (Outlook/Hotmail), Google (Gmail), y miles de empresas.

**bl.spamcop.net** SpamCop es una de las bases de datos de spam más respetadas. 

**dnsbl.sorbs.net** y dnsbl-1.uceprotect.net Son listas muy estrictas. Muchos servidores de correo las 
usan para puntuar negativamente el correo entrante (lo que hace que tus emails vayan a la carpeta 
de SPAM).

**barracudacentral.org** Es el sistema de reputación de Barracuda Networks, uno de los firewalls de 
email más vendidos del mundo.


### Consulta manual IP o dominio en lista negra ( blacklist )

https://whatismyipaddress.com/blacklist-check

https://blacklistalert.org/

https://www.dnsbl.info/

https://check.spamhaus.org/query/ip/$IP

https://mxtoolbox.com/

https://multirbl.valli.org/lookup/$IP.html

## Instalar Git

git clone https://github.com/hackingyseguridad/listanegra

cd listanegra

chmod 777 *

### Consulta IPs en listas negras, blacklist IP

./listanegra.sh     consulta mi IP actual

./listanegra2.sh    consulta IPv4 o IPv6

./checkip.sh        consulta una IP

./check2.sh         consulta desde fichero  ip.txt

#

http://www.hackingyseguridad.com/

#








