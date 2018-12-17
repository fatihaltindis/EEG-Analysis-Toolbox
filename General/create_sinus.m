function [signal_out, time_out] = create_sinus(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function creates sinus wave with customized signal length, sampling
% rate, frequency and phase shift.
% [signal_out, time_out] = create_sinus('signal_length',8,'frequency',15,'fs',250)
% In this example, 8 seconds long 15 Hz sinus wave is created with 250 Hz
% sampling rate. In default, phase shift is zero.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   OPTIONAL PARAMETERS:
%
% Parameter name        Values and description
%
%====================================================================== 
%
% 'phase'               (double) Phase can be set with this option. Phase
%                       unit is radian (pi).
%                       In default, it is zero.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check some basic requirements of the data
if nargin < 6
  error ('Not enough input argument.');
end
    
% Initialize needed parameters
fs = -1;
signal_length = 0;
freq = 0;
phase_shift = 0;

if (rem(length(varargin),2)==1)
  error('Parameters should always go by pairs');
else
  for i=1:2:(length(varargin))
      switch lower(varargin{i})
          case 'signal_length'
              if ~isnumeric(varargin{i+1}) || length(varargin{i+1}) ~= 1
                  error('Signal length should be a single number.')
              elseif varargin{i+1} <= 0
                  error('Signal length should be a positive number.')
              else
                  signal_length = varargin{i+1};
              end
          case 'frequency'
              if ~isnumeric(varargin{i+1}) || length(varargin{i+1}) ~= 1
                  error('Frequency should be a single number.')
              elseif varargin{i+1} <= 0 || rem(varargin{i+1},1) ~= 0
                  error('Frequency should be a positive integer.')
              else
                  freq = varargin{i+1};
              end
          case 'fs'
              if ~isnumeric(varargin{i+1}) || length(varargin{i+1}) ~= 1
                  error('Sampling frequency should be a single number.')
              elseif varargin{i+1} <= 0 || rem(varargin{i+1},1) ~= 0
                  error('Sampling frequency should be a positive integer.')
              else
                  fs = varargin{i+1};
              end
          case 'phase'
              if ~isnumeric(varargin{i+1}) || length(varargin{i+1}) ~= 1
                  error('Phase should be a single number.')
              elseif varargin{i+1} <= 0 || varargin{i+1} > 2
                  error('Phase should be between 0 and 2.')
              else
                  phase_shift = varargin{i+1};
              end
          
          otherwise
              error(['Unrecognized parameter: ''' varargin{i} '''']);
      end      
  end
end

% Signal creating begins
n = 0:1/fs:signal_length-1/fs;
signal_out = sin(2*pi*freq.*n + phase_shift*pi);
time_out = n;
end

