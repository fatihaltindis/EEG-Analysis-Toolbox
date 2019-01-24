function [clean_eeg,ics,comp_no,noise_times] = clear_EEG(eeg,fs,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function takes EEG and detects artefacts using Continous 
% Wavelet Transform (CWT) and Independent Component Analysis (ICA).
% FastICA toolbox was used to get Independent Components (ICs).
% %%%%%%%%%-- INPUTS --%%%%%%%%%%%%%%
% [clean_eeg,icasig,comp_no,noise_times] = clear_EEG(eeg,fs)
% eeg           -- Raw EEG signal portion (e.g. 8 seconds of EEG)
% fs            -- Sampling frequency
% %%%%%%%%%-- OUTPUTS --%%%%%%%%%%%%%
% clean_eeg     -- Artefact-free EEG signal   
% ics           -- Independent components of EEG signal
% comp_no       -- Cleaned components
% noise_times   -- Time epochs that are artefact-related
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   First EEG signal is rotated if rows are not the channells. ICA analysis
%   done by fastICA algorithm. Number of indipendent components (ICs) 
%   should be equal to number of channels. Thus while operant is included.
%   After ICA, ICs are taken into CWT process in order to highlight spikes
%   that are correspond to artefacts (e.g. eye blinks). Artefact related 
%   CWT coefficents of frequency intervals are averaged for each time epoch 
%   to find out noise related areas (w_coef). If there is a noise, w_coefs 
%   are replaced with zero (0). Finally, ICs were mixed to reconstruct 
%   EEG signal.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   OPTIONAL PARAMETERS:
%
% Parameter name        Values and description
%
%====================================================================== 
%
% 'sensivity'           (integer) This sensivity arranges width of wavelets
%                       and higher values detect narrow artefacts.
%                       In default, it is 3.
%
% 'visible'             (string) Plots the raw EEG vs clean EEG to show
%                       deleted parts of the signal. In default, it is 'on'.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Turn off default verbose of the functions
warning('off','signal:findpeaks:largeMinPeakHeight')

% Check some basic requirements of the data
if nargin < 2,
  error ('Not enough input argument.');
end

if length (size (eeg)) > 2,
  error ('Input data can not have more than two dimensions.');
end

if any (any (isnan (eeg))),
  error ('Input data contains NaN''s.');
end
% Row/Coloumn arrangements
[row,col] = size(eeg);
if row > col
    eeg = eeg';
end
[row,col] = size(eeg);

% Initialize variables
comp_no = [];
noise_times = cell(1,row);
t = 0:1/fs:col/fs-1/fs;
visible = 'on';
sensivity = 3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read the optional parameters

if (rem(length(varargin),2)==1)
  error('Optional parameters should always go by pairs');
else
  for i=1:2:(length(varargin))
      switch lower(varargin{i})
          case 'visible'
              visible = lower(varargin{i+1});
          case 'sensivity'
              sensivity = varargin{i+1};
          otherwise
              error(['Unrecognized parameter: ''' varargin{i} '''']);
      end      
  end
end

[ics, A, ~] = fastica(eeg,'verbose','off','numOfIC',row,'g','gauss');
trial = 0;
while (size(ics,1) < row) && (trial < 21)
    [ics, A, ~] = fastica(eeg,'verbose','off','numOfIC',row,'g','gauss');
    trial = trial+1;
end

if (~isnumeric(sensivity) || sensivity < 1 || sensivity > 3 || rem(sensivity,1)~= 0),
    error ('Sensivity must be 1 or 2 or 3.');
end

if sensivity == 1
    time_b = 20;
elseif sensivity == 2
    time_b = 10;
else
    time_b = 5;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Wavelet analysis begins
if isempty(ics) == 0
    for ch = 1:size(ics,1)
        fb5 = cwtfilterbank('SignalLength',col,'SamplingFrequency',fs,'TimeBandwidth',time_b);
        [w5,f] = cwt(ics(ch,:),'FilterBank',fb5);
        [w6,f] = cwt(ics(ch,:).^2,'FilterBank',fb5);
        w_coef = sum((abs(w5(31:50,:)).*abs(w6(31:50,:))).^2)./20;
        [pks,locs,w,~] = findpeaks(w_coef,fs,'MinPeakHeight',50);

        if isempty(pks) == 0
            cleaner = ones(1,col);
            x = locs*250-round(w*250);
            x(x<1) = 1;
            y = locs*250+100;
            delete_area = round(cell2mat(arrayfun(@(a,b)a:b-1, x,y,'UniformOutput',false)));
            cleaner(delete_area) = 0; cleaner = cleaner(1,1:col);
            temp = cleaner.*ics(ch,:);

            comp_no = [comp_no ch];
            noise_times{ch} = locs;

            ics(ch,:) = temp;
        end
    
    
    
    end
    clean_eeg = A*ics;
else
    clean_eeg = eeg;
end

if row/2 < 2
    p_f = [row 1];
elseif row/2 <= 3
    p_f = [ceil(row/2) 2];
elseif row/2 < 5
    p_f = [3 3];
elseif row/2 <= 8
    p_f = [4 4];
else
    p_f = 0;
end


if (strcmp(visible,'on') && p_f(1)~=0)
   figure;
   for p = 1:row
       subplot(p_f(1),p_f(2),p)
       plot(t,eeg(p,:))
       hold on
       plot(t,clean_eeg(p,:))
   end
elseif  strcmp(visible,'on') && p_f(1) == 0
    error('Too big to visualize!!!')
end

end

