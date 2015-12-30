function output_txt = cursorUpdate(~,event_obj)

pos = get(event_obj,'Position');
output_txt = {[datestr(pos(1))],[pos(2)]};