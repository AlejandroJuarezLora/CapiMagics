#!/usr/bin/env python3

from pathlib import Path


# ============================================================
# Colocar este script dentro de:
#
#   librelane/build/
#
# El archivo de salida se guardará en:
#
#   librelane/build/
#
# El contenido queda listo para copiar y pegar dentro de un YAML.
# IMPORTANTE: se usan únicamente ESPACIOS, nunca tabulaciones.
# ============================================================


BUILD_DIR = Path(__file__).resolve().parent


def listar_proyectos():
    proyectos = sorted(
        carpeta.name
        for carpeta in BUILD_DIR.iterdir()
        if carpeta.is_dir() and not carpeta.name.startswith(".")
    )

    return proyectos


def seleccionar_proyecto(proyectos):
    print("\nMacros encontradas en build/:\n")

    for i, proyecto in enumerate(proyectos, start=1):
        print(f"  [{i}] {proyecto}")

    print()

    while True:
        opcion = input("Selecciona el número del proyecto: ").strip()

        try:
            indice = int(opcion) - 1

            if 0 <= indice < len(proyectos):
                return proyectos[indice]

        except ValueError:
            pass

        print("Opción inválida. Intenta nuevamente.\n")


def ruta_dir(proyecto, *partes):
    """
    Genera rutas conservando literalmente:
    dir::build/<proyecto>/...
    """
    ruta = Path("build") / proyecto

    for parte in partes:
        ruta /= parte

    return f"dir::{ruta.as_posix()}"


def archivo_existe(proyecto, *partes):
    return (BUILD_DIR / proyecto / Path(*partes)).is_file()


def directorios_existentes(proyecto, carpeta):
    ruta = BUILD_DIR / proyecto / carpeta

    if not ruta.is_dir():
        return []

    return sorted(
        elemento.name
        for elemento in ruta.iterdir()
        if elemento.is_dir()
    )


def pedir_entero(mensaje, default):
    while True:
        texto = input(f"{mensaje} [{default}]: ").strip()

        if texto == "":
            return default

        try:
            return int(texto)
        except ValueError:
            print("Debe ser un número entero.")


def generar_configuracion(proyecto, instancia, x, y, orientacion):
    """
    Genera texto compatible con YAML usando EXCLUSIVAMENTE espacios.
    No se insertan caracteres de tabulación.
    """

    lineas = []

    lineas.append("MACROS:")
    lineas.append(f"  {proyecto}:")

    # --------------------------------------------------------
    # Vistas simples
    # --------------------------------------------------------
    vistas = [
        ("gds", f"{proyecto}.gds"),
        ("lef", f"{proyecto}.lef"),
        ("vh", f"{proyecto}.vh"),
        ("nl", f"{proyecto}.nl.v"),
        ("pnl", f"{proyecto}.pnl.v"),
        ("spice", f"{proyecto}.spice"),
    ]

    faltantes = []

    for clave, archivo in vistas:
        if archivo_existe(proyecto, clave, archivo):
            lineas.append(f"    {clave}:")
            lineas.append(
                f"      - {ruta_dir(proyecto, clave, archivo)}"
            )
        else:
            faltantes.append(
                str(BUILD_DIR / proyecto / clave / archivo)
            )

    # --------------------------------------------------------
    # SDF
    # --------------------------------------------------------
    corners_sdf = directorios_existentes(proyecto, "sdf")

    if corners_sdf:
        lineas.append("    sdf:")

        for corner in corners_sdf:
            archivo = f"{proyecto}__{corner}.sdf"

            if archivo_existe(proyecto, "sdf", corner, archivo):
                lineas.append(f"      {corner}:")
                lineas.append(
                    f"        - {ruta_dir(proyecto, 'sdf', corner, archivo)}"
                )
            else:
                faltantes.append(
                    str(BUILD_DIR / proyecto / "sdf" / corner / archivo)
                )

    # --------------------------------------------------------
    # LIB
    # --------------------------------------------------------
    corners_lib = directorios_existentes(proyecto, "lib")

    if corners_lib:
        lineas.append("    lib:")

        for corner in corners_lib:
            archivo = f"{proyecto}__{corner}.lib"

            if archivo_existe(proyecto, "lib", corner, archivo):
                lineas.append(f"      {corner}:")
                lineas.append(
                    f"        - {ruta_dir(proyecto, 'lib', corner, archivo)}"
                )
            else:
                faltantes.append(
                    str(BUILD_DIR / proyecto / "lib" / corner / archivo)
                )

    # --------------------------------------------------------
    # SPEF
    # --------------------------------------------------------
    corners_spef = directorios_existentes(proyecto, "spef")

    if corners_spef:
        lineas.append("    spef:")

        for corner in corners_spef:
            archivo = f"{proyecto}.{corner}.spef"

            if archivo_existe(proyecto, "spef", corner, archivo):
                lineas.append(f"      {corner}:")
                lineas.append(
                    f"        - {ruta_dir(proyecto, 'spef', corner, archivo)}"
                )
            else:
                faltantes.append(
                    str(BUILD_DIR / proyecto / "spef" / corner / archivo)
                )

    # --------------------------------------------------------
    # Instancia
    # --------------------------------------------------------
    lineas.append("    instances:")
    lineas.append(f"      {instancia}:")
    lineas.append(f"        location: [{x}, {y}]")
    lineas.append(f"        orientation: {orientacion}")
    lineas.append("")

    contenido = "\n".join(lineas)

    # Seguridad adicional:
    # si por algún motivo apareciera un tab, se reemplaza por 4 espacios.
    contenido = contenido.replace("\t", "    ")

    return contenido, faltantes


