function stocks = hist_stock_data(start_date, end_date, varargin)
% HIST_STOCK_DATA     Obtain historical stock data
%   hist_stock_data(X,Y,'Ticker1','Ticker2',...) retrieves historical stock
%   data for the ticker symbols Ticker1, Ticker2, etc... between the dates
%   specified by X and Y.  X and Y can either be strings in the format
%   ddmmyyyy or Matlab datenums, where X is the beginning date and Y is the
%   ending date.  The program returns the stock data in a structure giving
%   the Date, Open, High, Low, Close, Volume, and Adjusted Close price
%   adjusted for dividends and splits.
%
%   hist_stock_data(X,Y,'tickers.txt') retrieves historical stock data
%   using the ticker symbols found in the user-defined text file.  Ticker
%   symbols must be separated by line feeds.
%
%   hist_stock_data(X,Y,{'Ticker1' 'Ticker2'}) combined the ticker symbols
%   into a single cell array when calling hist_stock_data (sometimes easier
%   for calling the funtion with a cell array of ticker symbols).
%
%   hist_stock_data(X,Y,'Ticker1','frequency',FREQ) retrieves historical
%   stock data using the frequency specified by FREQ, which must be either
%   'd' for daily, 'wk' for weekly, or 'mo' for monthly.
%
%   hist_stock_data(X,Y,'Ticker1','type','div') retrieves dividend data. If
%   anything but 'div' is specified then it will default to retrieving
%   historical prices.
%
%   EXAMPLES
%       stocks = hist_stock_data('23012003','15042008','GOOG','C');
%           Returns the structure array 'stocks' that holds historical
%           stock data for Google and CitiBank for dates from January
%           23, 2003 to April 15, 2008.
%
%       stocks = hist_stock_data('12101997','18092001','tickers.txt');
%           Returns the structure arrary 'stocks' which holds historical
%           stock data for the ticker symbols listed in the text file
%           'tickers.txt' for dates from October 12, 1997 to September 18,
%           2001.  The text file must be a column of ticker symbols
%           separated by new lines.
%
%       stocks = hist_stock_data(now-10, now, {'GOOG' 'C'});
%           Get stock data for approximately the last 10 days for the two
%           tickers specified in the cell array.
%
%       stocks = hist_stock_data('12101997','18092001','C','frequency','w')
%           Returns historical stock data for Citibank using the date range
%           specified with a frequency of weeks.  Possible values for
%           frequency are d (daily), wk (weekly), or mo (monthly).  If not
%           specified, the default frequency is daily.
%
%       stocks = hist_stock_data('12101997','18092001','C','type','div')
%            Returned historical dividend data for Citibank between Oct 12,
%            1997 and September 18, 2001.
%
%   DATA STRUCTURE
%       INPUT           DATA STRUCTURE      FORMAT
%       X (start date)  ddmmyyyy            String
%       Y (end date)    ddmmyyyy            String
%       Ticker          NA                  String 
%       ticker.txt      NA                  Text file
%       FREQ            NA                  String; 'd', 'wk', or 'mo'
%       TYPE            NA                  String; 'div'
%
%   OUTPUT FORMAT
%       All data is output in the structure 'stocks'.  Each structure
%       element will contain the ticker name, then vectors consisting of
%       the organized data sorted by date, followed by the Open, High, Low,
%       Close, Volume, then Adjusted Close prices.
%
%   DATA FEED
%       The historical stock data is obtained using Yahoo! Finance website.
%       By using Yahoo! Finance, you agree not to redistribute the
%       information found therein.  Therefore, this program is for personal
%       use only, and any information that you obtain may not be
%       redistributed.
%
%   NOTE
%       This program uses the Matlab command urlread in a very basic form.
%       If the program gives you an error and does not retrieve the stock
%       information, it is most likely because there is a problem with the
%       urlread command.  You may have to tweak the code to let the program
%       connect to the internet and retrieve the data.

% Created by Josiah Renfree
% January 25, 2008

stocks = struct([]);        % initialize data structure

%% Parse inputs

