local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local Lobby = workspace:WaitForChild("Lobby")
local Spawns = Lobby:WaitForChild("Spawns")
local Spawn = Spawns:WaitForChild("SpawnLocation")

local Iris = loadstring(game:HttpGet("https://raw.githubusercontent.com/kchouzi/Iris-UI-Library-for-Exploits/refs/heads/main/lib/init.lua"))().Init(game.CoreGui)

local Config = {
	AutoFarm = {
		Enabled = false,
		TeleportCooldown = 2,
		TargetCoins = {
			Coin = false,
			SnowToken = false,
		};
		AntiAFK = true,
	}
}
local A_1 = tick()

local function GetCharacter()
	local Character = Player.Character
	
	if Character then
		local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

		if HumanoidRootPart then
			return Character, HumanoidRootPart
		end
	end
end

local function CollectCoin(Coin: BasePart)
	repeat task.wait()
		local Character, HumanoidRootPart = GetCharacter()
		
		if Character and HumanoidRootPart then
			HumanoidRootPart.CFrame = Coin.CFrame * CFrame.new(0, Random.new():NextNumber(-1, 1), 0)
		end
	until Iris.Disabled or not Config.AutoFarm.Enabled or Coin:GetAttribute("Collected")
end

local function GoToLobby()
	local Character, HumanoidRootPart = GetCharacter()
	
	if Character and HumanoidRootPart then
		HumanoidRootPart.CFrame = Spawn.CFrame * CFrame.new(0, Character:GetExtentsSize().Y/2, 0)
	end
end

Iris:Connect(function()
	Iris.Window({"MM2 AutoFarm - v1.0.0hlw"})
	do
		Iris.SeparatorText({"Main"})
		do
			local AutoFarmEnabled_Checkbox = Iris.Checkbox({"AutoFarm Enabled"}, {isChecked = Config.AutoFarm.Enabled})
			if AutoFarmEnabled_Checkbox.checked() or AutoFarmEnabled_Checkbox.unchecked() then
				Config.AutoFarm.Enabled = AutoFarmEnabled_Checkbox.state.isChecked.value
				
				if Config.AutoFarm.Enabled then
					task.spawn(function()
						while task.wait() and not Iris.Disabled and Config.AutoFarm.Enabled do
							local CoinContainer = workspace:FindFirstChild("CoinContainer", true)
							
							if tick()-A_1 >= Config.AutoFarm.TeleportCooldown and CoinContainer then
								for _,v in pairs(CoinContainer:GetChildren()) do
									if v:IsA("BasePart") then
										local CoinID = v:GetAttribute("CoinID")
										
										if CoinID and not v:GetAttribute("Collected") then
											local Index = Config.AutoFarm.TargetCoins[CoinID]
											
											if Index then
												CollectCoin(v)
												
												A_1 = tick()
												
												break
											end
										end
									end
								end
							else
								GoToLobby()
							end
						end
					end)
				end
			end

			local TeleportCooldown_InputNum = Iris.InputNum({"Teleport Cooldown", 0.01, 0}, {number = Config.AutoFarm.TeleportCooldown})
			local Warning_Text = Iris.TextColored({"You can be kicked", Color3.fromRGB(255, 0 ,0)})
			local Success, Number = pcall(function()
				return TeleportCooldown_InputNum.state.number.value
			end)

			if Success and Number then
				Config.AutoFarm.TeleportCooldown = Number

				if Number < 1.85 then
					Warning_Text.Instance.Visible = true
				else
					Warning_Text.Instance.Visible = false
				end
			end
		end

		Iris.SeparatorText({"Target Coins"})
		do
			local TargetCoins = Config.AutoFarm.TargetCoins

			for i,v in pairs(TargetCoins) do
				local Selectable = Iris.Selectable({i}, {index = v})
				if Selectable.clicked() then
					TargetCoins[i] = Selectable.state.index.value
				end
			end
		end

		Iris.SeparatorText({"Misc"})
		do 
			local AntiAFK_Checkbox = Iris.Checkbox({"Anti AFK"}, {isChecked = Config.AutoFarm.AntiAFK})
			if AntiAFK_Checkbox.checked() or AntiAFK_Checkbox.unchecked() then
				Config.AutoFarm.AntiAFK = AntiAFK_Checkbox.state.isChecked.value
			end
		end
	end
	Iris.End()
end)

Player.Idled:Connect(function()
	if Config.AutoFarm.AntiAFK then
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end
end)
