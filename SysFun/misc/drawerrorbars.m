function [whisker,tee] = drawerrorbars(x,y,l,u,teeoption,whiskerprop,teeprop)

% draw error whisker with tees
% all line objects got tags 'lwhisker', 'uwhisker', 'ltee','utee'
% function h = drawerrorbars(x,y,l,u,tee,whiskerprop,teeprop)
%
% INPUT
% x ............... x
% y ............... values
% l ............... distance to lower confidence border
% u ............... distance to upper confidence border
% tee ............. numeric       : length of tee in units of x axis 
%                   0             : no tee
%                   '-' 'marker'  : lower and upper errors are two line objects
% whiskerprop ..... cell array, lineproperties for the whiskers
% teeprop ......... cell array, lineproperties for the tees

[nX,nGrp] = size(x);

if nargin<7
     teeprop = {};
     if nargin<6
          whiskerprop = {};
     end;end

whisker = cell(2,nGrp);
tee = cell(2,nGrp);

for i = 1:nGrp

     % draw tee
     if ischar(teeoption) & strcmp(upper(teeoption),'PATCH')
          tee{1,i} = patch([x(:,i);flipud(x(:,i))],[[y(:,i)-l(:,i)];flipud([y(:,i)+u(:,i)])],'k');
          set(tee{1,i},whiskerprop{:});
      elseif ischar(teeoption) & strcmp(teeoption,'-')
          tee{2,i} = line(x(:,i)',[y(:,i)-l(:,i)]','marker','none','linestyle',teeoption,'tag','ltee',teeprop{:});
          tee{1,i} = line(x(:,i)',[y(:,i)+u(:,i)]','marker','none','linestyle',teeoption,'tag','utee',teeprop{:});
%      elseif ischar(teeoption) & ~strcmp(teeoption,'-')
%           tee{2,i} = line(x(:,i)',[y(:,i)-l(:,i)]','marker',teeoption,'linestyle','none','tag','ltee',teeprop{:});
%           tee{1,i} = line(x(:,i)',[y(:,i)+u(:,i)]','marker',teeoption,'linestyle','none','tag','utee',teeprop{:});
      elseif isnumeric(teeoption) 
          % draw whisker
		  if isempty(l), whisker{2,i} = NaN;
		  else whisker{2,i} = line([x(:,i) x(:,i)]',[y(:,i) y(:,i)-l(:,i)]','tag','lwhisker',whiskerprop{:});
		  end
		  if isempty(u), whisker{1,i} = NaN;
		  else whisker{1,i} = line([x(:,i) x(:,i)]',[y(:,i) y(:,i)+u(:,i)]','tag','uwhisker',whiskerprop{:});
		  end
		  if teeoption>0
			  tee{2,i} = line([x(:,i)-teeoption/2 x(:,i)+teeoption/2]',[y(:,i)-l(:,i) y(:,i)-l(:,i)]','tag','ltee','marker','none',teeprop{:});
			  tee{1,i} = line([x(:,i)-teeoption/2 x(:,i)+teeoption/2]',[y(:,i)+u(:,i) y(:,i)+u(:,i)]','tag','utee','marker','none',teeprop{:});
		  else
			  tee{2,i} = NaN;
			  tee{1,i} = NaN;
		  end
			
      else
          tee{2,i} = NaN;
          tee{1,i} = NaN;
      end
end
