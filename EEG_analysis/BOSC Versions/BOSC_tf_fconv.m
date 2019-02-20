function [B,T,P]=BOSC_tf_2(eegsignal,F,Fsample,wavenumber,parallel,conv_flag)% [B,T,P]=BOSC_tf_2(eegsignal,F,Fsample,wavenumber);%% This function computes a continuous wavelet (Morlet) transform on% a segment of EEG signal; this can be used to estimate the% background spectrum (BOSC_bgfit) or to apply the BOSC method to% detect oscillatory episodes in signal of interest (BOSC_detect).%this version uses frequency domain convolution%% parameters:% eegsignal - a row vector containing a segment of EEG signal to be%             transformed% F - a set of frequencies to sample (Hz)% Fsample - sampling rate of the time-domain signal (Hz)% wavenumber is the size of the wavelet (typically, width=6)% parallel - is 1 if you want serial processing, otherwise >1 is the%           integrer number of parallel workers to use% conv_flag - is 1 if you want matlab conv.m , or 2 if you want fconv.m        % frequency domain for faster computation (function lower in code)%	% returns:% B - time-frequency spectrogram: power as a function of frequency%     (rows) and time (columns)% T - vector of time values (based on sampling rate, Fsample)% P - estimated phase for each point in time and for each frequency - KEM 2014%setup matlabpoolif matlabpool('Size') == 0    matlabpool(parallel)endst=1./(2*pi*(F/wavenumber));A=1./sqrt(st*sqrt(pi));B = zeros(length(F),length(eegsignal)); % initialize the time-frequency matrixP = B;parfor f=1:length(F) % loop through sampled frequencies  tic;  fprintf(['Current working on ' num2str(F(f)) 'Hz. \n' ]);  t=-3.6*st(f):(1/Fsample):3.6*st(f);  m=A(f)*exp(-t.^2/(2*st(f)^2)).*exp(1i*2*pi*F(f).*t); % Morlet wavelet    switch conv_flag      case 1 %regular          y=conv(eegsignal,m,'same');       case 2 %frequency          y=fconv(eegsignal,m');           y = y((length(m)/2):end-(length(m)/2)); %cut off the ends  end    B(f,:) = abs(y).^2;  toc;endT=(1:size(eegsignal,2))/Fsample;%    This file is part of the Better OSCillation detection (BOSC) library.%%    The BOSC library is free software: you can redistribute it and/or modify%    it under the terms of the GNU General Public License as published by%    the Free Software Foundation, either version 3 of the License, or%    (at your option) any later version.%%    The BOSC library is distributed in the hope that it will be useful,%    but WITHOUT ANY WARRANTY; without even the implied warranty of%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the%    GNU General Public License for more details.%%    You should have received a copy of the GNU General Public License%    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.%%    Copyright 2010 Jeremy B. Caplan, Adam M. Hughes, Tara A. Whitten%    and Clayton T. Dickson.% Modifications made by K Mathewson 2016function [y]=fconv(x, h)%FCONV Fast Convolution%   [y] = FCONV(x, h) convolves x and h, and normalizes the output  %         to +-1.%%      x = input vector%      h = input vector% %      See also CONV%%   NOTES:%%   1) I have a short article explaining what a convolution is.  It%      is available at http://stevem.us/fconv.html.%%%Version 1.0%Coded by: Stephen G. McGovern, 2003-2004.Ly=length(x)+length(h)-1;  % Ly2=pow2(nextpow2(Ly));    % Find smallest power of 2 that is > LyX=fft(x, Ly2);		   % Fast Fourier transformH=fft(h, Ly2);	           % Fast Fourier transformY=X.*H;        	           % y=real(ifft(Y, Ly2));      % Inverse fast Fourier transformy=y(1:1:Ly);               % Take just the first N elements% y=y/max(abs(y));           % Normalize the output %mike cohen on board