function [DataMin,DataMax] = GetDataRange(H,varargin)
% [DataMin,DataMax] = GetDataRange(H,varargin)
H = H(:);
nH = length(H);
DataMin = zeros(nH,3).*NaN;
DataMax = zeros(nH,3).*NaN;
for i = 1:nH
%     currKids = get(H(i),'children');
	currKids = findobj('parent',H(i),varargin{:});
    VeryFirstPerAxes = 1;
    for k = 1:length(currKids)
        if ismember(upper(get(currKids(k),'type')),{'LIGHT','TEXT'})
            continue;
        end
        X = get(currKids(k),'xdata');
        Y = get(currKids(k),'ydata');
		try;Z = get(currKids(k),'zdata');
		catch;Z = [];end
		try;C = get(currKids(k),'cdata');
		catch;C = [];end
        if VeryFirstPerAxes
            DataMin(i,1) = min(X(:));
            DataMin(i,2) = min(Y(:));
            DataMax(i,1) = max(X(:));
            DataMax(i,2) = max(Y(:));
            if ~isempty(Z)
                DataMin(i,3) = min(Z(:));
                DataMax(i,3) = max(Z(:));
            end
            if ~isempty(C)
                DataMin(i,4) = min(C(:));
                DataMax(i,4) = max(C(:));
            end
            VeryFirstPerAxes = 0;
        else
            DataMin(i,1) = min([DataMin(i,1);X(:)]);
            DataMin(i,2) = min([DataMin(i,2);Y(:)]);
            DataMax(i,1) = max([DataMax(i,1);X(:)]);
            DataMax(i,2) = max([DataMax(i,2);Y(:)]);
            if ~isempty(Z)
                DataMin(i,3) = min([DataMin(i,3);Z(:)]);
                DataMax(i,3) = max([DataMax(i,3);Z(:)]);
            end
            if ~isempty(C)
                DataMin(i,4) = min([DataMin(i,4);C(:)]);
                DataMax(i,4) = max([DataMax(i,4);C(:)]);
            end
        end
    end
            
end

