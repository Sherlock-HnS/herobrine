AddCSLuaFile()


hook.Add("OnEntityCreated", "herobrine_redimated_pill_initialize", function(ent)
    timer.Simple(0.00, function()
        if !IsValid(ent) then return end
        if ent:GetClass() == "pill_ent_costume" then
            if not ent then return end
            if ent.formTable then
                local PuppetEntity = ent:GetPuppet()
                local entityply = ent:GetPillUser()
                local hookName = "ThinkHookForEntity_herobrine_redimated_" .. ent:EntIndex()

                if ent.formTable.think_noodles_herobrine_redimated_pill then
                    hook.Add("Think", hookName, function()
                        if not IsValid(ent) then
                            hook.Remove("Think", hookName)
                            return
                        end

                        local ply = ent:GetPillUser()
                        local puppet = ent:GetPuppet()

                        if not IsValid(puppet) or not IsValid(ply) then
                            hook.Remove("Think", hookName)
                            return
                        end

                        ent.formTable.think_noodles_herobrine_redimated_pill(ply, ent)
                    end)
                end


                if ent.formTable.herobrine_redimated_pill_initialize then
                    local tablevarable = {["player"] = entityply, ["entity"] = ent, ["puppet"] = PuppetEntity}
                    timer.Simple(0.1, function()
                        if !IsValid(ent) then return end
                        ent.formTable:herobrine_redimated_pill_initialize(tablevarable,tablevarable,tablevarable)


                        local self = ent
                        self.formTable = pk_pills.getPillTable(self:GetPillForm())
                        local ply = self:GetPillUser()

                        if not self.formTable or not IsValid(ply) then
                            self:Remove()

                            return
                        end

                        local hull = self.formTable.hull or Vector(32, 32, 72)
                        local duckBy = self.formTable.duckBy or (self.formTable.hull and 0 or 36)
                        ply:SetHull(-Vector(hull.x / 2, hull.y / 2, 0), Vector(hull.x / 2, hull.y / 2, hull.z))
                        ply:SetHullDuck(-Vector(hull.x / 2, hull.y / 2, 0), Vector(hull.x / 2, hull.y / 2, hull.z - duckBy or 0))--
                        ply:SetRenderMode(RENDERMODE_NONE)
                        pk_pills.mapEnt(ply, nil)

                        if SERVER then
                            if ply:FlashlightIsOn() then
                                ply:Flashlight(false)
                            end

                            ply:Freeze(false)
                            ply:SetNotSolid(false)
                            ply:DrawViewModel(false)

                            local camOffset = self.formTable.camera and self.formTable.camera.offset or Vector(0, 0, 64)
                            --clside this?
                            ply:SetStepSize(hull.z / 4)
                            ply:SetViewOffset(camOffset)
                            ply:SetViewOffsetDucked(camOffset - Vector(0, 0, duckBy))
                        end
                        pk_pills.mapEnt(ply, self)

                    end)

                    local self = ent
                    ent.Think = function()
                        local currentanim = 'idle'
                        local ply = self:GetPillUser()
                        local puppet = self:GetPuppet()
                        if not IsValid(puppet) or not IsValid(ply) then return end
                        local vel = ply:GetVelocity():Length()

                        if SERVER then

                            if self.formTable.cloak then
                                local cloak = self.formTable.cloak

                                if self.iscloaked then
                                    local cloakamt = self:GetCloakLeft()

                                    if cloakamt ~= -1 then
                                        cloakamt = cloakamt - FrameTime()

                                        if cloakamt < 0 then
                                            cloakamt = 0
                                            self:ToggleCloak()
                                        end

                                        self:SetCloakLeft(cloakamt)
                                    end
                                else
                                    local cloakamt = self:GetCloakLeft()

                                    if cloakmt ~= -1 and cloakamt < cloak.max then
                                        cloakamt = cloakamt + FrameTime() * cloak.rechargeRate

                                        if cloakamt > cloak.max then
                                            cloakamt = cloak.max
                                        end

                                        self:SetCloakLeft(cloakamt)
                                    end
                                end

                                local color = self:GetPuppet():GetColor()

                                if self.iscloaked then
                                    if color.a > 0 then
                                        color.a = color.a - 5
                                        self:GetPuppet():SetColor(color)
                                    end
                                else
                                    if color.a < 255 then
                                        color.a = color.a + 5
                                        self:GetPuppet():SetColor(color)
                                    end
                                end

                                --PrintTable(color)
                                if IsValid(self.wepmdl) and self.wepmdl:GetColor().a ~= color.a then
                                    self.wepmdl:SetColor(color)
                                end
                            end
                            --Anims
                            local anims = table.Copy(self.formTable.anims.default or {})
                            table.Merge(anims, (IsValid(ply:GetActiveWeapon()) and self.formTable.anims[ply:GetActiveWeapon():GetHoldType()]) or (self.forceAnimSet and self.formTable.anims[self.forceAnimSet]) or {})
                            local anim
                            --local useSeqVel=true
                            local overrideRate

                            if (not self.anim or not anims[self.anim]) then
                                self.animFreeze = nil
                                self.animStart = nil
                            end

                            if self.animFreeze and not self.plyFrozen then
                                self:ApplyMoveSpeed()
                                self.plyFrozen = true
                            elseif not self.animFreeze and self.plyFrozen then
                                self:ApplyMoveSpeed()
                                self.plyFrozen = nil
                            end

                            if self.anim and anims[self.anim] then
                                anim = anims[self.anim]
                                overrideRate = anims[self.anim .. "_rate"] or 1
                                local cycle = puppet:GetCycle()

                                if not self.animStart then
                                    if cycle == 1 or (self.animCycle and self.animCycle > cycle) or (string.lower(anim) ~= string.lower(puppet:GetSequenceName(puppet:GetSequence()))) then
                                        self.anim = nil
                                        self.animCycle = nil

                                        if self.animFreeze then
                                            self.animFreeze = nil
                                        end
                                    elseif self.animCycle then
                                        self.animCycle = cycle
                                    end
                                end
                            elseif self.tickAnim and anims[self.tickAnim] then
                                anim = anims[self.tickAnim]
                                overrideRate = anims[self.tickAnim .. "_rate"] or 1
                                self.tickAnim = nil
                            elseif self.burrowed then
                                anim = anims["burrow_loop"]
                            elseif ply:WaterLevel() > 2 then
                                anim = anims["swim"] or anims["glide"] or anims["idle"]
                            elseif ply:IsOnGround() then
                                if ply:Crouching() then
                                    if vel > ply:GetCrouchedWalkSpeed() / 4 then
                                        anim = anims["crouch_walk"] or anims["crouch"] or anims["walk"] or anims["idle"]
                                    else
                                        anim = anims["crouch"] or anims["idle"]
                                    end
                                else
                                    if vel > (ply:GetWalkSpeed() + ply:GetRunSpeed()) / 2 then
                                        anim = anims["run"] or anims["walk"] or anims["idle"]
                                    elseif vel > ply:GetWalkSpeed() / 4 then
                                        anim = anims["walk"] or anims["idle"]
                                    else
                                        anim = anims["idle"]
                                    end
                                end
                            else
                                anim = anims["glide"] or anims["idle"]
                            end

                            if anim == anims["idle"] or anim == anims["crouch"] then
                                overrideRate = 1
                            end
                            self:SetNWString("Animlastplayed", anim)

                            local ShouldAlternate = table.Copy(self.formTable.anims.ShouldAlternate or {})
                            if type(ShouldAlternate[anim]) == "function" and ShouldAlternate[anim](self) then
                                if ShouldAlternate[anim](self) ~= nil and isstring(ShouldAlternate[anim](self)) then
                                    
                                    anim = ShouldAlternate[anim](self)
                                end
                            end

                            if (anim and puppet:GetSequence() ~= puppet:LookupSequence(anim)) or self.animStart or (self.formTable.autoRestartAnims and puppet:GetCycle() == 1) then
                                if self.currentanim ~= anim then
                                    puppet:ResetSequence(puppet:LookupSequence(anim))
                                    puppet:SetCycle(0)
                                    self.animCycle = 0
                                    self.currentanim = anim
                                end
                            end

                            self.animStart = nil
                            local seq_vel = puppet:GetSequenceGroundSpeed(puppet:GetSequence())

                            --if true then
                            if self.formTable.movePoseMode ~= "xy" and self.formTable.movePoseMode ~= "xy-bot" and not overrideRate then
                                
                            else
                                --puppet:SetPlaybackRate(1)
                            end

                            --print(puppet:GetCycle())
                            if self.formTable.movePoseMode then
                                --
                                if self.formTable.movePoseMode == "yaw" then
                                    local move_dir = puppet:WorldToLocalAngles(ply:GetVelocity():Angle())
                                    puppet:SetPoseParameter("move_yaw", move_dir.y)
                                elseif self.formTable.movePoseMode == "xy" then
                                    if not overrideRate then
                                        local localvel = ply:WorldToLocal(ply:GetPos() + ply:GetVelocity())
                                        local maxdim = math.Max(math.abs(localvel.x), math.abs(localvel.y))
                                        local clampedvel = maxdim == 0 and Vector(0, 0, 0) or localvel / maxdim
                                        puppet:SetPoseParameter("move_x", clampedvel.x)
                                        puppet:SetPoseParameter("move_y", -clampedvel.y)
                                        seq_vel = puppet:GetSequenceGroundSpeed(puppet:GetSequence())

                                        if seq_vel ~= 0 then
                                            puppet:SetPoseParameter("move_x", math.Clamp(localvel.x / seq_vel, -.99, .99))
                                            puppet:SetPoseParameter("move_y", math.Clamp(-localvel.y / seq_vel, -.99, .99))
                                        end
                                        --print(puppet:GetPlaybackRate())
                                    else
                                        puppet:SetPoseParameter("move_x", 0)
                                        puppet:SetPoseParameter("move_y", 0)
                                    end
                                elseif self.formTable.movePoseMode == "xy-bot" then
                                    if not overrideRate then
                                        local localvel = ply:WorldToLocal(ply:GetPos() + ply:GetVelocity())
                                        local maxdim = math.Max(math.abs(localvel.x), math.abs(localvel.y))
                                        local clampedvel = maxdim == 0 and Vector(0, 0, 0) or localvel / maxdim
                                        local move_dir = puppet:WorldToLocalAngles(ply:GetVelocity():Angle())
                                        puppet:SetPoseParameter("move_x", clampedvel.x)
                                        puppet:SetPoseParameter("move_y", -clampedvel.y)
                                        puppet:SetPoseParameter("move_yaw", move_dir.y)
                                        puppet:SetPoseParameter("move_scale", 1)
                                        seq_vel = puppet:GetSequenceGroundSpeed(puppet:GetSequence())

                                        if seq_vel ~= 0 then
                                            puppet:SetPoseParameter("move_x", math.Clamp(localvel.x / seq_vel, -.99, .99))
                                            puppet:SetPoseParameter("move_y", math.Clamp(-localvel.y / seq_vel, -.99, .99))
                                            puppet:SetPoseParameter("move_scale", math.Clamp(localvel:Length() / seq_vel, -.99, .99))
                                        end
                                        --print(puppet:GetPlaybackRate())
                                    else
                                        puppet:SetPoseParameter("move_x", 0)
                                        puppet:SetPoseParameter("move_y", 0)
                                        puppet:SetPoseParameter("move_yaw", 0)
                                        puppet:SetPoseParameter("move_scale", 0)
                                    end
                                end
                            end

                            --Aimage
                            if self.formTable.aim then
                                if self.formTable.aim.xPose then
                                    local yaw = math.AngleDifference(ply:EyeAngles().y, puppet:GetAngles().y)

                                    if self.formTable.aim.xInvert then
                                        yaw = -yaw
                                    end

                                    puppet:SetPoseParameter(self.formTable.aim.xPose, yaw)
                                end

                                if self.formTable.aim.yPose then
                                    local pitch = math.AngleDifference(ply:EyeAngles().p, puppet:GetAngles().p)

                                    if self.formTable.aim.yInvert then
                                        pitch = -pitch
                                    end

                                    puppet:SetPoseParameter(self.formTable.aim.yPose, pitch)
                                end
                            end

                            if not ply:IsOnGround() and not self.touchingWater and ply:WaterLevel() > 0 and self.formTable.land then
                                self.formTable.land(ply, self)
                            end

                            --tick attack
                            if ply:KeyDown(IN_ATTACK) and self.formTable.attack and self.formTable.attack.mode == "tick" then
                                self.formTable.attack.func(ply, self, self.formTable.attack)
                            end

                            if ply:KeyDown(IN_ATTACK2) and self.formTable.attack2 and self.formTable.attack2.mode == "tick" then
                                self.formTable.attack2.func(ply, self, self.formTable.attack2)
                            end

                            --auto attack
                            if ply:KeyDown(IN_ATTACK) and self.formTable.attack and self.formTable.attack.mode == "auto" then
                                if not self.formTable.aim then
                                    self:PillLoopSound("attack")
                                else
                                    self:PillLoopStop("attack")
                                end

                                if (not self.lastAttack or (self.formTable.attack.interval or self.formTable.attack.delay) < CurTime() - self.lastAttack) then
                                    self.formTable.attack.func(ply, self, self.formTable.attack)
                                    self.lastAttack = CurTime()
                                end
                            else
                                self:PillLoopStop("attack")
                            end

                            if ply:KeyDown(IN_ATTACK2) and self.formTable.attack2 and self.formTable.attack2.mode == "auto" then
                                if not self.formTable.aim then
                                    self:PillLoopSound("attack2")
                                else
                                    self:PillLoopStop("attack2")
                                end

                                if not self.lastAttack2 or (self.formTable.attack2.interval or self.formTable.attack2.delay) < CurTime() - self.lastAttack2 then
                                    self.formTable.attack2.func(ply, self, self.formTable.attack2)
                                    self.lastAttack2 = CurTime()
                                end
                            else
                                self:PillLoopStop("attack2")
                            end

                            --if !IsValid(ply) then self:NextThink(CurTime()) return true end
                            --wepon-no longer SO hackey
                            if not self.formTable.hideWeapons then
                                local realWep = self:GetPillUser():GetActiveWeapon()

                                --&&self:GetPillUser()!=ply or pk_pills.var_thirdperson:GetBool()) then
                                if IsValid(realWep) and realWep:GetModel() ~= "" then
                                    --hiding the real thing [BROKEN]
                                    --[[if realWep:GetRenderMode()!=RENDERMODE_NONE then
                                        realWep:SetRenderMode(RENDERMODE_NONE)
                                    end]]
                                    if realWep.pill_attachment then
                                        if IsValid(self.wepmdl) then
                                            self.wepmdl:Remove()
                                        end

                                        self.wepmdl = ents.Create("pill_attachment_wep")
                                        self.wepmdl:SetParent(self:GetPuppet())
                                        self.wepmdl:SetModel(realWep:GetModel())
                                        self.wepmdl.attachment = realWep.pill_attachment
                                        self.wepmdl:Spawn()

                                        if realWep.pill_offset then
                                            self.wepmdl:SetWepOffset(realWep.pill_offset)
                                        end

                                        if realWep.pill_angle then
                                            self.wepmdl:SetWepAng(realWep.pill_angle)
                                        end

                                        realWep.pill_proxy = self.wepmdl
                                    elseif not IsValid(self.wepmdl) then
                                        self.wepmdl = ents.Create("pill_attachment_wep")
                                        self.wepmdl:SetParent(self:GetPuppet())
                                        self.wepmdl:SetModel(realWep:GetModel())
                                        self.wepmdl:Spawn()
                                        realWep.pill_proxy = self.wepmdl
                                    elseif self.wepmdl:GetModel() ~= realWep:GetModel() then
                                        self.wepmdl:SetModel(realWep:GetModel())
                                    end
                                elseif IsValid(self.wepmdl) then
                                    self.wepmdl:Remove()
                                end
                            end
                        else
                            if self:GetPillUser() ~= LocalPlayer() or pk_pills.convars.cl_thirdperson:GetBool() then
                                puppet:SetNoDraw(false)
                            else
                                puppet:SetNoDraw(true)
                            end

                            local realWep = self:GetPillUser():GetActiveWeapon()

                            if IsValid(realWep) and realWep:GetModel() ~= "" and not realWep:GetNoDraw() then
                                realWep:SetNoDraw(true)
                            end
                        end

                        --Align pos and angles with player
                        if SERVER then
                            puppet:SetPos(ply:GetPos())
                        else
                            puppet:SetRenderOrigin(ply:GetPos())
                        end
                        
                        currentanim = self:GetNWString("Animlastplayed")

                        --if vel > 0 or math.abs(math.AngleDifference(puppet:GetAngles().y, ply:EyeAngles().y)) > 350 then

                        local animsshouldspn = table.Copy(self.formTable.anims.ShouldMoveRotate or {})
                        
                        if SERVER then
                            local rate = 1
                            local animsshouldspn = table.Copy(self.formTable.anims.animrates or {})
                            if animsshouldspn[currentanim] or (type(animsshouldspn[currentanim]) == "function" and animsshouldspn[currentanim](self)) then
                                rate = (type(animsshouldspn[currentanim]) == "function" and animsshouldspn[currentanim](self)) or animsshouldspn[currentanim]
                            end
                            if rate > 12 then
                                rate = 12
                            end
                            puppet:SetPlaybackRate(rate)
                        end
                        if animsshouldspn[currentanim] or (type(animsshouldspn[currentanim]) == "function" and animsshouldspn[currentanim](self)) then
                            
                            local typeofitem = (type(animsshouldspn[currentanim]) == "function" and animsshouldspn[currentanim](self)) or animsshouldspn[currentanim]
                            local function SetTargetAngle(ang)
                                ang.p = 0
                                puppet:SetNW2Vector("SyncAng", ang:Forward())
                            end

                            local function GetTargetAngle()
                                local dir = puppet:GetNW2Vector("SyncAng")
                                if not dir or dir == vector_origin then return nil end
                                local ang = dir:Angle()
                                if not ang then return nil end
                                ang.p = 0
                                return ang
                            end

                            if typeofitem == "notshftlock" then
                                local dir = ply:GetVelocity():GetNormalized()
                                local aheadPos = ply:GetPos() + dir * 5
                                local ang = (aheadPos - ply:GetPos()):Angle()
                                ang.p = 0
                                if ply:GetVelocity().x == 0 and ply:GetVelocity().y == 0 then
                                else
                                    if SERVER then
                                        SetTargetAngle(ang)
                                        puppet:SetAngles(ang)
                                    end

                                    if CLIENT then
                                        local targetAng = GetTargetAngle()
                                        if targetAng then
                                            local curAng = puppet:GetRenderAngles()
                                            if not curAng then curAng = targetAng end
                                            if not curAng.p then curAng = Angle(0,0,0) end
                                            local smoothAng = LerpAngle(FrameTime() * 10, curAng, targetAng)
                                            puppet:SetRenderAngles(smoothAng)
                                        end
                                    end
                                end

                            elseif typeofitem == "assignedagnles_instant" then
                                local targetAng = self:GetNWAngle("pill_assignedangle")

                                if SERVER then
                                    SetTargetAngle(targetAng)
                                    puppet:SetAngles(targetAng)
                                end

                                if CLIENT then
                                    if targetAng then
                                        puppet:SetRenderAngles(targetAng)
                                    end
                                end

                            elseif typeofitem == "shiftlock" then
                                local angs = ply:EyeAngles()
                                angs.p = 0

                                if SERVER then
                                    SetTargetAngle(angs)
                                    puppet:SetAngles(angs)
                                end

                                if CLIENT then
                                    local targetAng = GetTargetAngle()
                                    if targetAng then
                                        local curAng = puppet:GetRenderAngles()
                                        if not curAng then curAng = targetAng end
                                        if not curAng.p then curAng = Angle(0,0,0) end
                                        local smoothAng = LerpAngle(FrameTime() * 10, curAng, targetAng)
                                        puppet:SetRenderAngles(smoothAng)
                                    end
                                end

                            elseif typeofitem == "Playerangles" then
                                local angs = ply:GetAngles()
                                angs.p = 0

                                if SERVER then
                                    SetTargetAngle(angs)
                                    puppet:SetAngles(angs)
                                end

                                if CLIENT then
                                    local targetAng = GetTargetAngle()
                                    if targetAng then
                                        local curAng = puppet:GetRenderAngles()
                                        if not curAng then curAng = targetAng end
                                        if not curAng.p then curAng = Angle(0,0,0) end
                                        local smoothAng = LerpAngle(FrameTime() * 10, curAng, targetAng)
                                        puppet:SetRenderAngles(smoothAng)
                                    end
                                end

                            elseif typeofitem == "assignedagnles" then
                                local targetAng = self:GetNWAngle("pill_assignedangle")

                                if SERVER then
                                    SetTargetAngle(targetAng)
                                    puppet:SetAngles(targetAng)
                                end

                                if CLIENT then
                                    if targetAng then
                                        local curAng = puppet:GetRenderAngles()
                                        if not curAng then curAng = targetAng end
                                        if not curAng.p then curAng = Angle(0,0,0) end
                                        local smoothAng = LerpAngle(FrameTime() * 10, curAng, targetAng)
                                        puppet:SetRenderAngles(smoothAng)
                                    end
                                end

                            elseif typeofitem == "notanything" then
                            end
                        end

                        self:NextThink(CurTime())

                        return true
                    end
                end
                if ent.formTable.herobrine_redimated_OM_pill_event then
                    local PuppetEntity = ent:GetPuppet()
                    local entityply = ent:GetPillUser()

                    if IsValid(PuppetEntity) then
                        function PuppetEntity:AcceptInput(inputName, activator, caller, data)
                            ent.formTable.herobrine_redimated_OM_pill_event(entityply, ent, inputName)
                            return true
                        end
                    end
                end
            end
        end
    end)
