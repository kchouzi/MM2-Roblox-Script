local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Extras = Remotes:WaitForChild("Extras")

local Player = Players.LocalPlayer

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({
	Title = "MM2 - " .. "1.0.0",
	SubTitle = "by @kchouzi",
	TabWidth = 200,
	Size = UDim2.fromOffset(580, 460),
	Acrylic = true,
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
	Menu = Window:AddTab({ Title = "Menu", Icon = "square-menu" }),
	Visual = Window:AddTab({ Title = "Visual", Icon = "eye" })
}

local Config = {
	HighlightTransparency = 0.7,
	
	RoleColor = {
		["Murderer"] = Color3.fromRGB(255, 0, 0),

		["Sheriff"] = Color3.fromRGB(0, 0, 255),

		["Hero"] = Color3.fromRGB(255, 255, 0),

		["Innocent"] = Color3.fromRGB(0, 255, 0),

		["Lobby"] = Color3.fromRGB(200, 200, 200),
	}
}

local Options = Fluent.Options

Fluent:Notify({
	Title = "Notification",
	Content = "Successful loaded!",
	SubContent = "Thanks for using",
	Duration = 5
})

do
	do  --Menu
		Tabs.Menu:AddSection("Welcome, @" .. Player.Name)

		Tabs.Menu:AddParagraph({
			Title = "Information",
			Content = "Name - @" .. Player.Name .. "\nDisplay Name - " .. Player.DisplayName .. "\nUser Id - " .. Player.UserId
		})

		Tabs.Menu:AddParagraph({
			Title = "Experimental",
			Content = "ESP - Testing Stage"
		})
	end

	do --Visual
		local ESP_Section = Tabs.Visual:AddSection("ESP - experimental")

		do 
			local function Update()
				local Roles = Extras:WaitForChild("GetPlayerData"):InvokeServer()

				for _,v in pairs(Players:GetPlayers()) do
					local Character = v.Character or v.CharacterAdded:Wait()

					if Character then
						local Highlight = Character:FindFirstChildWhichIsA("Highlight") or Instance.new("Highlight", Character)
						Highlight.Name = "ESP_bykchouzi"
						Highlight.FillColor = Config.RoleColor.Lobby
						Highlight.FillTransparency = Config.HighlightTransparency
						Highlight.OutlineTransparency = 1
						Highlight.Adornee = Character

						if Roles then
							local UserData = Roles[v.Name]

							local s, e = pcall(function()
								return UserData.Role
							end)

							if s then
								local RoleName = UserData.Role

								Highlight.FillColor = Config.RoleColor[RoleName]
							end
						end
					end
				end
			end

			local function Deinitialize()
				for _,v in pairs(Players:GetPlayers()) do
					local Character = v.Character or v.CharacterAdded:Wait()

					if Character then
						if Character:FindFirstChildWhichIsA("Highlight") then
							local Highlight = Character:FindFirstChildWhichIsA("Highlight")
							Highlight:Destroy()
						end
					end
				end
			end

			local ESP_Enable = ESP_Section:AddToggle("ESP_Enable", {
				Title = "Enable",
				Default = false
			})
			ESP_Enable:OnChanged(function()
				if Options.ESP_Enable.Value then
					Update()

					task.spawn(function()
						while wait(0.1) and Options.ESP_Enable.Value and not Fluent.Unloaded do
							Update()
						end

						Deinitialize()
					end)
				end
			end)
		end
		
		do
			local Table = {}
			for i,_ in pairs(Config.RoleColor) do
				table.insert(Table, i)
			end
			
			local Dropdown = ESP_Section:AddDropdown("Dropdown", {
				Title = "Dropdown",
				Values = Table,
				Default = 1,
			})
			local TColorpicker = Tabs.Visual:AddColorpicker("TransparencyColorpicker", {
				Title = "Colorpicker",
				Default = Config.RoleColor[Dropdown.Value],
				Transparency = Config.HighlightTransparency
			})
			
			Dropdown:OnChanged(function(Value)
				TColorpicker:SetValueRGB(Config.RoleColor[Value], Config.HighlightTransparency)
			end)

			TColorpicker:OnChanged(function()
				Config.RoleColor[Dropdown.Value] = TColorpicker.Value
				Config.HighlightTransparency = TColorpicker.Transparency
			end)
		end
	end
end

Window:SelectTab("Menu")
