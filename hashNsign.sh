#!/bin/bash
# Uso: ./generar_hashes.sh /ruta/al/directorio/raiz

set -euo pipefail

ROOT_DIR="${1:-.}"

# Cambia esto si quieres firmar con una clave específica
GPG_KEY_ID="tu_clave_gpg"  # Ej: ABC1234 (puedes dejarlo vacío si solo tienes una)

for dir in "$ROOT_DIR"/*/; do
    # Solo procesar si es un directorio con un repo Git
    if [ -d "$dir" ] && [ -d "$dir/.git" ]; then
        echo "📂 Procesando $dir"

        # Entrar en el subdirectorio
        cd "$dir"

        # Generar hashes.md5 (solo de los archivos dentro de este repo, excluyendo .git y el propio hashes)
        echo "🔹 Generando hashes..."
        find . -type f \
            ! -path "./.git/*" \
            ! -name "hashes.md5" \
            ! -name "hashes.md5.asc" \
            -exec md5sum {} \; > hashes.md5

        # Firmar el archivo
        echo "🔹 Firmando con GPG..."
        if [ -n "$GPG_KEY_ID" ]; then
            gpg --default-key "$GPG_KEY_ID" --armor --output hashes.md5.asc --sign hashes.md5
        else
            gpg --armor --output hashes.md5.asc --sign hashes.md5
        fi

        # Subir a Git
        echo "🔹 Subiendo a Git..."
        git add hashes.md5 hashes.md5.asc
        git commit -m "añadiendo fichero de hashes firmado"
        git push

        # Volver al directorio raíz
        cd - > /dev/null
    else
        echo "⚠️  Saltando $dir (no es un repo Git)"
    fi
done

echo "✅ Proceso completado."
