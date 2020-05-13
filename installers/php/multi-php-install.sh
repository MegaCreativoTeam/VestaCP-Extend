#!/bin/bash

# Official VestaCP Extends Installation Script
# =============================================
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#  Author: Brayan Rincon <brayan262@gmail.com>
#  Created: 11/05/2020
#  Last updated: 11/05/2020
#  Version: 1.0.0
#
#  Supported Operating Systems:
#  - CentOS 6/7/8 Minimal
#  - Ubuntu server 14.04/16.04/18.04
#  - Debian 7/8
#  - 32bit and 64bit

INSTALLER_VERSION="master"
REPO="https://raw.githubusercontent.com/megacreativo/VestaCP-Extend/$INSTALLER_VERSION"


h1() {
    echo "\e[1m\e[34m$1\e[0m"
}

h2() {
    echo "\n\e[21m\e[94m$1\e[0m"
}

success() {
    echo "\e[42m\e[4m[Done]\e[0m $1"
}

failed() {
    echo -"\e[41m\e[4m[Fail]\e[0m $1"
}

# Am I root?
is_root(){
    if [ "x$(id -u)" != 'x0' ]; then
        failed 'Error: this script can only be executed by root'
        exit 1
    fi
}

if [ -f /etc/centos-release ]; then
    OS="CentOs"
    VERFULL=$(sed 's/^.*release //;s/ (Fin.*$//' /etc/centos-release)
    VER=${VERFULL:0:1} # return 6 or 7
elif [ -f /etc/lsb-release ]; then # Ubuntu
    OS=$(grep DISTRIB_ID /etc/lsb-release | sed 's/^.*=//')
    VER=$(grep DISTRIB_RELEASE /etc/lsb-release | sed 's/^.*=//')    
elif [ -f /etc/os-release ]; then
    OS=$(grep -w ID /etc/os-release | sed 's/^.*=//')
    VER=$(grep VERSION_ID /etc/os-release | sed 's/^.*"\(.*\)"/\1/')
else
    OS=$(uname -s)
    VER=$(uname -r)
fi

ARCH=$(uname -m)


if [[ "$OS" = "CentOs" || "$OS" = "Ubuntu" || "$OS" = "debian" ]]; then
    success "Operating System Detected: $OS $VER $ARCH"
else
    failed "Operating System Detected: $OS $VER $ARCH"
    echo -e "  Sorry, your system does not meet the minimum requirements to continue with the installation."
fi


#####################################################
### Display the 'welcome' splash/user warning info
#####################################################
welcome(){
    clear
    echo ""
    h1 " __  __       _ _   _       ____  _   _ ____   "
    h1 "|  \/  |_   _| | |_(_)     |  _ \| | | |  _ \  "
    h1 "| |\/| | | | | | __| |_____| |_) | |_| | |_) | "
    h1 "| |  | | |_| | | |_| |_____|  __/|  _  |  __/  "
    h1 "|_|  |_|\__,_|_|\__|_|     |_|   |_| |_|_|     "
    echo ""
}

pre_install(){
	sudo apt update

	# Add the ondrej/php which has PHP 7.x package and other required PHP extensions
	sudo apt install software-properties-common python-software-properties -y
	sudo LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php -y
	sudo apt update

    echo "Enabling proxy_fcgi setenvif"
    a2enmod proxy_fcgi setenvif
    service apache2 restart
}

install_php_56() {
    apt -y install php5.6-mbstring php5.6-bcmath php5.6-cli php5.6-curl php5.6-fpm php5.6-gd php5.6-intl php5.6-mcrypt php5.6-mysql php5.6-soap php5.6-xml php5.6-zip php5.6-memcache php5.6-memcached
    update-rc.d php5.6-fpm defaults
    a2enconf php5.6-fpm

    sudo service apache2 restart

    cp -r /etc/php/5.6/ /root/vst_install_backups/php5.6/
    # rm -f /etc/php/5.6/fpm/pool.d/*
    wget -nv -q "$REPO/includes/apache2/PHP-FPM-56.stpl" -O /usr/local/vesta/data/templates/web/apache2/PHP-FPM-56.stpl
    wget -nv -q "$REPO/includes/apache2/PHP-FPM-56.tpl" -O /usr/local/vesta/data/templates/web/apache2/PHP-FPM-56.tpl
    wget -nv -q "$REPO/includes/apache2/PHP-FPM-56.sh" -O /usr/local/vesta/data/templates/web/apache2/PHP-FPM-56.sh
    
    chmod a+x /usr/local/vesta/data/templates/web/apache2/PHP-FPM-56.sh
    
    mkdir -p /root/vesta-temp-dl/vesta/patch
    wget -nv -q "$REPO/resources/patches/php5.6.patch" -O /root/vesta-temp-dl/vesta/patch/php5.6.patch
    patch -p1 --directory=/ </root/vesta-temp-dl/vesta/patch/php5.6.patch
    rm -rf /root/vesta-temp-dl
}

