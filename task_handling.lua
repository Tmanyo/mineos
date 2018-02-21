--[[
	Mineos Task Handling Version 1
	Contributors:
		Code: Tmanyo
--]]

-----
-- Functions used to handle tasks on the task bar and window status'.
-----
current_tasks = ""
active_task = ""
tasks = {
	name = {}
}

-- Function used to register a task.
function register_task(name)
	table.insert(tasks.name, name)
end

-- Function used to change between apps and save notepad text.
function remember_notes(fields)
	for k,v in pairs(tasks.name) do
		if v:match("notepad") then
			if fields.notes ~= nil then
				text = fields.notes
			end
		end
	end
end

-- Function that decides app location on the task bar.
function handle_tasks(name)
	local task_number = {}
	local task_location = {}
	local task_icon = {}
	local fs = 0
	for k,v in pairs(tasks.name) do
		if v:match("file_system") then
			fs = 1
		end
		if v == name then
			if fs == 1 then
				task_number = (k - 1)
			else
				task_number = k
			end
		end
	end
	local positions = {"1.5","2.25","3","3.75","4.5","5.25","6"}
	if task_number > #positions then
		return false
	else
		task_location = positions[task_number]
		_G[name .. "_task"] = "image_button[" .. task_location ..
		",8.25;.75,.75;" .. name .. ".png;" .. name .. "_task;" ..
		";true;false;]"
		task_icon = _G[name .. "_task"]
	end
	return task_icon
end

-- Function that makes sure all apps that aren't being used are minimized.
function change_tasks(program)
	if #tasks.name > 1 then
		for k,v in pairs(tasks.name) do
			if v ~= program then
				_G[v .. "_status"] = "minimized"
			end
		end
	end
end

-- Function used to end a task properly so that it doesn't create other issues.
function end_task(name)
	local task_number = {}
	local remaining = {}
	for k,v in pairs(tasks.name) do
		if v == name then
			task_number = k
		else
			table.insert(remaining, v)
		end
	end
	table.remove(tasks.name, task_number)
	if #remaining >= 1 then
		for k,v in pairs(remaining) do
			if v ~= "file_system" then
				handle_tasks(v)
				if k == 1 then
					current_tasks = ""
				end
				current_tasks = current_tasks ..
				_G[v .. "_task"]
			else
				current_tasks = ""
			end
			remaining = {}
		end
	else
		active_task = ""
		current_tasks = ""
	end
end