% Format start and end dates into Posix times. This is the number of
% seconds since Jan 1, 1970. This previously used the posixtime function,
% but since that is relatively new, it now does the calculation using
% Matlab datenum's, which are in units of days, then converting to seconds.
origDate = datenum('01-Jan-1970 00:00:00', 'dd-mmm-yyyy HH:MM:SS');

% Convert input dates to Matlab datenums, if necessary
if ischar(start_date)
    startDate = (datenum(start_date, 'ddmmyyyy') - origDate) * 24 * 60 * 60;
else
    startDate = (floor(start_date) - origDate) * 24 * 60 * 60;
end
if ischar(end_date)
    endDate = (datenum(end_date, 'ddmmyyyy') - origDate) * 24 * 60 * 60;
else
    endDate = (floor(end_date) - origDate) * 24 * 60 * 60;
end

% determine if user specified frequency
temp = find(strcmp(varargin,'frequency') == 1); % search for frequency
if isempty(temp)                            % if not given
    freq = 'd';                             % default is daily
else                                        % if user supplies frequency
    freq = varargin{temp+1};                % assign to user input
    varargin(temp:temp+1) = [];             % remove from varargin
end
clear temp

% determine if user specified event type
temp = find(strcmp(varargin,'type') == 1); % search for frequency
if isempty(temp)                            % if not given
    event = 'history';                      % default is historical prices
else                                        % if user supplies frequency
    event = varargin{temp+1};               % assign to user input
    varargin(temp:temp+1) = [];             % remove from varargin
end
clear temp

% If the first cell of varargin is itself a cell array, assume it is a cell
% array of ticker symbols
if iscell(varargin{1})
    tickers = varargin{1};

% Otherwise, check to see if it's a .txt file
elseif ~isempty(strfind(varargin{1},'.txt'))
    fid = fopen(varargin{1}, 'r');
    tickers = textscan(fid, '%s'); tickers = tickers{:};
    fclose(fid);
    
% Otherwise, assume it's either a single ticker or a list of tickers
else
    tickers = varargin;
end

%% Get historical data

h = waitbar(0, 'Please Wait...');           % create waitbar
idx = 1;                                    % idx for current stock data

% Cycle through each ticker symbol and retrieve historical data
for i = 1:length(tickers)
    
    % Update waitbar to display current ticker
    waitbar((i-1)/length(tickers), h, ...
        sprintf('Retrieving stock data for %s (%0.2f%%)', ...
        tickers{i}, (i-1)*100/length(tickers)))
    
    % Create url string for retrieving data
    url = sprintf(['https://query1.finance.yahoo.com/v7/finance/download/', ...
        '%s?period1=%d&period2=%d&interval=1%s&events=%s'], ...
        tickers{i}, startDate, endDate, freq, event);
    
    % Call data from Yahoo Finance
    [temp, status] = urlread(url,'post',{'matlabstockdata@yahoo.com', 'historical stocks'});
        
    % If data was downloaded successfully, then proceed to process it.
    % Otherwise, ignore this ticker symbol
    if status
        
        % Put data into appropriate variables
        if strcmp(event, 'history')     % If historical prices
            
            % Parse out the historical data
            data = textscan(temp, '%s%f%f%f%f%f%f', 'delimiter', ',', ...
                'Headerlines', 1);

            [stocks(idx).Date, stocks(idx).Open, stocks(idx).High, ...
                stocks(idx).Low, stocks(idx).Close, ...
                stocks(idx).AdjClose, stocks(idx).Volume] = deal(data{:});
            
        % If dividends
        else
            
            % Parse out the dividend data
            data = textscan(temp, '%s%f', 'delimiter', ',', ...
                'Headerlines', 1);
            
            [stocks(idx).Date, stocks(idx).Dividend] = deal(data{:});
        end

        stocks(idx).Ticker = tickers{i};	% Store ticker symbol
        
        idx = idx + 1;                      % Increment stock index
    end
        
    % update waitbar
    waitbar(i/length(tickers),h)
end
close(h)    % close waitbar