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

	local l_Up = Vec3(0, p_Height, 0)
	local l_FromUp = p_From + l_Up
	local l_ToUp = p_To + l_Up
	local l_Color4 = Vec4(p_Color.x, p_Color.y, p_Color.z, p_Opacity)

	DebugRenderer:DrawTriangle(p_From, l_FromUp, l_ToUp, l_Color4, l_Color4, l_Color4)
	DebugRenderer:DrawTriangle(p_From, l_ToUp, p_To, l_Color4, l_Color4, l_Color4)
end

function InnerCircleRenderer(p_From, p_To, p_DoubleDist, p_DoubleDrawDistance)
	local l_Opacity = 0.32
	if p_DoubleDist > 200 then
		l_Opacity = MathUtils:Lerp(0, l_Opacity, 1 - (math.min(1.0, p_DoubleDist / 500)))
	end

	DrawRect(p_From, p_To, 0.1, l_Opacity, s_WhiteColor)
end

function OuterCircleRenderer(p_From, p_To, p_DoubleDist, p_DoubleDrawDistance)
	-- calculate opacity based on distance
	local l_Opacity = CircleConfig.OuterCircleMaxOpacity
	if p_DoubleDist > p_DoubleDrawDistance * 0.06 then
		l_Opacity = MathUtils:Lerp(0.01, l_Opacity, 1 - EasedValue(math.min(1.0, (p_DoubleDist / p_DoubleDrawDistance) * 1.4)))
	end

	-- height of lower rect
	local l_Height = 0.08
	local l_Up = Vec3(0, l_Height, 0)

	-- draw lower and upper rects
	DrawRect(p_From + l_Up, p_To + l_Up, CircleConfig.Height, l_Opacity, s_OuterCircleColor)
	DrawRect(p_From, p_To, l_Height, l_Opacity * 3, s_OuterCircleColor)
end
