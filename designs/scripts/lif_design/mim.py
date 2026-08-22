"""Cuanta capacidad da un MIM de gf180, y que lado hace falta para una dada.

Esto NO son leyes ajustadas por nosotros como las de laws.py: son los
parametros del modelo del PDK, copiados de

    /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice

donde cada subcircuito cap_mim_* define

    c_c0 = c_cox * area + c_capsw * perimetro

El termino de perimetro no es un detalle. En un cap de 5 um de lado aporta
el 21% del total con el modelo de 1.0 fF/um2, asi que multiplicar area por
la densidad del nombre se queda corto justo en el tamaño que usamos.

Que opcion corre la fabrica es una decision de proceso, no de dibujo: el
layout del MIM es identico en las tres. Lo unico que cambia es cuanto vale,
y hay que elegirla de forma coherente en tres sitios -- el modelo de
simulacion, el mim_option del DRC (A o B) y el par de metales.
"""
from __future__ import annotations

# c_cox [fF/um2], c_capsw [fF/um]
DENSIDADES = {
    "1f0": (0.987, 0.330),
    "2f0": (1.990, 0.238),
}

def par_metales(pdk) -> str:
    """La pareja de metales del MIM, como la nombra el PDK: "m2m3", "m4m5"...

    No se escribe: gf180 trae un subcircuito por pareja -- cap_mim_2f0_m2m3,
    _m3m4, _m4m5, _m5m6 -- y cual toca depende de donde el PDK ponga capmet.
    Los coeficientes son IDENTICOS en todas (c_cox 1.99e-3, c_capsw 2.383e-10):
    el sandwich es el mismo nitruro y solo cambia a que altura se inserta, asi
    que la capacidad no depende de la pareja. El nombre si, y con el el LVS:
    declarar m2m3 una celda construida en met4/met5 da el valor correcto y el
    dispositivo equivocado.
    """
    bot = pdk.layer_to_glayer(pdk.get_grule("capmet")["capmetbottom"])
    top = pdk.layer_to_glayer(pdk.get_grule("capmet")["capmettop"])
    return "m%sm%s" % (bot[3:], top[3:])


def drc_option(pdk) -> str:
    """A o B, segun donde ponga el PDK la placa inferior."""
    bot = pdk.layer_to_glayer(pdk.get_grule("capmet")["capmetbottom"])
    return "A" if bot == "met2" else "B"

# Decidido por dos criterios, en este orden:
#
#   1. Dejar libres las capas altas para el ruteo entre neuronas cuando la
#      celda se replique en una red. Eso descarta la opcion B, que pone el MIM
#      entre metal4/metal5 (o metal5/metal6), y fija la A: metal2 / FuseTop /
#      metal3, lo mas abajo posible. Coincide con lo que genera glayout.
#   2. A igualdad de lo anterior, minimizar el area del condensador. Eso elige
#      la receta mas densa de las tres, 2.0 fF/um2.
#
# OJO: la receta es una decision de TODO el chip, no de esta celda. El PDK
# ofrece las tres pero un proceso solo puede usar una, y hace falta una
# mascara extra (L92). El integrador del equipo ya instancia cap_mim_2f0fF,
# pero el comentario de su notebook del LIF solo cuadra con 1f0, asi que esto
# hay que confirmarlo con el equipo antes de cerrar.
POR_DEFECTO = "2f0"


def capacidad(lado: float, mim: str = POR_DEFECTO, n: int = 1) -> float:
    """Capacidad [fF] de n MIM cuadrados de `lado` um en paralelo."""
    cox, capsw = DENSIDADES[mim]
    return n * (cox * lado * lado + capsw * 4.0 * lado)


def lado_para(Cm: float, mim: str = POR_DEFECTO, n: int = 1) -> float:
    """Lado [um] de cada uno de n MIM cuadrados que sumen Cm [fF].

    Invierte cox*s^2 + capsw*4s = Cm/n, que es una cuadratica con una sola
    raiz positiva.
    """
    if Cm <= 0 or n < 1:
        raise ValueError("Cm debe ser positivo y n al menos 1")
    cox, capsw = DENSIDADES[mim]
    objetivo = Cm / n
    b = 4.0 * capsw
    return (-b + (b * b + 4.0 * cox * objetivo) ** 0.5) / (2.0 * cox)


def modelo(pdk, mim: str = POR_DEFECTO) -> str:
    """Nombre del subcircuito del PDK que hay que usar al simular."""
    return "cap_mim_%s_%s_noshield" % (mim, par_metales(pdk))
