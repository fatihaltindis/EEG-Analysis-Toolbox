function [bandpower,filtered_eeg] = eeg_bandpower_extract(eeg,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function takes EEG signal and extracts specified band powers
%   You need to specify sampling frequency of the signal and band name or
%   frequency range to extract.
%
%   [bandpower,filtered_eeg] = eeg_bandpower_extract(eeg,'fs',250,'band','alpha')
%   In this example, function takes EEG signal, apply a filter to extract
%   alpha band.
%
%   [bandpower,filtered_eeg] = eeg_bandpower_extract(eeg,'fs',300,'range',[11 23])
%   In this example, function takes EEG signal, apply a filter to extract
%   band power of 11 - 23 Hz.
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   OPTIONAL PARAMETERS:
%
% Parameter name        Values and description
%
%====================================================================== 
%
% 'filter_order'        (integer) Filter order of the filter that is used
%                       in band power analysis. It must be even integer. In
%                       default, it is 6.
%                       i.e. (10) means that filter order is set to 10.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check some basic requirements of the data
if nargin < 5
  error ('Not enough input argument.');
end

if length (size (eeg)) > 2
  error ('Input data can not have more than two dimensions.');
end

if any (any (isnan (eeg)))
  error ('Input data contains NaN''s.');
end

if ~isempty(find(strcmp(varargin,'band'))) && ~isempty(find(strcmp(varargin,'range')))
   error('''range'' and ''band'' options cannot be used at the same time.') 
end
    
% Checks the input format to arrange row-coloumn specification
[row,col] = size(eeg);
if row > col
    eeg = eeg';
end
[row,col] = size(eeg);

% Initialize needed parameters
fs = -1;
band_name = 'no';
band_range = [-1 -1];
f_order = 6;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read the optimal parameters

if (rem(length(varargin),2)==1)
  error('Parameters should always go by pairs');
else
    for i=1:2:(length(varargin))
      switch lower(varargin{i})
          case 'fs'
              if varargin{i+1} < 1 || rem(varargin{i+1},1)~= 0 || ~isnumeric(varargin{i+1})
                  error('Sampling rate must be a positive integer.')
              else
                  fs = varargin{i+1};
              end
              
          case 'band'
              if strcmp(varargin{i+1},'delta')
                  band_name = 'delta';
                  band_range = [0.5 4];
              elseif strcmp(varargin{i+1},'theta')
                  band_name = 'theta';
                  band_range = [4 7];
              elseif strcmp(varargin{i+1},'alpha')
                  band_name = 'alpha';
                  band_range = [7.5 13];
              elseif strcmp(varargin{i+1},'beta')
                  band_name = 'beta';
                  band_range = [15 28];
              elseif strcmp(varargin{i+1},'gamma')
                  band_name = 'gamma';
                  band_range = [29 48];
              else
                  error('Please enter valid band name (delta,theta,alpha,beta,gamma).')
              end
              
          case 'range'
              if length(size(varargin{i+1})) ~= 2
                  error('There must be two numbers that will indicate frequency range.')
              elseif size(varargin{i+1},1)*size(varargin{i+1},2) ~= 2
                  error('There must be two numbers that will indicate frequency range.')
              elseif all(varargin{i+1} > 0) ~= 1 || ~isnumeric(varargin{i+1})
                  error('Range values must be positive integers.')
              elseif (varargin{i+1}(2) - varargin{i+1}(1)) <= 0
                  error('Upper range value must be bigger than low range value.')
              else
                  band_range = varargin{i+1};
              end
          
          case 'filter_order'
              f_order = varargin{i+1};
          otherwise
              error(['Unrecognized parameter: ''' varargin{i} '''']);
      end
      
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bandpower extraction begins
band_filter = designfilt('bandpassiir','FilterOrder',f_order, ...
         'HalfPowerFrequency1',band_range(1),'HalfPowerFrequency2',...
         band_range(2),'SampleRate',fs);
     
filtered_eeg = filter(band_filter,eeg')';
bandpower = filtered_eeg.^2;

end

