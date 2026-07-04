
### 📊 Tabla Completa de Códigos de Respuesta de Spamhaus

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


