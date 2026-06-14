--[[
	Save Manager addon for Galax-Obsidian-Lib (Matcha)
	Based on Obsidian's SaveManager, adapted for Matcha's limited environment.
	No filesystem functions - configs are stored in memory only.
]]

local SaveManager = {} do
	SaveManager.Folder = "GalaxObsidianSettings"
	SaveManager.SubFolder = ""
	SaveManager.Ignore = {}
	SaveManager.Library = nil
	SaveManager.UseLoadingOrder = false
	SaveManager.LoadingOrder = {}

	-- In-memory config storage (keyed by config name)
	SaveManager.Configs = {}

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

	-- Folder operations are no-ops (in-memory)
	function SaveManager:CheckSubFolder(_createFolder)
		return type(self.SubFolder) == "string" and self.SubFolder ~= ""
	end

	function SaveManager:GetPaths()
		local paths = { self.Folder, self.Folder .. "/themes", self.Folder .. "/settings" }
		if self:CheckSubFolder() then
			table.insert(paths, self.Folder .. "/settings/" .. self.SubFolder)
		end
		return paths
	end

	function SaveManager:BuildFolderTree() end
	function SaveManager:CheckFolderTree() end

	function SaveManager:SetFolder(folder)
		self.Folder = folder
	end

	function SaveManager:SetSubFolder(folder)
		self.SubFolder = folder
	end

	-- Save/Load/Delete/Refresh (in-memory)
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

		local key = name
		if self:CheckSubFolder() then
			key = self.SubFolder .. "/" .. name
		end

		self.Configs[key] = data
		return true
	end

	function SaveManager:Load(name)
		if not name then
			return false, "no config file is selected"
		end

		local key = name
		if self:CheckSubFolder() then
			key = self.SubFolder .. "/" .. name
		end

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

		local key = name
		if self:CheckSubFolder() then
			key = self.SubFolder .. "/" .. name
		end

		if not self.Configs[key] then
			return false, "invalid file"
		end

		self.Configs[key] = nil
		return true
	end

	function SaveManager:RefreshConfigList()
		local out = {}
		for key, _ in pairs(self.Configs) do
			table.insert(out, key)
		end
		table.sort(out)
		return out
	end

	-- Auto load (in-memory)
	SaveManager.AutoloadConfigName = nil

	function SaveManager:GetAutoloadConfig()
		return self.AutoloadConfigName or "none"
	end

	function SaveManager:LoadAutoloadConfig()
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
		return true, ""
	end

	function SaveManager:DeleteAutoLoadConfig()
		self.AutoloadConfigName = nil
		return true, ""
	end

	-- GUI
	function SaveManager:BuildConfigSection(tab)
		assert(self.Library, "Must set SaveManager.Library")

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
