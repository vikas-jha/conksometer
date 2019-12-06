require 'cairo'

function conky_init()
	ncpu = tonumber(io.popen("nproc"):read())
	seconds = 0
	last_update = 0
	cpu = {}
	duration = 180
	freq = 0
	ram = {}
	for i = 1, duration do
		ram[i] = -1
		cpu[i] = -1
	end
end

function conky_main()
	if conky_window == nil then
        return
    end
    local cs = cairo_xlib_surface_create (conky_window.display,
                                         conky_window.drawable,
                                         conky_window.visual,
                                         conky_window.width,
                                         conky_window.height)
    cr = cairo_create (cs)
    
    font = "Ubuntu"
	font_size = 14
	xpos, ypos = conky_window.width/2, conky_window.height/2
	red, green, blue, alpha = 1, 1, 1, 1
	font_slant = CAIRO_FONT_SLANT_NORMAL
	font_face = CAIRO_FONT_WEIGHT_BOLD
	
	cairo_select_font_face (cr, font, font_slant, font_face)
	cairo_set_font_size (cr, font_size)
	
	--render_clock(cr, xpos , ypos - 18, 45)
	local date = os.date("*t")
	seconds = date.sec
	
	render_frequency(cr, xpos, ypos, 85)
	render_cpu(cr, xpos, ypos, 90)
	render_memory(cr, xpos, ypos, 99)
	
	last_update = seconds
	
    cairo_destroy (cr)                                     
    cairo_surface_destroy (cs)
end

function render_cpu(cr, x, y, r)
	
	local _cpu = math.floor((tonumber(conky_parse ('$cpu'))*99 + cpu[1])/100 + 0.5)
	
	if seconds ~= last_update then
		table.insert(cpu,1,_cpu)
		table.remove(cpu)
	end
	
	local theta = 3*math.pi/2 * _cpu/100 - 5*math.pi/4
	
	cairo_set_line_width (cr, 1)
	cairo_set_source_rgba (cr, 0.3, 1, 0, 0.4)
	cairo_rectangle (cr, x  - 290, y - 25, 180, 50)
	cairo_move_to (cr, x - 290, y - 0)
	cairo_line_to(cr, x - 110 , y - 0)
	cairo_stroke (cr)
	
	cairo_set_line_width (cr, 1)
	cairo_set_source_rgba (cr, 0.3, 1, 0, 1)
	cairo_move_to (cr, x - 111, y - cpu[1]/2 + 25)
	for i=2, 180 do 
		if cpu[i] > 0 then
			cairo_line_to (cr, x - 110 - i , y - cpu[i]/2 +25)
		end
	end
	cairo_move_to (cr, x - 290, y - 30)
	cairo_show_text (cr, 'CPU: ' .. freq .. 'GHz, ' .. cpu[1] .. '% ' )
	cairo_stroke (cr)
	
	cairo_set_line_width (cr, 6)
	cairo_set_source_rgba (cr, 1, 1, 1, 1)
	cairo_arc (cr, x, y, r, -5*math.pi/4 , math.pi/4)
	cairo_stroke (cr)
	
	cairo_set_line_width (cr, 4)
	for i = 0,10 do
		local beta = -5*math.pi/4 + (math.pi/4 + 5*math.pi/4) * i / 10
		cairo_move_to (cr, x + r* math.cos(beta) * 0.73 - 10, y + r* math.sin(beta) * 0.75 + 5)
		cairo_show_text(cr, i * 10)
      	cairo_move_to (cr, x + r* math.cos(beta) * 0.87, y + r* math.sin(beta) * 0.87)
		cairo_line_to (cr, x + r* math.cos(beta) * 1.03, y + r* math.sin(beta) * 1.03)
    end
	cairo_stroke (cr)
	
	cairo_set_source_rgba (cr, 0, 1, 0, 0.8)
	cairo_move_to (cr, x, y)
	cairo_arc (cr, x, y, 10, 0 , 2 * math.pi)
	cairo_fill (cr)
	
	cairo_set_line_width (cr, 4)
	cairo_set_source_rgba (cr, 0, 1, 0, 1)
	cairo_set_line_cap (cr, CAIRO_LINE_CAP_ROUND)
	cairo_move_to (cr, x + r* math.cos(theta) * -0.2, y + r* math.sin(theta) * -0.2)
	cairo_line_to (cr, x + r* math.cos(theta) * 1, y + r* math.sin(theta) * 1)
	cairo_stroke (cr)
	
	cairo_set_line_cap (cr, CAIRO_LINE_CAP_BUTT)
end

