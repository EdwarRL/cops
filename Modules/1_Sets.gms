$EOLCOM //

sets
p                                    periods
p1(p)                                first period
d                                    days
pd(p,d)                              periods p belong to day d

uni                                  generation units
fkey
uni_t(uni)                           thermal generation units
uni_h(uni)                           hydro generation units
uni_v(uni)                           variable generation units
fuel                                 fuel of generation units
uni_fuel (uni_t,fuel)
uni_fkey(uni,fkey)


plt                                  generation plants
plt_t(plt)                           thermal plants plants
plt_h(plt)                           hydro plants plants
plt_v(plt)                           variable renewable energy sources
tstate                               thermal state                         /cold,warm,hot/
plt_uni(plt,uni)                    tuple to relate the plant to the unit

pltt_cs(plt_t)                       thermal plants of simple cycle 
pltt_cc(plt_t)                       thermal plants of combined cycle

pltt_m3(plt_t)                       thermal plants with model 3

conf                                 thermal plants configurations
pltt_conf(plt_t,conf)                declared thermal plants configurations
r                                    thermal plants ramps output ranges
l                                    thermal plants model 3 coefficients /a,b/

ar
sba
ar_sba(ar,sba)

zn                                    Electrical zones
zntype                                zone type                         /uni,min,max/


uni_sba(uni,sba)                     Unit-Subarea relation

e                                    reservoir
euh(e,plt)                             reservoir upstream of hydro plant
hue(plt,e)                             hydro plant upstream of reservoir
eue(e,e)                             reservoir 1 upstream of reservoir 2

* Br
* N1(Br,Br)
* ni
* LoadFkey



;

alias (p,pp), (r,rr), (l,ll), (e,ee), (conf,confAux), (pltt_cs,pltt_cs1) //, (Br,Brk)

;

