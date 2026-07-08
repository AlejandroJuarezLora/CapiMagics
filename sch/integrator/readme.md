
# Integrator

Based on [1], here is the Integrator circuit using a subthreshold first-order LPF circuit, implemented in the gf180mcuD pdk. 
![STDPDiagram](stdp.png)

## How it works
Each incoming spike at the gate of $M_5$ draws a current $I_{spks}$ from the capacitor $C_{syn}$, causing the synaptic voltage $v_{syn}$ to decrease. This reduction in $v_{syn}$ activates transistor $M_2$, allowing current to flow and generating a rising output voltage $\hat{x}$. In the absence of spikes, $C_{syn}$ remains charged, increasing $v_{syn}$ and driving $\hat{x}$ toward zero.

Since $I_{M_2} = I_{M_4}$, the output current can be expressed as:

```math
\frac{1}{2}\mu_p C_{ox}\left(\frac{W}{L}\right)_4
\left(v_{sg}-|v_{th,p}|\right)^2
=
\mu_n C_{ox}\left(\frac{W}{L}\right)_5
\left(v_{gs}-v_{th,n}\right)v_{ds}
-\frac{1}{2}v_{ds}^2
```

```math
\frac{1}{2}\mu_p \left(\frac{W}{L}\right)_4
\left(v_{dd}-v_{syn}-|v_{th,p}|\right)^2
\approx
\mu_n \left(\frac{W}{L}\right)_5
\left(v_x-v_{th,n}\right)v_{out}
```

Taking into account that

```math
v_x = \frac{R_2}{R_1 + R_2}v_{dd} = \frac{v_{dd}}{2}
```

we can find an expression for \(v_{out}=\hat{x}\) as:

```math
\frac{1}{2}\mu_p C_{ox}\left(\frac{W}{L}\right)_4
(v_{sg}-|v_{th,p}|)^2
=
\mu_n C_{ox}\left(\frac{W}{L}\right)_5
(v_{gs}-v_{th,n})v_{ds}
-\frac{1}{2}v_{ds}^2
```

```math
\frac{1}{2}\mu_p \left(\frac{W}{L}\right)_4
(v_{dd}-v_{syn}-|v_{th,p}|)^2
\approx
\mu_n \left(\frac{W}{L}\right)_5
(v_x-v_{th,n})v_{out}
```

Substituting \(v_x=v_{dd}/2\):

```math
\frac{1}{2}\mu_p \left(\frac{W}{L}\right)_4
(v_{dd}-v_{syn}-|v_{th,p}|)^2
\approx
\mu_n \left(\frac{W}{L}\right)_5
\left(\frac{v_{dd}}{2}-v_{th,n}\right)v_{out}
```

Solving for \(v_{out}\):

```math
v_{out}
\approx
\frac{
\frac{1}{2}\mu_p \left(\frac{W}{L}\right)_4
(v_{dd}-v_{syn}-|v_{th,p}|)^2
}{
\mu_n \left(\frac{W}{L}\right)_5
\left(\frac{v_{dd}}{2}-v_{th,n}\right)
}
```

This relationship can be expressed as

```math
v_{out} = \hat{x} = f(v_{syn})
```

where \(v_{syn}\) acts as the controlling input voltage.

## How to test
The testbench for this circuit consists of the integrator block driven by a neuron model that generates a train of pulses, allowing the circuit's operation and dynamic behavior to be evaluated.

![tb_stdp](tb_stdp.png)

## 📚 References
    - Satoshi Moriya, Tatsuki Kato, Daisuke Oguchi, Hideaki Yamamoto, Shigeo Sato, Yasushi Yuminaka, Yoshihiko Horio, Jordi Madrenas, Analog-circuit implementation of multiplicative spike-timing-dependent plasticity with linear decay, Nonlinear Theory and Its Applications, IEICE, 2021, Volume 12, Issue 4, Pages 685-694, Released on J-STAGE October 01, 2021, Online ISSN 2185-4106, https://doi.org/10.1587/nolta.12.685, https://www.jstage.jst.go.jp/article/nolta/12/4/12_685/_article/-char/en

    - Roy, K., Jaiswal, A. & Panda, P. Towards spike-based machine intelligence with neuromorphic computing. Nature 575, 607–617 (2019). https://doi.org/10.1038/s41586-019-1677-2
