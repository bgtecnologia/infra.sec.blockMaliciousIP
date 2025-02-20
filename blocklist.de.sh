#!/bin/bash

# Nome da lista no ipset
LIST_NAME="blocklist_de"

# Verificar se o ipset está instalado
if ! command -v ipset &> /dev/null; then
	echo "❌ Error: ipset não está instalado, instale antes de executar."
	exit 1
fi

# Verifica se a lista existe
if sudo ipset list -n | grep -q "^$LIST_NAME$"; then
	echo "✅ A lista '$LIST_NAME' existe."
	# Irei dar flush na lista somente no dia 01 de cada mês
	if [ "$(date +%d)" = "01" ]; then
		echo "Limpando a lista em todo o dia 01 de cada mês"
		sudo ipset flush $LIST_NAME
	fi
else
	# Não existindo vou criá-la
    echo "⚠️ A lista '$LIST_NAME' não existe. Criando a lista e aplicando regras ao iptables"
    sudo ipset create $LIST_NAME hash:ip
	# E adicionar regras ao iptables
	iptables -I INPUT -m set --match-set $LIST_NAME src -j DROP
	iptables -I DOCKER-USER -m set --match-set $LIST_NAME src -j DROP

fi

echo "Obtendo a lista do blocklist.de"
wget -O /tmp/blocklist.txt https://lists.blocklist.de/lists/all.txt

echo "Adicionando IPs à lista "
while read IP; do 
	if ! ipset -q test $LIST_NAME $IP; then
		ipset -q -A $LIST_NAME $IP
	fi
done < /tmp/blocklist.txt

echo "✅ Ips da blocklist.de bloqueados"
