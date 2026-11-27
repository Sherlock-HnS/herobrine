local EFFECT = {}

local matBeam = Material("effects/tool_tracer")
local matGlow = Material("sprites/light_glow02_add")

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.StartPos = self.Pos + Vector(0, 0, 1200)
    self.DieTime = CurTime() + 0.25

    local dlight = DynamicLight(self:EntIndex())
    if dlight then
        dlight.pos = self.Pos
        dlight.r = 255
        dlight.g = 255
        dlight.b = 255
        dlight.brightness = 6
        dlight.Decay = 1200
        dlight.Size = 1200
        dlight.DieTime = CurTime() + 0.2
    end

    util.ScreenShake(self.Pos, 15, 200, 0.5, 1000)

    local effectdata = EffectData()
    effectdata:SetOrigin(self.Pos)
    util.Effect("cball_explode", effectdata)
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
    render.SetMaterial(matBeam)

    render.DrawBeam(self.StartPos, self.Pos, 30, 0, 1, Color(255, 255, 255))

    for i = 1, 5 do
        local offset = VectorRand() * 80
        render.DrawBeam(
            self.StartPos + VectorRand() * 50,
            self.Pos + offset,
            math.random(8, 16),
            0,
            1,
            Color(255, 255, 255, 200)
        )
    end

    render.SetMaterial(matGlow)
    render.DrawSprite(self.Pos, 220, 220, Color(255, 255, 255, 255))
end

effects.Register(EFFECT, "Herobrine_thunder_red")
