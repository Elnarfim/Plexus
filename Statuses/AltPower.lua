--[[--------------------------------------------------------------------
    Plexus
    Compact party and raid unit frames.
    Copyright (c) 2020 Doadin <doadinaddons@gmail.com>
    All rights reserved. See the accompanying LICENSE file for details.
----------------------------------------------------------------------]]

local _, Plexus = ...
local PlexusRoster = Plexus:GetModule("PlexusRoster")
local PlexusStatus = Plexus:GetModule("PlexusStatus")

local PlexusAltPowerBar = PlexusStatus:NewModule("PlexusAltPowerBar")

PlexusAltPowerBar.menuName = "AltPowerBar"

PlexusAltPowerBar.defaultDB = {
    debug = false,
    unit_altpower = {
      color = { r=0, g=0, b=1, a=1 },
      text = "AltPowerBar",
      enable = false,
      priority = 30,
      range = false
    },
}

local settings --luacheck:ignore 231

function PlexusAltPowerBar:OnInitialize()
    self.super.OnInitialize(self)
    self:RegisterStatus('unit_altpower',"Alt Power Bar", nil, true)
    settings = PlexusAltPowerBar.db.profile
end

function PlexusAltPowerBar:OnStatusEnable(status)
    if status == "unit_altpower" then
        self:RegisterEvent("UNIT_POWER_UPDATE","UpdateUnit")
        self:RegisterEvent("UNIT_MAXPOWER","UpdateUnit")
        self:RegisterEvent("PLAYER_ENTERING_WORLD","UpdateAllUnits")
        self:RegisterMessage("Plexus_UnitJoined")
        self:UpdateAllUnits()
    end
end

function PlexusAltPowerBar:OnStatusDisable(status)
    if status == "unit_altpower" then
        for guid, _ in PlexusRoster:IterateRoster() do
            self.core:SendStatusLost(guid, "unit_altpower")
        end
        self:UnregisterEvent("UNIT_POWER_UPDATE")
        self:UnregisterEvent("UNIT_MAXPOWER")
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        self:UnregisterMessage("Plexus_UnitJoined")
    end
end

function PlexusAltPowerBar:UpdateUnit(_, unitid)
    if not PlexusAltPowerBar.db.profile.unit_altpower.enable then return end
    if not unitid then return end
    local unitGUID = UnitGUID(unitid)
    --don't update for a unit not in group
    if not PlexusRoster:IsGUIDInGroup(unitGUID) then return end
    if (not UnitIsPlayer(unitid)) then
        self.core:SendStatusLost(unitGUID, "unit_altpower")
    else
        self:UpdateUnitResource(unitid)
    end
end

function PlexusAltPowerBar:Plexus_UnitJoined(_, _, unitid)
    if not PlexusAltPowerBar.db.profile.unit_altpower.enable then return end
    local unitGUID = UnitGUID(unitid)
    if not unitid then return end
    if (not UnitIsPlayer(unitid)) then
        self.core:SendStatusLost(unitGUID, "unit_altpower")
    else
        self:UpdateUnitResource(unitid)
    end
end

function PlexusAltPowerBar:UpdateAllUnits()
    if not PlexusAltPowerBar.db.profile.unit_altpower.enable then return end
    for _, unitid in PlexusRoster:IterateRoster() do
        local unitGUID = UnitGUID(unitid)
        if (not UnitIsPlayer(unitid)) then
            self.core:SendStatusLost(unitGUID, "unit_altpower")
        else
            self:UpdateUnitResource(unitid)
        end
    end
end

function PlexusAltPowerBar:UpdateUnitResource(unitid)
    if not PlexusAltPowerBar.db.profile.unit_altpower.enable then return end
    if not unitid then return end
    --local UnitGUID = UnitGUID(unitid)
    --if not UnitGUID then return end
    local unitGUID = UnitGUID(unitid)
    local current, max = UnitPower(unitid,10), UnitPowerMax(unitid,10)
    local priority = PlexusAltPowerBar.db.profile.unit_altpower.priority
    local color = PlexusAltPowerBar.db.profile.unit_altpower.color

    if max <= 0 then
        self.core:SendStatusLost(unitGUID, "unit_altpower")
        return
    end

    self.core:SendStatusGained(
        unitGUID, "unit_altpower",
        priority,
        nil,
        color,
        nil,
        current,max,
        nil
    )
end
