--  ###             #             #
-- #     ## ## ###  # ##   # ## #####
-- ###   ## ## #  # #    # ##  #  #
-- #      #  # ###  # ###  #   #  #
-- ####  #  #  #    #  ##  #   #   #
--             #

--[[
	Useful functions in Infinite Yield's Source code.
	'notify' 'notify(string: title, string: text, number: duration)' -- Notifies text in a notification with title 'title' which disappears after 'duration' seconds
	'dragGUI' 'dragGUI(frame)' -- Makes 'frame' draggable
	'makeSettingsButton' 'makeSettingsButton(name, icon)' -- Creates a new button intended to be put into Infinite Yield settings with name 'name' and icon 'icon'
	
	Useful functions in Eggplant Admin.
	'newnotify' 'void newnotify(table: info, string: ...)' -- Like 'notify' but with a notification system that I like more, notifies '...' with a notification with 'info' (check implementation of newnotify to know how to use 'info')
	'makewindow' 'table makewindow(table: info, string: title)' -- Creates a new window ready to be used, returns a table to manage the window (check implementation of makewindow to know how to make use of 'info' and to see what returns)
	'addSettingsButton' 'addSettingsButton(name, icon)' -- Similar to 'makeSettingsButton' but easier to use, returns a table to manage the button (check implementation of addSettingsButton to see what returns)
	
	Functions replaced:
	'newnotify' replaces -> 'notify'
	'makeDraggable' replaces -> 'dragGUI'
]]

-- Run Infinite Yield
	-- Things for settings :
local settings_filename = "egg.plant"
	
	-- Change settings file
		-- Changes settings file from IY_FE.iy to egg.plant
local oldwritefile = writefile
local oldreadfile = readfile

if writefile then
	getfenv().writefile = function(path, contents)
		local path = path ~= "IY_FE.iy" and path or (path and settings_filename)
		return oldwritefile(path, contents)
	end
	
	getfenv().readfile = function(path)
		local path = path ~= "IY_FE.iy" and path or (path and settings_filename)
		local file_exists, content = pcall(oldreadfile, path)
		return file_exists and content or nil
	end
end
	--

	-- Modify settings
if writefile then
	local hs = game:GetService("HttpService")
	
	local contents = readfile(settings_filename)
	local settings = hs:JSONDecode(contents or "{}")
	
	settings.currentShade1 = {0, 0.666666686534881591796875, 0}
	settings.currentShade2 = {0.666666686534881591796875, 0, 1}
	settings.currentShade3 = {0.666666686534881591796875, 0, 1}
	settings.currentText1 = {1, 1, 1}
	settings.currentText2 = {1, 1, 1}
	settings.currentScroll = {0.3058823645114898681640625,0.3058823645114898681640625,0.3098039329051971435546875}
	settings.prefix = "h"
	
	if not contents then
		-- if egg.plant did not exist
		settings.binds = {}
		settings.PluginsTable = {}
		settings.StayOpen = false
		settings.logsEnabled = false
		settings.eventBinds = {}
		settings.aliases = {}
		settings.WayPoints = {}
		settings.jLogsEnabled = false
		
		-- i do this because these settings are essential for IY to load...
	end
	
	writefile(settings_filename, hs:JSONEncode(settings))
end
	--
	--

	-- This is for removing the annoying intro
local oldwait = wait
getfenv().wait = function()end
	--

	-- Load Infinite yield
local WAS_LOADED = IY_LOADED
getgenv().IY_LOADED = false
loadstring(game:HttpGet(('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'),true))()
getgenv().IY_LOADED = WAS_LOADED
	--

	-- And make wait() work again (because I made wait unusable to remove intro)
getfenv().wait = oldwait
	--

-- Useful stuff
	-- Making things draggable
local makeDraggable = function(frame)
	dragGUI(frame)
end
	--
	
	-- Adding things to color pallete easily
		-- Inf Yield has a table called shade1 which stores every instance that uses the color 'currentShade1'
		-- same with shade2, shade3, text1, text2 & scroll
