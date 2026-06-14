--[[
	Theme Manager addon for Galax-Obsidian-Lib (Matcha)
	Based on Obsidian's ThemeManager, adapted for Matcha's Drawing API.
	No filesystem functions - themes are built-in or in-memory only.
]]

local ThemeManager = {}
do
	-- Field mapping: Obsidian Scheme -> Galax Theme
	-- FontColor -> Text, MainColor -> Main, AccentColor -> Accent,
	-- BackgroundColor -> Background, OutlineColor -> Outline
	local ThemeFields = { "BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor" }

	ThemeManager.Library = nil
	ThemeManager.AppliedToTab = false

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

	-- In-memory custom themes (no filesystem available)
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
		-- Map Obsidian field names to our theme field names
		themeTable.BackgroundColor = Color3.fromHex(data.BackgroundColor)
		themeTable.MainColor = Color3.fromHex(data.MainColor)
		themeTable.AccentColor = Color3.fromHex(data.AccentColor)
		themeTable.OutlineColor = Color3.fromHex(data.OutlineColor)
		themeTable.FontColor = Color3.fromHex(data.FontColor)

		-- Set font face if specified
		if data.FontFace then
			themeTable.FontFace = data.FontFace
		end

		-- Apply to the active window
		if self.Library.ActiveWindow then
			self.Library.ActiveWindow:SetTheme(themeTable)
		end

		-- Update color picker UI if options exist
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
		-- Read current color picker values and apply them
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

	-- In-memory custom theme operations (stubs that mimic file operations)
	function ThemeManager:GetCustomTheme(file)
		return self.CustomThemes[file]
	end

	function ThemeManager:SaveCustomTheme(file)
		if file:gsub(" ", "") == "" then
			if self.Library then
				self.Library:Notify("Invalid file name for theme (empty)", 3)
			end
			return
		end

		local theme = {}
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
	end

	function ThemeManager:Delete(name)
		if not name or not self.CustomThemes[name] then
			return false, "invalid file"
		end
		self.CustomThemes[name] = nil
		return true
	end

	function ThemeManager:ReloadCustomThemes()
		-- Return the list of in-memory custom theme names
		local out = {}
		for name, _ in pairs(self.CustomThemes) do
			table.insert(out, name)
		end
		table.sort(out)
		return out
	end

	-- Load/Save default theme (in-memory)
	ThemeManager.DefaultThemeName = nil

	function ThemeManager:LoadDefault()
		local theme = self.DefaultThemeName or "Default"
		if self.Library.Options and self.Library.Options.ThemeManager_ThemeList then
			self.Library.Options.ThemeManager_ThemeList:SetValue(theme)
		end
	end

	function ThemeManager:SaveDefault(theme)
		self.DefaultThemeName = theme
	end

	-- GUI builder
	function ThemeManager:CreateThemeManager(groupbox)
		groupbox
			:AddLabel("Background color")
			:AddColorPicker("BackgroundColor", { Default = Color3.fromHex("0f0f0f") })
		groupbox:AddLabel("Main color"):AddColorPicker("MainColor", { Default = Color3.fromHex("191919") })
		groupbox:AddLabel("Accent color"):AddColorPicker("AccentColor", { Default = Color3.fromHex("7d55ff") })
		groupbox
			:AddLabel("Outline color")
			:AddColorPicker("OutlineColor", { Default = Color3.fromHex("282828") })
		groupbox:AddLabel("Font color"):AddColorPicker("FontColor", { Default = Color3.fromHex("ffffff") })

		-- Font face dropdown using available fonts from our library
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

		-- Built-in theme selector
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

		-- Custom theme section (in-memory)
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

		-- Hook color picker changes to live-update the theme
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
