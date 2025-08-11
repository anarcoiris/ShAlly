#!/bin/bash
# Uso: ./verificar_hashes.sh /ruta/al/directorio/raiz

set -euo pipefail

ROOT_DIR="${1:-.}"
GPG_KEY_ID="tu_clave_publica"  # Opcional, si quieres verificar con una clave específica

echo "🔍 Directorio raíz: $ROOT_DIR"
echo "🔍 Verificando archivos firmados con GPG: ${GPG_KEY_ID:-(cualquier clave)}"
echo "-------------------------------------------------"

for dir in "$ROOT_DIR"/*/; do
    if [ -d "$dir" ] && [ -d "$dir/.git" ]; then
        echo ""
        echo "📂 Verificando repo: $dir"
        cd "$dir"

        # Verificar que existan los archivos de hashes y firma
        if [ ! -f hashes.md5 ]; then
            echo "   ❌ No se encontró hashes.md5, saltando."
            cd - > /dev/null
            continue
        fi

        if [ ! -f hashes.md5.asc ]; then
            echo "   ❌ No se encontró hashes.md5.asc, saltando."
            cd - > /dev/null
            continue
        fi

        # Verificar la firma del archivo hashes.md5.asc
        echo "   ➡️ Verificando firma GPG..."
        if [ -n "$GPG_KEY_ID" ]; then
            gpg --verify --keyid-format LONG hashes.md5.asc hashes.md5 2>&1 | tee gpg_verify.log
        else
            gpg --verify hashes.md5.asc hashes.md5 2>&1 | tee gpg_verify.log
        fi

        # Revisar el resultado de la verificación
        if grep -q "Good signature" gpg_verify.log; then
            echo "   ✅ Firma GPG válida."
        else
            echo "   ❌ Firma GPG inválida o no verificable."
            # Opcional: continuar con la verificación o saltar
            # cd - > /dev/null
            # continue
        fi

        rm -f gpg_verify.log

        # Verificar integridad con md5sum
        echo "   ➡️ Verificando integridad de archivos..."
        if md5sum -c hashes.md5 --quiet; then
            echo "   ✅ Todos los hashes coinciden."
        else
            echo "   ❌ Hay archivos con hash diferente o que faltan."
        fi

        cd - > /dev/null
    else
        echo "⚠️  Saltando $dir (no es repo Git)"
    fi
done

echo ""
echo "✅ Proceso de verificación completado."
