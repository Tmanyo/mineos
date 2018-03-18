--[[
	Mineos Calculator Version 1
	Contributors:
		Code & Textures: Tmanyo
--]]

local equation = {}

function calculator(player)
	if equation[player:get_player_name()] == nil then
		equation[player:get_player_name()] = "Error"
	end
	desktop(player, files.theme[player:get_player_name()] ..
	"^calculator_overlay.png",
	"image_button[7.9,1.49;.6,.4" .. get_button_style(player, "calculator",
	"white").close[player:get_player_name()] .. ";true;false;]" ..
	"image_button[7.5,1.46;.6,.45" .. get_button_style(player, "calculator",
	"white").min[player:get_player_name()] .. ";true;false;]" ..
	"field[4.6,2;4,1;equation;;" .. minetest.formspec_escape(equation[player:get_player_name()]) ..
	"]" ..
	"button[4.3,2.7;1,1;one;1]" ..
	"button[5.3,2.7;1,1;two;2]" ..
	"button[6.3,2.7;1,1;three;3]" ..
	"button[7.3,2.7;1,1;plus;+]" ..
	"button[4.3,3.5;1,1;four;4]" ..
	"button[5.3,3.5;1,1;five;5]" ..
	"button[6.3,3.5;1,1;six;6]" ..
	"button[7.3,3.5;1,1;minus;-]" ..
	"button[4.3,4.3;1,1;seven;7]" ..
	"button[5.3,4.3;1,1;eight;8]" ..
	"button[6.3,4.3;1,1;nine;9]" ..
	"button[7.3,4.3;1,1;multiply;x]" ..
	"button[4.3,5.1;1,1;left_par;(]" ..
	"button[5.3,5.1;1,1;zero;0]" ..
	"button[6.3,5.1;1,1;right_par;)]" ..
	"button[7.3,5.1;1,1;divide;/]" ..
	"button[5.3,5.9;1,1;per;.]" ..
	"button[6.3,5.9;1,1;ans;=]" ..
	"button[4.3,5.9;1,1;clear;C]" ..
	current_tasks[player:get_player_name()])
end

calculator_status = {}
calculator_task = {}

minetest.register_on_joinplayer(function(player)
	calculator_status[player:get_player_name()] = {}
	calculator_task[player:get_player_name()] = {}
	equation[player:get_player_name()] = ""
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mineos:desktop" then
		if fields.calculator then
			active_task[player:get_player_name()] = "calculator"
			calculator_status[player:get_player_name()] = "minimized"
			remember_notes(fields, player)
			if not current_tasks[player:get_player_name()]:match("calculator") then
				register_task("calculator", player)
				handle_tasks("calculator", player)
				current_tasks[player:get_player_name()] = current_tasks[player:get_player_name()] .. calculator_task[player:get_player_name()]
			end
			change_tasks("calculator", player)
			calculator(player)
		end
		if fields.close_calculator then
			equation[player:get_player_name()] = ""
			end_task("calculator", player)
			desktop(player, files.theme[player:get_player_name()],
			current_tasks[player:get_player_name()])
		end
		if fields.minimize_calculator then
			desktop(player, files.theme[player:get_player_name()],
			current_tasks[player:get_player_name()])
			calculator_status[player:get_player_name()] = "minimized"
		end
		if fields.calculator_task then
			active_task[player:get_player_name()] = "calculator"
			change_tasks("calculator", player)
			remember_notes(fields, player)
			if calculator_status[player:get_player_name()] == "minimized" then
				calculator(player)
				calculator_status[player:get_player_name()] = "maximized"
			else
				desktop(player, files.theme[player:get_player_name()],
				current_tasks[player:get_player_name()])
				calculator_status[player:get_player_name()] = "minimized"
			end
		end
		if fields.one then
			equation[player:get_player_name()] = equation[player:get_player_name()] .. "1"
			calculator(player)
		end
		if fields.two then
			equation[player:get_player_name()] = equation[player:get_player_name()] .. "2"
			calculator(player)
		end
		if fields.three then
			equation[player:get_player_name()] = equation[player:get_player_name()] .. "3"
			calculator(player)
		end
		if fields.four then
			equation[player:get_player_name()] = equation[player:get_player_name()] .. "4"
			calculator(player)
		end
		if fields.five then
			equation[player:get_player_name()] = equation[player:get_player_name()] .. "5"
			calculator(player)
		end
		if fields.six then
			equation[player:get_player_name()] = equation[player:get_player_name()] .. "6"
			calculator(player)
		end
		if fields.seven then
			equation[player:get_player_name()] = equation[player:get_player_name()] .. "7"
			calculator(player)
		end
		if fields.eight then
			equation[player:get_player_name()] = equation[player:get_player_name()] .. "8"
			calculator(player)
		end
		if fields.nine then
			equation[player:get_player_name()] = equation[player:get_player_name()] .. "9"
			calculator(player)
		end
		if fields.zero then
			equation[player:get_player_name()] = equation[player:get_player_name()] .. "0"
			calculator(player)
		end
		if fields.plus then
			equation[player:get_player_name()] = equation[player:get_player_name()] .. "+"
			calculator(player)
		end
		if fields.minus then
			equation[player:get_player_name()] = equation[player:get_player_name()] .. "-"
			calculator(player)
		end
		if fields.multiply then
			equation[player:get_player_name()] = equation[player:get_player_name()] .. "*"
			calculator(player)
		end
		if fields.divide then
			equation[player:get_player_name()] = equation[player:get_player_name()] .. "/"
			calculator(player)
		end
		if fields.left_par then
			equation[player:get_player_name()] = equation[player:get_player_name()] .. "("
			calculator(player)
		end
		if fields.right_par then
			equation[player:get_player_name()] = equation[player:get_player_name()] .. ")"
			calculator(player)
		end
		if fields.per then
			equation[player:get_player_name()] = equation[player:get_player_name()] .. "."
			calculator(player)
		end
		if fields.clear then
			equation[player:get_player_name()] = ""
			calculator(player)
		end
		if fields.ans then
			if equation[player:get_player_name()] == "" then
				equation[player:get_player_name()] = fields.equation
			end
			local evaluation, err = loadstring("return " ..
			equation[player:get_player_name()])
			if not evaluation then
				equation[player:get_player_name()] = "Error"
				calculator(player)
			else
				equation[player:get_player_name()] = evaluation()
				calculator(player)
			end
		end
	end
end)
