local mail_type = {}
local selected = {}
local item = {}
email_task = {}
email_status = {}

-- Create tables if not already present.
minetest.register_on_joinplayer(function(player)
	if not files.inbox[player:get_player_name()] then
		files.inbox[player:get_player_name()] = {}
	end
	if not files.sent[player:get_player_name()] then
		files.sent[player:get_player_name()] = {}
	end
	save_files()
end)

-- Get incoming email.
function inbox_items(player)
	local emails = ""
	local index,email
	for index,email in ipairs(files.inbox[player:get_player_name()]) do
		-- Mark emails as important.
		if minetest.serialize(files.important_emails[player:get_player_name()]):match(email.body:sub(1,30)) then
			emails = emails .. "#FFFF00From: " .. email.sender ..
			" -- Subject: " .. email.subject
			-- Mark emails as read.
		elseif minetest.serialize(files.read_emails[player:get_player_name()]):match(email.body:sub(1,30)) then
			emails = emails .. "From: " .. email.sender ..
			" -- Subject: " .. email.subject
			-- Mark unimportant and unread emails.
		else
			emails = emails .. "#FF0000From: " .. email.sender ..
			" -- Subject: " .. email.subject
		end
		if index ~= #files.inbox[player:get_player_name()] then
			emails = emails .. ","
		end
	end
	return emails
end

-- Get sent items.
function sent_items(player)
	local sent_mail = ""
	local index,sent
	for index,sent in ipairs(files.sent[player:get_player_name()]) do
		sent_mail = sent_mail .. "To: " .. sent.recipient ..
		" -- Subject: " .. sent.subject
		if index ~= #files.sent[player:get_player_name()] then
			sent_mail = sent_mail .. ","
		end
	end
	return sent_mail
end

function email(player, type)
	local word = {}
	if type == inbox_items(player) then
		word = "Inbox"
	else
		word = "Sent Mail"
	end
	desktop(player, "default_email",
	"image_button[9.35,1.5;.5,.3;;minimize_email;" ..
	minetest.colorize("#000000", "--") .. ";true;false;]" ..
	"image_button[9.7,1.53;.5,.3;;close_email;" ..
	minetest.colorize("#000000", "X") .. ";true;false;]" ..
	"image_button[2.7,2;1.5,.5;;compose;" ..
	minetest.colorize("#FF0000", "Compose") .. ";true;false;]" ..
	"image_button[2.55,2.7;1.5,.5;;inbox_mail;" ..
	minetest.colorize("#000000", "Inbox") .. ";true;false;]" ..
	"image_button[2.7,3;1.5,.5;;sent;" ..
	minetest.colorize("#000000", "Sent Mail") .. ";true;false;]" ..
	"textlist[4.5,2;5.25,4;inbox;" .. type .. "]" ..
	"box[2.8,2;1.5,4;black]" ..
	"label[2.9,4.4;" .. minetest.colorize("#000000", "Mark As:") .. "]" ..
	"checkbox[2.9,4.5;read;" ..
	minetest.colorize("#000000", "Read") .. ";false]" ..
	"checkbox[2.9,5;important;" ..
	minetest.colorize("#000000", "Important") .. ";false]" ..
	"label[6.7,6;" .. minetest.colorize("#000000", word) .. "]" ..
	"image_button[2.85,3.5;1,.5;;delete_mail;" ..
	minetest.colorize("#FF0000", "Delete") .. ";true;false;]" ..
	current_tasks)
end

function compose(player, replier)
	desktop(player, "default_email",
	"box[2.65,1.48;7.4,4.95;black]" ..
	"textarea[3.2,1.75;5,.5;recipient;" ..
	minetest.colorize("#000000", "Recipient") .. ";" ..
	minetest.formspec_escape(replier) .. "]" ..
	"textarea[3.2,2.5;5,.5;subject;" ..
	minetest.colorize("#000000", "Subject") .. ";" ..
	minetest.formspec_escape("") .. "]" ..
	"textarea[3.2,3.25;5,3;body;" ..
	minetest.colorize("#000000", "Body") .. ";" ..
	minetest.formspec_escape("") .. "]" ..
	"image_button[7.2,5.9;1,.5;;cancel;" ..
	minetest.colorize("#FF0000", "Cancel") .. ";true;false;]" ..
	"image_button[8,5.9;1,.5;;send;" ..
	minetest.colorize("#FF0000", "Send") .. ";true;false;]" ..
	current_tasks)
