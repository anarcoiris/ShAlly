#!/bin/bash
# Uso: ./generar_hashes_debug.sh /ruta/al/directorio/raiz

set -euo pipefail

ROOT_DIR="${1:-.}"
GPG_KEY_ID="39414E39"  # Ejemplo: ABC1234, dejar vacío si solo tienes una

echo "🔍 Directorio raíz: $ROOT_DIR"
echo "🔍 Clave GPG: ${GPG_KEY_ID:-(por defecto)}"
echo "-------------------------------------------------"
read -p "Presiona ENTER para continuar..."

for dir in "$ROOT_DIR"/*/; do
    if [ -d "$dir" ] && [ -d "$dir/.git" ]; then
        echo ""
        echo "📂 Procesando repo: $dir"
        cd "$dir"

        # Generar hashes.md5
        echo "   ➡️ Generando hashes..."
        find . -type f \
            ! -path "./.git/*" \
            ! -name "hashes.md5" \
            ! -name "hashes.md5.asc" \
            -exec md5sum {} \; > hashes.md5
            read -p "Presiona ENTER para continuar..."
        if [ -s hashes.md5 ]; then
            echo "   ✅ hashes.md5 generado con $(wc -l < hashes.md5) entradas."
            read -p "Presiona ENTER para continuar..."
        else
            echo "   ⚠️ No se generaron hashes (¿repo vacío?)."
            read -p "Presiona ENTER para continuar..."
        fi

        # Firmar el archivo
        echo "   ➡️ Firmando hashes.md5..."
        read -p "Presiona ENTER para continuar..."
        if [ -n "$GPG_KEY_ID" ]; then
            gpg --default-key "$GPG_KEY_ID" --armor --output hashes.md5.asc --sign hashes.md5
        else
            gpg --armor --output hashes.md5.asc --sign hashes.md5
        fi
        echo "   ✅ hashes.md5.asc generado."
        read -p "Presiona ENTER para continuar..."

        # Mostrar archivos generados
        ls -lh hashes.md5 hashes.md5.asc
        read -p "Presiona ENTER para continuar..."
        # Git: añadir, commit y push
        echo "   ➡️ Subiendo a Git..."
        read -p "Presiona ENTER para continuar..."
        git add hashes.md5 hashes.md5.asc
        git status
        if git diff --cached --quiet; then
            echo "   ⚠️ No hay cambios nuevos para subir."
            read -p "Presiona ENTER para continuar..."
        else
            git commit -m "añadiendo fichero de hashes firmado"
            git push
            echo "   ✅ Cambios subidos."
            read -p "Presiona ENTER para continuar..."
        fi

        cd - > /dev/null
    else
        echo "⚠️  Saltando $dir (no es repo Git)"
        read -p "Presiona ENTER para continuar..."
    fi
    read -p "Presiona ENTER para continuar..."
done

echo ""
echo "✅ Proceso completado."
