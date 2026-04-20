function [Qout,Qin,P,k,F] = pumpDisplacementCalcs(type,setting,ru,lu,au,x,t,k_tube,mu,lt,rt)
    v = gradient(x)./gradient(t);
    if type == 1
        for j=1:length(setting)
            for i = 1:length(v)
                if v(i)>0   %out
                    Qout(i,j) = -pi*ru^2*(1/sin(au)^2 - 3*(x(i)/lu+1).^2./(tan(au))^2).*v(i);
                    Qin(i,j) = 0;
                    P(i,j) = setting(j)*Qout(i,j)^2;
                    k(i,j) = 6*pi*ru^2*P(i,j)*(1+x(i)/lu)/(lu*tan(au))^2 + k_tube; %E*pi*(rou^2-ri^2)/lu;
                    F(i,j) = pi*ru^2*P(i,j)*(3*(1+x(i)/lu).^2/tan(au)^2 - 1/sin(au)^2) + k_tube*x(i);
                else        %in
                    Qin(i,j) = pi*ru^2*(1/sin(au)^2 - 3*(x(i)/lu+1).^2./(tan(au))^2).*v(i);
                    Qout(i,j) = 0;
                    P(i,j) = -8*mu*lt/(pi*rt^4)*Qin(i,j);
                    k(i,j) = 6*pi*ru^2*P(i,j)*(1+x(i)/lu)/(lu*tan(au))^2 + k_tube; %E*pi*(rou^2-ri^2)/lu;
                    F(i,j) = pi*ru^2*P(i,j)*(3*(1+x(i)/lu).^2/tan(au)^2 - 1/sin(au)^2) + k_tube*x(i);
                end
            end
        end
    elseif type == 2
        k = zeros(length(t),length(setting));
        for j=1:length(setting)
            for i = 1:length(v)
                if v(i)>0   %out
                    P(i,j) = setting(j);
                    F(i,j) = pi*ru^2*P(i,j)*(3*(x(i)/lu+1)^2/(tan(au))^2 - 1/sin(au)^2) + k_tube*x(i);
                    Qout(i,j) = -pi*ru^2*(1/sin(au)^2 - 3*(x(i)/lu+1)^2/(tan(au))^2)*v(i);
                    Qin(i,j) = 0;
                    k(i,j) = 6*pi*ru^2*P(i,j)*(1+x(i)/lu)/(lu*tan(au))^2 + k_tube;
                    
        
                else        %in
                    F(i,j) = k_tube*x(i); %(8*pi*mu*lt*(r0/rt)^4*(3*(x(i)+lu)^2/(l0*tan(a0))^2 - 1/sin(a0)^2)^2)*v(i) + k_tube*x(i);
                    Qin(i,j) = pi*ru^2*(1/sin(au)^2 - 3*(x(i)/lu+1)^2/(tan(au))^2)*v(i);;
                    Qout(i,j) = 0;
                    P(i,j) = -8*mu*lt/(pi*rt^4)*Qin(i,j);
                    k(i,j) = k_tube;
                end
            end
            % k(:,j) = gradient(F(:,j))./gradient(transpose(x));
        end
    else
        fprintf('Type aint right fam')
        fprintf(newline)
    end    
end