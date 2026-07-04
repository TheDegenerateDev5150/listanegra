
#  Tabla Resumen de Listas Negras (RBLs) por Tipo de Amenaza

Esta tabla clasifica todas las listas negras del repositorio `listanegra` según su propósito principal, para que puedas seleccionar las más adecuadas para tu filtrado de correo o seguridad de red.

| Lista | Tipo de Amenaza | Descripción |
|-------|-----------------|-------------|
| **zen.spamhaus.org** | Combinada | Combina SBL, XBL, CSS y PBL de Spamhaus en una sola consulta. La principal fuente de reputación para Microsoft, Google, y miles de empresas. |
| **sbl-xbl.spamhaus.org** | Combinada | Combina la Spamhaus Blocklist (SBL) y la Exploits Blocklist (XBL). |
| **all.spamrats.com** | Combinada | Lista combinada que incluye spam, botnets y proxies. |
| **sbl.spamhaus.org** | Spam Email | IPs involucradas en spam, phishing o alojamiento malicioso. |
| **xbl.spamhaus.org** | Malware/Botnet | Exploits Blocklist - Equipos comprometidos (botnet, malware) que envían spam. |
| **pbl.spamhaus.org** | Política | Policy Blocklist - IPs dinámicas o residenciales que no deberían enviar correo directamente. |
| **css.spamhaus.org** | Spam Email | Combined Spam Sources - IPs que envían correo de baja reputación, sin verificaciones SPF, DKIM, DMARC. |
| **bl.spamcop.net** | Spam Email | Lista dinámica alimentada por reportes de usuarios y spamtraps. Una de las bases de datos de spam más respetadas. |
| **dnsbl.sorbs.net** | Spam Email/Relays | Spam and Open Relay Blocking System - Fuentes de spam y relays abiertos. |
| **dnsbl-1.uceprotect.net** | Spam Email | UCEPROTECT Nivel 1 - IPs individuales que envían spam. |
| **dnsbl-2.uceprotect.net** | Spam Email | UCEPROTECT Nivel 2 - Rangos más amplios si el spam persiste. |
| **dnsbl-3.uceprotect.net** | Spam Email | UCEPROTECT Nivel 3 - Proveedores enteros con alto porcentaje de abuso. |
| **b.barracudacentral.org** | Spam Email | Barracuda Reputation Block List - Basada en volumen de spam y autenticación. |
| **bb.barracudacentral.org** | Spam Email | Barracuda Backup - Lista secundaria de Barracuda. |
| **bl.mailspike.net** | Spam Email | Basada en spamtraps y heurísticas de volumen. |
| **cbl.abuseat.org** | Malware/Botnet | Composite Blocking List - IPs infectadas con malware, bots o proxies abiertos. |
| **backscatter.spameatingmonkey.net** | Spam Email | Backscatter - Correos devueltos a remitentes falsos. |
| **badnets.spameatingmonkey.net** | Malware/Botnet | Redes maliciosas conocidas por enviar spam y malware. |
| **spam.dnsbl.anonmails.de** | Spam Email | Fuentes de spam anónimo. |
| **bl.blocklist.de** | Spam Email | Ataques de fuerza bruta, spam, exploits. |
| **drone.abuse.ch** | Malware/Botnet | Drone - IPs que forman parte de botnets. |
| **ipbl.zeustracker.abuse.ch** | Malware/Botnet | Zeus Tracker - Servidores C&C de la botnet Zeus. |
| **spam.abuse.ch** | Malware/Botnet | Spamhaus de abuse.ch para malware. |
| **virus.rbl.msrbl.net** | Malware/Botnet | Virus - IPs que distribuyen virus. |
| **combined.abuse.ch** | Malware/Botnet | Combinación de listas de abuse.ch (malware). |
| **phishing.rbl.msrbl.net** | Phishing | Phishing - Sitios de suplantación de identidad. |
| **images.rbl.msrbl.net** | Phishing | Imágenes - IPs que alojan imágenes de phishing. |
| **web.rbl.msrbl.net** | Malware/Phishing | Web - Sitios web maliciosos (phishing, malware). |
| **dyna.spamrats.com** | Malware/Botnet | Dyna - IPs dinámicas que forman parte de botnets. |
| **noptr.spamrats.com** | Malware/Botnet | NOPTR - IPs sin registro PTR inverso usadas por botnets. |
| **proxies.dnsbl.sorbs.net** | Proxy | Proxies abiertos (HTTP, SOCKS, etc.) comprometidos. |
| **relays.dnsbl.sorbs.net** | Proxy | Relays SMTP abiertos. |
| **relays.mail-abuse.org** | Proxy | Relays abiertos de mail-abuse.org. |
| **relays.bl.kundenserver.de** | Proxy | Relays abiertos. |
| **dul.dnsbl.sorbs.net** | Política | Dynamic User/Host List - IPs dinámicas (DUHL). |
| **0spam.fusionzero.com** | Spam Email | Lista de spam de FusionZero. |
| **0spam-killlist.fusionzero.com** | Spam Email | Killlist - Lista agresiva de spam de FusionZero. |
| **0spamtrust.fusionzero.com** | Spam Email | Trust - Lista de confianza de FusionZero. |
| **access.redhawk.org** | Spam Email | Lista de spam de RedHawk. |
| **accredit.habeas.com** | Spam Email | Habeas - Lista de correo legítimo. |
| **all.dnsbl.bit.nl** | Spam Email | Bit.nl - Lista combinada de spam. |
| **all.rbl.jp** | Spam Email | RBL Japón - Lista de spam. |
| **all.s5h.net** | Spam Email | S5H - Lista de spam. |
| **asn.routeviews.org** | Política | ASN - Información de sistemas autónomos. |
| **aspath.routeviews.org** | Política | ASPATH - Información de rutas BGP. |
| **bad.psky.me** | Malware/Botnet | Psky - IPs maliciosas. |
| **bitonly.dnsbl.bit.nl** | Spam Email | Bit.nl - Solo spam. |
| **blackholes.mail-abuse.org** | Spam Email | Blackholes - Fuentes de spam. |
| **blacklist.sci.kun.nl** | Spam Email | Sci.kun - Lista de spam. |
| **blacklist.woody.ch** | Spam Email | Woody - Lista de spam. |
| **bl.deadbeef.com** | Spam Email | Deadbeef - Lista de spam. |
| **bl.drmx.org** | Spam Email | DRMX - Lista de spam. |
| **bl.emailbasura.org** | Spam Email | Emailbasura - Lista de spam. |
| **bl.konstant.no** | Spam Email | Konstant - Lista de spam. |
| **bl.mav.com.br** | Spam Email | MAV - Lista de spam. |
| **bl.nszones.com** | Spam Email | NSZones - Lista de spam. |
| **bl.rbl-dns.com** | Spam Email | RBL-DNS - Lista de spam. |
| **bl.scientificspam.net** | Spam Email | Scientificspam - Lista de spam. |
| **bl.score.senderscore.com** | Spam Email | Senderscore - Puntuación de reputación. |
| **bl.shlink.org** | Spam Email | Shlink - Lista de spam. |
| **bl.spamcannibal.org** | Spam Email | Spamcannibal - Lista de spam. |
| **bl.spameatingmonkey.net** | Spam Email | Spameatingmonkey - Lista de spam. |
| **bl.spamstinks.com** | Spam Email | Spamstinks - Lista de spam. |
| **bl.suomispam.net** | Spam Email | Suomispam - Lista de spam. |
| **bl.tiopan.com** | Spam Email | Tiopan - Lista de spam. |
| **block.dnsbl.sorbs.net** | Spam Email | Sorbs - Bloqueo de spam. |
| **bogons.cymru.com** | Política | Bogons - IPs no asignadas (bogon). |
| **bsb.empty.us** | Spam Email | Empty - Lista de spam. |
| **bsb.spamlookup.net** | Spam Email | Spamlookup - Lista de spam. |
| **cdl.anti-spam.org.cn** | Spam Email | Anti-Spam China - Lista de spam. |
| **combined.njabl.org** | Spam Email | NJABL - Lista combinada de spam. |
| **combined.rbl.msrbl.net** | Spam Email | MSRBL - Lista combinada de spam. |
| **csi.cloudmark.com** | Spam Email | Cloudmark - Lista de spam. |
| **db.wpbl.info** | Spam Email | WPBL - Lista de spam. |
| **dnsbl-0.uceprotect.net** | Spam Email | UCEPROTECT Nivel 0 - Lista de spam. |
| **dnsbl.anticaptcha.net** | Spam Email | Anticaptcha - Lista de spam. |
| **dnsbl.aspnet.hu** | Spam Email | ASPNET - Lista de spam. |
| **dnsblchile.org** | Spam Email | DNSBL Chile - Lista de spam. |
| **dnsbl.cobion.com** | Spam Email | Cobion - Lista de spam. |
| **dnsbl.cyberlogic.net** | Spam Email | Cyberlogic - Lista de spam. |
| **dnsbl.inps.de** | Spam Email | INPS - Lista de spam. |
| **dnsbl.justspam.org** | Spam Email | Justspam - Lista de spam. |
| **dnsbl.kempt.net** | Spam Email | Kempt - Lista de spam. |
| **dnsbl.madavi.de** | Spam Email | Madavi - Lista de spam. |
| **dnsbl.net.ua** | Spam Email | Net.ua - Lista de spam. |
| **dnsbl.proxybl.org** | Proxy | ProxyBL - Lista de proxies. |
| **dnsbl.rizon.net** | Spam Email | Rizon - Lista de spam. |
| **dnsbl.rv-soft.info** | Spam Email | RV-Soft - Lista de spam. |
| **dnsbl.rymsho.ru** | Spam Email | Rymsho - Lista de spam. |
| **dnsbl.spam-champuru.livedoor.com** | Spam Email | Livedoor - Lista de spam. |
| **dnsbl.tornevall.org** | Spam Email | Tornevall - Lista de spam. |
| **dnsbl.webequipped.com** | Spam Email | Webequipped - Lista de spam. |
| **dnsbl.zapbl.net** | Spam Email | ZapBL - Lista de spam. |
| **dnsrbl.org** | Spam Email | DNSRBL - Lista de spam. |
| **dnsrbl.swinog.ch** | Spam Email | Swinog - Lista de spam. |
| **dnswl.inps.de** | Política | DNSWL - Lista blanca de DNS. |
| **dsn.rfc-ignorant.org** | Política | RFC-Ignorant - IPs que ignoran RFCs. |
| **dul.pacifier.net** | Política | Pacifier - IPs dinámicas. |
| **dyn.nszones.com** | Política | NSZones - IPs dinámicas. |
| **dynip.rothen.com** | Política | Rothen - IPs dinámicas. |
| **escalations.dnsbl.sorbs.net** | Spam Email | Sorbs - Escalaciones de spam. |
| **eswlrev.dnsbl.rediris.es** | Spam Email | RedIRIS - Lista de spam. |
| **exitnodes.tor.dnsbl.sectoor.de** | Proxy | Tor - Nodos de salida de Tor. |
| **feb.spamlab.com** | Spam Email | Spamlab - Lista de spam. |
| **fnrbl.fast.net** | Spam Email | Fast - Lista de spam. |
| **forbidden.icm.edu.pl** | Spam Email | ICM - Lista de spam. |
| **free.v4bl.org** | Política | V4BL - IPs gratuitas. |
| **geobl.spameatingmonkey.net** | Política | GeoBL - Lista geográfica. |
| **gl.suomispam.net** | Spam Email | Suomispam - Lista de spam. |
| **hil.habeas.com** | Spam Email | Habeas - Lista de spam. |
| **hostkarma.junkemailfilter.com** | Spam Email | Junkemailfilter - Lista de spam. |
| **httpbl.abuse.ch** | Malware/Botnet | HTTPBL - Lista de malware. |
| **hul.habeas.com** | Spam Email | Habeas - Lista de spam. |
| **iadb.isipp.com** | Spam Email | ISIPP - Lista de spam. |
| **iadb2.isipp.com** | Spam Email | ISIPP - Lista de spam. |
| **ips.backscatterer.org** | Spam Email | Backscatterer - Lista de spam. |
| **ips.whitelisted.org** | Política | Whitelisted - Lista blanca. |
| **ip.v4bl.org** | Política | V4BL - IPs. |
| **ispmx.pofon.foobar.hu** | Spam Email | Pofon - Lista de spam. |
| **ix.dnsbl.manitu.net** | Spam Email | Manitu - Lista de spam. |
| **korea.services.net** | Spam Email | Korea - Lista de spam. |
| **l1.bbfh.ext.sorbs.net** | Spam Email | Sorbs - Lista de spam. |
| **l2.bbfh.ext.sorbs.net** | Spam Email | Sorbs - Lista de spam. |
| **l3.bbfh.ext.sorbs.net** | Spam Email | Sorbs - Lista de spam. |
| **l4.bbfh.ext.sorbs.net** | Spam Email | Sorbs - Lista de spam. |
| **list.blogspambl.com** | Spam Email | Blogspam - Lista de spam. |
| **list.dnswl.org** | Política | DNSWL - Lista blanca. |
| **list.quorum.to** | Spam Email | Quorum - Lista de spam. |
| **list.bbfh.org** | Spam Email | BBFH - Lista de spam. |
| **mail-abuse.blacklist.jippg.org** | Spam Email | JIPPG - Lista de spam. |
| **mtawlrev.dnsbl.rediris.es** | Spam Email | RedIRIS - Lista de spam. |
| **netblock.pedantic.org** | Política | Pedantic - Bloques de red. |
| **netblockbl.spamgrouper.to** | Spam Email | Spamgrouper - Lista de spam. |
| **netbl.spameatingmonkey.net** | Spam Email | Spameatingmonkey - Lista de spam. |
| **netscan.rbl.blockedservers.com** | Spam Email | Blockedservers - Lista de spam. |
| **new.spam.dnsbl.sorbs.net** | Spam Email | Sorbs - Nuevo spam. |
| **nobl.junkemailfilter.com** | Spam Email | Junkemailfilter - Lista de spam. |
| **no-more-funn.moensted.dk** | Spam Email | Moensted - Lista de spam. |
| **old.spam.dnsbl.sorbs.net** | Spam Email | Sorbs - Spam antiguo. |
| **opm.tornevall.org** | Proxy | Tornevall - Proxies abiertos. |
| **orvedb.aupads.org** | Spam Email | AUPADS - Lista de spam. |
| **phishing.rbl.msrbl.net** | Phishing | MSRBL - Phishing. |
| **plus.bondedsender.org** | Política | Bondedsender - Remitentes legítimos. |
| **pofon.foobar.hu** | Spam Email | Pofon - Lista de spam. |
| **problems.dnsbl.sorbs.net** | Spam Email | Sorbs - Problemas. |
| **psbl.surriel.com** | Spam Email | PSBL - Lista de spam. |
| **query.bondedsender.org** | Política | Bondedsender - Consulta. |
| **rbl.efnet.org** | Spam Email | EFNET - Lista de spam. |
| **rbl.fasthosts.co.uk** | Spam Email | Fasthosts - Lista de spam. |
| **rbl.interserver.net** | Spam Email | Interserver - Lista de spam. |
| **rbl.iprange.net** | Spam Email | IPRange - Lista de spam. |
| **rbl.lugh.ch** | Spam Email | Lugh - Lista de spam. |
| **rbl.schulte.org** | Spam Email | Schulte - Lista de spam. |
| **rbl.suresupport.com** | Spam Email | Suresupport - Lista de spam. |
| **rbl.talkactive.net** | Spam Email | Talkactive - Lista de spam. |
| **rbl.abuse.ro** | Spam Email | Abuse.ro - Lista de spam. |
| **rbl.blockedservers.com** | Spam Email | Blockedservers - Lista de spam. |
| **rbl.choon.net** | Spam Email | Choon - Lista de spam. |
| **rbl.dns-servicios.com** | Spam Email | DNS-Servicios - Lista de spam. |
| **rbl-plus.mail-abuse.org** | Spam Email | Mail-abuse - Lista de spam. |
| **rbl2.triumf.ca** | Spam Email | Triumf - Lista de spam. |
| **recent.spam.dnsbl.sorbs.net** | Spam Email | Sorbs - Spam reciente. |
| **rep.mailspike.net** | Spam Email | Mailspike - Reputación. |
| **rsbl.aupads.org** | Spam Email | AUPADS - Lista de spam. |
| **rwl.choon.net** | Política | Choon - Lista blanca. |
| **sa-accredit.habeas.com** | Spam Email | Habeas - Lista de spam. |
| **sa.senderbase.org** | Spam Email | Senderbase - Reputación. |
| **sbl.nszones.com** | Spam Email | NSZones - Lista de spam. |
| **score.senderscore.com** | Spam Email | Senderscore - Puntuación. |
| **service.mailwhitelist.com** | Política | Mailwhitelist - Lista blanca. |
| **short.rbl.jp** | Spam Email | RBL Japón - Lista de spam. |
| **singlebl.spamgrouper.com** | Spam Email | Spamgrouper - Lista de spam. |
| **singular.ttk.pte.hu** | Spam Email | TTK - Lista de spam. |
| **sohul.habeas.com** | Spam Email | Habeas - Lista de spam. |
| **spamlist.or.kr** | Spam Email | Korea - Lista de spam. |
| **spam.pedantic.org** | Spam Email | Pedantic - Lista de spam. |
| **spam.rbl.blockedservers.com** | Spam Email | Blockedservers - Lista de spam. |
| **spam.rbl.msrbl.net** | Spam Email | MSRBL - Spam. |
| **spam.spamrats.com** | Spam Email | Spamrats - Spam. |
| **spamguard.leadmon.net** | Spam Email | Leadmon - Lista de spam. |
| **spamsources.fabel.dk** | Spam Email | Fabel - Lista de spam. |
| **srn.surgate.net** | Spam Email | Surgate - Lista de spam. |
| **st.technovision.dk** | Spam Email | Technovision - Lista de spam. |
| **swl.spamhaus.org** | Política | Spamhaus - Lista blanca. |
| **tor.dnsbl.sectoor.de** | Proxy | Tor - Nodos de salida. |
| **tor.efnet.org** | Proxy | EFNET - Tor. |
| **torexit.dan.me.uk** | Proxy | Dan.me.uk - Nodos de salida Tor. |
| **truncate.gbudb.net** | Spam Email | Gbudb - Lista de spam. |
| **trusted.nether.net** | Política | Nether - Lista de confianza. |
| **ubl.unsubscore.com** | Spam Email | Unsubscore - Lista de spam. |
| **unsure.nether.net** | Spam Email | Nether - Lista de spam. |
| **v4.fullbogons.cymru.com** | Política | Bogons - IPs no asignadas. |
| **virbl.bit.nl** | Malware/Botnet | Bit.nl - Virus. |
| **virbl.dnsbl.bit.nl** | Malware/Botnet | Bit.nl - Virus. |
| **vote.drbl.caravan.ru** | Spam Email | Caravan - Lista de spam. |
| **vote.drbldf.dsbl.ru** | Spam Email | DSBL - Lista de spam. |
| **vote.drbl.gremlin.ru** | Spam Email | Gremlin - Lista de spam. |
| **wadb.isipp.com** | Spam Email | ISIPP - Lista de spam. |
| **wbl.triumf.ca** | Spam Email | Triumf - Lista de spam. |
| **whitelist.sci.kun.nl** | Política | Sci.kun - Lista blanca. |
| **whitelist.surriel.com** | Política | Surriel - Lista blanca. |
| **wl.mailspike.net** | Política | Mailspike - Lista blanca. |
| **wl.nszones.com** | Política | NSZones - Lista blanca. |
| **wl.shlink.org** | Política | Shlink - Lista blanca. |
| **work.drbl.caravan.ru** | Spam Email | Caravan - Lista de spam. |
| **work.drbldf.dsbl.ru** | Spam Email | DSBL - Lista de spam. |
| **work.drbl.gremlin.ru** | Spam Email | Gremlin - Lista de spam. |
| **z.mailspike.net** | Spam Email | Mailspike - Lista de spam. |

---
