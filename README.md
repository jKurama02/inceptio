# Inception - Containerized WordPress Infrastructure

## 📋 Panoramica del Progetto

Il progetto **Inception** è un'infrastruttura containerizzata che implementa un sito WordPress completamente funzionale utilizzando Docker e Docker Compose. L'architettura è composta da tre servizi principali che comunicano tra loro in una rete isolata.

## 🎓 Concetti Fondamentali

### **Cos'è Docker e perché lo usiamo?**
**Docker** è una tecnologia di containerizzazione che permette di:
- **Isolare applicazioni**: Ogni servizio gira nel suo "ambiente protetto"
- **Garantire riproducibilità**: Il setup funziona identicamente su qualsiasi macchina
- **Semplificare deployment**: Un comando per avviare tutta l'infrastruttura
- **Migliorare sicurezza**: Servizi separati = superficie d'attacco ridotta

### **Perché 3 container separati invece di uno solo?**
1. **Separazione delle responsabilità**: Ogni container ha un compito specifico
2. **Scalabilità**: Posso aumentare solo le risorse del servizio che ne ha bisogno
3. **Manutenzione**: Posso aggiornare un servizio senza toccare gli altri
4. **Sicurezza**: Se un container viene compromesso, gli altri rimangono protetti
5. **Best Practice**: Principio "one process per container"

### **Come comunicano i container?**
- **Rete Docker dedicata**: `inception` network isola i container dal resto del sistema
- **DNS automatico**: Ogni container è raggiungibile per nome (es: `mariadb`, `wordpress`)
- **Porte interne**: Comunicazione diretta senza esporre servizi all'esterno
- **Solo Nginx esposto**: Unico punto d'ingresso dall'esterno (porta 443)

## 🏗️ Architettura del Sistema

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     NGINX       │    │   WORDPRESS     │    │    MARIADB      │
│   (Proxy SSL)   │────│   (PHP-FPM)     │────│   (Database)    │
│   Port 443      │    │   Port 9000     │    │   Port 3306     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │  INCEPTION NET  │
                    │   (Docker Net)  │
                    └─────────────────┘
                                 │
                    ┌─────────────────┐
                    │    VOLUMES      │
                    │ wordpress_data  │
                    │ mariadb_data    │
                    └─────────────────┘
```

## 🔄 Flusso Operativo Dettagliato

### 1. **Inizializzazione del Sistema**
```bash
make build  # Costruisce le immagini Docker custom
make up     # Avvia i container in sequenza
```

### 2. **Sequenza di Avvio dei Container**

#### **Passo 1: MariaDB Container**
- **Base Image**: Debian Bullseye
- **Processo**: 
  1. **Installa MariaDB server**: Il database engine che gestirà tutti i dati WordPress (posts, utenti, configurazioni)
  2. **Installa curl**: Strumento per testare connettività di rete e fare richieste HTTP durante il setup
  3. **Installa tini**: Process manager che gestisce correttamente i segnali del sistema operativo nel container (evita processi zombie)
  4. **Copia configurazione custom** (`mariadb.conf`): Personalizza le impostazioni del database (binding di rete, charset, ottimizzazioni)
  5. **Esegue script di inizializzazione** (`setup_mariadb.sh`): Automatizza la creazione del database e degli utenti
  6. **Crea database `wordpress`**: Spazio dedicato per memorizzare tutti i dati del sito web
  7. **Crea utente `wpuser`**: Account dedicato con permessi limitati (sicurezza: non usa root per WordPress)
  8. **Configura root password**: Protegge l'account amministratore del database
  9. **Avvia MariaDB in modalità safe**: Modalità che gestisce graceful shutdown e restart automatici

#### **Passo 2: WordPress Container** (dipende da MariaDB)
- **Base Image**: Alpine 3.18 (scelta per leggerezza e sicurezza)
- **Processo**:
  1. **Installa PHP 8.2 + PHP-FPM**: Runtime per eseguire WordPress + process manager per gestire richieste multiple
  2. **Installa estensioni PHP necessarie**: mysqli (connessione database), gd (gestione immagini), curl (HTTP requests), etc.
  3. **Installa WP-CLI**: Tool ufficiale WordPress per automatizzare installazione e configurazione via command line
  4. **Configura utente nginx**: Crea utente dedicato per eseguire PHP-FPM (sicurezza: non root)
  5. **Esegue script di configurazione** (`wp-config.sh`): Automatizza tutto il setup di WordPress
  6. **Scarica WordPress core**: Download dell'ultima versione stabile di WordPress
  7. **Crea `wp-config.php`**: File di configurazione che connette WordPress al database MariaDB
  8. **Installa WordPress**: Inizializzazione del database con tabelle e dati iniziali
  9. **Crea utente admin `anmedyns`**: Account amministratore del sito (nome senza "admin" per sicurezza)
  10. **Crea secondo utente `regularuser`**: Utente con privilegi limitati (requirement del progetto)
  11. **Avvia PHP-FPM in modalità non-daemon**: Rimane attivo per ricevere richieste da Nginx via FastCGI

#### **Passo 3: Nginx Container** (dipende da WordPress)
- **Base Image**: Alpine 3.18 (leggera e sicura)
- **Processo**:
  1. **Installa Nginx**: Web server ad alte performance per servire il sito e gestire SSL
  2. **Installa OpenSSL**: Libreria per generare certificati SSL/TLS
  3. **Genera certificato SSL self-signed**: Crea certificato per HTTPS (requirement: solo connessioni sicure)
  4. **Configura virtual host SSL-only**: Nginx ascolta solo su porta 443 (HTTPS), blocca HTTP
  5. **Configura proxy FastCGI**: Inoltra richieste PHP a WordPress container via protocollo FastCGI
  6. **Configura serving file statici**: CSS, JS, immagini serviti direttamente da Nginx (performance)
  7. **Avvia Nginx**: Web server rimane attivo per gestire tutte le richieste web esterne

### 3. **Comunicazione Inter-Container**

#### **Flusso di una Richiesta HTTP (Spiegazione Dettagliata):**
1. **Client** → `https://anmedyns.42.fr:443`
   - *L'utente digita l'URL nel browser o clicca un link*
   
