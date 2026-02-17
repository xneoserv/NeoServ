#! /bin/bash
start-stop-daemon --start --quiet --pidfile /home/neoserv/bin/php/sockets/1.pid --exec /home/neoserv/bin/php/sbin/php-fpm -- --daemonize --fpm-config /home/neoserv/bin/php/etc/1.conf
start-stop-daemon --start --quiet --pidfile /home/neoserv/bin/php/sockets/2.pid --exec /home/neoserv/bin/php/sbin/php-fpm -- --daemonize --fpm-config /home/neoserv/bin/php/etc/2.conf
start-stop-daemon --start --quiet --pidfile /home/neoserv/bin/php/sockets/3.pid --exec /home/neoserv/bin/php/sbin/php-fpm -- --daemonize --fpm-config /home/neoserv/bin/php/etc/3.conf
start-stop-daemon --start --quiet --pidfile /home/neoserv/bin/php/sockets/4.pid --exec /home/neoserv/bin/php/sbin/php-fpm -- --daemonize --fpm-config /home/neoserv/bin/php/etc/4.conf
