"""El esquematico de referencia, emitido desde el mismo diseño que el layout.

En un flujo a mano el LVS es un DESCUBRIMIENTO: se dibuja el esquematico por
un lado, el layout por otro, y la comparacion revela si divergieron. Aqui es
una COMPROBACION: las dos salidas vienen de la misma NeuronDesign, asi que un
fallo solo puede significar un bug del generador. La clase de fallo "alguien
tecleo distinto en dos sitios" no existe.

La topologia es fija -- tres inversores, el interruptor M5 y el banco de MIM --
y lo unico que el solver decide son cuatro dimensiones y cuantos condensadores.

Los nombres de nodo son los que `_pin_labels` marca en el GDS: sin esa
correspondencia el extractor nombra las redes por su cuenta y el LVS compara
etiquetas que no existen.
"""
from __future__ import annotations

# Nodos internos. `integration` es la membrana y va al pin Iin -- la fuente de
# corriente entra ahi, asi que el nodo del integrador ES el puerto de entrada.
_RESET = "spike/reset"


def de_diseño(design, handles, name: str = "lif") -> str:
    """Netlist SPICE del diseño, para comparar contra el GDS.

    `handles` viene de from_design: aporta el nombre del modelo del MIM y el
    lado real de la placa, que no son del solver sino del generador -- el lado
    se ajusta a la rejilla y el modelo depende de donde el PDK ponga capmet.
    """
    p = design.params
    w_inv, l_inv = 0.22, 0.28          # los inversores van al minimo
    n_caps = len(handles["caps"])
    lado = float(handles["cap_lado"])

    def fet(nombre, d, g, s, b, tipo, w, l):
        return ("M%s %s %s %s %s %s L=%gu W=%gu nf=1 m=1"
                % (nombre, d, g, s, b, tipo, l, w))

    lineas = [
        ".subckt %s Vdd Vss Iin spike spike_neg" % name,
        "*.PININFO Vdd:B Vss:B Iin:I spike:O spike_neg:O",
        # inversor 0: la membrana lo excita, su salida es spike_neg
        fet("1", "spike_neg", "Iin", "Vdd", "Vdd", "pfet_03v3", w_inv, l_inv),
        fet("2", "spike_neg", "Iin", "Vss", "Vss", "nfet_03v3", w_inv, l_inv),
        # inversor 1: cierra el lazo de reset sobre la puerta de M5
        fet("3", _RESET, "spike_neg", "Vdd", "Vdd", "pfet_03v3", w_inv, l_inv),
        fet("4", _RESET, "spike_neg", "Vss", "Vss", "nfet_03v3", w_inv, l_inv),
        # inversor 2: el bufer de salida, el unico que el solver dimensiona
        fet("7", "spike", "spike_neg", "Vdd", "Vdd", "pfet_03v3",
            p["W_M7M8"], l_inv),
        fet("8", "spike", "spike_neg", "Vss", "Vss", "nfet_03v3",
            p["W_M7M8"], l_inv),
        # M5, el interruptor que descarga la membrana
        fet("5", "Iin", _RESET, "Vss", "Vss", "nfet_03v3",
            p["W_M5"], p["L_M5"]),
        # el banco. m=n en vez de n instancias: el comparador combina
        # dispositivos en paralelo, asi que las dos formas casan con la
        # extraccion, y una sola linea dice lo que hay.
        "XC1 Iin Vss %s c_width=%gu c_length=%gu m=%d"
        % (handles["mim"], lado, lado, n_caps),
        ".ends",
    ]
    return "\n".join(lineas) + "\n"