end)

hook.Add("PlayerButtonDown", "ActivateKeybind_HERObrine_pills_noodles", function(ply, button)
    local pillentity = ply.pk_pill_ent

    if IsValid(pillentity) then
        if pillentity.formTable.herobrine_survivor_keybinds then
            pillentity.formTable.herobrine_survivor_keybinds(ply, pillentity, button)
        end
    end
end)

local function AdvancedPillSound(SoundData, ent)
    if SERVER then
        if IsValid(ent) then
            SoundData = SoundData or {}
            SoundData.stringe = SoundData.stringe or {}
            SoundData.soundLevel = SoundData.soundLevel or 75
            SoundData.pitchPercent = SoundData.pitchPercent or 100
            SoundData.volume = SoundData.volume or 1
            SoundData.channel = SoundData.channel or CHAN_AUTO
            SoundData.soundFlags = SoundData.soundFlags or 0
            SoundData.dsp = SoundData.dsp or 0
            SoundData.filter = SoundData.filter or nil

            local chosenSound = SoundData.stringe

            if istable(SoundData.stringe) then
                local index = math.random(1, #SoundData.stringe)
                chosenSound = SoundData.stringe[index]
            end

            ent:EmitSound(
                chosenSound,
                SoundData.soundLevel,
                SoundData.pitchPercent,
                SoundData.volume,
                SoundData.channel,
                SoundData.soundFlags,
                SoundData.dsp,
                SoundData.filter
            )
        end
        return true
    end
end

if SERVER then
    util.AddNetworkString('rpp_herobrine_pill_cam')
    util.AddNetworkString("rpp_herobrine_variableset")
    net.Receive("rpp_herobrine_variableset", function()
        local ply = net.ReadEntity()
        ply:SetNWFloat("_rpp_hallucinationhighlight", CurTime()+7)
    end)
else
    local fadeAmount = 0
    hook.Add("RenderScreenspaceEffects", "herobrine_effect_darken", function()
        local ply = LocalPlayer()
        local ft = FrameTime()
        if ply:GetNWFloat("_rpp_hallucinationhighlight") > CurTime() then
            fadeAmount = math.Clamp(fadeAmount + ft * 0.5, 0, 1)
        else
            fadeAmount = math.Clamp(fadeAmount - ft * 0.3, 0, 1)
        end

        if fadeAmount <= 0 then return end
        DrawColorModify({
            ["$pp_colour_addr"] = fadeAmount * 0.7,
            ["$pp_colour_addg"] = fadeAmount * 0.7,
            ["$pp_colour_addb"] = fadeAmount * 0.7,

            ["$pp_colour_brightness"] = fadeAmount * -0.8,
            ["$pp_colour_contrast"] = 1 - (fadeAmount * 0.7),
            ["$pp_colour_colour"] = 1 - (fadeAmount * 0.8),

            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        })
    end)

    net.Receive('rpp_herobrine_pill_cam', function()
        local ent = net.ReadEntity()
        local state = net.ReadBool()
        local startTime = CurTime()

        local hookID = "redimated_herobrine_cam_" .. LocalPlayer():SteamID()

        if not state then
            hook.Remove('CalcView', hookID)
        else
            hook.Add('CalcView', hookID, function(ply, pos, angles, fov)
                if not IsValid(ply) or not ply:Alive() or !IsValid(ent) then
                    hook.Remove('CalcView', hookID)
                    if IsValid(ply) then
                        ply:RemoveFlags(FL_NOTARGET)
                        ply:Freeze(false)
                        ply:DrawViewModel(true)
                    end
                    return
                end

                local cam = ent:GetAttachment(ent:LookupAttachment('camera'))

                ply:AddFlags(FL_NOTARGET)
                ply:Freeze(true)
                ply:DrawViewModel(false)

                local lerpFactor = math.Clamp((CurTime() - startTime) / (0.7/3), 0, 1)
                
                local targetFOV = 80 

                local orgiginlerpto = LerpVector(lerpFactor, pos, cam.Pos)
                local angleslerpto = LerpAngle(lerpFactor, angles, cam.Ang)
                local interpolatedFOV = Lerp(lerpFactor, fov, targetFOV)

                local view = {
                    origin = orgiginlerpto,
                    angles = angleslerpto,
                    fov = interpolatedFOV,
                    drawviewer = false
                }
                return view
            end)
        end
    end)

    local preservedmats = {
        ["herobrian_fog"] = Material("redimated/herobrine/herobrian_fog.png"),
        ["herobrian_spectral"] = Material("redimated/herobrine/herobrian_spectral.png")
    }

    hook.Add("HUDPaint", "RPP_Herobrine_CooldownHUD", function()
        if SherlockHNS then return end
        local ply = LocalPlayer()
        local screenW, screenH = ScrW(), ScrH()
        local IconSize = ScrH()*0.15
        if IsValid(ply) then
            local ent = ply.pk_pill_ent
            if IsValid(ply.pk_pill_ent) and ply.pk_pill_ent.formTable == pk_pills.getPillTable("rpp_herobrine") then

                local xaxis = screenW*0.5
                local yaxis = screenH-IconSize
                surface.SetMaterial(preservedmats["herobrian_fog"])
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawTexturedRectUV(xaxis, yaxis, IconSize, IconSize, 0, 0, 1, 1)

                local progress = (ent:GetNWInt("Herobrine_r_cooldown") - CurTime())/ent:GetNWInt("Herobrine_r_timeleft")
                if progress > 0 then
                    local progress2 = Lerp(progress, 1, 0)
                    surface.SetDrawColor(75, 75, 75, 255)
                    surface.DrawTexturedRectUV(xaxis, yaxis + (IconSize* progress2), IconSize, IconSize * progress, 0, 1* progress2, 1, 1)
                end
                
                local xaxis = screenW*0.5-IconSize
                surface.SetMaterial(preservedmats["herobrian_spectral"])
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawTexturedRectUV(xaxis, yaxis, IconSize, IconSize, 0, 0, 1, 1)

                local progress = (ent:GetNWInt("Herobrine_rmb_cooldown") - CurTime())/ent:GetNWInt("Herobrine_rmb_timeleft")
                if progress > 0 then
                    local progress2 = Lerp(progress, 1, 0)
                    surface.SetDrawColor(75, 75, 75, 255)
                    surface.DrawTexturedRectUV(xaxis, yaxis + (IconSize* progress2), IconSize, IconSize * progress, 0, 1* progress2, 1, 1)
                end
            end
        end
    end)

    hook.Add("PreDrawHalos", "Outline_All_Entities", function()
        local ply = LocalPlayer()
        if IsValid(ply) then
            local ent = ply.pk_pill_ent
            if IsValid(ply.pk_pill_ent) and ply.pk_pill_ent.formTable == pk_pills.getPillTable("rpp_herobrine") then
                local entsToOutline = {}
                for _, ent2 in ipairs(ents.GetAll()) do
                    if !IsValid(ent2) then continue end
                    if ent2:IsWorld() then continue end

                    if ent2:IsPlayer() or ent2:IsNPC() or ent2.IsNextBot and ent2:IsNextBot() then


                        if ent:GetNWFloat("_rpp_SpectralSightcd") > CurTime() then 
                        else
                            if ent2:GetNWFloat("_rpp_hallucinationhighlight") < CurTime() then continue end
                        end
                        
                        table.insert(entsToOutline, ent2)
                    end
                end

                halo.Add(
                    entsToOutline,
                    Color(255, 255, 255, 255),
                    2,
                    2,
                    1,
                    true,
                    true
                )
            end
        end
    end)
    
    local FAR_DIST_SQR = 1450 ^ 2
    local LOOK_DOT_THRESHOLD = 0.7
    local MIN_VALID_DIST_SQR = 32 * 32

    local PositionsToCheck = {}

    local Hallucinations = {}
    local NEXT_SPAWN_TIME = 0

    local function CanHallucinate(ply)
        if #PositionsToCheck == 0 then return false end

        local eyePos = ply:EyePos() or ply:GetPos() + Vector(0,0,50)
        local viewDir = ply:EyeAngles():Forward()or ply:GetPos() + Vector(0,0,50) + ply:GetForward()*1

        local nearestPos
        local nearestDistSqr = math.huge

        for _, pos in ipairs(PositionsToCheck) do
            local d = eyePos:DistToSqr(pos)
            if d < nearestDistSqr then
                nearestDistSqr = d
                nearestPos = pos
            end
        end

        if not nearestPos then return false end
        if nearestDistSqr < MIN_VALID_DIST_SQR then return false end
        if nearestDistSqr <= FAR_DIST_SQR then return false end

        local dirToPos = (nearestPos - eyePos):GetNormalized()
        local dot = viewDir:Dot(dirToPos)

        if dot < LOOK_DOT_THRESHOLD then
            return true
        end

        local tr = util.TraceLine({
            start  = eyePos,
            endpos = nearestPos,
            filter = ply,
            mask   = MASK_SOLID
        })

        return tr.Hit
    end

    local HALLUCINATION_LIFETIME_MIN = 6
    local HALLUCINATION_LIFETIME_MAX = 25
    local MIN_GROUND_NORMAL_Z = 0.85
    local FADE_SPEED = 1

    local function SpawnHallucination(ply)
        if #Hallucinations >= 1 then return end

        local eyePos  = ply:EyePos()
        local plyPos  = ply:GetPos()
        local viewDir = ply:EyeAngles():Forward()

        for i = 1, 14 do
            local yaw  = math.random(0, 360)
            local dist = math.random(400, 1200)

            local dir = Angle(0, yaw, 0):Forward()
            if viewDir:Dot(dir) > 0.2 then continue end

            local startPos = plyPos + dir * dist + Vector(0, 0, 80)
            local endPos   = startPos - Vector(0, 0, 300)

            local tr = util.TraceLine({
                start  = startPos,
                endpos = endPos,
                filter = ply,
                mask   = MASK_SOLID
            })

            if !tr.Hit then continue end
            if tr.HitNormal.z < MIN_GROUND_NORMAL_Z then continue end

            local ent = ClientsideModel("models/redimated/herobrine.mdl", RENDERGROUP_TRANSLUCENT)
            if !IsValid(ent) then return end

            ent:SetPos(tr.HitPos)
            ent:SetAngles(Angle(0, (eyePos - tr.HitPos):Angle().y, 0))
            ent:SetSequence(ent:LookupSequence("idle_all_01") or 0)
            ent:SetPlaybackRate(0)
            ent:SetRenderMode(RENDERMODE_TRANSALPHA)
            ent:SetColor(Color(255, 255, 255, 0))
            ent.Alpha = 0
            ent.FadingOut = false

            table.insert(Hallucinations, ent)

            timer.Create("HallucinationFadeIn"..ent:EntIndex(), 0, 0, function()
                if not IsValid(ent) then timer.Remove("HallucinationFadeIn"..ent:EntIndex()) return end

                if ent.Alpha < 255 then
                    ent.Alpha = math.min(ent.Alpha + 255 * FrameTime(), 255)
                    ent:SetColor(Color(255, 255, 255, ent.Alpha))
                else
                    timer.Remove("HallucinationFadeIn"..ent:EntIndex())
                end
            end)

            local lifetime = math.Rand(HALLUCINATION_LIFETIME_MIN, HALLUCINATION_LIFETIME_MAX)
            timer.Simple(lifetime, function()
                if !IsValid(ent) then return end
                ent.FadingOut = true
            end)

            return
        end
    end

    hook.Add("Think", "ClientHallucinationSystem_FIXED", function()
        local ply = LocalPlayer()
        if !IsValid(ply) then return end
        local entities = {}

        for _, ent in ipairs(ents.GetAll()) do
            if !IsValid(ent) then continue end
            if ent.formTable then else continue end
            if ent.formTable.redimated_herobrine then else continue end
            table.insert(entities, ent:GetPos())
        end

        PositionsToCheck = entities


        for i = #Hallucinations, 1, -1 do
            local ent = Hallucinations[i]
            if !IsValid(ent) then
                table.remove(Hallucinations, i)
                continue
            end

            if ply:GetPos():DistToSqr(ent:GetPos()) < 200 * 200 then
                if !IsValid(ent) then return end
                if not FadingOut then
                    net.Start("rpp_herobrine_variableset")
                        net.WriteEntity(ply)
                    net.SendToServer()
                end
                ent.FadingOut = true
    
            end

            if ent.FadingOut then
                ent.Alpha = ent.Alpha - FADE_SPEED * 255 * FrameTime()
                if ent.Alpha <= 0 then
                    if IsValid(ent) then
                        ent:Remove()
                        table.RemoveByValue(Hallucinations, ent)
                    end
                    
                else
                    ent:SetColor(Color(255, 255, 255, ent.Alpha))


                    if not ent.FadeSoundPlayed then
                        ent:EmitSound("redimated/herobrine/cave"..math.random(1,6)..".wav", 70, 100)
                        ent.FadeSoundPlayed = true
                    end

                end
            end
        end

        if CanHallucinate(ply) then
            if CurTime() >= NEXT_SPAWN_TIME then
                NEXT_SPAWN_TIME = CurTime() + math.Rand(2.5, 5)
                if math.random() < 0.4 then
                    SpawnHallucination(ply)
                end
            end
        end
    end)



end

hook.Add("SetupMove", "DisablePlayerMovement_Redimated_herobine", function(ply, mv, cmd)
    local cool = ply._rpp_standstilldur or 0
    if cool > CurTime() or ply:GetNWInt("DisablePlayerMovement_herobrine_red_stun") > CurTime() then
        mv:SetForwardSpeed(0)
        mv:SetSideSpeed(0)
        mv:SetUpSpeed(0)
        mv:SetButtons(0)
    end
end)


local function racheljackietien_jumpscare(ply, ent, duration, customanimstuff, radius)
    if SERVER then
        if not ent.IsInJumpscare then ent.IsInJumpscare = 0 end
        if ent.IsInJumpscare >= CurTime() then return end
        if not ent.IsInJumpscareCooldown then ent.IsInJumpscareCooldown = 0 end
        if ent.IsInJumpscareCooldown >= CurTime() then return end

        local jumpscare_entity = nil

if SherlockHNS then
    jumpscare_entity = SherlockHNS.FindVictim(ply, ent:LocalToWorld(Vector(0, 0, 50)), radius or 90)
else
    for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), radius or 90)) do
                if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                    if ent2 == ply then continue end
                    if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
    
                    if IsValid(ent2) then
                        jumpscare_entity = ent2
                        break
                    end
                end
            end
