#!/bin/bash
set -e

PHP_PREFIX="/home/neoserv/bin/php"
PHP_BIN="$PHP_PREFIX/bin/php"
PHPIZE="$PHP_PREFIX/bin/phpize"
PHP_CONFIG="$PHP_PREFIX/bin/php-config"
PHP_INI="$PHP_PREFIX/lib/php.ini"

EXT_DIR=$($PHP_BIN -i | awk -F'=> ' '/extension_dir/ {print $2}' | tr -d ' ')

XDEBUG_REPO="https://github.com/xdebug/xdebug.git"
TMP_DIR="/tmp/php-xdebug-build"

# ====================
# Install dependencies (Ubuntu/Debian)
# ====================
echo "=== Updating package list and installing dependencies ==="

# Update package index
sudo apt update -qq

# Core set for building PHP extensions + git
sudo apt install -y --no-install-recommends \
    build-essential \
    autoconf \
    automake \
    libtool \
    git \
    pkg-config
# ====================

echo "=== Environment check ==="
for bin in "$PHP_BIN" "$PHPIZE" "$PHP_CONFIG"; do
    if [ ! -x "$bin" ]; then
        echo "Error: $bin not found"
        exit 1
    fi
done

if [ ! -f "$PHP_INI" ]; then
    echo "Error: Main php.ini not found at $PHP_INI"
    exit 1
fi

echo "PHP binary     : $PHP_BIN"
echo "php.ini        : $PHP_INI"
echo "Extension dir  : $EXT_DIR"

echo
echo "=== Preparing Xdebug build ==="
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

git clone "$XDEBUG_REPO" .
$PHPIZE
./configure --with-php-config="$PHP_CONFIG"

echo
echo "=== Building ==="
make -j$(nproc)

echo
echo "=== Installing extension ==="
cp modules/xdebug.so "$EXT_DIR"/

echo
echo "=== Adding settings to $PHP_INI ==="

# Check if Xdebug section already exists
if grep -q "^;.*Xdebug" "$PHP_INI" || grep -q "^zend_extension=.*xdebug.so" "$PHP_INI"; then
    echo "Warning: Xdebug appears to already be present in php.ini"
    echo "New settings will NOT be added to avoid duplication."
else
    cat >> "$PHP_INI" <<EOF


; ====================
; Xdebug (added $(date '+%Y-%m-%d %H:%M:%S'))
; ====================
zend_extension=xdebug.so

; Enable debugging and profiling
xdebug.mode=debug,profile
xdebug.start_with_request=trigger
xdebug.output_dir=/home/neoserv/xdebug
xdebug.client_host=127.0.0.1
xdebug.client_port=9003
xdebug.discover_client_host=0

; Other settings (optional)
; xdebug.log=/tmp/xdebug.log
; xdebug.profiler_enable=1
; xdebug.profiler_output_name=cachegrind.out.%p
; ====================
EOF

    echo "Xdebug settings successfully added to end of $PHP_INI"
fi

sudo chown neoserv:neoserv -R /home/neoserv >/dev/null 2>&1
sudo chmod 777 "$EXT_DIR/xdebug.so" >/dev/null 2>&1

echo
echo "=== Restarting php-fpm ==="
if systemctl is-active --quiet php-fpm; then
    sudo systemctl restart php-fpm
else
    echo "php-fpm not found in systemd, restart manually"
fi
sleep 2

echo
echo "=== Checking module load ==="
if $PHP_BIN -r 'exit(extension_loaded("xdebug") ? 0 : 1);'; then
    echo "Xdebug successfully loaded (verified via extension_loaded)"
else
    echo "Error: Xdebug failed to load"
    echo "Check: php -r 'var_dump(extension_loaded(\"xdebug\"));'"
    exit 1
fi

echo
echo "=============================="
echo "Xdebug installed successfully"
echo
echo "📂 Profile folder: /home/neoserv/xdebug"
echo "For php-fpm don't forget to restart:"
echo "  systemctl restart php-fpm      # if systemd"
echo "  or"
echo "  $PHP_PREFIX/sbin/php-fpm --reload"
echo "  or"
echo "  pkill -USR2 php-fpm"
echo
echo "=============================="
