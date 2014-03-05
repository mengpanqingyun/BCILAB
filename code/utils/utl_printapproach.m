function string = utl_printapproach(app,strip_direct,indent,indent_incr)
% Convert an approach to a string representation
% String = utl_printapproach(Approach)
%
% In:
%   Approach : a BCI approach, either designed in the GUI or constructed in a script
%   
%   StripDirect : strip arg_direct flags (default: true)
%
%   Indent : initial indent (default: 0)
%
%   IndentIncrement : indentation increment (default: 4)
%
% Out:
%   String : a string representation of the approach, for use in scripts
%
%                                Christian Kothe, Swartz Center for Computational Neuroscience, UCSD
%                                2013-10-22

% check inputs
if nargin < 2
    strip_direct = true; end
if nargin < 3
    indent = 0; end
if nargin < 4
    indent_incr = 4; end
if ~isa(strip_direct,'logical')
    error('The StripDirect argument must be a logical/boolean value.'); end

% get required approach properties
if ischar(app)
    paradigm = ['Paradigm' app];
    parameters = {};
elseif iscell(app)
    paradigm = ['Paradigm' app{1}];
    parameters = app(2:end);
elseif all(isfield(app,{'paradigm','parameters'}))
    paradigm = app.paradigm;
    parameters = app.parameters;
else
    error('The given data structure is not an approach.');
end

% get a handle to the paradigm's calibrate() function
try
    instance = eval(paradigm);
catch e
    if ~exist(char(paradigm),'file')
        error('A BCI paradigm with name %s does not exist.',char(paradigm));
    else
        error('Failed to instantiate the paradigm named %s with error: %s; this is likely an error in the Paradigm''s code.',char(paradigm),e.message);
    end
end
func = @instance.calibrate;

% report both the defaults of the paradigm and 
% the current settings in form of argument specifications
defaults = clean_fields(arg_report('rich',func));
settings = clean_fields(arg_report('lean',func,parameters));

% get the difference as cell array of human-readable name-value pairs
specdiff = arg_diff(defaults,settings);
difference = arg_tovals(specdiff,[],'HumanReadableCell',false);

% pre-pend the paradigm choice 
paradigm_name = char(paradigm);
difference = [{'arg_selection',paradigm_name(9:end)} difference];

% and convert to string
string = arg_tostring(difference,strip_direct,indent,indent_incr);


% clean fields of x, by removing all arg_direct instances and 
% all skippable fields
function x = clean_fields(x)
x(strcmp({x.first_name},'arg_direct') | [x.skippable]) = [];
try
    children = {x.children};
    empty_children = cellfun('isempty',children);
    [x(~empty_children).children] = celldeal(cellfun(@clean_fields,children(~empty_children),'UniformOutput',false));    
catch %#ok<CTCH>
end