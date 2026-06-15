--[[
	Save Manager addon for Galax-Obsidian-Lib (Matcha)
	Based on Obsidian's SaveManager, adapted for Matcha's Drawing API.
	Supports file I/O (writefile/readfile) if available, falls back to in-memory.
]]

local SaveManager = {} do
	SaveManager.Folder = "Galax/Obsidian/Settings"
	SaveManager.SubFolder = ""
	SaveManager.Ignore = {}
	SaveManager.Library = nil
	SaveManager.UseLoadingOrder = false
	SaveManager.LoadingOrder = {}

	SaveManager.Configs = {}

	local function hasFS()
		return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function" and type(listfiles) == "function" and type(makefolder) == "function" and type(isfolder) == "function" and type(delfile) == "function"
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

	local function configFilePath(name)
		local safeName = name:gsub("[^%w_%-%. ]", "")
		if SaveManager:CheckSubFolder() then
			return SaveManager.Folder .. "/Config/" .. SaveManager.SubFolder .. "/" .. safeName .. ".json"
		else
			return SaveManager.Folder .. "/Config/" .. safeName .. ".json"
		end
	end

	local function autoloadFilePath()
		return SaveManager.Folder .. "/autoload_config.txt"
	end

	-- Build config key (used for in-memory storage + file ref)
	local function configKey(name)
		if SaveManager:CheckSubFolder() then
			return SaveManager.SubFolder .. "/" .. name
		else
			return name
		end
	end

	SaveManager.Parser = {
		Toggle = {
			Save = function(idx, object)
				return { type = "Toggle", idx = idx, value = object.Value }
			end,
			Load = function(idx, data)
				local object = SaveManager.Library.Toggles[idx]
				if object and object.Value ~= data.value then
					object:SetValue(data.value)
				end
			end,
		},
		Slider = {
			Save = function(idx, object)
				return { type = "Slider", idx = idx, value = tostring(object.Value) }
			end,
			Load = function(idx, data)
				local object = SaveManager.Library.Options[idx]
				if object and object.Value ~= data.value then
					object:SetValue(data.value)
				end
			end,
		},
		Dropdown = {
			Save = function(idx, object)
				return { type = "Dropdown", idx = idx, value = object.Value, multi = object.Multi }
			end,
			Load = function(idx, data)
				local object = SaveManager.Library.Options[idx]
				if object and object.Value ~= data.value then
					object:SetValue(data.value)
				end
			end,
		},
		ColorPicker = {
			Save = function(idx, object)
				return { type = "ColorPicker", idx = idx, value = object.Value:ToHex(), transparency = object.Transparency }
			end,
			Load = function(idx, data)
				if SaveManager.Library.Options[idx] then
					SaveManager.Library.Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
				end
			end,
		},
		KeyPicker = {
			Save = function(idx, object)
				return { type = "KeyPicker", idx = idx, mode = object.Mode, key = object.Value }
			end,
			Load = function(idx, data)
				if SaveManager.Library.Options[idx] then
					SaveManager.Library.Options[idx]:SetValue({ data.key, data.mode })
				end
			end,
		},
		Input = {
			Save = function(idx, object)
				return { type = "Input", idx = idx, text = object.Value }
			end,
			Load = function(idx, data)
				local object = SaveManager.Library.Options[idx]
				if object and object.Value ~= data.text and type(data.text) == "string" then
					SaveManager.Library.Options[idx]:SetValue(data.text)
				end
			end,
		},
	}

	function SaveManager:SetLibrary(library)
		self.Library = library
	end

	function SaveManager:SetLoadingOrder(enabled, order)
		self.UseLoadingOrder = enabled
		if typeof(order) == "table" then
			self.LoadingOrder = order
		end
	end

	function SaveManager:IgnoreThemeSettings()
		self:SetIgnoreIndexes({
			"BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor", "FontFace",
			"ThemeManager_ThemeList", "ThemeManager_CustomThemeList", "ThemeManager_CustomThemeName",
		})
	end

	function SaveManager:SetIgnoreIndexes(list)
		for _, key in pairs(list) do
			self.Ignore[key] = true
		end
	end

	function SaveManager:CheckSubFolder(_createFolder)
		return type(self.SubFolder) == "string" and self.SubFolder ~= ""
	end

	function SaveManager:GetPaths()
		local paths = { self.Folder, self.Folder .. "/Themes", self.Folder .. "/Config" }
		if self:CheckSubFolder() then
			table.insert(paths, self.Folder .. "/Config/" .. self.SubFolder)
		end
		return paths
	end

	function SaveManager:BuildFolderTree()
		if not hasFS() then return end
		for _, path in ipairs(self:GetPaths()) do
			if not isfolder(path) then
				pcall(function() makefolder(path) end)
			end
		end
	end

	function SaveManager:CheckFolderTree()
		if not hasFS() then return true end
		for _, path in ipairs(self:GetPaths()) do
			if not isfolder(path) then
				return false
			end
		end
		return true
	end

	function SaveManager:SetFolder(folder)
		self.Folder = folder
	end

	function SaveManager:SetSubFolder(folder)
		self.SubFolder = folder
	end

	-- Load a single config from disk into memory
	function SaveManager:LoadConfigFromDisk(name)
		local key = configKey(name)
		if not hasFS() then return end
		local path = configFilePath(name)
		if not isfile(path) then return end
		local ok, raw = pcall(readfile, path)
		if not (ok and raw) then return end
		local decodeOk, data = pcall(function() return game:GetService("HttpService"):JSONDecode(raw) end)
		if decodeOk and type(data) == "table" then
			self.Configs[key] = data
		end
	end

	-- Scan all config files from disk into memory
	function SaveManager:SyncConfigsFromDisk()
		if not hasFS() then return end
		local settingsDir = self.Folder .. "/Config"
		if not isfolder(settingsDir) then return end

		if self:CheckSubFolder() then
			local subDir = settingsDir .. "/" .. self.SubFolder
			if not isfolder(subDir) then return end
			local ok, files = pcall(listfiles, subDir)
			if not ok then return end
			for _, path in ipairs(files) do
				if path:sub(-5) == ".json" then
					local fileName = path:match("([^/\\]+)%.json$")
					if fileName then
						self:LoadConfigFromDisk(fileName)
					end
				end
			end
		else
			local ok, files = pcall(listfiles, settingsDir)
			if not ok then return end
			for _, path in ipairs(files) do
				local statOk, stat = pcall(function() return delfile end) -- nop, just checking
				-- Check if path ends with .json and is a file, not a directory
				if path:sub(-5) == ".json" then
					local fileName = path:match("([^/\\]+)%.json$")
					if fileName then
						self:LoadConfigFromDisk(fileName)
					end
				end
			end
		end
	end

	function SaveManager:Save(name)
		if not name then
			return false, "no config file is selected"
		end

		local data = { objects = {} }

		for idx, toggle in pairs(self.Library.Toggles) do
			if not toggle.Type then continue end
			if not self.Parser[toggle.Type] then continue end
			if self.Ignore[idx] then continue end
			table.insert(data.objects, self.Parser[toggle.Type].Save(idx, toggle))
		end

		for idx, option in pairs(self.Library.Options) do
			if not option.Type then continue end
			if not self.Parser[option.Type] then continue end
			if self.Ignore[idx] then continue end
			table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
		end

		local key = configKey(name)
		self.Configs[key] = data

		if hasFS() then
			pcall(self.BuildFolderTree, self)
			local ok, json = pcall(function() return game:GetService("HttpService"):JSONEncode(data) end)
			if ok and json then
				pcall(writefile, configFilePath(name), json)
			end
		end
		return true
	end

	function SaveManager:Load(name)
		if not name then
			return false, "no config file is selected"
		end

		local key = configKey(name)

		-- Try loading from disk into memory first
		self:LoadConfigFromDisk(name)

		local data = self.Configs[key]
		if not data then
			return false, "invalid file"
		end

		if self.UseLoadingOrder == true and type(self.LoadingOrder) == "table" then
			table.sort(data.objects, function(a, b)
				local aIndex = table.find(self.LoadingOrder, a.type) or math.huge
				local bIndex = table.find(self.LoadingOrder, b.type) or math.huge
				return aIndex < bIndex
			end)
		end

		for _, option in ipairs(data.objects) do
			if not option.type then continue end
			if not self.Parser[option.type] then continue end
			if self.Ignore[option.idx] then continue end
			task.spawn(self.Parser[option.type].Load, option.idx, option)
		end

		return true
	end

	function SaveManager:Delete(name)
		if not name then
			return false, "no config file is selected"
		end

		local key = configKey(name)
		self.Configs[key] = nil

		if hasFS() then
			local path = configFilePath(name)
			if isfile(path) then
				pcall(delfile, path)
			end
		end
		return true
	end

	function SaveManager:RefreshConfigList()
		self:SyncConfigsFromDisk()
		local out = {}
		for key, _ in pairs(self.Configs) do
			-- If SubFolder is set, only show keys that start with SubFolder .. "/"
			if self:CheckSubFolder() then
				local prefix = self.SubFolder .. "/"
				if key:sub(1, #prefix) == prefix then
					table.insert(out, key:sub(#prefix + 1))
				end
			else
				if not key:find("/") then
					table.insert(out, key)
				end
			end
		end
		table.sort(out)
		return out
	end

	-- Auto load
	SaveManager.AutoloadConfigName = nil

	function SaveManager:GetAutoloadConfig()
		return self.AutoloadConfigName or "none"
	end

	function SaveManager:LoadAutoloadConfig()
		-- Try reading from disk
		if hasFS() then
			local path = autoloadFilePath()
			if isfile(path) then
				local ok, raw = pcall(readfile, path)
				if ok and raw and raw ~= "" then
					self.AutoloadConfigName = raw
				end
			end
		end

		local name = self.AutoloadConfigName
		if name then
			local success, err = self:Load(name)
			if success then
				if self.Library then
					self.Library:Notify(string.format("Auto loaded config %q", name))
				end
			elseif self.Library then
				self.Library:Notify("Failed to load autoload config: " .. tostring(err))
			end
		end
	end

	function SaveManager:SaveAutoloadConfig(name)
		self.AutoloadConfigName = name
		if hasFS() then
			pcall(self.BuildFolderTree, self)
			pcall(writefile, autoloadFilePath(), tostring(name))
		end
		return true, ""
	end

	function SaveManager:DeleteAutoLoadConfig()
		self.AutoloadConfigName = nil
		if hasFS() then
			local path = autoloadFilePath()
			if isfile(path) then
				pcall(delfile, path)
			end
		end
		return true, ""
	end

	-- GUI
	function SaveManager:BuildConfigSection(tab)
		assert(self.Library, "Must set SaveManager.Library")

		-- Build folder tree on first use
		self:BuildFolderTree()

		local section = tab:AddRightGroupbox("Configuration")

		section:AddInput("SaveManager_ConfigName", { Text = "Config name" })
		section:AddButton("Create config", function()
			local name = self.Library.Options.SaveManager_ConfigName.Value
			if name:gsub(" ", "") == "" then
				self.Library:Notify("Invalid config name (empty)", 2)
				return
			end
			local success, err = self:Save(name)
			if not success then
				self.Library:Notify("Failed to create config: " .. tostring(err))
				return
			end
			self.Library:Notify(string.format("Created config %q", name))
			self.Library.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
			self.Library.Options.SaveManager_ConfigList:SetValue(nil)
		end)

		section:AddDivider()

		section:AddDropdown("SaveManager_ConfigList", { Text = "Config list", Values = self:RefreshConfigList(), AllowNull = true })
		section:AddButton("Load config", function()
			local name = self.Library.Options.SaveManager_ConfigList.Value
			local success, err = self:Load(name)
			if not success then
				self.Library:Notify("Failed to load config: " .. tostring(err))
				return
			end
			self.Library:Notify(string.format("Loaded config %q", name))
		end)
		section:AddButton("Overwrite config", function()
			local name = self.Library.Options.SaveManager_ConfigList.Value
			local success, err = self:Save(name)
			if not success then
				self.Library:Notify("Failed to overwrite config: " .. tostring(err))
				return
			end
			self.Library:Notify(string.format("Overwrote config %q", name))
		end)
		section:AddButton("Delete config", function()
			local name = self.Library.Options.SaveManager_ConfigList.Value
			local success, err = self:Delete(name)
			if not success then
				self.Library:Notify("Failed to delete config: " .. tostring(err))
				return
			end
			self.Library:Notify(string.format("Deleted config %q", name))
			self.Library.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
			self.Library.Options.SaveManager_ConfigList:SetValue(nil)
		end)
		section:AddButton("Refresh list", function()
			self.Library.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
			self.Library.Options.SaveManager_ConfigList:SetValue(nil)
		end)

		section:AddButton("Set as autoload", function()
			local name = self.Library.Options.SaveManager_ConfigList.Value
			local success, err = self:SaveAutoloadConfig(name)
			if not success then
				self.Library:Notify("Failed to set autoload config: " .. tostring(err))
				return
			end
			self.Library:Notify(string.format("Set %q to auto load", name))
		end)
		section:AddButton("Reset autoload", function()
			local success, err = self:DeleteAutoLoadConfig()
			if not success then
				self.Library:Notify("Failed to set autoload config: " .. tostring(err))
				return
			end
			self.Library:Notify("Set autoload to none")
		end)

		self:SetIgnoreIndexes({ "SaveManager_ConfigList", "SaveManager_ConfigName" })
	end
end

return SaveManager
