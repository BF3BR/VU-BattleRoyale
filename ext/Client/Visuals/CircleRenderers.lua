local l_WhiteColor = Vec3(1, 1, 1)
local l_BlueColor = Vec3(0, 0, 1)

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

-- 
function InnerCircleRenderer(p_From, p_To, p_DoubleDist)
    local l_Opacity = 0.32
    if p_DoubleDist > 200 then l_Opacity = MathUtils:Lerp(0, 0.32, 1 - (math.min(1.0, p_DoubleDist / 500))) end

    DrawRect(p_From, p_To, 0.1, l_Opacity, l_WhiteColor)
end

-- 
function OuterCircleRenderer(p_From, p_To, p_DoubleDist)
    local l_Opacity = 0.16
    if p_DoubleDist > 250 then l_Opacity = MathUtils:Lerp(0, 0.16, 1 - (math.min(1.0, p_DoubleDist / 600))) end

    local l_Up = Vec3(0, 0.2, 0)
    DrawRect(p_From + l_Up, p_To + l_Up, 20, l_Opacity, l_BlueColor)
    DrawRect(p_From, p_To, 0.2, l_Opacity * 1.5, l_BlueColor)
end
