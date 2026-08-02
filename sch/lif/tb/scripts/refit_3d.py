#!/usr/bin/env python3
"""Reajusta f(W,L,Cm) y Vth(W,L,Cm) incorporando W_M5.

Las leyes previas fijaban W_M5=1.25u. Este script las reajusta sobre el barrido
3D y las valida con leave-one-out, comparandolas contra las leyes viejas.
"""
import csv, itertools
import numpy as np

RES = '/foss/repo/sch/lif/results'


def load(fn, need_ok=True):
    rows = []
    with open(f'{RES}/{fn}') as f:
        for r in csv.DictReader(f):
            if need_ok and r.get('estado') != 'OK':
                continue
            try:
                rows.append({k: v for k, v in r.items()})
            except Exception:
                pass
    return rows


def num(s):
    return float(str(s).replace('u', '').replace('f', ''))


# ---------- reunir puntos (W, L, Cm, freq, Vth) ----------
pts = []
for r in load('sweep_3d_wlcm.csv'):
    if r['freq_kHz'] in ('', 'ERR'):
        continue
    pts.append((num(r['W_M5']), num(r['L_M5']), num(r['Cm_f']),
                float(r['freq_kHz']), float(r['Vth_V']), float(r['Iex_nA'])))

# el barrido 2D aporta 8 puntos OK mas a Cm=200f
for r in load('sweep_wl_m5_2d.csv'):
    if r['freq_kHz'] in ('', 'ERR'):
        continue
    pts.append((num(r['W_M5']), num(r['L_M5']), 200.0,
                float(r['freq_kHz']), float(r['Vth_V']), float(r['Iex_nA'])))

W = np.array([p[0] for p in pts])
L = np.array([p[1] for p in pts])
C = np.array([p[2] for p in pts])
F = np.array([p[3] for p in pts])
V = np.array([p[4] for p in pts])
I = np.array([p[5] for p in pts])

print(f'Puntos validos: {len(pts)}')
print(f'  W  {W.min():.2f} - {W.max():.2f} um')
print(f'  L  {L.min():.0f} - {L.max():.0f} um')
print(f'  Cm {C.min():.0f} - {C.max():.0f} fF')
print(f'  f  {F.min():.0f} - {F.max():.0f} kHz')
print(f'  Vth {V.min():.3f} - {V.max():.3f} V')
print()


def loo_powerlaw(X, y):
    """Ajuste log-log y * = k*prod(xi^ai). Devuelve coefs y error LOO."""
    A = np.column_stack([np.log(x) for x in X] + [np.ones(len(y))])
    b = np.log(y)
    coef, *_ = np.linalg.lstsq(A, b, rcond=None)
    pred = np.exp(A @ coef)
    r2 = 1 - ((y - pred) ** 2).sum() / ((y - y.mean()) ** 2).sum()
    # LOO
    errs = []
    for i in range(len(y)):
        m = np.ones(len(y), bool)
        m[i] = False
        c2, *_ = np.linalg.lstsq(A[m], b[m], rcond=None)
        errs.append(y[i] - np.exp(A[i] @ c2))
    return coef, r2, np.sqrt(np.mean(np.array(errs) ** 2)), pred


def loo_linear(A, y):
    coef, *_ = np.linalg.lstsq(A, y, rcond=None)
    pred = A @ coef
    r2 = 1 - ((y - pred) ** 2).sum() / ((y - y.mean()) ** 2).sum()
    errs = []
    for i in range(len(y)):
        m = np.ones(len(y), bool)
        m[i] = False
        c2, *_ = np.linalg.lstsq(A[m], y[m], rcond=None)
        errs.append(y[i] - A[i] @ c2)
    return coef, r2, np.sqrt(np.mean(np.array(errs) ** 2)), pred


# ---------- LEY DE FRECUENCIA ----------
print('=' * 62)
print('FRECUENCIA  f = k * W^a * L^b * Cm^c   (a Iex ~ const)')
print('=' * 62)
coef, r2, loo, pred = loo_powerlaw([W, L, C], F)
a, b, c, lk = coef
print(f'  f = {np.exp(lk):.4g} * W^{a:.4f} * L^{b:.4f} * Cm^{c:.4f}')
print(f'  R2 = {r2:.4f}   LOO = {loo:.1f} kHz  ({100*loo/F.mean():.1f}% del promedio)')

# comparar con la ley vieja (fijada a W=1.25) sobre estos mismos puntos
old = (363.6 / L - 2.08) * I
r2_old = 1 - ((F - old) ** 2).sum() / ((F - F.mean()) ** 2).sum()
print(f'  [ley vieja f=(363.6/L-2.08)*Iex, sin W ni Cm]  R2 = {r2_old:.4f}')
print(f'  RMSE nueva = {np.sqrt(np.mean((F-pred)**2)):.1f} kHz   '
      f'vieja = {np.sqrt(np.mean((F-old)**2)):.1f} kHz')
print()