function render_frequency(cr, x, y, r)
	
	local _freq = 0
	for i = 1, ncpu do 
		_freq = _freq + tonumber(conky_parse ('${freq_g ' .. i .. ' }'))
	end
	_freq = math.floor(10 * _freq / ncpu + 0.5)/10
	freq = math.floor(freq * 9 + _freq) / 10
	
	theta = 3*math.pi/4 - math.pi/2 * freq/5 + 0.007
	
	cairo_set_line_cap (cr, CAIRO_LINE_CAP_BUTT)
	cairo_set_line_width (cr, 4)
	cairo_set_source_rgba (cr, 1, 1, 1, 1)
	cairo_arc_negative (cr, x, y, r, 3*math.pi/4 - 0.1, math.pi/4 + 0.1)
	cairo_stroke (cr)
	
	cairo_set_line_width (cr, 4)
	for i = 0,5 do
		local beta = 3*math.pi/4 - 0.12 - (-math.pi/4 + 3*math.pi/4 - 0.24) * i / 5
      	cairo_move_to (cr, x + r* math.cos(beta) * 0.98, y + r* math.sin(beta) * 0.98)
		cairo_line_to (cr, x + r* math.cos(beta) * 1.1, y + r* math.sin(beta) * 1.1)
    end
	cairo_stroke (cr)
	
	cairo_set_line_width (cr, 4)
	cairo_set_source_rgba (cr, 1, 0.6, 0, 1)
	cairo_set_line_cap (cr, CAIRO_LINE_CAP_ROUND)
	cairo_move_to (cr, x + r* math.cos(theta) * 0.95, y + r* math.sin(theta) * 0.95)
	cairo_line_to (cr, x + r* math.cos(theta) * 1.15, y + r* math.sin(theta) * 1.15)
	cairo_stroke (cr)
	
	cairo_set_line_cap (cr, CAIRO_LINE_CAP_BUTT)
end

function render_memory(cr, x, y, r)
	
	local max_memory = string.sub(conky_parse ('${memmax}'),0,3) .. ' GiB'
	local mem = string.sub(conky_parse ('${mem}'), 0, 3) 
	if seconds ~= last_update then
		local memory = tonumber(conky_parse ('${memperc}'))
		table.insert(ram,1,memory)
		table.remove(ram)
	end
	
	local theta = 3*math.pi/2 * ram[1]/100 - 5*math.pi/4
	
	cairo_set_line_width (cr, 1)
	cairo_set_source_rgba (cr, 1, 0.5, 0, 0.3)
	cairo_rectangle (cr, x + 290 - 180, y - 25, 180, 50)
	cairo_move_to (cr, x + 290 - 180, y - 0)
	cairo_line_to(cr, x + 290, y - 0)
	cairo_stroke (cr)
	
	cairo_set_line_width (cr, 2)
	cairo_set_source_rgba (cr, 1, 0.5, 0, 1)
	cairo_move_to (cr, x + 110, y - 30)
	cairo_show_text (cr, 'Memory: ' .. ram[1] .. '%, ' .. mem .. '/' .. max_memory)
	cairo_move_to (cr, x + 290 - 1, y - ram[1]/2 + 25)
	for i=2, 180 do 
		if ram[i] > 0 then
			cairo_line_to (cr, x - i + 290, y - ram[i]/2 + 25)
		end
	end
	cairo_stroke (cr)
	
	cairo_set_line_width (cr, 6)
	cairo_set_source_rgba (cr, 1, 1, 1, 1)
	cairo_arc (cr, x, y, r, -5*math.pi/4 - 0.03 , math.pi/4 + 0.02)
	cairo_stroke (cr)
	
	cairo_set_line_width (cr, 4)
	cairo_set_source_rgba (cr, 1, 0.5, 0, 1)
	cairo_arc (cr, x, y, r, - 5*math.pi/4 - 0.02 , theta)
	cairo_stroke (cr)
	
	cairo_set_line_cap (cr, CAIRO_LINE_CAP_BUTT)

end

function render_clock(cr, x, y, r)
	local date_string =  (conky_parse ('${time %H:%M:%S}'))
 
    cairo_set_source_rgba (cr, 1, 1, 1, 1)
	cairo_move_to (cr, x-32, y + 5)
	cairo_show_text (cr, date_string)
	cairo_set_line_width (cr, 8)
	cairo_move_to (cr, x, y - r - 3)
	cairo_set_source_rgba (cr, 1, 1, 1, 0.5)
	cairo_arc (cr, x, y, r , -math.pi/2 , 3 * math.pi/2)
	cairo_stroke (cr)
	cairo_set_source_rgba (cr, 1, 1, 1, alpha)
	cairo_stroke (cr)
	cairo_set_line_width (cr, 8)
	cairo_arc (cr, x, y, r, -math.pi/2 , 2 * math.pi * seconds/60 - math.pi/2)
	cairo_stroke (cr)
end
