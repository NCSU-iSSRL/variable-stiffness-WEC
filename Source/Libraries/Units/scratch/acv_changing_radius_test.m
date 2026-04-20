clear;clc;
r_d = 0.01;
l_t = 0.01;

results = [];
for V_internal = linspace(0, 5e-6, 100)

    x = V_internal / (pi * r_d^2);
    valveCracked = 0;
    
    if x > l_t % passed cracking threshold, revise x estimate due to throat expansion
        valveCracked = 1;
        V_rem = V_internal - pi * r_d^2 * l_t; % remaining volume
        
        syms x_frustum real
        d = r_d;
        b = r_d * (x_frustum/l_t + 1);
        eq1 = V_rem == pi * x_frustum / 3 * (d^2 + d*b + b^2); % volume of frustum
        x_rem1 = eval(vpasolve(eq1));
    
        x_rem2 = roots([1, 3*l_t, 3*l_t^2, -3*l_t^2*V_rem/pi/r_d^2]);
    
        x = l_t + x_rem2(imag(x_rem2) == 0);
    end
    
    results(end+1,:) = [V_internal, x, valveCracked];
end

figure(1)
clf
plot(results(~results(:,3),1), results(~results(:,3),2))
hold on
plot(results(results(:,3) == 1,1), results(results(:,3) == 1,2))
xlabel('Volume into ACV')
ylabel('Displacement of disk')
%% 
clear;clc
syms x_frustum rd lt V q real 
% assume(x_frustum > 0)
% eq1 = V == pi*x_frustum/12 * rd^2 * (1 + x_frustum/lt + x_frustum^2/lt^2);
% solve(eq1, x_frustum, 'ReturnConditions',true)
d = rd;
b = rd * (0.5*x_frustum/lt + 1);
V_frustum = pi*x_frustum/3 * (d^2 + d*b + b^2)
simplify(V_frustum)