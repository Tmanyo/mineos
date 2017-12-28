--[[
	Mineos Calculator Version 1
	Contributors:
		Code & Textures: Tmanyo
--]]

local equation = ""

function calculator(player)
	desktop(player, "calculator_bg",
	"image_button[8,1.55;.5,.3;;close_calculator;X;true;false;]" ..
	"image_button[7.7,1.45;.5,.5;;minimize_calc;--;true;false;]" ..
	"field[4.6,2;4,1;equation;;" .. minetest.formspec_escape(equation) ..
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
	"image_button[1.5,8.25;.75,.75;calculator.png;calculator_task;;true;" ..
	"false;]")
end

local status = {}

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mineos:desktop" then
		if fields.calculator then
			calculator(player)
		end
		if fields.close_calculator then
			desktop(player, "default", "")
		end
		if fields.minimize_calc then
			desktop(player, "default",
			"image_button[1.5,8.25;.75,.75;calculator.png;" ..
			"calculator_task;;true;false;]")
			status = "minimized"
		end
		if fields.calculator_task then
			if status == "minimized" then
				calculator(player)
				status = "maximized"
			else
				desktop(player, "default",
				"image_button[1.5,8.25;.75,.75;calculator" ..
				".png;calculator_task;;true;false;]")
				status = "minimized"
			end
		end
		if fields.one then
			equation = equation .. "1"
			calculator(player)
		end
		if fields.two then
			equation = equation .. "2"
			calculator(player)
		end
		if fields.three then
			equation = equation .. "3"
			calculator(player)
		end
		if fields.four then
			equation = equation .. "4"
			calculator(player)
		end
		if fields.five then
			equation = equation .. "5"
			calculator(player)
		end
		if fields.six then
			equation = equation .. "6"
			calculator(player)
		end
		if fields.seven then
			equation = equation .. "7"
			calculator(player)
		end
		if fields.eight then
			equation = equation .. "8"
			calculator(player)
		end
		if fields.nine then
			equation = equation .. "9"
			calculator(player)
		end
		if fields.zero then
			equation = equation .. "0"
			calculator(player)
		end
		if fields.plus then
			equation = equation .. "+"
			calculator(player)
		end
		if fields.minus then
			equation = equation .. "-"
			calculator(player)
		end
		if fields.multiply then
			equation = equation .. "*"
			calculator(player)
		end
		if fields.divide then
			equation = equation .. "/"
			calculator(player)
		end
		if fields.left_par then
			equation = equation .. "("
			calculator(player)
		end
		if fields.right_par then
			equation = equation .. ")"
			calculator(player)
		end
		if fields.per then
			equation = equation .. "."
			calculator(player)
		end
		if fields.clear then
			equation = ""
			calculator(player)
		end
		if fields.ans then
			if equation == "" then
				equation = fields.equation
			end
			local evaluation, err = loadstring("return " ..
			equation)
			if not evaluation then
				equation = "Error"
				calculator(player)
			else
				equation = evaluation()
				calculator(player)
			end
		end
	end
end)
