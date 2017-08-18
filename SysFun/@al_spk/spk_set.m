function s = spk_set(s,varargin)

% set the fields of an @al_spk object
% function s = spk_set(s,varargin)

if rem(length(varargin),2)~= 0
     error('Arguments must be Property/Value pairs !');
end

numProp = length(varargin)./2;

for i = 1:numProp
     
     cprop = lower(varargin{i*2-1});
     cval = varargin{i*2};
     
     switch cprop
          case 'currenttrials'
               if size(cval,1)>1
                    cval = cval';
               end
     end
               
     
     eval(['s.' cprop ' =  cval;']);
     
end
