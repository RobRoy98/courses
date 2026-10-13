#!/bin/bash
# Legt einmalig ein lokales, selbst signiertes Code-Signing-Zertifikat an.
# Damit bleibt die Signatur zwischen Builds gleich und macOS fragt
# Berechtigungen (Automation, Kalender) nicht nach jedem Build erneut ab.
set -euo pipefail
NAME="NotchIsland Local"
KEYCHAIN="$HOME/Library/Keychains/login.keychain-db"

if security find-certificate -c "$NAME" "$KEYCHAIN" >/dev/null 2>&1; then
    echo "Zertifikat \"$NAME\" existiert bereits."
    exit 0
fi

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

cat > "$TMP/cert.cnf" <<CNF
[ req ]
distinguished_name = dn
prompt = no
x509_extensions = ext
[ dn ]
CN = $NAME
[ ext ]
basicConstraints = critical,CA:false
keyUsage = critical,digitalSignature
extendedKeyUsage = critical,codeSigning
CNF

# Bewusst /usr/bin/openssl (LibreSSL): dessen .p12 kann "security import" lesen.
/usr/bin/openssl req -x509 -newkey rsa:2048 -nodes -days 3650 \
    -config "$TMP/cert.cnf" -keyout "$TMP/key.pem" -out "$TMP/cert.pem" 2>/dev/null
/usr/bin/openssl pkcs12 -export -inkey "$TMP/key.pem" -in "$TMP/cert.pem" \
    -out "$TMP/id.p12" -passout pass:notch -name "$NAME"
security import "$TMP/id.p12" -k "$KEYCHAIN" -P notch -T /usr/bin/codesign >/dev/null

echo "Zertifikat \"$NAME\" angelegt (Schlüsselbund: Anmeldung)."
echo "Falls macOS fragt, ob codesign den Schlüssel verwenden darf: \"Immer erlauben\"."
