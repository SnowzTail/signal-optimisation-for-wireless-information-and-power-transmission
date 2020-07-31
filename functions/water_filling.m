function [streamPower] = water_filling(lambda, txPower, noisePower)
% Function: 
%   - iterative stream power allocation based on water-filling algorithm
%
% InputArg(s):
%   - lambda: eigenvalues of the channel matrix corresponding to valid
%   non-zero eigenvectors
%   - txPower: average transmit power
%   - noisePower: average noise power
%
% OutputArg(s):
%   - streamPower: power allocated to each stream
%
% Restraints:
%   - this function is based on iterative method which can be inefficient 
%   when numerous streams exist
%
% Comments:
%   - assume power budget is unit
%   - non-zero eigenvalues correspond to feasible eigenvectors and streams
%   - favour multiple eigenmode transmission for high snr and dominant 
%   eigenmode transmission for low snr
%
% Author & Date: Yang (i@snowztail.com) - 11 Feb 19


% calculate SNR
snr = txPower / noisePower;
% initialise power allocation
streamPowerTemp = zeros(length(lambda), 1);
% obtain number of available streams
stream = length(lambda(abs(lambda) > eps));
% sort in descending order for water filling
[lambda, index] = sort(lambda, 'descend');
% calculate the stream base level (status)
baseLevel = 1 ./ (snr * lambda);
% begin iteration
for iStream = 1: stream
    % update quasi water level
    waterLevel = 1 / (stream - iStream + 1) * (1 + sum(baseLevel(1: (stream - iStream + 1))));
    % try to allocate power with this new water level
    streamPowerTemp(1: iStream) = waterLevel - baseLevel(1: iStream);
    % negative allocation is invalid
    isInvalid = ~all(streamPowerTemp >= 0);
    if isInvalid 
        % invalid power distribution, return the latest valid solution
        break;
    else
        % update power allocation
        streamPower = streamPowerTemp;
    end
end
% sort to ensure power corresponds to correct eigenvalues
streamPower(index) = streamPower;
% normalise power
streamPower = streamPower ./ sum(streamPower) * txPower;
end

