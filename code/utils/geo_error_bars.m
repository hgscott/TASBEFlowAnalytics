% Copyright (C) 2010-2017, Raytheon BBN Technologies and contributors listed
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

function [LU L U] = geo_error_bars(val,err)
% function [LU L U] = geo_error_bars(val,err)
%
% Function for turning geometric error into Lower/Upper error bar pairs
% for graphing routines that assume arithmetic error.
%
% This function assumes that error is represented positively
% in terms of fold, i.e. err >= 1.
%
% For example, geo_error_bars(10000,4) produces [7500; 30000]
% Adding and subtracting these from 10000 yields [2500; 40000], 
% i.e., 4-fold lower and higher than the original.

U = val.*(err-1);
L = val.*(1-(1./err));
U(err<1) = NaN; L(err<1) = NaN; % wipe points that don't fit the assumption
LU = [L;U];
