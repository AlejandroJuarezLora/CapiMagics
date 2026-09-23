#!/bin/bash

set -e

# Versión exacta utilizada por el template de wafer.space
PDK_COMMIT="f6eeac7dad085ffcc829ccfd721f7b4ce39edcf7"

# PDK utilizado por el proyecto
PDK="gf180mcuD"

# # Crear/usar la carpeta gf180mcu en el directorio actual
PDK_ROOT="$(pwd)/gf180mcu"

echo "=========================================="
echo " Clonando GF180MCU PDK"
echo "=========================================="
echo "PDK_ROOT   : $PDK_ROOT"
echo "PDK        : $PDK"
echo "PDK_COMMIT : $PDK_COMMIT"
echo "=========================================="

ciel enable "$PDK_COMMIT" \
    --pdk-root "$PDK_ROOT" \
    --pdk-family "$PDK" \
    --include-libraries all

#ciel enable "f6eeac7dad085ffcc829ccfd721f7b4ce39edcf7" --pdk-root ".\gf180mcu" --pdk-family "gf180mcuD" --include-librarieciels all


echo ""
echo "=========================================="
echo " GF180MCU PDK instalado correctamente"
echo "=========================================="
echo "Ubicación:"
echo "$PDK_ROOT"