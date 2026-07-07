
# STDP circuit with linear decay

Based on [1], here is the Synaptic Time Dependant Platicity with linear decay, implemented in the gf180mcuD pdk. 
[STDP Diagram](stdp.pdf)

## How it works
(jalton, aqui agrega el funcionamiento del circuito, en base al articulo. Asegurate de agregar las ecuaciones.)

## How to test
The testbench for this circuit consist into two voltage ramps that fed two neurons (See ../LIF).... Jalton. continua aqui con la descripcion 
[tb_stdp](tb_stdp.pdf)

## 📚 References
    1-Satoshi Moriya, Tatsuki Kato, Daisuke Oguchi, Hideaki Yamamoto, Shigeo Sato, Yasushi Yuminaka, Yoshihiko Horio, Jordi Madrenas, Analog-circuit implementation of multiplicative spike-timing-dependent plasticity with linear decay, Nonlinear Theory and Its Applications, IEICE, 2021, Volume 12, Issue 4, Pages 685-694, Released on J-STAGE October 01, 2021, Online ISSN 2185-4106, https://doi.org/10.1587/nolta.12.685, https://www.jstage.jst.go.jp/article/nolta/12/4/12_685/_article/-char/en

    -Roy, K., Jaiswal, A. & Panda, P. Towards spike-based machine intelligence with neuromorphic computing. Nature 575, 607–617 (2019). https://doi.org/10.1038/s41586-019-1677-2