function [stocks] = retrieveStockHistory(start_date, end_date, varargin);

stocks = hist_stock_data(start_date, end_date, cell2mat(varargin));
for i = 1:length(stocks)
    stocks(i).Date = (stocks(i).Date);
    stocks(i).Open = (stocks(i).Open);
    stocks(i).High = (stocks(i).High);
    stocks(i).Low = (stocks(i).Low);
    stocks(i).Close = (stocks(i).Close);
    stocks(i).Volume = (stocks(i).Volume);
    stocks(i).AdjClose = (stocks(i).AdjClose);
end
