#!/bin/bash
CMDFD='/opt'
WWWFD='/var/www'
DOCROOT='/var/www/html'
PHPMYFD='/var/www/phpmyadmin'
PHPMYCONF="${PHPMYFD}/config.inc.php"
LSDIR='/usr/local/lsws'
LSCONF="${LSDIR}/conf/httpd_config.xml"
LSVCONF="${LSDIR}/DEFAULT/conf/vhconf.xml"
USER=''
GROUP=''
THEME='twentytwenty'
MARIAVER='10.4'
DF_PHPVER='74'
PHPVER='74'
PHP_M='7'
PHP_S='4'
FIREWALLLIST="22 80 443 7080 9200"
PHP_MEMORY='999'
PHP_BIN="${LSDIR}/lsphp${PHPVER}/bin/lsphp"
PHPINICONF=""
WPCFPATH="${DOCROOT}/wp-config.php"
REPOPATH=''
WP_CLI='/usr/local/bin/wp'
MA_COMPOSER='/usr/local/bin/composer'
MA_VER='2.4.2'
OC_VER='3.0.3.7'
PS_VER='1.7.6.7'
COMPOSER_VER='1.10.20'
EMAIL='test@example.com'
APP_ACCT=''
APP_PASS=''
MA_BACK_URL=''
OC_BACK_URL='admin'
PS_BACK_URL='admin'
MEMCACHECONF=''
REDISSERVICE=''
REDISCONF=''
WPCONSTCONF="${DOCROOT}/wp-content/plugins/litespeed-cache/data/const.default.ini"
PLUGIN='litespeed-cache.zip'
BANNERNAME='wordpress'
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
BANNERDST=''
SKIP_WP=0
SKIP_REDIS=0
SKIP_MEMCA=0
app_skip=0
SAMPLE='false'
OSNAMEVER=''
OSNAME=''
OSVER=''
APP='wordpress'
EPACE='        '
USER='www-data'
GROUP='www-data'
REPOPATH='/etc/apt/sources.list.d'

MARIADBCPUARCH=
UBUNTU_V=$(grep 'DISTRIB_RELEASE' /etc/lsb-release | awk -F '=' '{print substr($2,1,2)}')
if [ ${UBUNTU_V} = 14 ] ; then
    OSNAMEVER=UBUNTU14
    OSVER=trusty
    MARIADBCPUARCH="arch=amd64,i386,ppc64el"
elif [ ${UBUNTU_V} = 16 ] ; then
    OSNAMEVER=UBUNTU16
    OSVER=xenial
    MARIADBCPUARCH="arch=amd64,i386,ppc64el"
elif [ ${UBUNTU_V} = 18 ] ; then
    OSNAMEVER=UBUNTU18
    OSVER=bionic
    MARIADBCPUARCH="arch=amd64"
elif [ ${UBUNTU_V} = 20 ] ; then
    OSNAMEVER=UBUNTU20
    OSVER=focal
    MARIADBCPUARCH="arch=amd64"
fi

echo "OSNAMEVER: $OSNAMEVER"
echo "my name: ";  whoami 


ubuntu_pkg_mariadb(){
    apt list --installed 2>/dev/null | grep mariadb-server-${MARIAVER} >/dev/null 2>&1
    if [ ${?} = 0 ]; then
        echoG "Mariadb ${MARIAVER} already installed"
    else
        if [ -e /etc/mysql/mariadb.cnf ]; then
            echoY 'Remove old mariadb'
            rm_old_pkg mariadb-server
        fi
        echo "Install Mariadb ${MARIAVER}"
        echo "add repo~~~~~~~~~~~~~"

        sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
        sudo  add-apt-repository "deb [arch=amd64,arm64,ppc64el] http://mirror.lstn.net/mariadb/repo/${MARIAVER}/ubuntu bionic main"
        #sudo add-apt-repository "deb [arch=amd64,arm64,ppc64el] http://mirror.lstn.net/mariadb/repo/${MARIAVER}/ubuntu focal main"
        if [ "$(grep "mariadb.*${MARIAVER}" /etc/apt/sources.list)" = '' ]; then
            echo '[Failed] to add MariaDB repository'
        fi
        echo 'start update ~~~~~~~~~~~'
        sudo apt update
        echo 'start install~~~~~~~~~~'
        sudo DEBIAN_FRONTEND=noninteractive apt -y -o Dpkg::Options::='--force-confdef' \
            -o Dpkg::Options::='--force-confold' install mariadb-server           
    fi
    echo 'Start-------------------------'
    sudo systemctl start mariadb
    local DBSTATUS=$(systemctl is-active mariadb)
    if [ ${DBSTATUS} = active ]; then
        echo "MARIADB is: ${DBSTATUS}"
    else
        echo "[Failed] Mariadb is: ${DBSTATUS}"
        systemctl status mariadb.service
        exit 1
    fi
}
ubuntu_pkg_mariadb