local setShade1 = function(el) table.insert(shade1, el) end
local setShade2 = function(el) table.insert(shade2, el) end
local setShade3 = function(el) table.insert(shade3, el) end
local setText1  = function(el) table.insert(text1,  el) end
local setText2  = function(el) table.insert(text2,  el) end
local setScroll = function(el) table.insert(scroll, el) end

local color = setmetatable({}, {
	__index = function(self, key)
		if key == "shade1" then
			return currentShade1
		elseif key == "shade2" then
			return currentShade2
		elseif key == "shade3" then
			return currentShade3
		elseif key == "text1" then
			return currentText1
		elseif key == "text2" then
			return currentText2
		elseif key == "shade" then
			return currentScroll
		end
		return nil
	end
})
	--
	
	-- A function that will really help me
local new = function(class, parent, ...)
	-- Creates a new instance of class 'class' and with parent 'parent'
	-- you can also add tables as arguments ('new("TextButton", gui, {table}, {table})')
	-- the tables will define properties of the instance
	-- for example adding as last argument
	--  {
	--   Size = UDim2.fromOffset(20, 20)
	--  }
	-- will make the instace have a size of an UDim {0, 20, 0, 20}
	-- and you can use multiple tables to change properties
	
	local instance = Instance.new(class)
	instance.Parent = parent
	
	local props = {}
	for i, v in ipairs({...}) do
		for ii, vv in pairs(v) do
			props[ii] = vv
		end
	end
	
	for i, v in pairs(props) do
		instance[i] = v
	end
	
	return instance
end
	--
	
	-- Creating windows
