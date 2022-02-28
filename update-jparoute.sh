#!/bin/sh

updateIPV4() {
    curl -4 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | grep JP | grep ipv4 | awk -F'|' '{printf("%s/%d\n", $4, 32-log($5)/log(2))}' > /usr/share/xray/jparoute.ipset

    ipset -! create tp_spec_dst_jparoute4 hash:net maxelem 16384
    ipset flush tp_spec_dst_jparoute4

    for address in $(cat /usr/share/xray/jparoute.ipset)
    do
        ipset add tp_spec_dst_jparoute4 $address
    done
}

updateIPV6() {
    curl -4 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | grep JP | grep ipv6 | awk -F'|' '{printf("%s/%d\n", $4, $5)}' > /usr/share/xray/jparoute6.ipset

    ipset -! create tp_spec_dst_jparoute6 hash:net maxelem 4096 family inet6
    ipset flush tp_spec_dst_jparoute6

    for address in $(cat /usr/share/xray/jparoute6.ipset)
    do
        ipset add tp_spec_dst_jparoute6 $address
    done
}

set -o errexit
set -o pipefail

if [ $1 == '-4' ]
then
    updateIPV4
elif [ $1 == '-6' ]
then
    updateIPV6
else
    updateIPV4
    updateIPV6
fi
