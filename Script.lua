local CamConfig = {
	CamSmooth = true,
	CamSmoothDelay = 0,
	CamDuration = 1.5
}

local isExecuting = false
local dashStartTime = 0
local camSmoothConn = nil
local _wasAttachedByScript = false
local _prevCamSubject = nil

local function updateCamSmooth(isEnabled)
	if camSmoothConn then
		camSmoothConn:Disconnect()
		camSmoothConn = nil
	end
	if not isEnabled then
		if _wasAttachedByScript then
			pcall(function()
				local char = LP.Character
				Camera.CameraType = Enum.CameraType.Custom
				Camera.CameraSubject = _prevCamSubject or (char and char:FindFirstChildOfClass("Humanoid"))
			end)
			_wasAttachedByScript = false
		end
		return
	end

	camSmoothConn = RunService.RenderStepped:Connect(function(dt)
		local char = LP.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local cam = workspace and workspace.CurrentCamera
		if not root or not cam then return end

		local now = os.clock()
		local elapsed = now - dashStartTime
		local inSmoothWindow = isExecuting and (elapsed >= CamConfig.CamSmoothDelay) and (elapsed <= CamConfig.CamSmoothDelay + CamConfig.CamDuration)

		if not inSmoothWindow then
			if _wasAttachedByScript then
				pcall(function()
					cam.CameraType = Enum.CameraType.Custom
					cam.CameraSubject = _prevCamSubject or (char:FindFirstChildOfClass("Humanoid"))
				end)
				_wasAttachedByScript = false
			end
			return
		end

		if not _wasAttachedByScript then
			_prevCamSubject = cam.CameraSubject
			_wasAttachedByScript = true
		end
		pcall(function()
			cam.CameraType = Enum.CameraType.Attach
			cam.CameraSubject = root
		end)
	end)
end

local function onDashStart()
	isExecuting = true
	dashStartTime = os.clock()
	updateCamSmooth(CamConfig.CamSmooth)
end

local function onDashEnd()
	isExecuting = false
	updateCamSmooth(CamConfig.CamSmooth)
end