install_php_70() {
    apt -y install php7.0-mbstring php7.0-bcmath php7.0-cli php7.0-curl php7.0-fpm php7.0-gd php7.0-intl php7.0-mcrypt php7.0-mysql php7.0-soap php7.0-xml php7.0-zip php7.0-memcache php7.0-memcached
    update-rc.d php7.0-fpm defaults
    a2enconf php7.0-fpm
    sudo service apache2 restart

    cp -r /etc/php/7.0/ /root/vst_install_backups/php7.0/
    # rm -f /etc/php/7.0/fpm/pool.d/*

    wget -nv -q "$REPO/includes/apache2/PHP-FPM-70.stpl" -O /usr/local/vesta/data/templates/web/apache2/PHP-FPM-70.stpl
    wget -nv -q "$REPO/includes/apache2/PHP-FPM-70.tpl" -O /usr/local/vesta/data/templates/web/apache2/PHP-FPM-70.tpl
    wget -nv -q "$REPO/includes/apache2/PHP-FPM-70.sh" -O /usr/local/vesta/data/templates/web/apache2/PHP-FPM-70.sh
    
    chmod a+x /usr/local/vesta/data/templates/web/apache2/PHP-FPM-70.sh
    
    if [[ "$OS" = "debian" ]]; then
        if [[ "$VER" = "9" ]]; then
            cp /etc/php/7.0/apache2/php.ini /etc/php/7.0/fpm/php.ini
        fi
        if [[ "$VER" = "10" ]]; then
            cp /etc/php/7.3/fpm/php.ini /etc/php/7.0/fpm/php.ini
        fi
    fi
}

install_php_71() {
    apt -y install php7.1-mbstring php7.1-bcmath php7.1-cli php7.1-curl php7.1-fpm php7.1-gd php7.1-intl php7.1-mcrypt php7.1-mysql php7.1-soap php7.1-xml php7.1-zip php7.1-memcache php7.1-memcached
    update-rc.d php7.1-fpm defaults
    a2enconf php7.1-fpm
    sudo service apache2 restart

    cp -r /etc/php/7.1/ /root/vst_install_backups/php7.1/
    # rm -f /etc/php/7.1/fpm/pool.d/*
    wget -nv -q "$REPO/includes/apache2/PHP-FPM-71.stpl" -O /usr/local/vesta/data/templates/web/apache2/PHP-FPM-71.stpl
    wget -nv -q "$REPO/includes/apache2/PHP-FPM-71.tpl" -O /usr/local/vesta/data/templates/web/apache2/PHP-FPM-71.tpl
    wget -nv -q "$REPO/includes/apache2/PHP-FPM-71.sh" -O /usr/local/vesta/data/templates/web/apache2/PHP-FPM-71.sh
    
    chmod a+x /usr/local/vesta/data/templates/web/apache2/PHP-FPM-71.sh
    
    if [[ "$OS" = "debian" ]]; then
        if [[ "$VER" = "9" ]]; then
            cp /etc/php/7.0/apache2/php.ini /etc/php/7.1/fpm/php.ini
        fi
        if [[ "$VER" = "10" ]]; then
            cp /etc/php/7.3/fpm/php.ini /etc/php/7.1/fpm/php.ini
        fi
    fi
}

install_php_72() {
    apt -y install php7.2-mbstring php7.2-bcmath php7.2-cli php7.2-curl php7.2-fpm php7.2-gd php7.2-intl php7.2-mysql php7.2-soap php7.2-xml php7.2-zip php7.2-memcache php7.2-memcached
    update-rc.d php7.2-fpm defaults
    a2enconf php7.2-fpm
    sudo service apache2 restart

    cp -r /etc/php/7.2/ /root/vst_install_backups/php7.2/
    # rm -f /etc/php/7.2/fpm/pool.d/*

    wget -nv -q "$REPO/includes/apache2/PHP-FPM-72.stpl" -O /usr/local/vesta/data/templates/web/apache2/PHP-FPM-72.stpl
    wget -nv -q "$REPO/includes/apache2/PHP-FPM-72.tpl" -O /usr/local/vesta/data/templates/web/apache2/PHP-FPM-72.tpl
    wget -nv -q "$REPO/includes/apache2/PHP-FPM-72.sh" -O /usr/local/vesta/data/templates/web/apache2/PHP-FPM-72.sh
    
    chmod a+x /usr/local/vesta/data/templates/web/apache2/PHP-FPM-72.sh
    
    if [[ "$OS" = "debian" ]]; then
        if [[ "$VER" = "9" ]]; then
            cp /etc/php/7.0/apache2/php.ini /etc/php/7.2/fpm/php.ini
        fi
        if [[ "$VER" = "10" ]]; then
            cp /etc/php/7.3/fpm/php.ini /etc/php/7.2/fpm/php.ini
        fi
    fi
}

