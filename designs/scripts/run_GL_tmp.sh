#!/usr/bin/env bash
# Instala gLayout y arranca Jupyter, como run_GL_conda.sh y run_GL_pyenv.sh,
# pero desde la rama con los arreglos y sobre el python que ya trae la imagen.
#
#     bash /foss/designs/scripts/run_GL_tmp.sh
#
# TEMPORAL: esto sobra el dia que entren los PR 100, 102, 103 y 104 en
# ReaLLMASIC/gLayout. Mientras tanto hace falta, por tres razones:
#
#   1. glayout de upstream NO ARRANCA en esta imagen. Su backend por defecto
#      es gdsfactory, y el 9.40 que trae la imagen ya no expone
#      gdsfactory.component_reference, asi que glayout cae a un DummyPdk sin
#      fallar del todo: parece que funciona y no funciona. Con
#      GLAYOUT_BACKEND=gdstk si arranca, y por eso la variable no es opcional.
#
#   2. En gf180 el mimcap sale con las placas EN CORTO. capmet apunta a
#      CAP_MK, que es solo un marcador, en vez de a FuseTop, asi que el
#      condensador se queda sin dielectrico. No lo detecta el DRC ni la
#      extraccion habitual.
#
#   3. Los transistores por debajo de ~0.36 um de ancho no se pueden
#      construir.
#
# Los dos scripts que ya hay llevan a un glayout con esos tres problemas:
# run_GL_conda.sh hace `pip install glayout` desde PyPI, y run_GL_pyenv.sh
# instala designs/libs/gLayout, que es un clon de upstream main.
#
# Este no toca ninguno de los dos ni sus entornos. Instala aparte.
set -euo pipefail

REPO="${GLAYOUT_REPO:-https://github.com/carloscl03/gLayout.git}"
RAMA="${GLAYOUT_RAMA:-capimagics-base}"
DESTINO="${GLAYOUT_DIR:-/tmp/glayout}"
VENV="${GLAYOUT_VENV:-/tmp/venv}"
SALIDA_NB="${LIF_OUT:-/tmp/nbout}"
PUERTO="${JUPYTER_PORT_INT:-8888}"
LANZAR="${LANZAR_JUPYTER:-1}"

echo "== gLayout desde ${REPO} rama ${RAMA}"
if [ -d "${DESTINO}/.git" ]; then
    git -C "${DESTINO}" fetch -q origin "${RAMA}"
    git -C "${DESTINO}" checkout -q "origin/${RAMA}"
else
    rm -rf "${DESTINO}"
    git clone -q --depth 1 -b "${RAMA}" "${REPO}" "${DESTINO}"
fi
git -C "${DESTINO}" log --oneline -1

echo "== venv sobre el python de la imagen (ya trae gdstk, klayout, matplotlib)"
[ -x "${VENV}/bin/python" ] || python3 -m venv --system-site-packages "${VENV}"
# --no-deps a proposito: lo que hace falta ya viene en la imagen, y resolver
# las dependencias otra vez arrastra un gdsfactory que no queremos.
"${VENV}/bin/pip" install -q --no-deps -e "${DESTINO}"

echo "== comprobacion"
GLAYOUT_BACKEND=gdstk PYTHONPATH= LD_LIBRARY_PATH= "${VENV}/bin/python" - <<'PY'
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
# Se llama 'lif' y no 'GLdev' a proposito: no pisa el kernel que registran los
# otros scripts. La contrapartida es que hay que elegirlo a mano al abrir un
# notebook, porque los notebooks declaran GLdev.
#
# Las variables van DENTRO del kernel. Si dependieran de exportarlas en la
# terminal, abrir el notebook desde Jupyter fallaria y no seria obvio por que.
# PYTHONPATH y LD_LIBRARY_PATH vacios porque la imagen los trae puestos y se
# colarian segun desde que shell se lance -- los scripts del equipo empiezan
# con un unset por lo mismo.
"${VENV}/bin/python" -m ipykernel install --user --name lif \
    --display-name 'LIF motor (gdstk)' >/dev/null 2>&1
"${VENV}/bin/python" - <<PYK
import json, os
import jupyter_core.paths as p
k = os.path.join(p.jupyter_data_dir(), "kernels", "lif", "kernel.json")
spec = json.load(open(k))
spec["env"] = {"GLAYOUT_BACKEND": "gdstk",
               "PATH": "/foss/tools/klayout:/usr/local/bin:/usr/bin:/bin",
               "PYTHONPATH": "",
               "LD_LIBRARY_PATH": "",
               "LIF_OUT": "${SALIDA_NB}"}
json.dump(spec, open(k, "w"), indent=1)
print("  kernel 'lif' registrado con su entorno")
PYK
mkdir -p "${SALIDA_NB}"

if [ "${LANZAR}" != "1" ]; then
    echo "== listo (sin lanzar Jupyter)"
    exit 0
fi

if (ss -ltn 2>/dev/null || netstat -ltn 2>/dev/null) | grep -q ":${PUERTO}\b"; then
    echo
    echo "== el puerto ${PUERTO} ya esta ocupado, no lanzo otro Jupyter."
    echo "   Si el que hay es el bueno, uselo. Si no, matelo y repita, o"
    echo "   pase JUPYTER_PORT_INT=8889."
    exit 0
fi

echo "== Jupyter en el puerto ${PUERTO} (token: lif)"
cd /foss/designs
exec env PYTHONPATH= LD_LIBRARY_PATH= "${VENV}/bin/python" -m jupyterlab \
    --ip=0.0.0.0 --port="${PUERTO}" --no-browser \
    --IdentityProvider.token=lif --ServerApp.root_dir=/foss/designs
