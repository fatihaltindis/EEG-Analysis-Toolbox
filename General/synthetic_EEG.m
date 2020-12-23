function [synt_EEG, time_vector] = synthetic_EEG(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function creates synthetic EEG signals that are composed of sinus
% waves. It is possible to customize power of certain frequency bands such
% as alpha, beta etc., signal duration (seconds), maximum amplitude of
% created EEG signals, sampling rate of signal.
%
% By default, synthetic EEG signals with duration of 8 seconds, 30uV
% maximum amplitude can be created. Band powers are uniform in default
% mode and sampling rate is set to 250 Hz.
%
% Synthetic EEG is returned as first output variable. 
% Time vector of created signals is returned as second out variable of 
% the function.
%
% ========== EXAMPLE OF DEFAULT SETTINGS ==============================
% 
% [synt_EEG, time_vector] = synthetic_EEG();
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   OPTIONAL PARAMETERS:
%
% Parameter name        Values and description
%
% ===================================================================== 
%
% 'duration'            (double) Duration of the signal can be set with 
%                       this option. Unit of signal duration (length) is
%                       seconds.
%                       In default, duration is zero.
%
% 'fs'                  (integer) Sampling rate of the signal can be
%                       adjusted with this option.
%                       In default, sampling rate is 250 Hz.
% %%% EXAMPLE 1 
% [synt_EEG, time_vector] = synthetic_EEG('duration',10,'fs',500);
% %%%
%
% 'max_amp'             (double) This option can be used to set maximum
%                       amplitude that synthetic EEG will be. Unit of this
%                       variable is microvolt (uV).
%                       In default, it is set to 30 uV.
%
% %%% EXAMPLE 2
% [synt_EEG, time_vector] = synthetic_EEG('fs',500,'max_amp',40);
% %%%
%
% 'alpha'               (vector) This option adjusts alpha band power of
%                       synthetic EEG signal. Value of this option should
%                       be a vector that contains: 
%                       1) at what time bandpower will be increased
%                       2) duration of bandpower change
%                       3) band power increase rate - that should be
%                       between 0.1 to 5. If it is higher than 1, band
%                       power increases correspondingly. Band power
%                       decreases if this value is lower than 1.
%                       
%
% 'beta'                (double) This option adjusts alpha band power of
%                       synthetic EEG signal. Value of this option should
%                       be a vector that contains: 
%                       1) at what time bandpower will be increased
%                       2) duration of bandpower change
%                       3) band power increase rate - that should be
%                       between 0.1 to 5. If it is higher than 1, band
%                       power increases correspondingly. Band power
%                       decreases if this value is lower than 1.
%
% 'delta'               (double) This option adjusts alpha band power of
%                       synthetic EEG signal. Value of this option should
%                       be a vector that contains: 
%                       1) at what time (sec) bandpower will be increased
%                       2) duration (sec) of bandpower change
%                       3) band power increase rate - that should be
%                       between 0.1 to 5. If it is higher than 1, band
%                       power increases correspondingly. Band power
%                       decreases if this value is lower than 1.
%
% 'theta'               (double) This option adjusts alpha band power of
%                       synthetic EEG signal. Value of this option should
%                       be a vector that contains: 
%                       1) at what time bandpower will be increased
%                       2) duration of bandpower change
%                       3) band power increase rate - that should be
%                       between 0.1 to 5. If it is higher than 1, band
%                       power increases correspondingly. Band power
%                       decreases if this value is lower than 1.
%
% %%% EXAMPLE 3
% [synt_EEG, time_vector] = synthetic_EEG('duration',10,'fs',500,...
% 'alpha',[1,3,2.4]'max_amp',25);
% 
% Alpha band power of this signal will be 2.4 times higher between 
% 1st second to 4th second than remaining of the signal
% %%%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Initialize needed parameters
if (nargin == 0)
    fs = 250;
    duration = 8;
    max_amp = 30;
    alpha = 1;
    beta = 1;
    delta = 1;
    theta = 1;
%% Exceptions and conditions    
elseif (rem(length(varargin),2)==1)
    error('Parameters should always go by pairs');
  