end

if SherlockHNS and IsValid(jumpscare_entity) and jumpscare_entity:IsPlayer() then
            return pk_pills.playHNSJumpscare(ply, ent, jumpscare_entity, duration, {
                camera = "rpp_herobrine_pill_cam",
                onStart = customanimstuff,
            })
        end

        if jumpscare_entity ~= nil then
            
            ent.JuumpscareStart = CurTime()

            ent.jumpscare_entity = jumpscare_entity
            ent.entitylastpos = jumpscare_entity:GetPos()
            ent.entitylastang = jumpscare_entity:GetAngles()

            local targetAngle = (ply:GetPos() - jumpscare_entity:GetPos()):Angle()

            targetAngle.p = 0
            targetAngle.r = 0

            ply:SetNWInt("DisablePlayerMovement_herobrine_red_stun", duration+CurTime())
            jumpscare_entity:SetNWInt("DisablePlayerMovement_herobrine_red_stun", duration+CurTime())

            ent.IsInJumpscare = CurTime() + duration

            local puppet = ent:GetPuppet()

            if jumpscare_entity:IsPlayer() then
                net.Start('rpp_herobrine_pill_cam')
                net.WriteEntity(puppet)
                net.WriteBool(true)
                net.Send(jumpscare_entity)
            else
                jumpscare_entity:NextThink(duration+0.1+CurTime())
            end



            local hookName = "herobrine_red_jumpscarehandel" .. ent:EntIndex()

            hook.Add("Think", hookName, function()
                if !IsValid(ent) then
                    hook.Remove("Think", hookName)
                    return
                end


                local puppet = ent:GetPuppet()
                if ent.jumpscare_entity then
                    local entity = ent.jumpscare_entity
                    if IsValid(entity) then

                        local lengthofentitybody = (entity:EyePos() - entity:GetPos()):Length() /2

                        local cam = ent:GetPuppet():GetAttachment(ent:GetPuppet():LookupAttachment('camera'))

                        if entity:Health() < 0.1 and entity:IsPlayer() then
                            ent.jumpscare_entity = nil
                        else
                            local mins, maxs = ent:OBBMins(), ent:OBBMaxs()
                            local lengthofentitybody = ((maxs.z - mins.z)/2)*0

                            local lerpFactor = math.Clamp((CurTime() - ent.JuumpscareStart) / 0.5, 0, 1)
                            local newAngle = LerpAngle(lerpFactor, ent.entitylastang, cam.Ang)
                            local NewVector = LerpVector(lerpFactor, ent.entitylastpos, cam.Pos - entity:GetUp() * lengthofentitybody)
                            entity:SetPos(NewVector)
                            entity:SetAngles(newAngle)
                        end
                    end
                end
            end)

            jumpscare_entity:AddFlags(FL_NOTARGET)
            ent:CallOnRemove("RachelJumpscare"..ent:EntIndex(), function()
                if !IsValid(jumpscare_entity) then return end

                hook.Remove("Think", hookName)
                jumpscare_entity:RemoveFlags(FL_NOTARGET)
                ent.jumpscare_entity = nil

                if jumpscare_entity:IsPlayer() then
                    net.Start('rpp_herobrine_pill_cam')
                    net.WriteEntity(puppet)
                    net.WriteBool(false)
                    net.Send(jumpscare_entity)
                else
                    jumpscare_entity:NextThink(CurTime())
                end
                jumpscare_entity:SetPos(ent.entitylastpos)
                jumpscare_entity:SetAngles(ent.entitylastang)
                jumpscare_entity:SetNWInt("DisablePlayerMovement_herobrine_red_stun", CurTime())
            end)

            customanimstuff()
        end
    end
