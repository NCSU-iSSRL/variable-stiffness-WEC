clear;clc;
syms x(t) R0 L0 a b pi
strain = x/L0;
V = pi*R0^2*L0*(b*(1+strain) - a/3 * (1+strain)^3);
diff(V, t)
