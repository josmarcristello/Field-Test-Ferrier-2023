%%%%%%   PSD computation through FFT (hann window)  %%%%%


function [freq_x, ave_psdx] = PSD(time_data, freq, ave_period)
N = floor(freq * ave_period); 
ave_num = floor(length(time_data)/N); 
freq_x = (0:freq/N:freq/2)';

%creat a hann (hanning) window, in column vector
w_hann = hann(N, 'periodic');

%Averaging FFT
ave_psdx = zeros(N/2+1,1);
for i = 1 : ave_num
xdft = fft( w_hann .* time_data( (i-1)*N+1 : i*N ) );
xdft = xdft(1:N/2+1);
psdx = (1/(freq*N)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1); 
ave_psdx = ave_psdx + psdx;

end

ave_psdx = ave_psdx./ave_num; % averaging the PSD (V^2/Hz)

end