function [llik,parameters] = evaluate_likelihood(parameters)
% Evaluate the logged likelihood at parameters.
%
% INPUTS
%    o parameters  a string ('posterior mode','posterior mean','posterior median','prior mode','prior mean') or a vector of values for
%                  the (estimated) parameters of the model.
%
%
% OUTPUTS
%    o ldens       [double]  value of the sample logged density at parameters.
%    o parameters  [double]  vector of values for the estimated parameters.
%
% SPECIAL REQUIREMENTS
%    None
%
% REMARKS
% [1] This function cannot evaluate the likelihood of a dsge-var model...
% [2] This function use persistent variables for the dataset and the description of the missing observations. Consequently, if this function
%     is called more than once (by changing the value of parameters) the sample *must not* change.

% Copyright (C) 2009-2010 Dynare Team
%
% This file is part of Dynare.
%
% Dynare is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <http://www.gnu.org/licenses/>.

global options_ M_ bayestopt_ oo_ estim_params_

persistent dataset

if nargin==0
    parameters = 'posterior mode';
end

if ischar(parameters)
    switch parameters
      case 'posterior mode'
        parameters = get_posterior_parameters('mode');
      case 'posterior mean'
        parameters = get_posterior_parameters('mean');
      case 'posterior median'
        parameters = get_posterior_parameters('median');
      case 'prior mode'
        parameters = bayestopt_.p5(:);
      case 'prior mean'
        parameters = bayestopt_.p1;
      otherwise
        disp('eval_likelihood:: If the input argument is a string, then it has to be equal to:')
        disp('                   ''posterior mode'', ')
        disp('                   ''posterior mean'', ')
        disp('                   ''posterior median'', ')
        disp('                   ''prior mode'' or')
        disp('                   ''prior mean''.')
        error
    end
end

if isempty(dataset)
    % Load and transform data.
    transformation = [];
    if options_.loglinear && ~options_.logdata
        transformation = @log;
    end
    xls.sheet = options_.xls_sheet;
    xls.range = options_.xls_range;

    if ~isfield(options_,'nobs')
        options_.nobs = [];
    end

    dataset = initialize_dataset(options_.datafile,options_.varobs,options_.first_obs,options_.nobs,transformation,options_.prefilter,xls);
end

llik = -dsge_likelihood(parameters,dataset,options_,M_,estim_params_,bayestopt_,oo_);
ldens = evaluate_prior(parameters);
llik = llik - ldens;

