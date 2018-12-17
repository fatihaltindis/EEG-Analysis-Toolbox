function [ eeg_out ] = get_eeg( eeg_in,trial,varargin )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This function takes EEG data of all channels, takes a the starting 
%   index of interest and return it as an output.
%   - Rows represent channels
%   - Coloumns represent data points
%
%   [eeg_out] = get_eeg(eeg_in,trial)
%   In default, sampling frequency assumed 250 Hz and function takes 
%   8 seconds partition of the EEG from all channels available. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   OPTIONAL PARAMETERS:
%
% Parameter name        Values and description
%
%====================================================================== 
%
% 'fs'                  (integer) Sampling frequency of the EEG signal.
%                       i.e. (125) means that 1 second long EEG signal has
%                       125 data points. In default, it is 250 Hz.
%
% 'length'              (integer) Length of EEG signal to be partitioned. 
%                       Unit is seconds. In default, it is 8 seconds.
%
% 'Select_Ch'           (single integer or integer vector) Selects
%                       specified channels and returned them.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check some basic requirements of the data
if nargin < 2,
  error ('Not enough input argument.');
end

% Checks the input format to arrange row-coloumn specification
[row,col] = size(eeg_in);
if row > col
    eeg_in = eeg_in';
end
[row,col] = size(eeg_in);

if length (size (eeg_in)) > 2,
  error ('Input data can not have more than two dimensions.');
end

if any (any (isnan (eeg_in))),
  error ('Input data contains NaN''s.');
end

if (~isnumeric(trial) || trial < 1 || rem(trial,1)~= 0),
    error ('Index must be positive integer.');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Default values for optional parameters
fs = 250;
len = 8;
ch = 1:row;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read the optional parameters

if (rem(length(varargin),2)==1)
  error('Optional parameters should always go by pairs');
else
  for i=1:2:(length(varargin))
      switch lower(varargin{i})
          case 'fs'
              fs = varargin{i+1};
          case 'length'
              len = varargin{i+1};
          case 'select_ch'
              ch = varargin{i+1};
              
          otherwise
              error(['Unrecognized parameter: ''' varargin{i} '''']);
      end
      
  end
end

eeg_out = eeg_in(ch,trial:trial+(fs*len-1));

end