local makewindow = function(info, title)
	--[[ 'info' should be like this
		{
			width = 300, -- window width
			height = 300, -- window height
			not_draggable = false, -- if the window should not be draggable
			disable_close = false, -- disables close button
			disable_min = false, -- disables min button
		}
	]]
	
	--[[ returns a table that look like this
		{
			-- Attributes
			minimized = false, -- Window is minimized
			closeButton = icon, -- closeButton is a button added with the 'addIcon' function and its stored on this variable, check 'addIcon'
			minButton = icon, -- same as closeButton but with the minimize button
			width = 100, -- Window width
			height = 100, -- Window height
			shown = true, -- If window is not hidded
			
			-- Methods
			add(instance), -- Parents instance to the window (so you can add buttons) (also, it returns the instance you gave as param)
			changeTitle(newTitle), -- Changes window title to 'newTitle'
			hide(), -- Hides window
			show(), -- Shows window
			minimize(), -- Minimizes window
			unminimize(), -- Unminimizes window
			changeWidth(width), -- Changes window's width to 'width'
			changeHeight(height), -- Changes window's height to 'height'
			toggle(), -- Minimizes/Unminimizes window
			addIcon(assetId), -- Adds a new 'assetId' icon to the window, returns a table that looks like this
							{
								-- Attributes
								bg = Frame, -- A frame 'button' is parented to
								button = ImageButton, -- The icon image button
								
								-- Methods
								remove(), -- Removes the icon from the window
								readd(), -- ReAdds the icon to the window
								changeIcon(assetId), -- Changes icon's image to 'assetId'
								createTween(info, goals), -- Creates a tween of the icon and returns it (using TweenService:Create('info', 'goals'))
								-- Events
								onClicked(), -- Fired when the icon is clicked
							}
			
			-- Events
			onHide(), -- Fired when window gets hided
			onShow(), -- Fired when window gets show
			onClosed(), -- Fired when close button gets clicked
			onMinimized(), -- Fired when minimize button gets clicked
		}
	]]
	
	info = info or {}
	info.width = info.width or 300
	info.height = info.height or 100
	info.not_draggable = false
	
	local win = {}
	win.width = info.width
	win.height = info.height
	
		-- Window border
	win.border = new("Frame", PARENT, {
		Size = UDim2.fromOffset(win.width, 20),
		BorderSizePixel = 0,
		BackgroundColor3 = color.shade1,
	})
	setShade1(win.border)
	
	if not info.not_draggable then
		makeDraggable(win.border)
	end
	
		-- Window title
	win.title = new("TextLabel", win.border, {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = title or "Unnamed window",
		TextColor3 = color.text1,
	})
	setText1(win.title)
	
	win.changeTitle = function(self, title)
		self.title.Text = title
	end
	
		-- Window icons
	win.icons = new("Frame", win.border, {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	})
	
	win.iconsLayout = new("UIListLayout", win.icons, {
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		FillDirection = Enum.FillDirection.Horizontal,
	})
	
	win.iconsAmount = 0
	win.addIcon = function(self, assetId)
		self.iconsAmount = self.iconsAmount + 1
		
		local icon = {}
		icon.parent = self
		
		icon.bg = new("Frame", self.icons, {
			BackgroundTransparency = 1,
			LayoutOrder = 0 - self.iconsAmount,
			Size = UDim2.fromOffset(20, 20),
		})
		
		icon.button = new("ImageButton", icon.bg, {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Image = assetId,
		})
		
		icon.remove = function(self)
			self.bg.Parent = nil
		end
		
		icon.readd = function(self)
			self.bg.Parent = self.parent.icons
		end
		
		icon.changeIcon = function(self, assetId)
			self.button.Image = assetId
		end
		
		icon.tween = function(self, info, goals)
			return game:GetService("TweenService"):Create(self.button, info, goals)
		end
		
		icon.onClicked = icon.button.Activated
		
		return icon
	end
	
		-- Window background
	win.behindbg = new("Frame", win.border, {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, win.height),
		Position = UDim2.fromScale(0, 1),
		ClipsDescendants = true,
	})
			-- Minimize / Unminimize
	local ts = game:GetService("TweenService")
	local animInfo = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	win.minAnim = ts:Create(win.behindbg, animInfo, {Size = UDim2.new(1, 0, 0, 0)})
	win.unminAnim = ts:Create(win.behindbg, animInfo, {Size = UDim2.new(1, 0, 0, win.height)})
	
	win.minimized = false
	win.minimize = function(self)
		if not self.minimized then
			-- If window was unminimized
			self.minAnim:Play()
			self.minimized = true
		end
	end
	
	win.unminimize = function(self)
		if self.minimized then
			-- If window was minimized
			self.unminAnim:Play()
			self.minimized = false
		end
	end
	
	win.toggle = function(self)
		self.minimized = not self.minimized
		
		if self.minimized then
			self.minAnim:Play()
		else
			self.unminAnim:Play()
		end
	end
			-- </Minimize / Unminimize>
	
	win.bg = new("Frame", win.behindbg, {
		BorderSizePixel = 0,
		BackgroundColor3 = color.shade2,
		Size = UDim2.new(1, 0, 0, win.height),
	})
	setShade2(win.bg)
	
	win.add = function(self, obj)
		obj.Parent = self.bg
		return obj
	end
	
		-- Set width/height
	win.setWidth = function(self, width)
		self.width = width
		
		self.border.Size = UDim2.fromOffset(width, 20)
	end
	
	win.setHeight = function(self, height)
		self.height = height
		
		self.bg.Size = UDim2.new(1, 0, 0, win.height)
		
		if not self.minimized then
			self.behindbg.Size = UDim2.new(1, 0, 0, win.height)
		end
	end
	
		-- Hide / show
	win.shown = true
	
	win.hide = function(self)
		win.shown = false
		self.border.Visible = false
	end
	
	win.show = function(self)
		self.border.Visible = true
		win.shown = true
	end
	
		-- Minimize & close button
	win.closeButton = win:addIcon("rbxassetid://3192543734")
	win.closeButton.onClicked:Connect(function()
		win:hide()
	end)
	if info.disable_close then
		win.closeButton:remove()
	end
	
	win.minButton = win:addIcon("rbxassetid://3192533593")
	win.minBtnAnim = win.minButton:tween(animInfo, {Rotation = 180})
	win.unminBtnAnim = win.minButton:tween(animInfo, {Rotation = 0})
	win.minButton.onClicked:Connect(function()
		win:toggle()
		
		if win.minimized then
			win.minBtnAnim:Play()
		else
			win.unminBtnAnim:Play()
		end
	end)
	if info.disable_min then
		win.minButton:remove()
	end
	
	return win
