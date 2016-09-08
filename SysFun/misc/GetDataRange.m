function [DataMin,DataMax] = GetDataRange(H,varargin)

% gets the data range in a number of axes
% [DataMin,DataMax] = GetDataRange(H,varargin)
%
% 'XRange','YRange','ZRange','CRange' followed by two element vector
% defines the range of data that will be included in the range.
% varargin ... properties of the axes children (e.g. 'tag','dataline'),
%              whose data are used.

%% get windows 
Range = ones(4,2).*NaN;
for i=1:4
    idx = find(cellfun('isclass',varargin,'char'));
    switch i
        case 1;Rangei = ismember(varargin(idx),'XRange');
        case 2;Rangei = ismember(varargin(idx),'YRange');
        case 3;Rangei = ismember(varargin(idx),'ZRange');
        case 4;Rangei = ismember(varargin(idx),'CRange');
    end
    if any(Rangei)
        Range(i,:) = varargin{idx(Rangei)+1};
        varargin([idx(Rangei) idx(Rangei)+1]) = [];
    end
end


%% get range of data
H = H(:);
nH = length(H);
DataMin = zeros(nH,4).*NaN;
DataMax = zeros(nH,4).*NaN;
for i = 1:nH
%     currKids = get(H(i),'children');
	currKids = findobj('parent',H(i),varargin{:});
    VeryFirstPerAxes = 1;
    for k = 1:length(currKids)
        if ismember(upper(get(currKids(k),'type')),{'LIGHT','TEXT'})
            continue;
        end

        Data = []; 
        for iDim = 1:4
            switch iDim
                case 1;DataType = 'xdata';
                case 2;DataType = 'ydata';
                case 3;DataType = 'zdata';
                case 4;DataType = 'cdata';
            end
            try
                dd = get(currKids(k),DataType);
                Data(:,iDim) = dd(:);
            catch
                Data(:,iDim) = NaN;
            end
        end
            
        if isempty(Data);continue;end
        
        DataIndex = true(size(Data,1),1);
        for iDim = 1:4
            if ~all(isnan(Range(iDim,:)))
                DataIndex([Data(:,iDim)<Range(iDim,1) | Data(:,iDim)>Range(iDim,2)],iDim) = false;
            end
        end
        
        if VeryFirstPerAxes
            DataMin(i,:) = min(Data(DataIndex,:),[],1);
            DataMax(i,:) = max(Data(DataIndex,:),[],1);
            VeryFirstPerAxes = 0;
        else
            DataMin(i,:) = min([DataMin(i,:);Data(DataIndex,:)],[],1);
            DataMax(i,:) = max([DataMax(i,:);Data(DataIndex,:)],[],1);
        end
    end
            
end

