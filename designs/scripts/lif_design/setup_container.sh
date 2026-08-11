#!/usr/bin/env bash
# Deja un contenedor iic-osic-tools listo para correr el motor de la neurona.
#
#     docker exec <contenedor> bash /foss/designs/scripts/lif_design/setup_container.sh
#
# No toca los scripts del equipo. Instala en un venv aparte para no tocar
# tampoco el python de la imagen.
#
# Por que hace falta: la imagen no trae glayout, y el glayout de upstream NO
# arranca aqui -- su backend por defecto es gdsfactory y el 9.40 de la imagen
# ya no expone gdsfactory.component_reference, asi que glayout cae a un
# DummyPdk. Con GLAYOUT_BACKEND=gdstk sí funciona, sobre el python 3.12 de
# fabrica y sin conda.
#
# Y se instala desde la rama, no desde PyPI ni desde upstream: ahi estan los
# arreglos sin los cuales el mimcap de gf180 sale con las placas en corto y
# los transistores estrechos no se pueden construir.
set -euo pipefail

REPO="${GLAYOUT_REPO:-https://github.com/carloscl03/gLayout.git}"
RAMA="${GLAYOUT_RAMA:-capimagics-base}"
DESTINO="${GLAYOUT_DIR:-/tmp/glayout}"
VENV="${GLAYOUT_VENV:-/tmp/venv}"

echo "== glayout desde ${REPO} rama ${RAMA}"
if [ -d "${DESTINO}/.git" ]; then
    git -C "${DESTINO}" fetch -q origin "${RAMA}"
    git -C "${DESTINO}" checkout -q "origin/${RAMA}"
else
    rm -rf "${DESTINO}"
    git clone -q --depth 1 -b "${RAMA}" "${REPO}" "${DESTINO}"
fi
git -C "${DESTINO}" log --oneline -1

echo "== venv en ${VENV} (ve los paquetes de la imagen: gdstk, klayout, matplotlib)"
[ -x "${VENV}/bin/python" ] || python3 -m venv --system-site-packages "${VENV}"
# --no-deps a proposito: las dependencias que importan ya vienen en la imagen,
# y resolverlas de nuevo arrastra un gdsfactory que no queremos.
"${VENV}/bin/pip" install -q --no-deps -e "${DESTINO}"

echo "== comprobacion"
GLAYOUT_BACKEND=gdstk "${VENV}/bin/python" - <<'PY'
import os

import glayout
from glayout import gf180

print("  glayout:  ", os.path.dirname(glayout.__file__))
print("  capmet -> ", gf180.glayers.get("capmet"), "(tiene que ser fusetop)")
assert gf180.glayers.get("capmet") == "fusetop", \
    "capmet apunta al marcador: este glayout genera los MIM en corto"

from glayout.primitives.fet import nmos
nmos(gf180, width=0.22, length=0.28, multipliers=1, fingers=1,
     with_dnwell=False, with_substrate_tap=False, with_dummy=False)
print("  fet de 0.22 um: se construye")
PY

echo "== kernel de jupyter"
# Con las variables dentro del kernel: si dependieran de exportarlas en la
# terminal, el notebook fallaria al abrirlo desde Jupyter y no seria obvio
# por que. GLAYOUT_BACKEND=gdstk sobre todo -- sin el, glayout no arranca.
"${VENV}/bin/python" -m ipykernel install --user --name lif     --display-name 'LIF motor (gdstk)' >/dev/null 2>&1
"${VENV}/bin/python" - <<PYK
import json, os
import jupyter_core.paths as p
k = os.path.join(p.jupyter_data_dir(), "kernels", "lif", "kernel.json")
spec = json.load(open(k))
# PYTHONPATH y LD_LIBRARY_PATH vacios a proposito: la imagen los trae
# puestos y se colarian en el kernel segun desde que shell se lance. Los
# scripts del equipo empiezan con un unset por lo mismo.
spec["env"] = {"GLAYOUT_BACKEND": "gdstk",
               "PATH": "/foss/tools/klayout:/usr/local/bin:/usr/bin:/bin",
               "PYTHONPATH": "",
               "LD_LIBRARY_PATH": "",
               "LIF_OUT": "${SALIDA_NB:-/tmp/nbout}"}
json.dump(spec, open(k, "w"), indent=1)
print("  kernel 'lif' registrado con su entorno")
PYK
mkdir -p "${SALIDA_NB:-/tmp/nbout}"

cat <<EOF

Listo. Desde la terminal:

    ${VENV}/bin/python -m nbconvert --to notebook --execute \\
        --output-dir=${SALIDA_NB:-/tmp/nbout} --ExecutePreprocessor.kernel_name=lif \\
        /foss/designs/notebooks/3_test_lif_engine.ipynb

O desde Jupyter:

    cd /foss/designs && ${VENV}/bin/python -m jupyterlab \\
        --ip=0.0.0.0 --port=8888 --no-browser --IdentityProvider.token=lif

OJO con dos cosas:

  - Hay que elegir el kernel "LIF motor (gdstk)". El kernel GLdev que declara
    el notebook NO sirve en esta imagen: su python no tiene glayout instalado.
  - GLAYOUT_BACKEND=gdstk no es opcional. Sin el, glayout no arranca aqui: cae
    a un DummyPdk sin fallar del todo, asi que parece que funciona y no.
EOF