def main():

    print("============================================================")
    print(" Generador de bloque MACROS para LibreLane")
    print(" Salida: archivo .txt")
    print("============================================================")
    print(f"Directorio build: {BUILD_DIR}")

    proyectos = listar_proyectos()

    if not proyectos:
        print("\nNo se encontraron carpetas dentro de build/.")
        return

    proyecto = seleccionar_proyecto(proyectos)

    print(f"\nProyecto seleccionado: {proyecto}\n")

    # --------------------------------------------------------
    # Instancia
    # --------------------------------------------------------
    instancia_default = f"i_chip_core.{proyecto}_u"

    instancia = input(
        f"Nombre jerárquico de la instancia [{instancia_default}]: "
    ).strip()

    if not instancia:
        instancia = instancia_default

    # --------------------------------------------------------
    # Coordenadas
    # --------------------------------------------------------
    x = pedir_entero("Coordenada X", 550)
    y = pedir_entero("Coordenada Y", 550)

    # --------------------------------------------------------
    # Orientación
    # --------------------------------------------------------
    orientacion = input("Orientación [N]: ").strip().upper()

    if not orientacion:
        orientacion = "N"

    # --------------------------------------------------------
    # Nombre del TXT
    # --------------------------------------------------------
    txt_default = f"macro_{proyecto}.txt"

    nombre_salida = input(
        f"Nombre del archivo TXT [{txt_default}]: "
    ).strip()

    if not nombre_salida:
        nombre_salida = txt_default

    if not nombre_salida.lower().endswith(".txt"):
        nombre_salida += ".txt"

    salida = BUILD_DIR / nombre_salida

    # --------------------------------------------------------
    # Generación
    # --------------------------------------------------------
    contenido, faltantes = generar_configuracion(
        proyecto,
        instancia,
        x,
        y,
        orientacion
    )

    if faltantes:
        print("\nADVERTENCIA: faltan algunos archivos esperados:\n")

        for archivo in faltantes:
            print(f"  - {archivo}")

        print("\nLas rutas faltantes NO serán agregadas al TXT.")

        continuar = input(
            "\n¿Deseas generar el archivo de todos modos? [s/N]: "
        ).strip().lower()

        if continuar not in ("s", "si", "sí", "y", "yes"):
            print("\nOperación cancelada.")
            return

    # --------------------------------------------------------
    # Evitar sobreescritura accidental
    # --------------------------------------------------------
    if salida.exists():
        respuesta = input(
            f"\n{salida.name} ya existe. ¿Sobrescribir? [s/N]: "
        ).strip().lower()

        if respuesta not in ("s", "si", "sí", "y", "yes"):
            print("\nOperación cancelada.")
            return

    salida.write_text(contenido, encoding="utf-8")

    print("\n============================================================")
    print(" Archivo TXT generado correctamente")
    print("============================================================")
    print(f"\nArchivo:\n  {salida}")
    print("\nContenido listo para copiar al YAML:\n")
    print(contenido)


if __name__ == "__main__":
    main()