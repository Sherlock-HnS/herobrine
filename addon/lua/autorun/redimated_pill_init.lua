if ! pcall(require, "pk_pills") then
    if SERVER then
        hook.Add("PlayerInitialSpawn", "pk_pill_extfail_cl", function(ply)
            if game.SinglePlayer() || ply:IsListenServerHost() then
                ply:SendLua(
                'notification.AddLegacy("One or more pill extensions failed to load. Did you forget to install Parakeet\'s Pill Pack?",NOTIFY_ERROR,30)')
            end
        end)
        hook.Add("Initialize", "pk_pill_extfail_sv", function(ply)
            print(
            "[ALERT] One or more pill extensions failed to load. Did you forget to install Enhanced Parakeet's Pill Base?")
        end)
    end
    return
end

AddCSLuaFile()
include("include/pill_herobrine.lua")

sound.Add({
    name = "REDIMATED.HEROBRINE.WalkStep",
    channel = CHAN_USER_BASE + 10,
    volume = 1.0,
    sound = {
        "redimated/herobrine/Step1.wav",
        "redimated/herobrine/Step2.wav",
        "redimated/herobrine/Step3.wav",
        "redimated/herobrine/Step4.wav",
    }
})
