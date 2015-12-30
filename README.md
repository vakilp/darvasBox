# darvasBox
Experiments with Darvas Box Theory for Stock markets

The way to use the commands here is as follows (on MATLAB/OCTAVE prompt):

>s = retrieveStockHistory('01012015','12292015','GOOG'); %retrieve historical price information from finance.yahoo from Jan 1 2015 to 12/29/2015
>b = findDarvasBox(s(1),2); %Look for details below on how the box is constructed
>visualizeDarvasBox(s,b); %Provides a visual on where the boxes are located in the data pulled. Also prints the stop loss that the stock should be set to based on the lateset existing box.
