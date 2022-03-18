---@class AirdropSmokeModifier
AirdropSmokeModifier = class "AirdropSmokeModifier"

local m_SmokeColorData = DC(Guid("5CE988C3-6622-11DE-9DCF-A96EA7FB2539"), Guid("0302E7F2-51CE-4089-817C-2DCDC9114BF4"))

local m_Logger = Logger("AirdropSmokeModifier", false)

function AirdropSmokeModifier:RegisterCallbacks()
	m_SmokeColorData:RegisterLoadHandler(self, self.ModifySmokeColorData)
end

function AirdropSmokeModifier:DeregisterCallbacks()
	m_SmokeColorData:Deregister()
end

function AirdropSmokeModifier:ModifySmokeColorData(p_PolynomialColorInterpData)
	p_PolynomialColorInterpData.color0 = Vec3(0.9, 0.1, 0.1)
	p_PolynomialColorInterpData.color1 = Vec3(0.8, 0.1, 0.1)
	p_PolynomialColorInterpData.coefficients = Vec4(0.0, 0.0, -1.3197676, 1.0089285)
	m_Logger:Write("Airdrop smoke modified.")
end

return AirdropSmokeModifier()
