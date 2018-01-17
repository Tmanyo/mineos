current_tasks = ""
active_task = ""

local tasks = {
	name = {}
}

function register_task(name)
	table.insert(tasks.name, name)
end

function remember_notes(fields)
	for k,v in pairs(tasks.name) do
		if v:match("notepad") then
			if fields.notes ~= nil then
				text = fields.notes
			end
		end
	end
end

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
			task_number = k
		end
	end
	if fs == 1 and #tasks.name > 2 then
		task_number = task_number - 1
	end
	local positions = {"1.5","2.25","3","3.75"}
	task_location = positions[task_number]
	_G[name .. "_task"] = "image_button[" .. task_location ..
	",8.25;.75,.75;" .. name .. ".png;" .. name .. "_task;" ..
	";true;false;]"
	task_icon = _G[name .. "_task"]
	return task_icon
end

function change_tasks(program)
	if #tasks.name > 1 then
		for k,v in pairs(tasks.name) do
			if v ~= program then
				_G[v .. "_status"] = "minimized"
			end
		end
	end
end

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
				current_tasks = _G[v .. "_task"]
			else
				if #remaining == 1 then
					current_tasks = ""
				end
			end
			remaining = {}
		end
	else
		current_tasks = ""
	end
end