install_php_73(){
    apt -y install php7.3-mbstring php7.3-bcmath php7.3-cli php7.3-curl php7.3-fpm php7.3-gd php7.3-intl php7.3-mysql php7.3-soap php7.3-xml php7.3-zip php7.3-memcache php7.3-memcached
    update-rc.d php7.3-fpm defaults
    a2enconf php7.3-fpm
    sudo service apache2 restart

    cp -r /etc/php/7.3/ /root/vst_install_backups/php7.3/
    # rm -f /etc/php/7.3/fpm/pool.d/*

    wget -nv -q "$REPO/includes/apache2/PHP-FPM-73.stpl" -O /usr/local/vesta/data/templates/web/apache2/PHP-FPM-73.stpl
    wget -nv -q "$REPO/includes/apache2/PHP-FPM-73.tpl" -O /usr/local/vesta/data/templates/web/apache2/PHP-FPM-73.tpl
    wget -nv -q "$REPO/includes/apache2/PHP-FPM-73.sh" -O /usr/local/vesta/data/templates/web/apache2/PHP-FPM-73.sh
    
    wget -nv -q "$REPO/includes/apache2/PHP-FPM-73-public.stpl" -O /usr/local/vesta/data/templates/web/apache2/PHP-FPM-73-public.stpl
    wget -nv -q "$REPO/includes/apache2/PHP-FPM-73-public.tpl" -O /usr/local/vesta/data/templates/web/apache2/PHP-FPM-73-public.tpl
    wget -nv -q "$REPO/includes/apache2/PHP-FPM-73-public.sh" -O /usr/local/vesta/data/templates/web/apache2/PHP-FPM-73-public.sh
    
    chmod a+x /usr/local/vesta/data/templates/web/apache2/PHP-FPM-73.sh
    chmod a+x /usr/local/vesta/data/templates/web/apache2/PHP-FPM-73-public.sh
    
    if [[ "$OS" = "debian" ]]; then
        if [[ "$VER" = "9" ]]; then
            cp /etc/php/7.0/apache2/php.ini /etc/php/7.3/fpm/php.ini
        fi
    fi
}

install_php_74(){ 
    apt -y install php7.4-mbstring php7.4-bcmath php7.4-cli php7.4-curl php7.4-fpm php7.4-gd php7.4-intl php7.4-mysql php7.4-soap php7.4-xml php7.4-zip php7.4-memcache php7.4-memcached
    update-rc.d php7.4-fpm defaults
    a2enconf php7.4-fpm
    sudo service apache2 restart

    cp -r /etc/php/7.4/ /root/vst_install_backups/php7.4/
    wget -nv -q "$REPO/includes/apache2/PHP-FPM-74.stpl" -O /usr/local/vesta/data/templates/web/apache2/PHP-FPM-74.stpl
    wget -nv -q "$REPO/includes/apache2/PHP-FPM-74.tpl" -O /usr/local/vesta/data/templates/web/apache2/PHP-FPM-74.tpl
    wget -nv -q "$REPO/includes/apache2/PHP-FPM-74.sh" -O /usr/local/vesta/data/templates/web/apache2/PHP-FPM-74.sh
    
    wget -nv -q "$REPO/includes/apache2/PHP-FPM-74-public.stpl" -O /usr/local/vesta/data/templates/web/apache2/PHP-FPM-74-public.stpl
    wget -nv -q "$REPO/includes/apache2/PHP-FPM-74-public.tpl" -O /usr/local/vesta/data/templates/web/apache2/PHP-FPM-74-public.tpl
    wget -nv -q "$REPO/includes/apache2/PHP-FPM-74-public.sh" -O /usr/local/vesta/data/templates/web/apache2/PHP-FPM-74-public.sh
    
    chmod a+x /usr/local/vesta/data/templates/web/apache2/PHP-FPM-74.sh
    chmod a+x /usr/local/vesta/data/templates/web/apache2/PHP-FPM-74-public.sh

    if [[ "$OS" = "debian" ]]; then
        if [[ "$VER" = "9" ]]; then
            cp /etc/php/7.0/apache2/php.ini /etc/php/7.4/fpm/php.ini
        fi
        if [[ "$VER" = "10" ]]; then
            cp /etc/php/7.3/fpm/php.ini /etc/php/7.4/fpm/php.ini
        fi
    fi
}

finalize(){
    apt update
    apt upgrade -y

    if [[ "$OS" = "debian" ]]; then
        if [[ "$VER" = "10" ]]; then
            a2dismod ruid2
            a2dismod suexec
            a2dismod php5.6
            a2dismod php7.0
            a2dismod php7.1
            a2dismod php7.2
            a2dismod php7.3
            a2dismod php7.4
            a2dismod mpm_prefork
            a2enmod mpm_event
            service apache2 restart
        fi
    fi
}

setup(){
    is_root
    welcome
    pre_install
    install_php_56
    install_php_70
    install_php_71
    install_php_72
    install_php_73
    install_php_74
    finalize
}
setup