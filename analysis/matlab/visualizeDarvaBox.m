function visualizeDarvasBox(stock,box)

dt = datenum(stock.Date);
plot(dt,stock.Close);hold on;plot(dt,stock.Low);title(stock.Ticker)
set(gca,'XTick',dt);
datetick('x', 'mmm yyyy')
for i = 1:length(box)
    d = box(i).high-box(i).low;
    w = box(i).exitDate-box(i).enterDate;
    if(~or(isempty(d),isempty(w)))
        rectangle('Position',[box(i).enterDate box(i).low w d]);
    end
end