end

pk_pills.packStart("Herobrine", "rpp_herobrine", "pills/redimated_herobrine.png")


pk_pills.register('rpp_herobrine', {
    printName = 'Herobrine',
    modelScale='1.0',
    type = 'ply',
    model="models/redimated/herobrine.mdl",

    anims = {
        default = {
            idle = "idle",
            walk = "walk",
            run = "run",
            crouch = "crouch_idle",
            crouch_walk = "crouch_walk.smd",
            kill = "kill",
        },


            
        ShouldMoveRotate={
            idle= function(ent) 
                return 'notshftlock' 
            end,
            walk= function(ent) 
                return 'notshftlock' 
            end,
            run= function(ent) 
                return 'notshftlock' 
            end,
            crouch_idle= function(ent) 
                return 'notshftlock' 
            end,
            ["crouch_walk.smd"]= function(ent) 
                return 'notshftlock' 
            end,
            kill= function(ent) 
                return 'notshftlock' 
            end,
            
        },

        ShouldAlternate={
        },

    },
    
    sounds = {
        attack = "Weapon_Pistol.Single",
        enterfog = "redimated/herobrine/enter fog.mp3",
        leavefog = "redimated/herobrine/leave fog.mp3",
        spectralstart = "redimated/herobrine/spectral start.mp3",
        spectralambience = "redimated/herobrine/spectral ambience.wav",
        herohit = "redimated/herobrine/hero hit.mp3",
        kill = "redimated/herobrine/Herobrine_kill.wav",
    },
    health = 10000,

    Herobrinemoveset = {
        moveSpeed = {
            walk = 200,
            run = 500,
            ducked= 25,
            jumppower = 0,
        },
    },
    
    redimated_herobrine = true,

    stats={
        ["m1"] = {
            ['damage'] = 30,
            ['cd'] = 1,
        },
        ["r"] = {
            ['killcd'] = 3.5,
            ['cd'] = 53,
            ['durcd'] = 3
        },
        ["m2"] = {
            ['standstill'] = 5.5,
            ['cd'] = 46 ,
        },
    },
    togglefly = function(tog, ply)
        ply:SetLocalVelocity(Vector(0,0,0))
        if tog then
            ply:SetMoveType(8)
            ply:SetNotSolid(true)
        else
            ply:SetMoveType(2)
            ply:SetNotSolid(false)
        end
    end,

    hullSize = { 16, 16, 32 },
    movePoseMode="xy",
    aim={ xPose="aim_yaw", yPose="aim_pitch", nocrosshair = true },
    muteSteps = true,
    cloak = {
        ["max"] = 255,
        ["rechargeRate"] = 5
    },


    camera={
        offset = Vector(0, 0, 50),
        dist=130,
    },

    attack = {
        mode = 'trigger',
        func = function(ply, ent)
            if ent._rpp_last_hitcd and CurTime() < ent._rpp_last_hitcd then return end
            if ent.durcdHerobrine_r and CurTime() < ent.durcdHerobrine_r then return end
            if ply._rpp_standstilldur and CurTime() < ply._rpp_standstilldur then return end
            if ply:GetNWInt("DisablePlayerMovement_herobrine_red_stun") > CurTime() then return end
            if ent.iscloaked then return end

            local puppet = ent:GetPuppet()
            if not IsValid(puppet) then return end
            if SERVER then
                local layeredAnim = puppet:AddGesture(ACT_VM_RELOAD, false)

                local current = 1
                puppet:SetLayerWeight(layeredAnim, current)
                puppet:SetLayerPriority(layeredAnim, 4)
                if ply:IsPlayer() then
                    puppet:SetLayerPlaybackRate(layeredAnim, 0.5)
                else
                    puppet:SetLayerPlaybackRate(layeredAnim, 1)
                end

                local function fadeLayer()
                    if not IsValid(puppet) then return end
                    current = current - 0.04
                    puppet:SetLayerWeight(layeredAnim, math.max(current, 0))

                    if current > 0 then
                        timer.Simple(0.0005, fadeLayer)
                    end
                end

                timer.Simple(0.15, fadeLayer)

                timer.Simple(0.9,function()
                    if !IsValid(ent) then return end
                    puppet:RemoveLayer(layeredAnim)
                end)
            end
            ent._rpp_last_hitcd = CurTime()+1.1
            pk_pills.setHNSCooldown(ent, "attack", 1.1)

            --[[
            ]]
        end,
    },

    attack2 = {
        mode = 'trigger',
        func = function(ply, ent)
            local COOLDOWN, standstill = ent.formTable.stats["m2"]["cd"], ent.formTable.stats["m2"]["standstill"]
            if ent._rpp_SpectralSightcd and CurTime() < ent._rpp_SpectralSightcd then return end
            if ent.durcdHerobrine_r and CurTime() < ent.durcdHerobrine_r then return end
            if ply:GetNWInt("DisablePlayerMovement_herobrine_red_stun") > CurTime() then return end
            if ent.iscloaked then return end
            ply._rpp_standstilldur = CurTime() + standstill
            ent._rpp_SpectralSightcd = CurTime() + COOLDOWN
            ent:SetNWFloat("Herobrine_rmb_cooldown", CurTime() + COOLDOWN)
            pk_pills.setHNSCooldown(ent, "sight", ent:GetNWFloat("Herobrine_rmb_cooldown") - CurTime())
            ent:SetNWFloat("Herobrine_rmb_timeleft", COOLDOWN)
            ent:SetNWFloat("_rpp_SpectralSightcd", CurTime() + standstill)
            if ent.PillSound then
                ent:PillSound("spectralstart")
            end
            timer.Simple(2,function()
                if !IsValid(ent) then return end
                    
                if ent.PillSound then
                    ent:PillSound("spectralambience")
                end
            end)
        end,
    },
    herobrine_survivor_keybinds = function(ply,ent,button)
        if button == KEY_R then

            local COOLDOWN, durcd, killcd = ent.formTable.stats["r"]["cd"], ent.formTable.stats["r"]["durcd"], ent.formTable.stats["r"]["killcd"]
            if ent._rpp_inviscd and CurTime() < ent._rpp_inviscd then return end
            if ent.durcdHerobrine_r and CurTime() < ent.durcdHerobrine_r then return end
            if ply._rpp_standstilldur and CurTime() < ply._rpp_standstilldur then return end
            if ply:GetNWInt("DisablePlayerMovement_herobrine_red_stun") > CurTime() then return end
            if ent.iscloaked then
                if ent.PillSound then
                    ent:PillSound("leavefog")
                end
                ent._rpp_inviscd = CurTime() + COOLDOWN
                ent._rpp_last_hitcd = CurTime() + killcd
                ent.iscloaked = false
                ent.formTable.togglefly(false, ply)
                ent:SetNWFloat("Herobrine_r_cooldown", ent._rpp_inviscd)
                pk_pills.setHNSCooldown(ent, "fog", ent:GetNWFloat("Herobrine_r_cooldown") - CurTime())
                ent:SetNWFloat("Herobrine_r_timeleft", COOLDOWN)

                local ed = EffectData()
                ed:SetOrigin(ply:GetPos()+Vector(0,0,0))
                ed:SetEntity(ply)
                util.Effect("Herobrine_thunder_red", ed)

                ent:RemoveCallOnRemove("RemoveSound"..ent:EntIndex())
                ent:StopSound("redimated/herobrine/spectural_ambiance.wav")

                ply._rpp_standstilldur = CurTime() + 1.5
                
            else
                if ent.PillSound then
                    ent:PillSound("enterfog")
                end
                ent.durcdHerobrine_r = CurTime() + durcd
                ent:SetNWFloat("Herobrine_r_cooldown", CurTime() + durcd)
                pk_pills.setHNSCooldown(ent, "fog", ent:GetNWFloat("Herobrine_r_cooldown") - CurTime())
                ent:SetNWFloat("Herobrine_r_timeleft", durcd)

                ent.iscloaked = true
                timer.Simple(1,function()
                    if !IsValid(ent) then return end
                    ent.formTable.togglefly(true, ply)


                    ent:CallOnRemove("RemoveSound"..ent:EntIndex(), function()
                        ent:StopSound("redimated/herobrine/spectural_ambiance.wav")
                    end)

                    AdvancedPillSound(
                        {
                            stringe = "redimated/herobrine/spectural_ambiance.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                end)
            end
        end
    end,


    herobrine_redimated_OM_pill_event = function(ply, ent, event)
        if SERVER then
            if event == "REDIMATEDKill" then
                local jumpscare_entity = ent.jumpscare_entity
                if !(IsValid(jumpscare_entity)) or !IsValid(ent) then return end
                ent.jumpscare_entity = nil
                if jumpscare_entity:IsPlayer() then
                    net.Start('rpp_herobrine_pill_cam')
                    net.WriteEntity(ent:GetPuppet())
                    net.WriteBool(false)
                    net.Send(jumpscare_entity)
                    jumpscare_entity:Kill(ply)
                else
                    jumpscare_entity:NextThink(CurTime())
                    jumpscare_entity:TakeDamage(1e9, ply)
                end
                ent:RemoveCallOnRemove("RachelJumpscare"..ent:EntIndex())
                hook.Remove("Think", "herobrine_red_jumpscarehandel" .. ent:EntIndex())
                
            end

            if event == "SpawnStake" then
                if SERVER then
                    local stakeOrigin = ent:LocalToWorld(Vector(0, 0, 50))
                    local stakeTargets

                    if SherlockHNS then
                        local target = SherlockHNS.FindVictim(ply, stakeOrigin, 180)
                        stakeTargets = IsValid(target) and {target} or {}
                    else
                        stakeTargets = ents.FindInSphere(stakeOrigin, 180)
                    end

                    for _, ent2 in ipairs(stakeTargets) do
                        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                            if ent2 == ply then continue end
                            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                            if IsValid(ent2) then

                                if (SherlockHNS and ent2:IsPlayer()) or ent2:Health()-45 <= 0.1 then
                                    local dur = ent:GetPuppet():SequenceDuration(ent:GetPuppet():LookupSequence("kill"))
                                    racheljackietien_jumpscare(
                                        ply,
                                        ent,
                                        dur,
                                        function()
                                            ent:PillSound("kill")
                                            ent:PillAnim('kill')
                                        end,
                                        180
                                    )
                                    break
                                end

                                local dmg = DamageInfo()
                                dmg:SetDamage(45)
                                dmg:SetAttacker(ply)
                                dmg:SetInflictor(ply)
                                dmg:SetDamageType(DMG_CLUB)
                                dmg:SetDamagePosition(ent2:GetPos())

                                ent2:TakeDamageInfo(dmg)
                                
                            end
                        end
                    end
                end
            end
        end
    end,

    herobrine_redimated_pill_initialize = function(tablevarable1,tablevarable2,tablevarable3)
    end,


    think_noodles_herobrine_redimated_pill = function(ply, ent)
        if SERVER then
            --[[ Speed handeler
                desc: This is the speed handeler, if a ability gives him speed boost, use this code to boost the values up.
            ]]
            local speed = {
                ['walk'] = ent.formTable.Herobrinemoveset.moveSpeed.walk,
                ['run'] = ent.formTable.Herobrinemoveset.moveSpeed.run,
                ['ducked'] = ent.formTable.Herobrinemoveset.moveSpeed.ducked,
                ['jumppower'] = ent.formTable.Herobrinemoveset.moveSpeed.jumppower
            }
            if IsValid(ply) and IsValid(ent) then
                pk_pills.setCostumeMoveSpeed(ent, speed.walk, speed.run, speed.ducked, speed.jumppower)
            end
        end
    end,

}, function(form)
    -- The legacy damage branches are for Sandbox and NPCs.
    form.hnsKillAPI = true
    form.hnsAbilities = {
        { id = "attack", name = "Ataque", key = IN_ATTACK, OnUse = form.attack.func },
        { id = "sight", name = "Visão espectral", key = IN_ATTACK2, OnUse = form.attack2.func },
    }
    form.attack, form.attack2, form.reload = nil, nil, nil
    form.cloak = nil
    pk_pills.bindHNSButtons(form, "herobrine_survivor_keybinds", {
        { id = "fog", name = "Névoa", button = KEY_R, keyLabel = "R" },
    })
end)