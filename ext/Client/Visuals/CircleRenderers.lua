require "__shared/Configs/CircleConfig"

local s_EasingFunctions = require "__shared/Libs/easing"
local s_WhiteColor = Vec3(1, 1, 1)
local s_BlueColor = Vec3(0.1, 0.3, 1)
local s_OrangeColor = Vec3(1, 0.45, 0)
local s_OuterCircleColor = s_OrangeColor

function EasedValue(t)
	return s_EasingFunctions.inOutQuad(t, 0, 1, 1)
end

-- Draws a Rectangle using DebugRenderer
function DrawRect(p_From, p_To, p_Height, p_Opacity, p_Color)
	p_Height = p_Height or 1
	p_Opacity = p_Opacity or 0.25
	p_Color = p_Color or Vec3(1, 1, 1)

	local s_Up = Vec3(0, p_Height, 0)
	local s_FromUp = p_From + s_Up
	local s_ToUp = p_To + s_Up
	local s_Color4 = Vec4(p_Color.x, p_Color.y, p_Color.z, p_Opacity)

	DebugRenderer:DrawTriangle(p_From, s_FromUp, s_ToUp, s_Color4, s_Color4, s_Color4)
	DebugRenderer:DrawTriangle(p_From, s_ToUp, p_To, s_Color4, s_Color4, s_Color4)
end

function InnerCircleRenderer(p_From, p_To, p_DoubleDist, p_DoubleDrawDistance)
	local s_Opacity = 0.32
	if p_DoubleDist > 200 then
		s_Opacity = MathUtils:Lerp(0, s_Opacity, 1 - (math.min(1.0, p_DoubleDist / 500)))
	end

	DrawRect(p_From, p_To, 0.1, s_Opacity, s_WhiteColor)
end

function OuterCircleRenderer(p_From, p_To, p_DoubleDist, p_DoubleDrawDistance)
	-- calculate opacity based on distance
	local s_Opacity = CircleConfig.OuterCircleMaxOpacity
	if p_DoubleDist > p_DoubleDrawDistance * 0.06 then
		s_Opacity = MathUtils:Lerp(0.01, s_Opacity, 1 - EasedValue(math.min(1.0, (p_DoubleDist / p_DoubleDrawDistance) * 1.4)))
	end

	-- height of lower rect
	local s_Height = 0.08
	local s_Up = Vec3(0, s_Height, 0)

	-- draw lower and upper rects
	DrawRect(p_From + s_Up, p_To + s_Up, CircleConfig.Height, s_Opacity, s_OuterCircleColor)
	DrawRect(p_From, p_To, s_Height, s_Opacity * 3, s_OuterCircleColor)
end