end

-- Show sender, subject, and body.
function read_mail(player, table, number, addon)
	local sender = {}
	local subject = {}
	local body = {}
	local extra = ""
	-- Get email specific information.
	local index,email
	for index,email in ipairs(table) do
		if index == number then
			if mail_type == "inbox" then
				sender = email.sender
			else
				sender = email.recipient
			end
			subject = email.subject
			body = email.body
		end
	end
	-- Check for inbox or sentbox.
	if mail_type == "inbox" then
		extra = "label[3.2,2;" .. minetest.colorize("#000000", "From: " ..
		sender) .. "]"
	else
		extra = "label[3.2,2;" .. minetest.colorize("#000000", "To: " ..
		sender) .. "]"
	end
	-- Refine body text.
	local email_body = wrap_text(body, 80):gsub("\n ", "\n"):gsub(",",
	minetest.formspec_escape(",")):gsub("\n", ",#000000")
	extra = extra .. addon
	-- Display formspec.
	desktop(player, "default_email",
	extra ..
	"label[3.2,2.5;" .. minetest.colorize("#000000", "Subject: " ..
	subject) .. "]" ..
	"textlist[3.2,3.25;6,2.5;body_text;#000000" .. email_body ..
	";;true]" ..
	"image_button[2.8,6;1,.5;;back;" .. minetest.colorize("#FF0000",
	"Back") .. ";true;false;]" ..
	"image_button[4,6;1,.5;;reply;" .. minetest.colorize("#FF0000",
	"Reply") .. ";true;false;]" ..
	"image_button[5.2,6;1,.5;;forward;" .. minetest.colorize("#FF0000",
	"Forward") .. ";true;false;]" ..
	current_tasks)
	return body
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mineos:desktop" then
		if fields.email then
			remember_notes(fields)
			if not current_tasks:match("email") then
				register_task("email")
				handle_tasks("email")
				current_tasks = current_tasks .. email_task
			end
			active_task = "email"
			email_status = "minimized"
			mail_type = "inbox"
			change_tasks("email")
			if not files.inbox[player:get_player_name()] then
				files.inbox[player:get_player_name()] = {}
			end
			email(player, inbox_items(player))
		end
		if fields.compose then
			compose(player, "")
		end
		if fields.minimize_email then
			email_status = "minimized"
			desktop(player, "default", current_tasks)
		end
		if fields.close_email then
			end_task("email")
			desktop(player, "default", current_tasks)
		end
		if fields.send then
			local subject = {}
			if fields.recipient ~= "" and fields.body ~= "" then
				if not files.inbox[fields.recipient] then
					files.inbox[fields.recipient] = {}
				end
				if fields.subject == "" then
					subject = "(No Subject)"
				else
					subject = fields.subject
				end
				-- Save email contents.
				table.insert(files.inbox[fields.recipient], 1,
				{sender = player:get_player_name(),
				subject = subject, body = fields.body})
				if not files.sent[player:get_player_name()] then
					files.sent[player:get_player_name()] = {}
				end
				table.insert(files.sent[player:get_player_name()],
				1, {recipient = fields.recipient,
				subject = subject, body = fields.body})
				save_files()
			end
			mail_type = "inbox"
			email(player, inbox_items(player))
		end
		if fields.cancel then
			mail_type = "inbox"
			email(player, inbox_items(player))
		end
		if fields.inbox_mail then
			mail_type = "inbox"
			email(player, inbox_items(player))
		end
		if fields.sent then
			mail_type = "sent"
			email(player, sent_items(player))
		end
		if fields.email_task then
			remember_notes(fields)
			active_task = "email"
			change_tasks("email")
			if email_status == "minimized" then
				email(player, inbox_items(player))
				email_status = "maximized"
			else
				desktop(player, "default", current_tasks)
				email_status = "minimized"
			end
		end
		if fields.back then
			if mail_type == "inbox" then
				email(player, inbox_items(player))
			else
				email(player, sent_items(player))
			end
		end
		if fields.reply then
			if mail_type == "inbox" then
				local sender = {}
				for i,v in ipairs(files.inbox[player:get_player_name()]) do
					if i == item then
						sender = v.sender
					end
				end
				if type(sender) ~= "table" then
					compose(player, sender)
				end
			end
		end
		if fields.forward then
			if mail_type == "inbox" then
				read_mail(player, files.inbox[player:get_player_name()],
				item, "field[6.4,2;4,1;forward_to;" ..
				minetest.colorize("#000000", "Recipients:") .. ";]" ..
				"box[6,1.5;4,1;black]" .. "field_close_on_enter[" ..
				"forward_to;false]")
			end
		end
		if fields.forward_to then
			local recipients = {}
			if fields.forward_to ~= "" then
				for recipient in fields.forward_to:gmatch("([^,]+),") do
					table.insert(recipients, recipient)
				end
				if fields.forward_to:match(",.+$") then
					table.insert(recipients,
					fields.forward_to:match(",.+$"))
				end
				if type(recipients) == "table" then
					table.insert(recipients, fields.forward_to)
				end
				local sender = {}
				local subject = {}
				local body = {}
				for i,v in ipairs(files.inbox[player:get_player_name()]) do
					if i == item then
						sender = v.sender
						subject = v.subject
						body = v.body
					end
				end
				for k,v in pairs(recipients) do
					if not files.inbox[v] then
						files.inbox[v] = {}
					end
					table.insert(files.inbox[v], 1,
					{sender = sender ..
					" - Forwarded by " .. player:get_player_name(),
					subject = subject, body = body})
				end
				save_files()
				read_mail(player, files.inbox[player:get_player_name()],
				item, "")
			end
		end
		local list = minetest.explode_textlist_event(fields.inbox)
		if list.type == "DCL" then
			item = list.index
			local body = {}
			if mail_type == "inbox" then
				if #files.inbox[player:get_player_name()] > 0 then
					-- Read email.
					body = read_mail(player,
					files.inbox[player:get_player_name()],
					list.index, "")
					if not files.read_emails[player:get_player_name()] then
						files.read_emails[player:get_player_name()] = {}
					end
					-- Mark email as read.
					if #files.read_emails[player:get_player_name()] < 1 then
						table.insert(files.read_emails[player:get_player_name()], body:sub(1,30))
						save_files()
					else
						if not minetest.serialize(files.read_emails[player:get_player_name()]):match(body:sub(1,30)) then
							table.insert(files.read_emails[player:get_player_name()], body:sub(1,30))
							save_files()
						end
					end
				end
			else
				-- Read sent mail.
				if #files.sent[player:get_player_name()] > 0 then
					read_mail(player,
					files.sent[player:get_player_name()],
					list.index, "")
				end
			end
		end
		if list.type == "CHG" then
			selected = "true"
			item = list.index
		end
		if fields.delete_mail then
			if selected == "true" then
				if mail_type == "inbox" then
					table.remove(files.inbox[player:
					get_player_name()], item)
					email(player, inbox_items(player))
				else
					table.remove(files.sent[player:
					get_player_name()], item)
					email(player, inbox_items(player))
				end
			end
			save_files()
			selected = "false"
			item = {}
		end
		if fields.read then
			if selected == "true" then
				if mail_type == "inbox" then
					local search = {}
					local index,emails
					for index,emails in ipairs(
					files.inbox[player:get_player_name()]) do
						if index == item then
							search = emails.body
						end
					end
					if not files.read_emails[player:
					get_player_name()] then
						files.read_emails[player:
						get_player_name()] = {}
					end
					if not minetest.serialize(
					files.read_emails[player:get_player_name()]):
					match(search:sub(1,30)) then
						table.insert(
						files.read_emails[player:
						get_player_name()], search:sub(1,30))
						save_files()
					end
					email(player, inbox_items(player))
				end
				selected = "false"
				item = {}
			end
		end
		if fields.important then
			if selected == "true" then
				if mail_type == "inbox" then
					local search = {}
					local index,emails
					for index,emails in ipairs(
					files.inbox[player:get_player_name()]) do
						if index == item then
							search = emails.body
						end
					end
					if not files.important_emails[player:
					get_player_name()] then
						files.important_emails[player:
						get_player_name()] = {}
					end
					if not minetest.serialize(
					files.important_emails[player:
					get_player_name()]):match(search:sub(1,30)) then
						table.insert(
						files.important_emails[player:
						get_player_name()], search:sub(1,30))
						save_files()
					end
					email(player, inbox_items(player))
				end
				selected = "false"
				item = {}
			end
		end
	end
end)
