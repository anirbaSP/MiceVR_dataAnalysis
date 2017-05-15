function data = read_actions_file(filename, fieldNames)
% This function reads data from _actions.txt file generated by mouseVR.
% Where
%   filename is a string of the *_actions.txt file name with full pathname.
% Actions file is a ASCII file with column headers.
%   filedNames is optional. They matches to the headers in the actions
%  files. If not provided, this function will return all available fields (
% column headers) in the input file.
%
% OUT
%   data is a structure array of retreived data, with selected or all
%   avialable fields.

% copyright Sabrina Pei Xu (2017)

if exist(filename, 'file')
    data = struct;
    testSize = dir(filename);
    if testSize.bytes
        u = importdata(filename);
        % check if headers exist
        if isempty(u.textdata)
            error('/n Action files has no header info /n')
        end
        
        headers =  u.textdata(1,:);
        n_headers = length(headers);
        
        % deal textdata and numeric data seperation. Try to find the column
        % index of the numeric data in the textdata
        dataIdx = nan(1,n_headers);
        count = 0;
        for i = 1:n_headers
            tmp = cat(1,u.textdata{2:end,i});
            if isempty(tmp)
                count = count+1;
                dataIdx(i) = count;
            end
        end
        
        if nargin < 2
            fieldNames = headers;
        end
        n_fields = length(fieldNames);
        
        for i = 1:n_fields
            thisfield = fieldNames{i};
            idx = strcmp(thisfield, headers);
            % find the data as textdata first
            thisdata = cat(1, u.textdata{2:end, idx});
            if isempty(thisdata) % if empty, then find as numeric data
                thisdata = u.data(:,dataIdx(idx));
            end
            
            if strcmp(thisfield, 'TrialDur') 
                % convert the time duration from characters to a numerical 
                % value of seconds 
               [~,~,~,H,M,S] = datevec(thisdata);
               thisdata = H*3600+M*60+S;
            end
            
            while ~isvarname(thisfield) % in case some headers contain symbol
                % like (ul) which cannot be a structure fieldname. In this
                % case, we truncate the fieldname as necessary
                thisfield = thisfield(1:end-1);
            end
            
            data = setfield(data, thisfield, thisdata);
        end
    end
else error('/n File not exist! /n')
end