end
	-- </Creating windows>

	-- Adding eggplant icon to things
local eggplant_icon_id = "rbxassetid://6245615283"

local addEggplantIcon = function(ins, dir, margin, margin2)
	-- Creates a new ImageButton with the texture of an eggplant
	-- parented to 'ins'
	-- if dir is 'left' then the icon will be at the left, if its 'right' then the icon will be at the right
	-- margin is the space between the icon and the instance (on x axis)
	-- margin2 is the same as margin but in the y axis
	dir = string.lower(dir)
	dir = (dir == "left" and 0) or (dir == "right" and 1)
	
	return new("ImageButton", ins, {
		BackgroundTransparency = 1,
		Position = UDim2.new(dir, margin * (0 - dir), 0, margin2),
		AnchorPoint = Vector2.new(dir),
		Size = UDim2.new(0, 16, 0, 16),
		Image = eggplant_icon_id,
		ZIndex = 10
	})
end
	--
	
	-- Making commands easier
local eggplantCmds = {} -- Contains every command added by newCmd function

local onCmdAddBin = new("BindableEvent") -- A bindable event fired when a command is added (with the 'newCmd' func)
local onCmdAdd = onCmdAddBin.Event

local newCmd = function(name, aliases, title, description, func)
    addcmdtext(title, name, description) -- Add the command to auto complete
    
    local id = #cmds + 1
    
    cmds[id] = {
        NAME = name,
        ALIAS = aliases or {},
        FUNC = func
    } -- Make the command work
	
	table.insert(eggplantCmds, {
		id = id,
		desc = description,
		title = title
	}) -- Add the command to the 'eggplantCmds' table
	
	onCmdAddBin:Fire(id) -- Fires 'onCmdAddBin'
end
		--'<Pending: Add 'removeCmd' function>'--
	--

	-- New notification system
local notifsbg = new("Frame", PARENT, {
	Size = UDim2.fromOffset(200, 400),
	AnchorPoint = Vector2.new(0.5),
	Position = UDim2.new(0.5, 0, 0, 20),
	BackgroundTransparency = 1
})

local notifsbglist = new("UIListLayout", notifsbg, {
	Padding = UDim.new(0, 0),
	SortOrder = Enum.SortOrder.LayoutOrder,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
})