2. **Nginx** riceve richiesta SSL
   - *Nginx decripta la connessione HTTPS usando il certificato SSL*
   - *Verifica che il client stia usando TLS 1.2 o 1.3 (versioni sicure)*
   
3. **Nginx** analizza il tipo di richiesta:
   - **Se file statico** (immagine, CSS, JS): serve direttamente da `/var/www/html`
     - *Esempio: logo.png viene servito immediatamente senza coinvolgere PHP*
   - **Se file PHP** (pagina WordPress): inoltra a `wordpress:9000` via FastCGI
     - *Esempio: index.php richiede elaborazione server-side*
     
4. **WordPress** (se richiesta PHP):
   - *PHP-FPM riceve la richiesta via protocollo FastCGI*
   - *Esegue il codice PHP di WordPress*
   - *Se necessario, fa query al database MariaDB*
   
5. **MariaDB** (se query database):
   - *Riceve query SQL da WordPress via porta 3306*
   - *Cerca/modifica dati nel database `wordpress`*
   - *Ritorna risultati a WordPress*
   
6. **WordPress** elabora e genera HTML:
   - *Combina dati database + template PHP*
   - *Genera HTML finale della pagina*
   - *Ritorna il risultato a Nginx via FastCGI*
   
7. **Nginx** ritorna risposta finale al client:
   - *Cripta la risposta con SSL*
   - *Invia HTML al browser dell'utente*
   - *Browser renderizza la pagina WordPress*

**Perché questa architettura?**
- **Performance**: Nginx serve file statici velocemente, PHP solo quando necessario
- **Sicurezza**: Database non esposto all'esterno, solo Nginx accessibile
- **Scalabilità**: Posso aggiungere più container WordPress se aumenta il traffico

## 📊 Componenti Tecnici Dettagliati

### **Nginx (Reverse Proxy + SSL Termination)**
```nginx
- Porta esposta: 443 (HTTPS only) - Requirement: solo connessioni sicure
- Protocolli SSL: TLSv1.2, TLSv1.3 - Versioni moderne e sicure
- Certificato: Self-signed per anmedyns.42.fr - Cripta il traffico
- FastCGI: Proxy verso wordpress:9000 - Protocollo ottimizzato PHP
- Document Root: /var/www/html - Directory condivisa con WordPress
```
**Perché Nginx?**: Web server ad alte performance, ottimo per servire file statici e fare da proxy

### **WordPress (Application Server)**
```php
- Runtime: PHP 8.2 + PHP-FPM - Versione moderna PHP con process manager
- Porta interna: 9000 (FastCGI) - Protocollo di comunicazione con Nginx
- Database: MariaDB via mariadb:3306 - Connessione diretta al database
- Utenti: anmedyns (admin), regularuser (author) - Due livelli di accesso
- Volume: /var/www/html - Condiviso con Nginx per file statici
```
**Perché PHP-FPM?**: Gestisce multiple richieste in modo efficiente, migliore performance di mod_php

### **MariaDB (Database Server)**
```sql
- Porta interna: 3306 - Porta standard MySQL/MariaDB
- Database: wordpress - Spazio dedicato per i dati del sito
- Utenti: root (admin), wpuser (limitato) - Separazione privilegi
- Storage: /var/lib/mysql - Directory persistente su volume
- Config: Custom mariadb.conf - Ottimizzazioni per WordPress
```
**Perché MariaDB?**: Fork open-source di MySQL, ottimizzato e compatibile al 100%

## 💾 Gestione dei Dati (Volumi Docker)

