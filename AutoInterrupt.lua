local grailSummons = ...

---@class AutoInterruptSavedVariables
---@field focusMarker? number
---@field dbVersion? number
---@type AutoInterruptSavedVariables
AutoInterruptDB = AutoInterruptDB or {}

local HOLY_GRAIL_FOCUS_SCROLL = "AutoFocus"
local BLACK_KNIGHT_KICK_SCROLL = "AutoKick"
local MINISTRY_STOP_SCROLL = "AutoStop"

local DEFAULT_SHRUBBERY_MARKER = 4
local sirNotAppearingInThisFight = false

local SACRED_INTERRUPTION_TABLET = {
    WARRIOR = 6552,
    PALADIN = 96231,
    HUNTER = 147362,
    ROGUE = 1766,
    PRIEST = 15487,
    DEATHKNIGHT = 47528,
    SHAMAN = 57994,
    MAGE = 2139,
    WARLOCK = 119898,
    MONK = 116705,
    DRUID = 106839,
    DEMONHUNTER = 183752,
    EVOKER = 351338,
}

local SPECIALIZED_NI_TABLET = {
    [102] = { 78675, 106839 }, -- Balance: Solar Beam, fallback Skull Bash
    [255] = { 187707, 147362 }, -- Survival: Muzzle, fallback Counter Shot
    [266] = { 89766, 119898 }, -- Demonology: Axe Toss, fallback Command Demon
}

local MINISTRY_OF_STOPPING_TABLET = {
    WARRIOR = 107570,
    PALADIN = 853,
    HUNTER = 19577,
    ROGUE = 2094,
    PRIEST = 64044,
    DEATHKNIGHT = 221562,
    SHAMAN = 51514,
    MAGE = 118,
    WARLOCK = 6789,
    MONK = 115078,
    DRUID = 5211,
    DEMONHUNTER = 217832,
    EVOKER = 360806,
}

local function ConsultTheOracle(spellSigil)
    if not spellSigil then return nil end
    local oracleScroll = C_Spell.GetSpellInfo(spellSigil)
    return oracleScroll and oracleScroll.name
end

local function KnowsTheSecretHandshake(spellSigil)
    if not spellSigil then return false end
    return C_SpellBook.IsSpellKnown(spellSigil, Enum.SpellBookSpellBank.Player)
        or C_SpellBook.IsSpellKnown(spellSigil, Enum.SpellBookSpellBank.Pet)
end

local function AskBridgeKeeperForInterrupt(chosenSpec, braveClass)
    local bridgeAnswer = chosenSpec and SPECIALIZED_NI_TABLET[chosenSpec]
    if type(bridgeAnswer) == "number" then
        return bridgeAnswer
    end
    if type(bridgeAnswer) == "table" then
        for _, spellSigil in ipairs(bridgeAnswer) do
            if KnowsTheSecretHandshake(spellSigil) then
                return spellSigil
            end
        end
        return bridgeAnswer[1]
    end
    return SACRED_INTERRUPTION_TABLET[braveClass]
end

local function SummonClassAppropriateNi()
    local chosenPath = GetSpecialization()
    local chosenSpec = chosenPath and GetSpecializationInfo(chosenPath) or nil
    local pacifistClergy = {
        [65] = true,   -- Holy Paladin
        [256] = true,  -- Discipline Priest
        [257] = true,  -- Holy Priest
        [270] = true,  -- Mistweaver Monk
        [105] = true,  -- Restoration Druid
        [1468] = true, -- Preservation Evoker
    }

    if chosenSpec and pacifistClergy[chosenSpec] then
        return nil
    end

    local _, braveClass = UnitClass("player")
    return ConsultTheOracle(AskBridgeKeeperForInterrupt(chosenSpec, braveClass))
end

local function FetchMinistryApprovedStop()
    local _, braveClass = UnitClass("player")
    return ConsultTheOracle(MINISTRY_OF_STOPPING_TABLET[braveClass])
end

local function InscribeOrRefreshScroll(scrollName, incantation, iconSigil)
    if string.len(incantation or "") > 255 then
        return
    end

    local scrollSlot = GetMacroIndexByName(scrollName)
    if scrollSlot > 0 then
        local _, _, existingIncantation = GetMacroInfo(scrollSlot)
        if existingIncantation and strtrim(existingIncantation) == strtrim(incantation) then
            return
        end
        EditMacro(scrollSlot, scrollName, iconSigil or 134400, incantation)
        return
    end

    CreateMacro(scrollName, iconSigil or 134400, incantation, false)
end