local newnotifframe = function()
	-- Used by the function 'newnotifframe'
	-- used to create a notification
	
	local w = 100
	local h = 60
	local titlesize = 20
	
	local notif = {}
	
	notif.bg = new("Frame", notifsbg, {
		Size = UDim2.new(1, 0, 0, 0),
		LayoutOrder = notifs,
		AnchorPoint = Vector2.new(0.5),
		Position = UDim2.fromScale(0.5),
		BackgroundTransparency = 1
	})
	
	notif.notif = new("Frame", notif.bg, {
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0 - titlesize),
		Position = UDim2.fromScale(0.5, 1), AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = color.shade1,
		BackgroundTransparency = 1
	})
	setShade1(notif.notif)
	
	notif.text = new("TextLabel", notif.notif, {
		BackgroundTransparency = 1,
		TextColor3 = color.text1,
		Size = UDim2.fromScale(1, 1),
		BorderSizePixel = 0,
		TextTransparency = 1,
		TextWrapped = true,
	})
	setText1(notif.text)
	
	notif.title = new("TextLabel", notif.bg, {
		Size = UDim2.new(1, 0, 0, titlesize),
		Position = UDim2.fromScale(0.5), AnchorPoint = Vector2.new(0.5),
		BorderSizePixel = 0,
		TextColor3 = color.text1,
		BackgroundColor3 = color.shade2,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		TextTransparency = 1,
	})
	setText1(notif.title)
	setShade2(notif.title)
	
	notif.closeButton = new("ImageButton", notif.title, {
		Image = "rbxassetid://3192543734",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(19, 19),
		Position = UDim2.fromScale(1, 0.5),
		AnchorPoint = Vector2.new(1, 0.5),
		ImageTransparency = 1,
	})
	
	notif.icon = new("ImageLabel", notif.title, {
		Image = eggplant_icon_id,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.new(0, 2, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		ImageTransparency = 1,
	})
	
	-- Create animations
	local ts = game:GetService("TweenService")
	local animInfo = TweenInfo.new(
		0.1, -- Time
		Enum.EasingStyle.Sine, -- Style
		Enum.EasingDirection.Out -- Direction
	)
	
		-- Create animation to show notification
	notif.showAnimTweens = {
		ts:Create(notif.notif, animInfo, {BackgroundTransparency = 0}),
		ts:Create(notif.text, animInfo, {TextTransparency = 0}),
		ts:Create(notif.title, animInfo, {BackgroundTransparency = 0, TextTransparency = 0}),
		ts:Create(notif.closeButton, animInfo, {ImageTransparency = 0}),
		ts:Create(notif.icon, animInfo, {ImageTransparency = 0}),
	}
	
		-- Create animation to hide notification
	notif.hideAnimTweens = {
		ts:Create(notif.notif, animInfo, {BackgroundTransparency = 1}),
		ts:Create(notif.text, animInfo, {TextTransparency = 1}),
		ts:Create(notif.title, animInfo, {BackgroundTransparency = 1, TextTransparency = 1}),
		ts:Create(notif.closeButton, animInfo, {ImageTransparency = 1}),
		ts:Create(notif.icon, animInfo, {ImageTransparency = 1}),
	}
	
	-- Functionality
	notif.closedBin = new("BindableEvent") -- an event called when notification is hided closed(byButton), byButton is true if it was closed by button
	notif.closed = notif.closedBin.Event
	notif.shown = false
	
	notif.closeButton.Activated:Connect(function()
		notif:hide()
		notif.closedBin:Fire(true)
	end)
	
	notif.show = function(self, height, width)
		-- Shows notification
		for i, v in ipairs(self.showAnimTweens) do
			v:Play()
		end
		self.bg.Size = UDim2.fromOffset(width, 0)
		self.bg:TweenSize(UDim2.fromOffset(width, height), animInfo.EasingDirection, animInfo.EasingStyle, animInfo.Time)
		notif.shown = true
	end
	
	notif.hide = function(self)
		-- Hides notification
		for i, v in ipairs(self.hideAnimTweens) do
			v:Play()
		end
		self.bg:TweenSize(UDim2.fromOffset(self.bg.AbsoluteSize.X, 0), animInfo.EasingDirection, animInfo.EasingStyle, animInfo.Time)
		notif.shown = false
	end
	
	notif.close = function(self)
		self:hide()
		self.closedBin:Fire()
	end
	
	-- Add notification to 'notifications' table
	return notif
end

local notifications = {} -- Stores pre made notifications

local currentNotifications = 0 -- How many notifications are on screen
local aliveNotifications = 0 -- How many of these notifications are still open
			-- ^^ This is to optimize the notification system

local newnotify = function(info, ...)
	-- A function like 'notify' (in inf yield source code)
	-- the info table can change some aspects of the notifications
	-- the info table is optional but it should be like this:
	--	{
	--		title = "Eggplant admin", -- The title of the notification
	--		icon = "rbxassetid://6245615283", -- The icon of the notification
	--      duration = 1, -- How much time will pass before notifications dissapears
	--		width = 100, -- Width of the notification
	--		height = 60, -- Height of the notification
	--	}
	
	coroutine.wrap(function(info, args) -- I make this a coroutine cuz I can yield the main thread if this function is ran
		currentNotifications = currentNotifications + 1
		aliveNotifications = aliveNotifications + 1
		local choosedNotif = currentNotifications
		
		local notif
		
		if choosedNotif > #notifications then
			-- If we cant use a notification from 'notifications' table
			notif = newnotifframe() -- Create new notification
			
				-- Insert it into the table 'notifications'
			local notificationid = #notifications + 1
			notif.id = notificationid
			table.insert(notifications, notif)
				--
			
				-- And make it work with the 'notifications' table good
			notif.closed:Connect(function()
				if aliveNotifications == currentNotifications then
					-- If its the last notification
					currentNotifications = currentNotifications - 1
				end
				aliveNotifications = aliveNotifications - 1
			end)
				--
		else
			notif = notifications[choosedNotif]
		end
		
		-- Change notification text
		local notiftext = ""
		for i, v in ipairs(args) do
			notiftext = notiftext .. tostring(v)
		end
		
		notif.text.Text = notiftext
		
		--
		info = info or {}
		
		-- Change notification title
		info.title = info.title or "Eggplant Admin"
		notif.title.Text = info.title
		
		-- Change notification icon
		info.icon = info.icon or "rbxassetid://0"
		notif.icon.Image = info.icon
		
		-- Change notification size
		info.height = info.height or 70
		info.width = info.width or 300
		
		wait() -- I do this to fix some tween issues that I dont know why they happen
		notif:show(info.height, info.width)
		
		-- Make so it dissapears after info.duration time
		if info.duration then
			local timer = info.duration
			local lastTimer
			local loop
			loop = game:GetService("RunService").Heartbeat:Connect(function(dt)
				timer = timer - dt
				
				-- Change notif text
				local roundTimer = math.ceil(timer)
				if roundTimer ~= lastTimer then
					lastTimer = roundTimer
					notif.title.Text = info.title .. " [" .. tostring(lastTimer) .. "]"
				end
				
				-- Close notif when time passed
				if not notif.shown then loop:Disconnect() end -- Disconnect event if notification was closed before the time passed
				if timer <= 0 then
					loop:Disconnect()
					notif.title.Text = info.title -- restore title
					notif:close()
				end
			end)
		end
	end)(info, {...})
end

		-- Replace the 'notify' function with 'newnotify'
notify = function(txt1, txt2, duration)
	newnotify({title = "Infinite Yield"}, txt1, txt2)
end
		--
	-- </New notify system>
	
	--[[ File browser

FILE BROWSER IS CANCELLED FOR NOW

local fb = {}
		-- <File browser window>
		-- File browser window border
fb.winborder = new("Frame", PARENT, {
	Size = UDim2.fromOffset(400, 20),
	BorderSizePixel = 0,
	BackgroundColor3 = color.shade1,
	Visible = false,
})
setShade1(fb.winborder)
makeDraggable(fb.winborder)

		-- File browser window background
fb.winbg = new("Frame", fb.winborder, {
	Size = UDim2.new(1, 0, 0, 300),
	Position = UDim2.fromScale(0, 1),
	BorderSizePixel = 0,
	BackgroundColor3 = color.shade2,
})
setShade2(fb.winbg)

		-- File browser window title
fb.wintitle = new("TextLabel", fb.winborder, {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Text = "File browser",
	TextColor3 = color.text1,
})
setText1(fb.wintitle)
	
		-- File browser window close button
fb.winclose = new("ImageButton", fb.winborder, {
	BackgroundTransparency = 1,
	Position = UDim2.fromScale(1),
	AnchorPoint = Vector2.new(1),
	Image = "rbxassetid://3192543734",
	Size = UDim2.fromOffset(20, 20),
})
		-- </File browser window>
		
		-- <File browser files list>
		-- </Files browser files list>

fb.requestFile = function(self)
	self.winborder.Visible = true
end

fb:requestFile()
	]]-- </File browser>

	-- <New settings menu>
		-- Clear everything on 'SettingsHolder'
SettingsHolder:ClearAllChildren()
SettingsHolder.Position = UDim2.fromOffset(0, 10)
		--
local SettingsHolderList = new("UIListLayout", SettingsHolder, {
	SortOrder = Enum.SortOrder.LayoutOrder,
	HorizontalAlignment = Enum.HorizontalAlignment.Center
})

local SettingsItems = 0

local makeSettingsFrame = function()
	SettingsItems = SettingsItems + 1
	
	return new("Frame", SettingsHolder, {
		LayoutOrder = SettingsItems,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(230, 25),
	})
end

local addSettingsButton = function(name, icon)
	--[[
		Returns
		{
			-- Methods
			remove(), -- Removes the button
			readd(), -- ReAdds the button
			changeText(text), -- Changes button text to 'text'
			changeIcon(assetId), -- Changes button icon to 'assetId'
			
			-- Events
			onClicked(), -- Fired when the button gets clicked
		}
	]]
	
	local button = {}
	
	button.frame = makeSettingsFrame()
	
	button.button = new("TextButton", button.frame, {
		Size = UDim2.fromScale(1, 1),
		BorderSizePixel = 0,
		Text = "",
		BackgroundColor3 = color.shade2,
	})
	setShade2(button)
	
	button.icon = new("ImageLabel", button.button, {
		Size = UDim2.fromOffset(25, 25),
		BackgroundTransparency = 1,
		Image = icon,
	})
	
	button.text = new("TextLabel", button.button, {
		Size = UDim2.new(1, -25, 1, 0),
		Position = UDim2.fromScale(1),
		AnchorPoint = Vector2.new(1),
		TextColor3 = color.text2,
		Text = name,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	setText2(text)
	
	button.remove = function(self)
		self.frame.Parent = nil
	end
	
	button.readd = function(self)
		self.frame.Parent = SettingsHolder
	end
	
	button.changeText = function(self, text)
		self.text.Text = text
	end
	
	button.changeIcon = function(self, assetId)
		self.icon.Image = assetId
	end
	
	button.onClickedBin = new("BindableEvent")
	button.onClicked = button.onClickedBin.Event
	
	button.button.Activated:Connect(function()
		button.onClickedBin:Fire()
	end)
	
	return button
end

local button = addSettingsButton("Close Infinite Yield", "rbxassetid://3192543734")

button.onClicked:Connect(function()
	newnotify({duration = 3}, "Button clicked")
end)
	-- </New settings menu>

-- Modifications
	--
Title.Text = "Eggplant Admin"
maximizeHolder()
	--

	-- Commands
local sayremote = game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest

		-- Roast
local roasts = {
	swear = {
		{"Hey ", " your reptarpded brain can't comprehend 2 + 2"},
		{"Yo ", " go psupck your mmom ddipck"},
		{"I just noticed ", " ffupcpked his cat"},
		{"", " is a ddipckphead"},
		{"", " has cunm in his pmouth"},
	},
	notswear = {
		{""},
	}
}

newCmd("roast", {}, "roast [plr] [swear/notswear]", "Roasts [plr]", function(args, caller)
    local player = getPlayer(args[1], caller)[1]
    local rtype = string.lower(args[2] or "notswear")
    
    local len = #roasts[rtype]
    local roast = roasts[rtype][math.random(1, len)]
    
    if not player then
        notify("Unable to find player " .. args[1])
        return
    end
	
	
    
    sayremote:FireServer(roast[1] .. player .. roast[2], "All")
end)
		-- </Roast>
	
		-- <Anchor, Unanchor>
newCmd("anchor", {}, "anchor", "Makes your player unmovable", function(args, caller)
	caller.Character.HumanoidRootPart.Anchored = true
end)

newCmd("unanchor", {}, "unanchor", "Makes your player unmovable", function(args, caller)
	caller.Character.HumanoidRootPart.Anchored = false
end)
		--
	-- </Commands>
	
	-- Holder modifications
		-- Eggplant icon
local icon = addEggplantIcon(Holder, "right", 20 * 2, 1)

		-- </Eggplant>
	--
