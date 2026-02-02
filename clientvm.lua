// Client View Model Loop
--// Roblox Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Folders
local Assets = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

--// Remotes
local EquipRemote = Remotes:WaitForChild("Equip")
local FireRemote = Remotes:WaitForChild("Fire")

--// Connections
local WeaponUpdateConnection = nil

local FPSServiceClient = {}

function FPSServiceClient:EquipWeapon(WeaponName)
	local WeaponModel = Assets:WaitForChild("Models"):WaitForChild("Weapons"):WaitForChild(WeaponName)
	if WeaponModel then
		WeaponModel.Parent = game.Workspace.Camera
		EquipRemote:FireServer(WeaponName)
		WeaponModel:ScaleTo(0.1)
		
		local baseOffset = CFrame.new(0.8, -1, -1.5) 
		local lastCameraCF = workspace.CurrentCamera.CFrame
		local swayOffset = CFrame.new()
		local mult = 1
		
		function FPSServiceClient:AddRecoil(recoilX, recoilY, recoilZ)
			swayOffset = swayOffset * CFrame.Angles(math.rad(recoilX), math.rad(recoilY), 0)
			swayOffset = swayOffset * CFrame.new(0, 0, recoilZ or -0.1)
		end

		WeaponUpdateConnection = RunService.RenderStepped:Connect(function()
			
			local camera = workspace.CurrentCamera
			local rotationDelta = camera.CFrame:ToObjectSpace(lastCameraCF)
			local x, y, z = rotationDelta:ToOrientation()

			swayOffset = swayOffset:Lerp(CFrame.Angles(math.sin(x)*mult, math.sin(y)*mult, 0), 0.1)

			WeaponModel:SetPrimaryPartCFrame((camera.CFrame * baseOffset * swayOffset) * CFrame.Angles(math.rad(0), math.rad(180), 0)) 

			lastCameraCF = camera.CFrame
		end)
	end

end


FireRemote.OnClientEvent:Connect(function()
	
	FPSServiceClient:AddRecoil(1, 0, 0.35)
	
end)

--// Test Function
FPSServiceClient:EquipWeapon("Vandal")

type FPSServiceClient = typeof(FPSServiceClient)

return FPSServiceClient :: FPSServiceClient
