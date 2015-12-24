function stocks = retrieveStockHistory(start_date, end_date, varargin);

stocks = hist_stock_data(start_date, end_date, cell2mat(varargin));
for i = 1:length(stocks)
    stocks(i).Date = flipud(stocks(i).Date);
    stocks(i).Open = flipud(stocks(i).Open);
    stocks(i).High = flipud(stocks(i).High);
    stocks(i).Low = flipud(stocks(i).Low);
    stocks(i).Close = flipud(stocks(i).Close);
    stocks(i).Volume = flipud(stocks(i).Volume);
    stocks(i).AdjClose = flipud(stocks(i).AdjClose);
end