local function RefreshTheSacredScrolls()
    if InCombatLockdown() then
        sirNotAppearingInThisFight = true
        return
    end

    sirNotAppearingInThisFight = false

    local shrubberyMarker = AutoInterruptDB.focusMarker or DEFAULT_SHRUBBERY_MARKER
    local focusIncantation = "/tm [@focus,exists] 0\n/focus [@mouseover,nodead,exists] [@target,nodead,exists][]\n/tm [@focus,exists,nodead] " .. shrubberyMarker
    InscribeOrRefreshScroll(HOLY_GRAIL_FOCUS_SCROLL, focusIncantation, 1033497)

    local knightlyNi = SummonClassAppropriateNi()
    local kickIncantation = "#showtooltip"
    if knightlyNi and strtrim(knightlyNi) ~= "" then
        kickIncantation = "#showtooltip " .. knightlyNi .. "\n/cast [@focus,exists,nodead,harm] " .. knightlyNi .. "\n/stopmacro [@focus,exists,nodead,harm]\n/focus target\n/cleartarget\n/targetenemy\n/cast " .. knightlyNi .. "\n/target focus\n/clearfocus\n/startattack"
    end
    InscribeOrRefreshScroll(BLACK_KNIGHT_KICK_SCROLL, kickIncantation, 134400)

    local ministryStop = FetchMinistryApprovedStop()
    if ministryStop and strtrim(ministryStop) ~= "" then
        local stopIncantation = "#showtooltip\n/cast [@focus,exists,nodead] [@mouseover,exists,nodead] [] " .. ministryStop
        InscribeOrRefreshScroll(MINISTRY_STOP_SCROLL, stopIncantation, 134400)
    end
end

local function AppointTheProperHats()
    local roundTable = { "player", "party1", "party2", "party3", "party4" }

    for _, braveSoul in ipairs(roundTable) do
        if UnitExists(braveSoul) then
            local appointedOffice = UnitGroupRolesAssigned(braveSoul)
            if appointedOffice == "TANK" and not GetRaidTargetIndex(braveSoul) then
                SetRaidTarget(braveSoul, 6)
            elseif appointedOffice == "HEALER" and not GetRaidTargetIndex(braveSoul) then
                SetRaidTarget(braveSoul, 5)
            end
        end
    end
end

local ministryInbox = CreateFrame("Frame")
ministryInbox:RegisterEvent("ADDON_LOADED")
ministryInbox:RegisterEvent("PLAYER_ENTERING_WORLD")
ministryInbox:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
ministryInbox:RegisterEvent("PLAYER_REGEN_ENABLED")
ministryInbox:RegisterEvent("READY_CHECK")

ministryInbox:SetScript("OnEvent", function(_, royalDecree, decreePayload)
    if royalDecree == "ADDON_LOADED" and decreePayload == grailSummons then
        if not AutoInterruptDB.dbVersion and (not AutoInterruptDB.focusMarker or AutoInterruptDB.focusMarker == 3) then
            AutoInterruptDB.focusMarker = DEFAULT_SHRUBBERY_MARKER
        end
        if not AutoInterruptDB.focusMarker then AutoInterruptDB.focusMarker = DEFAULT_SHRUBBERY_MARKER end
        AutoInterruptDB.dbVersion = 1
    elseif royalDecree == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(2, RefreshTheSacredScrolls)
    elseif royalDecree == "PLAYER_SPECIALIZATION_CHANGED" then
        if decreePayload == "player" then
            C_Timer.After(1, RefreshTheSacredScrolls)
        end
    elseif royalDecree == "PLAYER_REGEN_ENABLED" then
        if sirNotAppearingInThisFight then
            RefreshTheSacredScrolls()
        end
    elseif royalDecree == "READY_CHECK" then
        if IsInGroup() and not IsInRaid() and not InCombatLockdown() then
            AppointTheProperHats()
        end
    end
end)

_G["SLASH_AUTOINTERUPT1"] = "/ai"
_G["SLASH_AUTOINTERUPT2"] = "/autointerrupt"
SlashCmdList["AUTOINTERUPT"] = function(msg)
    msg = strtrim(string.lower(msg or ""))

    local demandedShrubbery = string.match(msg, "^marker%s+(%d+)$")
    if demandedShrubbery then
        demandedShrubbery = tonumber(demandedShrubbery)
        if demandedShrubbery and demandedShrubbery >= 1 and demandedShrubbery <= 8 then
            AutoInterruptDB.focusMarker = demandedShrubbery
        end
    end

    RefreshTheSacredScrolls()
end
