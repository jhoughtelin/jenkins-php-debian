#!/bin/bash

#
# Install Jenkins for PHP on Debian
#

echo "### Adding Apt package source for Jenkins"
wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
echo "deb http://pkg.jenkins-ci.org/debian binary/" >> /etc/apt/sources.list

echo "### Updating Apt"
apt-get update >/dev/null

echo "### Installing Apt installables"
apt-get --yes --force-yes install \
    memcached \
    vim screen \
    jenkins ant git \
    php5 php5-dev php5-xdebug php5-xsl php5-memcache php5-memcached php5-common php5-cli php5-curl \
    php-pear php-codesniffer php-codecoverage \
    phpunit

echo "### Updating PEAR"
pear upgrade PEAR

echo "## Installing Pecl PHP Extensions"
pecl install pecl_http

echo "### Installing PEAR Modules"
pear config-set auto_discover 1
# Discover the channels we'll be installing modules from
pear channel-discover pear.pdepend.org
pear channel-discover pear.phpmd.org
pear channel-discover pear.phpunit.de
pear channel-discover pear.phing.info
pear channel-discover pear.netpirates.net
pear channel-discover pear.phpdoc.org
pear channel-discover pear.symfony.com

#PHP_Depend
pear install pdepend/PHP_Depend
pear install pear.phpmd.org/PHP_PMD
# PHP_PMD
pear install pear.phpdoc.org/phpDocumentor
# phpDocumentor
pear install pear.phpunit.de/PHP_Timer
# PHP_Timer
pear install pear.phpunit.de/phpcpd
# phpcpd
pear install pear.phpunit.de/phploc
# phploc
pear install pear.phpunit.de/phpdcd-beta
# phpdcd
pear install pear.phpunit.de/DbUnit
# DBunit
pear install--alldeps phing/phing
# phing
pear install pear.netpirates.net/fDOMDocument
# fDOMDocument
pear install pear.netpirates.net/phpDox-0.6.5
# phpDox

echo "### Installing PHPUnit"
wget https://phar.phpunit.de/phpunit.phar
chmod +x phpunit.phar
mv phpunit.phar /usr/local/bin/phpunit


echo "### Fetching Jenkins-cli.jar"
if [[ ! -f jenkins-cli.jar ]]; then
	wget http://localhost:8080/jnlpJars/jenkins-cli.jar
fi

echo "### Manually updating Jenkins update-center"
curl -L http://updates.jenkins-ci.org/update-center.json | sed '1d;$d' | curl -X POST -H 'Accept: application/json' -d @- http://localhost:8080/updateCenter/byId/default/postBack
echo "### Installing PHP Plugins for Jenkins."
java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin checkstyle cloverphp dry htmlpublisher jdepend plot pmd violations xunit php git phing build-pipeline-plugin dashboard-view
echo "### Restarting Jenkins."
java -jar jenkins-cli.jar -s http://localhost:8080 safe-restart