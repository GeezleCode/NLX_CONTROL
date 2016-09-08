function spk_htmldoc(s,helpdir)

% creates the html documentation by use of m2html.m

old_CD = cd;

TargetDir = fileparts(which('al_spk'));

if nargin<2
    % make the directory one up the current directory
    [TargetDir,CurrDir] = strtok(fliplr(TargetDir),'\');
    TargetDir = fliplr(TargetDir);
    CurrDir = fliplr(CurrDir);
    cd(CurrDir);
    
    helpdir = fullfile(TargetDir,'htmldoc');
end
    

if exist(helpdir)
    button = questdlg(['Do you really want to remove ...' helpdir]);
    if strcmpi(button,'Yes') 
        rmdir(helpdir,'s');
    end
end

m2html( ...
	'mfiles',TargetDir, ...
	'htmldir',helpdir, ...
	'recursive','off', ...
	'source','on', ...
	'global','on');

cd(old_CD);

%    o mFiles - Cell array of strings or character array containing the
%       list of M-files and/or directories of M-files for which an HTML
%       documentation will be built [ '.' ]
%    o htmlDir - Top level directory for generated HTML files [ '.' ]
%    o recursive - Process subdirectories [ on | {off} ]
%    o source - Include Matlab source code in the HTML documentation
%                               [ {on} | off ]
%    o syntaxHighlighting - Syntax Highlighting [ {on} | off ]
%    o tabs - Replace '\t' (horizontal tab) in source code by n white space
%        characters [ 0 ... {4} ... n ]
%    o globalHypertextLinks - Hypertext links among separate Matlab 
%        directories [ on | {off} ]
%    o todo - Create a TODO file in each directory summarizing all the
%        '% TODO %' lines found in Matlab code [ on | {off}]
%    o graph - Compute a dependency graph using GraphViz [ on | {off}]
%        'dot' required, see <http://www.research.att.com/sw/tools/graphviz/>
%    o indexFile - Basename of the HTML index file [ 'index' ]
%    o extension - Extension of generated HTML files [ '.html' ]
%    o template - HTML template name to use [ 'blue' ]
%    o save - Save current state after M-files parsing in 'm2html.mat' 
%        in directory htmlDir [ on | {off}]
%    o load - Load a previously saved '.mat' M2HTML state to generate HTML 
%        files once again with possibly other options [ <none> ]
%    o verbose - Verbose mode [ {on} | off ]
