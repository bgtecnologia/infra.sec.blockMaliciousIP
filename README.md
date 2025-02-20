# infra.sec.blockMaliciousIP
Conjuntos de scripts para bloquear acesso de IPS maliciosos a servidores utilizando IPSET e IPTABLES

## Requisitos
Você precisa ter o ipset instalado no servidor

### Bloqueando acessos de IPs da rede TOR
Arquivo: `tor-network.sh`
Este vai fazer download da relação de ips da rede tor a partir do projeto https://github.com/SecOps-Institute e repositório https://github.com/platformbuilds/Tor-IP-Addresses inseri-los em uma list do ipset e adicionar essa lista como bloqueada no IPTables.

Utilizo esse repositório diretamente em vez da lista da própria tor-network (https://check.torproject.org/torbulkexitlist) pois realizei testes utilizando a rede tor e os ips utilizados não estavam nessa lista, mas estavam na disponibilizada pelo SecOPs, não sei porque disso.

Para começar a impedir os acessos você deve executar o script `./tor-network.sh`

Esse bloqueio não será persistido caso o servidor seja reiniciado, recomendo a você rodar o script todos os dias via cron. Todo dia 01 a lista de IPs será limpa e repopulada

`0 0 * * * ~/infra.sec.blockMaliciousIP/tor-network.sh`

### Bloqueando acessos de IPs registrados na blocklist.de
Arquivo: `blocklist.de.sh`
Este vai fazer download da relação de ips do site [blocklist.de](https://www.blocklist.de/) e inseri-los em uma list do ipset e adicionar essa lista como bloqueada no IPTables.

Para começar a impedir os acessos você deve executar o script `./blocklist.de.sh`

Esse bloqueio não será persistido caso o servidor seja reiniciado, recomendo a você rodar o script todos os dias via cron. Todo dia 01 a lista de IPs será limpa e repopulada

`0 0 * * * ~/infra.sec.blockMaliciousIP/blocklist.de.sh`

