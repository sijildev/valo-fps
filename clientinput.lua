--Client-Sided Input Handler
--// Roblox Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

--// Variables
local Player = Players.LocalPlayer

--// Folders
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

--// Remotes
local InputRemote = Remotes:WaitForChild("Input")

--// Booleans
local MouseDown = false

--// Tables
local ValidKeys = {
	Enum.UserInputType.MouseButton1,
	Enum.KeyCode.LeftControl,
	Enum.KeyCode.LeftShift,
	Enum.KeyCode.V,
	Enum.KeyCode.R
}

local InputServiceClient = {}

function InputServiceClient.CalculateRaycast()
	local MouseLocation = UserInputService:GetMouseLocation()
	local Camera = workspace.CurrentCamera
	local UnitRay = Camera:ViewportPointToRay(MouseLocation.X, MouseLocation.Y)
	
	return {
		Origin = UnitRay.Origin,
		Direction = UnitRay.Direction
	}
end

UserInputService.InputBegan:Connect(function(Input, GameProcessed)
	if GameProcessed then return end
	if table.find(ValidKeys, Input.UserInputType) or table.find(ValidKeys, Input.KeyCode) then
		InputRemote:FireServer("Begin",{
			InputType = Input.UserInputType,
			KeyCode = Input.KeyCode
		}
		, InputServiceClient.CalculateRaycast(),
		Player:GetMouse().Hit
		)
	end
	if Input.UserInputType == Enum.UserInputType.MouseButton1 then
		MouseDown = true
	end
end)

UserInputService.InputEnded:Connect(function(Input, GameProcessed)
	if GameProcessed then return end
	if table.find(ValidKeys, Input.UserInputType) or table.find(ValidKeys, Input.KeyCode) then
		InputRemote:FireServer("End",{
			InputType = Input.UserInputType,
			KeyCode = Input.KeyCode
		})
	end
	if Input.UserInputType == Enum.UserInputType.MouseButton1 then
		MouseDown = false
	end
end)

--// Full Auto Connection
RunService.Heartbeat:Connect(function()
	if MouseDown then
		InputRemote:FireServer("Begin",{
			InputType = Enum.UserInputType.MouseButton1,
			KeyCode = nil
		}
		, InputServiceClient.CalculateRaycast(),
		Player:GetMouse().Hit
		)
	end
end)

type InputServiceClient = typeof(InputServiceClient)

return InputServiceClient :: InputServiceClient
