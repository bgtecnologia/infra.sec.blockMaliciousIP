#!/bin/bash

# Nome da lista no ipset
LIST_NAME="tor"

# Check if ipset is installed
if ! command -v ipset &> /dev/null; then
	echo "❌ Error: ipset não está instalado, instale antes de executar."
	exit 1
fi

# Verifica se a lista existe
if sudo ipset list -n | grep -q "^$LIST_NAME$"; then
	#Irei dar flush na lista somente no dia 01 de cada mês
	if [ "$(date +%d)" = "01" ]; then
		echo "✅ A lista '$LIST_NAME' existe. Limpando a lista..."
		sudo ipset flush $LIST_NAME
	fi
else
	#Não existindo vou cria-la
    echo "⚠️ A lista '$LIST_NAME' não existe. Criando a lista e aplicando regras ao iptables"
    sudo ipset create $LIST_NAME hash:ip
	#E adicionar regras ao iptables
	iptables -I INPUT -m set --match-set $LIST_NAME src -j DROP
	iptables -I DOCKER-USER -m set --match-set $LIST_NAME src -j DROP

fi

echo "Carregando a lista de IPs da rede tor no ipset"
curl -sSL "https://raw.githubusercontent.com/SecOps-Institute/Tor-IP-Addresses/master/tor-exit-nodes.lst" | sed '/^#/d' | while read IP; do
	if ! ipset -q test $LIST_NAME $IP; then
		ipset -q -A $LIST_NAME $IP
	fi
done

echo "✅ Ips da rede tor bloqueados"