### **wordpress_data** (Volume Condiviso)
- **Scopo**: Condivisione file WordPress tra Nginx e WordPress
- **Perché necessario**: Nginx deve servire file statici (CSS, immagini) mentre WordPress li gestisce
- **Contenuto**: 
  - Core WordPress (file PHP dell'applicazione)
  - Themes, plugins (personalizzazioni del sito)
  - Media uploads (immagini caricate dagli utenti)
  - wp-config.php (configurazione database)
- **Mount Point**: `/var/www/html`
- **Persistenza**: I dati sopravvivono anche se i container vengono riavviati

### **mariadb_data** (Volume Database)
- **Scopo**: Persistenza database anche dopo restart/rimozione container
- **Perché necessario**: Senza volume, tutti i dati del sito si perderebbero ad ogni restart
- **Contenuto**:
  - Database files (.ibd, .frm): File binari contenenti posts, utenti, configurazioni
  - Transaction logs: Garantiscono consistenza dei dati in caso di crash
  - Configuration: Impostazioni runtime del database
- **Mount Point**: `/var/lib/mysql` (directory standard MariaDB)
- **Sicurezza**: Volume accessibile solo al container MariaDB

## 🔐 Sicurezza e Configurazione

### **Variabili d'Ambiente (`.env`)**
```env
DOMAIN_NAME=anmedyns.42.fr
WORDPRESS_DB_HOST=mariadb
WORDPRESS_DB_NAME=wordpress
WORDPRESS_USER=wpuser
WORDPRESS_PASSWORD=wppassword
MYSQL_ROOT_PASSWORD=rootpassword
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=wppassword
ADMIN_PASSWORD=the_adminpassword
```

### **Misure di Sicurezza**
- ✅ **SSL/TLS Only**: Nessun traffico HTTP in chiaro
- ✅ **Network Isolation**: Rete Docker dedicata `inception`
- ✅ **No Direct DB Access**: Database non esposto all'host
- ✅ **Environment Variables**: Password fuori dai Dockerfile
- ✅ **Non-Root Processes**: Container con utenti dedicati
- ✅ **Container Restart Policy**: Auto-restart in caso di crash

## 🚀 Risultato Finale

### **Cosa Ottieni:**
1. **Sito WordPress Completo**: Accessibile via `https://anmedyns.42.fr`
2. **Dashboard Admin**: Login con `anmedyns` / `the_adminpassword`
3. **Utente Regular**: Login con `regularuser` / `regularuserpass`
4. **SSL Certificate**: Connessione sicura (self-signed)
5. **Persistenza Dati**: Database e file sopravvivono ai restart
6. **Isolation**: Infrastruttura completamente isolata
7. **Performance**: FastCGI + PHP-FPM per alta performance

### **URLs Disponibili:**
- **Frontend**: `https://anmedyns.42.fr`
- **Admin Panel**: `https://anmedyns.42.fr/wp-admin`
- **Database**: Interno al container (mariadb:3306)

## 🛠️ Comandi Utili

### **Gestione Container**
```bash
make build          # Costruisci immagini
make up             # Avvia infrastruttura
make down           # Ferma container
make clean          # Rimuovi container e immagini
make fclean         # Rimuovi tutto + volumi
make re             # Rebuild completo
```

### **Debug e Monitoring**
```bash
docker ps                                    # Lista container attivi
docker logs nginx                           # Log Nginx
docker logs wordpress                       # Log WordPress  
docker logs mariadb                         # Log MariaDB
docker exec -it wordpress sh                # Shell nel container WordPress
docker exec -it mariadb mariadb -u root -p  # MySQL shell
docker volume ls                            # Lista volumi
docker network ls                           # Lista network
```

### **Accesso ai Dati**
```bash
# Backup del database
docker exec mariadb mariadb-dump -u root -p wordpress > backup.sql

# Accesso ai file WordPress
docker exec -it wordpress ls -la /var/www/html

# Verifica SSL
openssl s_client -connect anmedyns.42.fr:443 -servername anmedyns.42.fr
```

## 🎯 Conformità ai Requisiti 42

- ✅ **Docker Compose**: Orchestrazione multi-container
- ✅ **Custom Dockerfiles**: Uno per ogni servizio
- ✅ **Base Images**: Alpine/Debian (no DockerHub services)
- ✅ **SSL Only**: TLSv1.2/TLSv1.3
- ✅ **Dedicated Containers**: Nginx, WordPress, MariaDB separati
- ✅ **Shared Volumes**: WordPress files condivisi
- ✅ **Database Volume**: Persistenza MariaDB
- ✅ **Docker Network**: Comunicazione isolata
- ✅ **Auto-Restart**: Resilienza ai crash
- ✅ **Two Users**: Admin + regular user
- ✅ **Environment Variables**: Configuration esterna
- ✅ **Domain Name**: anmedyns.42.fr
- ✅ **No Forbidden Practices**: No tail -f, no --link, no host network

---

**Autore**: anmedyns  
**Progetto**: 42 School - Inception  
**Data**: Novembre 2025
