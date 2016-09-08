function value = subsref(s,subscript)

% Subsref for al_spk Objects
%
% function value= subsref(s,subscript)
%
% MAG 20.12.2000

error('No access to object field, use spk_get(s) !');

% for i = 1:length(subscript)
%    switch subscript(i).type
%       
%    case '.'
%       Evaluation = strcat(Evaluation,'.',subscript(i).subs);
%       
%    case '()'
%       numericString = '(';
%       for k = 1:length(subscript(i).subs)
%          if ischar(subscript(i).subs{k}) & strcmp(subscript(i).subs{k},':')
%             numericString = strcat(numericString,subscript(i).subs{k});
%          else
%             numericString = strcat(numericString,'[',num2str(subscript(i).subs{k}),']');
%          end
%          if k < length(subscript(i).subs)
%             numericString = strcat(numericString,',');
%          end
%       end
%       numericString = strcat(numericString,')');
%       Evaluation = strcat(Evaluation,numericString);
%       
%    case '{}'
%       cellString = '{';
%       for k = 1:length(subscript(i).subs)
%          if k == length(subscript(i).subs)
%             cellString = strcat(cellString,'[',num2str(subscript(i).subs{k}),']');
%          else
%             cellString = strcat(cellString,'[',num2str(subscript(i).subs{k}),']',',');
%          end
%       end
%       cellString = strcat(cellString,'}');
%       Evaluation = strcat(Evaluation,cellString);
%       
%    end
% end
% 
% eval(['value = ' Evaluation ';']);
