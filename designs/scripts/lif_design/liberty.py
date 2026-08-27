"""Stub de Liberty para integrar la celda como macro.

LibreLane necesita tres vistas de un bloque analogico: el GDS con la
geometria, el LEF con el contorno y los pines, y un `.lib` que declare
que pines tiene y en que direccion van. Este ultimo es un *stub*: no
lleva tiempos ni potencia, solo la declaracion, que es lo que la
herramienta necesita para no tratar la celda como una caja negra sin
conexiones.

Los nombres y las direcciones salen del mismo sitio que el netlist de
referencia -- `netlist.de_diseño` -- para que un pin no pueda llamarse de
una forma en el LVS y de otra en el flujo de integracion.
"""
from typing import Optional


# Los cinco pines del top, con la direccion que ya declara el .PININFO del
# netlist de referencia. B = bidireccional (alimentacion), I = entrada,
# O = salida.
PINES = (
    ("Vdd",       "inout",  "power"),
    ("Vss",       "inout",  "ground"),
    ("Iin",       "input",  "signal"),
    ("spike",     "output", "signal"),
    ("spike_neg", "output", "signal"),
)


def de_diseño(handles, name: str = "lif", ancho: Optional[float] = None,
              alto: Optional[float] = None) -> str:
    """Devuelve el contenido del `.lib` para la celda ya construida.

    `ancho` y `alto` en um: el area va en el stub porque la herramienta la
    usa para estimar antes de leer el LEF. Si no se pasan, se omite.
    """
    lineas = [
        'library (%s) {' % name,
        '  technology (cmos);',
        '  delay_model : table_lookup;',
        '  time_unit : "1ns";',
        '  voltage_unit : "1V";',
        '  current_unit : "1uA";',
        '  capacitive_load_unit (1, pf);',
        '  pulling_resistance_unit : "1kohm";',
        '',
        '  cell (%s) {' % name,
    ]
    if ancho is not None and alto is not None:
        lineas.append('    area : %.4f;' % (float(ancho) * float(alto)))
    lineas.append('    is_macro_cell : true;')
    for pin, direccion, tipo in PINES:
        lineas.append('    pin (%s) {' % pin)
        lineas.append('      direction : %s;' % direccion)
        if tipo == "power":
            lineas.append('      pg_type : primary_power;')
        elif tipo == "ground":
            lineas.append('      pg_type : primary_ground;')
        lineas.append('    }')
    lineas += ['  }', '}', '']
    return "\n".join(lineas)
