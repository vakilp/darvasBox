function Box = findDarvasBox(stock,maxDays)

close = (stock.Close);
low = (stock.Low);
dateval = datenum(stock.Date);
m = length(close);

val = close(1);
state = 1;
idx = 1;
index = 1;
for i = 2:m
    if state==1
        if close(i) <= val
            index = index+1;
            if index==maxDays
                Box(idx).enterDate = dateval(i-maxDays+1);
                Box(idx).enterIdx = i-maxDays+1;
                Box(idx).high = val;
                Box(idx).boxFormed = 0;
                val = min(low(i-maxDays+1:i));
%                 Box(idx).low = min(low(i-2:i));
                index = 1;
                state = 2;
            end
        else
            val = close(i);
            index = 1;
        end
    elseif state==2
        if low(i) >= val
            index = index+1;
            if index == maxDays
                Box(idx).low = val;
                Box(idx).boxFormed = 1;
                state = 3;
            end
        else
            val = low(i);
            index = 1;
        end
        if(close(i)>Box(idx).high)
            val = close(i);
            index = 1;
            state = 1;
        end
    elseif state==3
        if(or(close(i)>Box(idx).high,low(i)<Box(idx).low))
            state = 1;
            Box(idx).exitDate = dateval(i-1);
            Box(idx).exitIdx = i-1;
            idx = idx+1;
            val = close(i);
            index = 1;
        end
    end
end

boxFormed = [Box.boxFormed];
ii = find(boxFormed);
index = ii(end);
if ~isempty(index)
    if(isempty(Box(index).exitDate))
        end_date = dateval(end);
    else
        end_date = Box(index).exitDate;
    end
    idx = find(and(dateval>=Box(index).enterDate,dateval<=end_date));
    std_val = std(stock.Low(idx));
    stop_loss = Box(index).low-std_val;
end

val = sprintf('The Stop Loss for %s ought to be %f',stock.Ticker,stop_loss);
disp(val)
