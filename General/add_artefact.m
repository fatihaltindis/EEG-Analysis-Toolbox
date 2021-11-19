function [signal_out] = add_artefact(signal_in,fs,varargin)
% This function can add 6 different artefact types to given signal and 
% returns artefact added signal as an output.
% 
% ========== EXAMPLE OF A SIMPLE CASE ==============================
% [signal_out] = add_artefact(signal_in,fs,'blink',3)
% 
% In this example, blink artefact will be added to given signal. Artefact
% will be added to third(3rd) second of the given signal. 
% ========= IMPORTANT NOTICE =======================================
% Sampling rate of the signal must be given as second input.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   OPTIONAL PARAMETERS:
%
% Parameter name        Values and description
%
% ===================================================================== 
%
% 'blink'               (double) Starting time of blink artefact must be 
%                       given. Unit of time is second. 
% [signal_out] = add_artefact(signal_in,fs,'blink',3)
% 
% 'muscle'              (double) Starting time of muscle artefact must be 
%                       given. Unit of time is second. 
% [signal_out] = add_artefact(signal_in,fs,'muscle',3)
% 
% 'discont'             (double) Starting time of discontinuity artefact 
%                       must be given. Unit of time is second. 
% [signal_out] = add_artefact(signal_in,fs,'discont',3)
% 
% 'awgn'                (double) Starting time of awgn noise must be given.
%                       Unit of time is second. 
% [signal_out] = add_artefact(signal_in,fs,'awgn',3)
% 
% 'linear'              (double) Starting time of linear artefact must be 
%                       given. Unit of time is second. 
% [signal_out] = add_artefact(signal_in,fs,'linear',3)
% 
% 'powerline'           (string) You need to specify powerline noise type.
%                       Function will add specified noise to whole signal.
%                       It can be either '50' or '60'.
% [signal_out] = add_artefact(signal_in,fs,'powerline','60')
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3
  error ('Not enough input arguments.');
end

% Checks the input format to arrange row-coloumn specification
% Rows will be channels and coloumns will be time instances
[row,col] = size(signal_in);
if row > col
    signal_in = signal_in';
    [row,col] = size(signal_in);
end

if length (size (signal_in)) > 2
  error ('Input data can not have more than two dimensions.');
end

if any (any (isnan (signal_in)))
  error ('Input data contains NaN''s.');
end

% Starts to check artefact type and adds artefact to signal 
if (rem(length(varargin),2)==1)
  error('Artefact parameters should always go by pairs');
else
  n = 0:1/fs:2-1/fs; % two second long vector
  % Find maximum amplitude of each channel for adjusting amplitude of
  % artefacts
  channel_max_amplitudes = max(abs(signal_in),[],2);
  for i=1:2:(length(varargin))
      switch lower(varargin{i})
          case 'blink'
              artefact_start = fs*varargin{i+1}; % Start time of blink
              if artefact_start >= col-(1.25*fs)
                  error('Blink artefact start time exceeds signal length');
              else
                  f = randi([10 20],5,1)/10;
                  s = (channel_max_amplitudes)*sum(sin(2*pi*f*n+pi*rand))/5;
                  signal_in(:,artefact_start:artefact_start+round(1.25*fs))...
                      = signal_in(:,artefact_start:artefact_start+round(1.25*fs))...
                      + s(30:30+round(1.25*fs));
              end
          case 'muscle'
              artefact_start = fs*varargin{i+1};
              if artefact_start >= col-(1.25*fs)
                  error('Muscle artefact start time exceeds signal length');
              else
                  f = randi([4000 8000],40,1)/10;
                  s = transpose(channel_max_amplitudes)*sum(sin(2*pi*f*n+pi*rand))/10;
                  signal_in(:,artefact_start:artefact_start+(1.25*fs))...
                      = signal_in(:,artefact_start:artefact_start+(1.25*fs))...
                      + s(30:30+(1.25*fs));
              end
          case 'discont'
              artefact_start = fs*varargin{i+1};
              if artefact_start >= col-2.25*fs
                  error('Discontinuity artefact start time exceeds signal length');
              else
                  s = zeros(row,2*fs+1);
                  s(:,5:randi(fs*[0.9 2])) = channel_max_amplitudes*2;
                  signal_in(:,artefact_start:artefact_start+(2*fs))...
                      = signal_in(:,artefact_start:artefact_start+(2*fs))...
                      + s;
              end
          case 'awgn'
              artefact_start = fs*varargin{i+1};
              if artefact_start >= col-2.25*fs
                  error('White noise artefact start time exceeds signal length');
              else
                  signal_in(:,artefact_start:artefact_start+2*fs)...
                      = awgn(signal_in(:,artefact_start:artefact_start+2*fs),1/1000); 
              end
          case 'linear'
              artefact_start = fs*varargin{i+1};
              if artefact_start >= col-4.25*fs
                  error('Linear artefact start time exceeds signal length');
              else
                  s = zeros(row,4*fs+1);
                  f = randi(fs*[3 4]);
                  s(:,5:4+f) = linspace(-max(channel_max_amplitudes)...
                      ,max(channel_max_amplitudes),f);
                  signal_in(:,artefact_start:artefact_start+(4*fs))...
                      = signal_in(:,artefact_start:artefact_start+(4*fs))...
                      + s;
              end
              
          case 'powerline'
              if strcmp(varargin{i+1},'50')
                  f = [0:col-1]/fs;
                  s = randi([100,150],1)*channel_max_amplitudes*sin(2*pi*50*f)/100;
                  signal_in = signal_in + s;
              elseif strcmp(varargin{i+1},'60')
                  f = [0:col-1]/fs;
                  s = randi([100,150],1)*channel_max_amplitudes*sin(2*pi*60*f)/100;
                  signal_in = signal_in + s;
              else
                  error(['You need to choose either ''50'' or ''60'' !!!']);
              end
   
          otherwise
              error(['Unrecognized parameter: ''' varargin{i} '''']);
      end
      signal_out = signal_in; 
  end
end


end