# ---------- LEY DE THRESHOLD ----------
print('=' * 62)
print('THRESHOLD  Vth(W, L, Cm)')
print('=' * 62)
# forma fisica: Vth = V0 - q*W^a*L^b/Cm  (el acoplamiento capacitivo del reset
# baja el piso; el pico sube). Linealizamos en 1/Cm con termino de area.
cands = {
    'V0 + p*W/Cm + q*L/Cm + r*W*L/Cm':
        np.column_stack([np.ones(len(V)), W / C, L / C, W * L / C]),
    'V0 + p*W + q*L + r*W*L + s/Cm':
        np.column_stack([np.ones(len(V)), W, L, W * L, 1 / C]),
    'V0 + p*W + q*L + r*W*L/Cm + s/Cm':
        np.column_stack([np.ones(len(V)), W, L, W * L / C, 1 / C]),
}
best = None
for name, A in cands.items():
    coef, r2, loo, pred = loo_linear(A, V)
    print(f'  {name}')
    print(f'      R2 = {r2:.4f}   LOO = {loo:.4f} V')
    if best is None or loo < best[2]:
        best = (name, coef, loo, r2, pred)

print()
name, coef, loo, r2, pred = best
print(f'  MEJOR: {name}')
print('     coefs = ' + ', '.join(f'{c:.6g}' for c in coef))
print(f'     R2 = {r2:.4f}   LOO = {loo:.4f} V')

# ley vieja de Vth (solo L y Cm, a W=1.25)
old_v = 2.893 * L / C - 21.28 / C + 1.2606
r2_ov = 1 - ((V - old_v) ** 2).sum() / ((V - V.mean()) ** 2).sum()
print(f'  [ley vieja Vth(L,Cm), sin W]  R2 = {r2_ov:.4f}   '
      f'RMSE = {np.sqrt(np.mean((V-old_v)**2)):.4f} V')
print(f'  RMSE nueva = {np.sqrt(np.mean((V-pred)**2)):.4f} V')
print()

# ---------- tabla de residuos ----------
print('  W     L    Cm   f_med  f_pred   Vth_med Vth_pred')
fp = np.exp(np.column_stack([np.log(W), np.log(L), np.log(C),
                             np.ones(len(F))]) @
            loo_powerlaw([W, L, C], F)[0])
for i in np.argsort(W * 1000 + L):
    print(f'{W[i]:5.2f} {L[i]:5.0f} {C[i]:5.0f} {F[i]:7.0f} {fp[i]:7.0f}   '
          f'{V[i]:7.3f} {pred[i]:7.3f}')

# ---------- LEY DE FRECUENCIA v2: mediada por Vth ----------
print()
print('=' * 62)
print('FRECUENCIA v2: f = k * W^a * L^b * Vth^d   (Cm entra via Vth)')
print('=' * 62)
coef2, r2b, loob, pred2 = loo_powerlaw([W, L, V], F)
a2, b2, d2, lk2 = coef2
print(f'  f = {np.exp(lk2):.4g} * W^{a2:.4f} * L^{b2:.4f} * Vth^{d2:.4f}')
print(f'  R2 = {r2b:.4f}   LOO = {loob:.1f} kHz  ({100*loob/F.mean():.1f}%)')
print(f'  RMSE = {np.sqrt(np.mean((F-pred2)**2)):.1f} kHz')

print()
print('FRECUENCIA v3: f = k * W^a * L^b * Vth^d * Cm^c  (ambos)')
coef3, r2c, looc, pred3 = loo_powerlaw([W, L, V, C], F)
a3, b3, d3, c3, lk3 = coef3
print(f'  f = {np.exp(lk3):.4g} * W^{a3:.4f} * L^{b3:.4f} * Vth^{d3:.4f} * Cm^{c3:.4f}')
print(f'  R2 = {r2c:.4f}   LOO = {looc:.1f} kHz  ({100*looc/F.mean():.1f}%)')
print(f'  RMSE = {np.sqrt(np.mean((F-pred3)**2)):.1f} kHz')

print()
print('FRECUENCIA v4: f = k * W^a * L^b * (Iex/(Cm*Vth))^e   [forma LIF]')
Q = I * 1e-9 / (C * 1e-15 * V) / 1e3   # kHz teorico del integrador ideal
coef4, r2d, lood, pred4 = loo_powerlaw([W, L, Q], F)
a4, b4, e4, lk4 = coef4
print(f'  f = {np.exp(lk4):.4g} * W^{a4:.4f} * L^{b4:.4f} * (Iex/(Cm*Vth))^{e4:.4f}')
print(f'  R2 = {r2d:.4f}   LOO = {lood:.1f} kHz  ({100*lood/F.mean():.1f}%)')
print(f'  RMSE = {np.sqrt(np.mean((F-pred4)**2)):.1f} kHz')

print()
print('  W     L    Cm   f_med   v1     v2     v3     v4')
for i in np.argsort(W*1000+L+C/10000):
    print(f'{W[i]:5.2f} {L[i]:5.0f} {C[i]:5.0f} {F[i]:6.0f} {fp[i]:6.0f} '
          f'{pred2[i]:6.0f} {pred3[i]:6.0f} {pred4[i]:6.0f}')
