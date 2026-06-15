--[[
	Theme Manager addon for Galax-Obsidian-Lib (Matcha)
	Based on Obsidian's ThemeManager, adapted for Matcha's Drawing API.
	Supports file I/O (writefile/readfile) if available, falls back to in-memory.
]]

local ThemeManager = {}
do
	local ThemeFields = { "BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor" }

	ThemeManager.Library = nil
	ThemeManager.AppliedToTab = false
	ThemeManager.Folder = "Galax/Obsidian/Settings"
	ThemeManager.ThemesFolder = "Galax/Obsidian/Settings/Themes"

	local function hasFS()
		return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function" and type(listfiles) == "function" and type(makefolder) == "function"
	end

	local function ensureDir(path)
		if not hasFS() then return end
		local parts = {}
		for part in path:gmatch("[^/]+") do
			table.insert(parts, part)
			local dir = table.concat(parts, "/")
			local ok, _ = pcall(function() makefolder(dir) end)
		end
	end

	local function themeFilePath(name)
		return ThemeManager.ThemesFolder .. "/" .. name:gsub("[^%w_%-%. ]", "") .. ".json"
	end

	local function defaultFilePath()
		return ThemeManager.Folder .. "/default_theme.txt"
	end

	-- Built-in themes (hex colors)
	ThemeManager.BuiltInThemes = {
		["Default"] = {
			1,
			{ FontColor = "ffffff", MainColor = "191919", AccentColor = "7d55ff", BackgroundColor = "0f0f0f", OutlineColor = "282828" },
		},
		["BBot"] = {
			2,
			{ FontColor = "ffffff", MainColor = "1e1e1e", AccentColor = "7e48a3", BackgroundColor = "232323", OutlineColor = "141414" },
		},
		["Fatality"] = {
			3,
			{ FontColor = "ffffff", MainColor = "1e1842", AccentColor = "c50754", BackgroundColor = "191335", OutlineColor = "3c355d" },
		},
		["Jester"] = {
			4,
			{ FontColor = "ffffff", MainColor = "242424", AccentColor = "db4467", BackgroundColor = "1c1c1c", OutlineColor = "373737" },
		},
		["Mint"] = {
			5,
			{ FontColor = "ffffff", MainColor = "242424", AccentColor = "3db488", BackgroundColor = "1c1c1c", OutlineColor = "373737" },
		},
		["Tokyo Night"] = {
			6,
			{ FontColor = "ffffff", MainColor = "191925", AccentColor = "6759b3", BackgroundColor = "16161f", OutlineColor = "323232" },
		},
		["Ubuntu"] = {
			7,
			{ FontColor = "ffffff", MainColor = "3e3e3e", AccentColor = "e2581e", BackgroundColor = "323232", OutlineColor = "191919" },
		},
		["Quartz"] = {
			8,
			{ FontColor = "ffffff", MainColor = "232330", AccentColor = "426e87", BackgroundColor = "1d1b26", OutlineColor = "27232f" },
		},
		["Nord"] = {
			9,
			{ FontColor = "eceff4", MainColor = "3b4252", AccentColor = "88c0d0", BackgroundColor = "2e3440", OutlineColor = "4c566a" },
		},
		["Dracula"] = {
			10,
			{ FontColor = "f8f8f2", MainColor = "44475a", AccentColor = "ff79c6", BackgroundColor = "282a36", OutlineColor = "6272a4" },
		},
		["Monokai"] = {
			11,
			{ FontColor = "f8f8f2", MainColor = "272822", AccentColor = "f92672", BackgroundColor = "1e1f1c", OutlineColor = "49483e" },
		},
		["Gruvbox"] = {
			12,
			{ FontColor = "ebdbb2", MainColor = "3c3836", AccentColor = "fb4934", BackgroundColor = "282828", OutlineColor = "504945" },
		},
		["Solarized"] = {
			13,
			{ FontColor = "839496", MainColor = "073642", AccentColor = "cb4b16", BackgroundColor = "002b36", OutlineColor = "586e75" },
		},
		["Catppuccin"] = {
			14,
			{ FontColor = "d9e0ee", MainColor = "302d41", AccentColor = "f5c2e7", BackgroundColor = "1e1e2e", OutlineColor = "575268" },
		},
		["One Dark"] = {
			15,
			{ FontColor = "abb2bf", MainColor = "282c34", AccentColor = "c678dd", BackgroundColor = "21252b", OutlineColor = "5c6370" },
		},
		["Cyberpunk"] = {
			16,
			{ FontColor = "f9f9f9", MainColor = "262335", AccentColor = "00ff9f", BackgroundColor = "1a1a2e", OutlineColor = "413c5e" },
		},
		["Oceanic Next"] = {
			17,
			{ FontColor = "d8dee9", MainColor = "1b2b34", AccentColor = "6699cc", BackgroundColor = "16232a", OutlineColor = "343d46" },
		},
		["Material"] = {
			18,
			{ FontColor = "eeffff", MainColor = "212121", AccentColor = "82aaff", BackgroundColor = "151515", OutlineColor = "424242" },
		},
	}

	-- Custom themes (loaded from disk or in-memory)
	ThemeManager.CustomThemes = {}

	function ThemeManager:SetLibrary(library)
		self.Library = library
	end

	-- Apply a built-in or custom theme
	function ThemeManager:ApplyTheme(theme)
		local data = self.CustomThemes[theme] or (self.BuiltInThemes[theme] and self.BuiltInThemes[theme][2])

		if not data then
			return
		end

		local themeTable = {}
		themeTable.BackgroundColor = Color3.fromHex(data.BackgroundColor)
		themeTable.MainColor = Color3.fromHex(data.MainColor)
		themeTable.AccentColor = Color3.fromHex(data.AccentColor)
		themeTable.OutlineColor = Color3.fromHex(data.OutlineColor)
		themeTable.FontColor = Color3.fromHex(data.FontColor)

		if data.FontFace then
			themeTable.FontFace = data.FontFace
		end

		if self.Library.ActiveWindow then
			self.Library.ActiveWindow:SetTheme(themeTable)
		end

		if self.Library.Options then
			for _, field in ipairs(ThemeFields) do
				if self.Library.Options[field] then
					local color = Color3.fromHex(data[field])
					self.Library.Options[field]:SetValueRGB(color)
				end
			end
			if data.FontFace and self.Library.Options["FontFace"] then
				self.Library.Options["FontFace"]:SetValue(data.FontFace)
			end
		end
	end

	function ThemeManager:ThemeUpdate()
		local themeTable = {}
		for _, field in ipairs(ThemeFields) do
			if self.Library.Options and self.Library.Options[field] then
				local color = self.Library.Options[field]:Get()
				if color then
					themeTable[field] = color
				end
			end
		end

		if self.Library.ActiveWindow then
			self.Library.ActiveWindow:SetTheme(themeTable)
		end
	end

	-- Load all custom themes from disk
	function ThemeManager:LoadCustomThemes()
		self.CustomThemes = {}
		if not hasFS() then return end
		ensureDir(self.ThemesFolder)
		local ok, files = pcall(listfiles, self.ThemesFolder)
		if not ok then return end
		for _, path in ipairs(files) do
			if path:sub(-5) == ".json" then
				local ok2, raw = pcall(readfile, path)
				if ok2 and raw then
					local decodeOk, data = pcall(function() return game:GetService("HttpService"):JSONDecode(raw) end)
					if decodeOk and type(data) == "table" and data.ThemeName then
						self.CustomThemes[data.ThemeName] = data
					end
				end
			end
		end
	end

	function ThemeManager:SaveCustomTheme(file)
		if file:gsub(" ", "") == "" then
			if self.Library then
				self.Library:Notify("Invalid file name for theme (empty)", 3)
			end
			return
		end

		local theme = { ThemeName = file }
		for _, field in ipairs(ThemeFields) do
			if self.Library.Options and self.Library.Options[field] then
				local color = self.Library.Options[field]:Get()
				if color then
					theme[field] = color:ToHex()
				end
			end
		end
		if self.Library.Options and self.Library.Options["FontFace"] then
			theme.FontFace = self.Library.Options["FontFace"].Value
		end

		self.CustomThemes[file] = theme

		if hasFS() then
			ensureDir(self.ThemesFolder)
			local ok, json = pcall(function() return game:GetService("HttpService"):JSONEncode(theme) end)
			if ok and json then
				pcall(writefile, themeFilePath(file), json)
			end
		end
	end

	function ThemeManager:Delete(name)
		if not name or not self.CustomThemes[name] then
			return false, "invalid file"
		end
		self.CustomThemes[name] = nil
		if hasFS() then
			local path = themeFilePath(name)
			if isfile(path) then
				pcall(delfile, path)
			end
		end
		return true
	end

	function ThemeManager:ReloadCustomThemes()
		if hasFS() then
			self:LoadCustomThemes()
		end
		local out = {}
		for name, _ in pairs(self.CustomThemes) do
			table.insert(out, name)
		end
		table.sort(out)
		return out
	end

	-- Load/Save default theme
	ThemeManager.DefaultThemeName = nil

	function ThemeManager:LoadDefault()
		if hasFS() then
			local path = defaultFilePath()
			if isfile(path) then
				local ok, raw = pcall(readfile, path)
				if ok and raw and raw ~= "" then
					self.DefaultThemeName = raw
				end
			end
		end
		local theme = self.DefaultThemeName or "Default"
		if self.Library.Options and self.Library.Options.ThemeManager_ThemeList then
			self.Library.Options.ThemeManager_ThemeList:SetValue(theme)
		end
	end

	function ThemeManager:SaveDefault(theme)
		self.DefaultThemeName = theme
		if hasFS() then
			ensureDir(self.Folder)
			pcall(writefile, defaultFilePath(), tostring(theme))
		end
	end

	-- GUI builder
	function ThemeManager:CreateThemeManager(groupbox)
		self:LoadCustomThemes()

		groupbox
			:AddLabel("Background color")
			:AddColorPicker("BackgroundColor", { Default = Color3.fromHex("0f0f0f") })
		groupbox:AddLabel("Main color"):AddColorPicker("MainColor", { Default = Color3.fromHex("191919") })
		groupbox:AddLabel("Accent color"):AddColorPicker("AccentColor", { Default = Color3.fromHex("7d55ff") })
		groupbox
			:AddLabel("Outline color")
			:AddColorPicker("OutlineColor", { Default = Color3.fromHex("282828") })
		groupbox:AddLabel("Font color"):AddColorPicker("FontColor", { Default = Color3.fromHex("ffffff") })

		local fontValues = {}
		if self.Library.FontMap then
			for name, _ in pairs(self.Library.FontMap) do
				table.insert(fontValues, name)
			end
		else
			fontValues = { "UI", "System", "SystemBold", "Minecraft", "Monospace", "Pixel", "Fortnite" }
		end
		table.sort(fontValues)

		groupbox:AddDropdown("FontFace", {
			Text = "Font Face",
			Default = "Monospace",
			Values = fontValues,
		})

		local ThemesArray = {}
		for Name, _ in pairs(self.BuiltInThemes) do
			table.insert(ThemesArray, Name)
		end
		table.sort(ThemesArray, function(a, b)
			return self.BuiltInThemes[a][1] < self.BuiltInThemes[b][1]
		end)

		groupbox:AddDivider()

		groupbox:AddDropdown("ThemeManager_ThemeList", { Text = "Theme list", Values = ThemesArray, Default = 1 })
		groupbox:AddButton("Set as default", function()
			self:SaveDefault(self.Library.Options.ThemeManager_ThemeList.Value)
			if self.Library then
				self.Library:Notify(string.format("Set default theme to %q", self.Library.Options.ThemeManager_ThemeList.Value))
			end
		end)

		self.Library.Options.ThemeManager_ThemeList:OnChanged(function()
			self:ApplyTheme(self.Library.Options.ThemeManager_ThemeList.Value)
		end)

		groupbox:AddDivider()

		groupbox:AddInput("ThemeManager_CustomThemeName", { Text = "Custom theme name" })
		groupbox:AddButton("Create theme", function()
			local name = self.Library.Options.ThemeManager_CustomThemeName.Value
			if name:gsub(" ", "") == "" then
				if self.Library then
					self.Library:Notify("Invalid theme name (empty)", 2)
				end
				return
			end
			self:SaveCustomTheme(name)
			if self.Library then
				self.Library:Notify(string.format("Created theme %q", name))
			end
			self.Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
			self.Library.Options.ThemeManager_CustomThemeList:SetValue(nil)
		end)

		groupbox:AddDivider()

		local customList = self:ReloadCustomThemes()
		groupbox:AddDropdown("ThemeManager_CustomThemeList", { Text = "Custom themes", Values = customList, AllowNull = true, Default = 1 })
		groupbox:AddButton("Load theme", function()
			local name = self.Library.Options.ThemeManager_CustomThemeList.Value
			if not name then return end
			self:ApplyTheme(name)
			if self.Library then
				self.Library:Notify(string.format("Loaded theme %q", name))
			end
		end)
		groupbox:AddButton("Overwrite theme", function()
			local name = self.Library.Options.ThemeManager_CustomThemeList.Value
			if not name then return end
			self:SaveCustomTheme(name)
			if self.Library then
				self.Library:Notify(string.format("Overwrote config %q", name))
			end
		end)
		groupbox:AddButton("Delete theme", function()
			local name = self.Library.Options.ThemeManager_CustomThemeList.Value
			if not name then return end
			local success, err = self:Delete(name)
			if not success then
				if self.Library then
					self.Library:Notify("Failed to delete theme: " .. tostring(err))
				end
				return
			end
			if self.Library then
				self.Library:Notify(string.format("Deleted theme %q", name))
			end
			self.Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
			self.Library.Options.ThemeManager_CustomThemeList:SetValue(nil)
		end)
		groupbox:AddButton("Refresh list", function()
			self.Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
			self.Library.Options.ThemeManager_CustomThemeList:SetValue(nil)
		end)

		self:LoadDefault()
		self.AppliedToTab = true

		local function UpdateTheme()
			self:ThemeUpdate()
		end

		self.Library.Options.BackgroundColor:OnChanged(UpdateTheme)
		self.Library.Options.MainColor:OnChanged(UpdateTheme)
		self.Library.Options.AccentColor:OnChanged(UpdateTheme)
		self.Library.Options.OutlineColor:OnChanged(UpdateTheme)
		self.Library.Options.FontColor:OnChanged(UpdateTheme)
		self.Library.Options.FontFace:OnChanged(function(Value)
			if self.Library.ActiveWindow then
				self.Library.ActiveWindow:SetTheme({ FontFace = Value })
			end
		end)
	end

	function ThemeManager:CreateGroupBox(tab)
		assert(self.Library, "Must set ThemeManager.Library first!")
		return tab:AddLeftGroupbox("Themes")
	end

	function ThemeManager:ApplyToTab(tab)
		assert(self.Library, "Must set ThemeManager.Library first!")
		local groupbox = self:CreateGroupBox(tab)
		self:CreateThemeManager(groupbox)
	end

	function ThemeManager:ApplyToGroupbox(groupbox)
		assert(self.Library, "Must set ThemeManager.Library first!")
		self:CreateThemeManager(groupbox)
	end
end

return ThemeManager