else
    % Initialize before giving actual values
    fs = 250;
    duration = 8;
    max_amp = 30;
    alpha = 1;
    beta = 1;
    delta = 1;
    theta = 1;
    for i=1:2:(length(varargin))
        switch lower(varargin{i})
            case 'duration'
                if ~isnumeric(varargin{i+1}) || length(varargin{i+1}) ~= 1
                    error('Duration should take a single number!')
                elseif varargin{i+1} <= 0
                    error('Duration should be a positive number.')
                else
                    duration = varargin{i+1};
                end
                
            case 'fs'
                if ~isnumeric(varargin{i+1}) || length(varargin{i+1}) ~= 1
                    error('Sampling rate should take a single number!')
                elseif varargin{i+1} <= 0
                    error('Sampling rate should be a positive number.')
                else
                    fs = varargin{i+1};
                end
            
            case 'max_amp'
                if ~isnumeric(varargin{i+1}) || length(varargin{i+1}) ~= 1
                    error('Maximum amplitude should take a single number!')
                elseif varargin{i+1} <= 0
                    error('Maximum amplitude should be a positive number.')
                else
                    max_amp = varargin{i+1};
                end
                
            case 'alpha'
                if ~isnumeric(varargin{i+1}) || length(varargin{i+1}) ~= 3
                    error('Alpha band should take a vector containing 3 values!')
                elseif varargin{i+1}(3) < 0.1
                    warning('Alpha band cannot be lower than 0.1')
                    warning('Alpha band power set to 0.1')
                    alpha = varargin{i+1};
                    alpha(3) = 0.1;
                elseif varargin{i+1}(3) > 5
                    warning('Alpha band cannot be higher than 5')
                    warning('Alpha band power set to 5')
                    alpha = varargin{i+1};
                    alpha(3) = 5;                        
                else
                    alpha = varargin{i+1};
                end
                
            case 'beta'
                if ~isnumeric(varargin{i+1}) || length(varargin{i+1}) ~= 3
                    error('Beta band should take a vector containing 3 values!')
                elseif varargin{i+1}(3) < 0.1
                    warning('Beta band cannot be lower than 0.1')
                    warning('Beta band power set to 0.1')
                    beta = varargin{i+1};
                    beta(3) = 0.1;
                elseif varargin{i+1}(3) > 5
                    warning('Beta band cannot be higher than 5')
                    warning('Beta band power set to 5')
                    beta = varargin{i+1};
                    beta(3) = 5;
                else
                    beta = varargin{i+1};
                end
                
            case 'delta'
                if ~isnumeric(varargin{i+1}) || length(varargin{i+1}) ~= 3
                    error('Delta band should take a vector containing 3 values!')
                elseif varargin{i+1}(3) < 0.1
                    warning('Delta band cannot be lower than 0.1')
                    warning('Delta band power set to 0.1')
                    delta = varargin{i+1};
                    delta(3) = 0.1;
                elseif varargin{i+1}(3) > 5
                    warning('Delta band cannot be higher than 5')
                    warning('Delta band power set to 5')
                    delta = varargin{i+1};
                    delta(3) = 5;
                else
                    delta = varargin{i+1};
                end
                
            case 'theta'
                if ~isnumeric(varargin{i+1}) || length(varargin{i+1}) ~= 3
                    error('Theta band should take a vector containing 3 values!')
                elseif varargin{i+1}(3) < 0.1
                    warning('Theta band cannot be lower than 0.1')
                    warning('Theta band power set to 0.1')
                    theta = varargin{i+1};
                    theta(3) = 0.1;
                elseif varargin{i+1}(3) > 5
                    warning('Theta band cannot be higher than 5')
                    warning('Theta band power set to 5')
                    theta = varargin{i+1};
                    theta(3) = 5;
                else
                    theta = varargin{i+1};
                end
                
            otherwise
                error(['Unrecognized parameter: ''' varargin{i} '''']);
        end
    end
end

%% MAIN CODE
time_vector = 0:1/fs:duration-1/fs;

% ALPHA
if numel(alpha) == 3
    % Band power change vector created here
    alpha_center = alpha(1)+alpha(2)/2;
    alpha_width = alpha(2)/2;
    alpha_change = (alpha(3)-1)*gbellmf(time_vector,...
        [alpha_width 10 alpha_center])+1;
else
    alpha_change = ones(1,length(time_vector));
end

% BETA
if numel(beta) == 3
    % Band power change vector created here
    beta_center = beta(1)+beta(2)/2;
    beta_width = beta(2)/2;
    beta_change = (beta(3)-1)*gbellmf(time_vector,...
        [beta_width 10 beta_center])+1;
else
    beta_change = ones(1,length(time_vector));
end

% DELTA
if numel(delta) == 3
    % Band power change vector created here
    delta_center = delta(1)+delta(2)/2;
    delta_width = delta(2)/2;
    delta_change = (delta(3)-1)*gbellmf(time_vector,...
        [delta_width 10 delta_center])+1;
else
    delta_change = ones(1,length(time_vector));
end

% THETA
if numel(theta) == 3
    % Band power change vector created here
    theta_center = theta(1)+theta(2)/2;
    theta_width = theta(2)/2;
    theta_change = (theta(3)-1)*gbellmf(time_vector,...
        [theta_width 10 theta_center])+1;
else
    theta_change = ones(1,length(time_vector));
end

control = ones(1,length(time_vector));
N = length(control);
tsig = zeros(1,N);


for i = 0:0.1:100

    if i > 1 && i < 4 
        %% DELTA BAND related sine waves
        temp = sin(2*pi*i.*time_vector + 2*rand*pi);
        tsig = tsig + delta_change.*temp;
    elseif i >= 4 && i < 8
        %% THETA BAND related sine waves
        temp = sin(2*pi*i.*time_vector + 2*rand*pi);
        tsig = tsig + theta_change.*temp;
    elseif i >= 8 && i < 15
        %% ALPHA BAND related sine waves
        temp = sin(2*pi*i.*time_vector + 2*rand*pi);
        tsig = tsig + alpha_change.*temp;
    elseif i >= 15 && i < 30
        %% BETA BAND related sine waves
        temp = sin(2*pi*i.*time_vector + 2*rand*pi);
        tsig = tsig + beta_change.*temp;
    else
        temp = sin(2*pi*i.*time_vector + 2*rand*pi);
        tsig = tsig + temp;
    end
    
    
end



synt_EEG = max_amp * rescale(tsig,-1,1);
end
