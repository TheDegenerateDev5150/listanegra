<img align="left" alt="Listas Negras IP" src="https://github.com/hackingyseguridad/listanegra/blob/main/blacklist.png" width="120" style="margin-right: 20px; margin-bottom: 20px;">

# Listanegra

**Repositorio de Listas Negras (Blacklists) de IPs y dominios maliciosos.**

Herramientas técnicas para filtrar y bloquear direcciones IP y dominios utilizados en actividades maliciosas.

### ¿Para qué sirven estas listas?

Las listas negras permiten detectar y bloquear:

1. **Spam y Phishing**
   - Envío masivo de correo no deseado
   - Campañas de phishing y scams
   - Servidores de *bulletproof hosting*
   - Spambots

2. **Sitios de Phishing**
   - Páginas falsas de suplantación de identidad

3. **Distribución de Malware**
   - Sitios que hospedan malware
   - Equipos infectados (bots, troyanos, etc.)

4. **Botnets**
   - Servidores de comando y control (C&C)
   - Zombies infectados

5. **Proxies Abiertos**
   - Proxies HTTP/SOCKS comprometidos o abusados

---

## Impacto de estar en una lista negra

Aparecer en una blacklist puede tener consecuencias graves:

- **Correo electrónico**: Tus emails son rechazados o enviados directamente a spam.
- **Reputación**: Proveedores de internet (ISPs) y servicios en la nube te consideran no confiable.
- **Bloqueos**: Restricciones en servicios de hosting, VPS, email marketing, etc.

### Listas negras más importantes

- **zen.spamhaus.org** — La más usada por Microsoft, Google y miles de empresas.
- **bl.spamcop.net** — Muy respetada en la comunidad anti-spam.
- **dnsbl.sorbs.net** y **dnsbl-1.uceprotect.net** — Listas muy estrictas.
- **barracudacentral.org** — Usada por firewalls de email Barracuda.

---

## Umbral Crítico: 20% de IPs Listadas en un AS

Las listas más estrictas (como UCEPROTECT Level 3 o Spamhaus) pueden **bloquear todo un proveedor** si:

> **20% o más de sus IPs activas** aparecen en listas negras.

En ese caso, el Sistema Autónomo (AS) se considera **"fuera de control"**.

Spamhaus publica diariamente el **Top 10 Worst ASNs** (los peores proveedores del mundo). Estar en esa lista provoca bloqueos masivos a nivel global.

---

## Cómo consultar si una IP o dominio está en lista negra

- [WhatIsMyIPAddress Blacklist Check](https://whatismyipaddress.com/blacklist-check)
- [BlacklistAlert.org](https://blacklistalert.org/)
- [DNSBL.info](https://www.dnsbl.info/)
- [Spamhaus Check](https://check.spamhaus.org/)
- [MXToolbox](https://mxtoolbox.com/)
- [MultiRBL](https://multirbl.valli.org/)

---

## Uso del repositorio

```bash
git clone https://github.com/hackingyseguridad/listanegra.git
cd listanegra
chmod +x *.sh
