bodyAcc = get(logsout, "<acc>");
T = bodyAcc.Values.Time(2) - bodyAcc.Values.Time(1);
Fs = 1/T;
L = length(bodyAcc.Values.Time);
t = (0:L-1)*T;        % Time vector
Y_lin = fft(bodyAcc.Values.Data(:,3));
Y_rot = fft(bodyAcc.Values.Data(:,5));

figure(1)
clf
subplot(1,2,1)
plot(Fs/L*(0:L-1),abs(Y_lin),"LineWidth",3)
title("Complex Magnitude of fft Spectrum (linear)")
xlabel("f (Hz)")
ylabel("|fft(X)|")
grid on

subplot(1,2,2)
plot(Fs/L*(0:L-1),abs(Y_rot),"LineWidth",3)
title("Complex Magnitude of fft Spectrum (rotational)")
xlabel("f (Hz)")
ylabel("|fft(X)|")
grid on