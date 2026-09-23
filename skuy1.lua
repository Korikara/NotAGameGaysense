local M = {}

local ENetRole = import("ENetRole")
local EPawnState = import("EPawnState")
local ESpecialMovementType = import("ESpecialMovementType")
local ESpiderSwingMoveState = import("ESpiderSwingMoveState")
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local EParachuteState = import("EParachuteState")
local EMovementMode = import("EMovementMode")
local EStateType = import("EStateType")
local ESTEPoseState = import("ESTEPoseState")
local EGameModeType = import("EGameModeType")
local STExtraGameStateBase = import("STExtraGameStateBase")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local MatchModeIds = require("GameLua.Mod.BaseMod.GamePlay.Config.MatchModeIdsConfig")

-- ============================================================
-- PREMIUM MENU + AIM TOUCH + ESP SYSTEM (v7 - FIXED)
-- ============================================================

local IsValid = function(obj) return obj and slua and slua.isValid and slua.isValid(obj) end
local FLinearColor = import("LinearColor")
local FVector2D = import("Vector2D")
local FSlateColor = import("SlateColor") or import("/Script/SlateCore.SlateColor")

-- ============================================================
-- [1] INIT GLOBAL STATE
-- ============================================================
_G.TakoroModConfig = _G.TakoroModConfig or {}
_G.TakoroModState  = _G.TakoroModState or {}
_G.TakoroModState.MenuHidden    = false
_G.TakoroModState.ExpiredHidden = false
_G.TakoroModState.CustomTextData = _G.TakoroModState.CustomTextData or {}
_G.TakoroModState.IsAutoFiring   = _G.TakoroModState.IsAutoFiring or false
_G.TakoroModState.IsExpired      = _G.TakoroModState.IsExpired or false
_G.AimTouchVisCache = _G.AimTouchVisCache or {}

_G.TakoroModState.EnemyMarks   = _G.TakoroModState.EnemyMarks or {}
_G.TakoroModState.TrackedMarks = _G.TakoroModState.TrackedMarks or {}
_G.TakoroModState.NativeESPReady = false

_G.TakoroModConfig.AutoFeedback = _G.TakoroModConfig.AutoFeedback or false
_G.TakoroModState.AutoFeedbackInstalled = _G.TakoroModState.AutoFeedbackInstalled or false

if _G.TakoroModConfig.EspAimWarning == nil then _G.TakoroModConfig.EspAimWarning = false end
if _G.TakoroModConfig.EspAimWarningVisCheck == nil then _G.TakoroModConfig.EspAimWarningVisCheck = false end
if _G.TakoroModConfig.EspEnemyCounter == nil then _G.TakoroModConfig.EspEnemyCounter = false end
if _G.TakoroModConfig.EspVipPro == nil then _G.TakoroModConfig.EspVipPro = false end
if _G.TakoroModConfig.Esp3ShowHP == nil then _G.TakoroModConfig.Esp3ShowHP = true end
if _G.TakoroModConfig.EspLoai5 == nil then _G.TakoroModConfig.EspLoai5 = false end
if _G.TakoroModConfig.EspDistance == nil then _G.TakoroModConfig.EspDistance = false end
if _G.TakoroModConfig.EspRadar == nil then _G.TakoroModConfig.EspRadar = false end
if _G.TakoroModConfig.EspLoai8 == nil then _G.TakoroModConfig.EspLoai8 = false end

if _G.TakoroModConfig.WallXuyenTuong == nil then _G.TakoroModConfig.WallXuyenTuong = false end
if _G.TakoroModConfig.ColorBodyV2 == nil then _G.TakoroModConfig.ColorBodyV2 = false end
if _G.TakoroModConfig.ColorBodyV3 == nil then _G.TakoroModConfig.ColorBodyV3 = false end
if _G.TakoroModConfig.ColorBodyNew == nil then _G.TakoroModConfig.ColorBodyNew = false end

if _G.TakoroModConfig.IpadView == nil then _G.TakoroModConfig.IpadView = false end
if _G.TakoroModConfig.IpadViewScope == nil then _G.TakoroModConfig.IpadViewScope = false end

if _G.TakoroModState.CustomTextData.ColorV3Hidden == nil then _G.TakoroModState.CustomTextData.ColorV3Hidden = 1 end
if _G.TakoroModState.CustomTextData.ColorV3Visible == nil then _G.TakoroModState.CustomTextData.ColorV3Visible = 2 end
if _G.TakoroModState.CustomTextData.ColorV3Thickness == nil then _G.TakoroModState.CustomTextData.ColorV3Thickness = 4 end
if _G.TakoroModState.CustomTextData.IpadViewFOV == nil then _G.TakoroModState.CustomTextData.IpadViewFOV = 120 end

if not _G.GameplayData then
    pcall(function() _G.GameplayData = require("GameLua.GameCore.Data.GameplayData") end)
end
if not _G.GameplayData then
    pcall(function() _G.GameplayData = package.loaded["GameLua.GameCore.Data.GameplayData"] end)
end

local _FVector = _G.FVector or import("Vector")

-- ============================================================
-- [2] THEME SYSTEM (REDESIGN — DARK/SLATE MODERN)
-- ============================================================
_G.Themes = {
    -- ⭐ TEMA UTAMA — persis gambar referensi
    ["DARK"] = {
        bg_main=FLinearColor(0.169,0.169,0.208,1),      -- #2B2B35 panel utama
        bg_header=FLinearColor(0.118,0.118,0.149,1),    -- #1E1E26 sidebar
        bg_header2=FLinearColor(0.145,0.145,0.176,1),
        bg_header3=FLinearColor(0.227,0.227,0.271,1),   -- #3A3A45 header
        bg_row=FLinearColor(0.145,0.145,0.176,1),
        bg_row_alt=FLinearColor(0.176,0.176,0.208,1),
        bg_tab=FLinearColor(0.118,0.118,0.149,1),
        bg_tab_active=FLinearColor(0.910,0.298,0.235,1), -- #E74C3C aktif
        bg_pill=FLinearColor(0.196,0.196,0.235,1),
        bg_pill_on=FLinearColor(0.910,0.298,0.235,1),
        bg_subtab=FLinearColor(0.145,0.145,0.176,1),
        gold=FLinearColor(0.910,0.298,0.235,1),          -- #E74C3C accent (merah)
        gold_bright=FLinearColor(1.0,0.42,0.35,1),
        gold_dark=FLinearColor(0.50,0.16,0.13,1),
        gold_deep=FLinearColor(0.29,0.10,0.08,1),
        gold_glow=FLinearColor(0.910,0.298,0.235,0.10),
        gold_glow_strong=FLinearColor(0.910,0.298,0.235,0.18),
        red=FLinearColor(0.910,0.298,0.235,1),
        red_bright=FLinearColor(1.0,0.42,0.35,1),
        red_dark=FLinearColor(0.50,0.16,0.13,1),
        red_deep=FLinearColor(0.29,0.10,0.08,1),
        white=FLinearColor(1,1,1,1),
        text_label=FLinearColor(0.95,0.95,0.97,1),
        text_dim=FLinearColor(0.63,0.63,0.66,1),         -- #A0A0A8
        divider=FLinearColor(0.196,0.196,0.235,1),
        divider_gold=FLinearColor(0.910,0.298,0.235,0.5),
        divider_red=FLinearColor(0.50,0.16,0.13,1),
        border_gold=FLinearColor(0.910,0.298,0.235,1),
        border_dark=FLinearColor(0.08,0.08,0.10,1),
        close_bg=FLinearColor(1.0,0.37,0.34,1),          -- #FF5F57
        shadow1=FLinearColor(0,0,0,0.85),
        shadow2=FLinearColor(0,0,0,0.65),
        shadow3=FLinearColor(0,0,0,0.45),
        shadow4=FLinearColor(0,0,0,0.25),
        shadow5=FLinearColor(0,0,0,0.15),
        transparent=FLinearColor(0,0,0,0.01),
        -- ⭐ Warna khusus baru
        traffic_red=FLinearColor(1.0,0.373,0.341,1),     -- #FF5F57
        traffic_yellow=FLinearColor(1.0,0.741,0.180,1),  -- #FFBD2E
        traffic_green=FLinearColor(0.157,0.784,0.251,1), -- #28C840
        status_online=FLinearColor(0.180,0.800,0.443,1), -- #2ECC71
        sidebar_active=FLinearColor(0.910,0.298,0.235,0.15),
        card_bg=FLinearColor(0.145,0.145,0.176,1),
        card_border=FLinearColor(0.227,0.227,0.271,1),
    },
    
    -- ⭐ TEMA WHITE — putih bersih modern
    ["WHITE"] = {
        bg_main=FLinearColor(0.976,0.976,0.984,1),       -- #F9F9FB
        bg_header=FLinearColor(0.937,0.941,0.957,1),     -- #EFF0F4
        bg_header2=FLinearColor(0.953,0.957,0.969,1),
        bg_header3=FLinearColor(0.882,0.894,0.918,1),
        bg_row=FLinearColor(0.949,0.953,0.965,1),
        bg_row_alt=FLinearColor(0.925,0.933,0.949,1),
        bg_tab=FLinearColor(0.937,0.941,0.957,1),
        bg_tab_active=FLinearColor(0.910,0.298,0.235,1),
        bg_pill=FLinearColor(0.882,0.894,0.918,1),
        bg_pill_on=FLinearColor(0.910,0.298,0.235,1),
        bg_subtab=FLinearColor(0.949,0.953,0.965,1),
        gold=FLinearColor(0.910,0.298,0.235,1),
        gold_bright=FLinearColor(0.82,0.24,0.18,1),
        gold_dark=FLinearColor(0.72,0.28,0.24,1),
        gold_deep=FLinearColor(0.85,0.65,0.62,1),
        gold_glow=FLinearColor(0.910,0.298,0.235,0.10),
        gold_glow_strong=FLinearColor(0.910,0.298,0.235,0.20),
        red=FLinearColor(0.910,0.298,0.235,1),
        red_bright=FLinearColor(0.82,0.24,0.18,1),
        red_dark=FLinearColor(0.72,0.28,0.24,1),
        red_deep=FLinearColor(0.85,0.65,0.62,1),
        white=FLinearColor(0.13,0.14,0.16,1),
        text_label=FLinearColor(0.15,0.17,0.20,1),
        text_dim=FLinearColor(0.45,0.48,0.52,1),
        divider=FLinearColor(0.85,0.87,0.89,1),
        divider_gold=FLinearColor(0.910,0.298,0.235,0.5),
        divider_red=FLinearColor(0.72,0.28,0.24,1),
        border_gold=FLinearColor(0.910,0.298,0.235,1),
        border_dark=FLinearColor(0.75,0.78,0.82,1),
        close_bg=FLinearColor(1.0,0.37,0.34,1),
        shadow1=FLinearColor(0.5,0.5,0.6,0.15),
        shadow2=FLinearColor(0.5,0.5,0.6,0.12),
        shadow3=FLinearColor(0.5,0.5,0.6,0.09),
        shadow4=FLinearColor(0.5,0.5,0.6,0.06),
        shadow5=FLinearColor(0.5,0.5,0.6,0.04),
        transparent=FLinearColor(0,0,0,0.01),
        traffic_red=FLinearColor(1.0,0.373,0.341,1),
        traffic_yellow=FLinearColor(1.0,0.741,0.180,1),
        traffic_green=FLinearColor(0.157,0.784,0.251,1),
        status_online=FLinearColor(0.180,0.800,0.443,1),
        sidebar_active=FLinearColor(0.910,0.298,0.235,0.12),
        card_bg=FLinearColor(0.969,0.973,0.980,1),
        card_border=FLinearColor(0.882,0.894,0.918,1),
    },
    
    -- Tema lama tetap dipertahankan
    ["GOLD"] = {
        bg_main=FLinearColor(0.03,0.03,0.04,1), bg_header=FLinearColor(0.015,0.015,0.02,1),
        bg_header2=FLinearColor(0.03,0.025,0.035,1), bg_header3=FLinearColor(0.05,0.04,0.06,1),
        bg_row=FLinearColor(0.035,0.03,0.04,1), bg_row_alt=FLinearColor(0.05,0.045,0.055,1),
        bg_tab=FLinearColor(0.02,0.02,0.025,1), bg_tab_active=FLinearColor(0.12,0.09,0.02,1),
        bg_pill=FLinearColor(0.05,0.045,0.06,1), bg_pill_on=FLinearColor(0.35,0.27,0.02,1),
        bg_subtab=FLinearColor(0.02,0.02,0.025,1),
        gold=FLinearColor(0.85,0.68,0,1), gold_bright=FLinearColor(1,0.84,0.08,1),
        gold_dark=FLinearColor(0.42,0.32,0,1), gold_deep=FLinearColor(0.25,0.19,0,1),
        gold_glow=FLinearColor(0.85,0.68,0,0.08), gold_glow_strong=FLinearColor(0.85,0.68,0,0.15),
        red=FLinearColor(0.9,0.16,0.16,1), red_bright=FLinearColor(1,0.25,0.25,1),
        red_dark=FLinearColor(0.45,0.06,0.06,1), red_deep=FLinearColor(0.25,0.03,0.03,1),
        white=FLinearColor(0.93,0.93,0.96,1), text_label=FLinearColor(0.84,0.84,0.88,1),
        text_dim=FLinearColor(0.38,0.38,0.42,1),
        divider=FLinearColor(0.08,0.07,0.09,1), divider_gold=FLinearColor(0.22,0.17,0,1),
        divider_red=FLinearColor(0.2,0.04,0.04,1),
        border_gold=FLinearColor(0.5,0.38,0,1), border_dark=FLinearColor(0.01,0.01,0.02,1),
        close_bg=FLinearColor(0.65,0.08,0.08,1),
        shadow1=FLinearColor(0,0,0,0.8), shadow2=FLinearColor(0,0,0,0.6),
        shadow3=FLinearColor(0,0,0,0.4), shadow4=FLinearColor(0,0,0,0.22),
        shadow5=FLinearColor(0,0,0,0.12), transparent=FLinearColor(0,0,0,0.01),
        traffic_red=FLinearColor(1.0,0.373,0.341,1),
        traffic_yellow=FLinearColor(1.0,0.741,0.180,1),
        traffic_green=FLinearColor(0.157,0.784,0.251,1),
        status_online=FLinearColor(0.180,0.800,0.443,1),
        sidebar_active=FLinearColor(0.85,0.68,0,0.15),
        card_bg=FLinearColor(0.035,0.03,0.04,1),
        card_border=FLinearColor(0.12,0.09,0.02,1),
    },
    ["CYBERPUNK"] = {
        bg_main=FLinearColor(0.01,0.01,0.05,1), bg_header=FLinearColor(0,0,0.03,1),
        bg_header2=FLinearColor(0.02,0.01,0.06,1), bg_header3=FLinearColor(0.03,0.02,0.09,1),
        bg_row=FLinearColor(0.02,0.02,0.07,1), bg_row_alt=FLinearColor(0.03,0.03,0.1,1),
        bg_tab=FLinearColor(0.01,0.01,0.04,1), bg_tab_active=FLinearColor(0,0.15,0.2,1),
        bg_pill=FLinearColor(0.02,0.02,0.08,1), bg_pill_on=FLinearColor(0,0.25,0.3,1),
        bg_subtab=FLinearColor(0.01,0.01,0.04,1),
        gold=FLinearColor(0,1,0.8,1), gold_bright=FLinearColor(0.3,1,0.95,1),
        gold_dark=FLinearColor(0,0.35,0.3,1), gold_deep=FLinearColor(0,0.15,0.15,1),
        gold_glow=FLinearColor(0,1,0.8,0.1), gold_glow_strong=FLinearColor(0,1,0.8,0.2),
        red=FLinearColor(1,0,0.5,1), red_bright=FLinearColor(1,0.3,0.7,1),
        red_dark=FLinearColor(0.4,0,0.2,1), red_deep=FLinearColor(0.2,0,0.1,1),
        white=FLinearColor(0.9,0.98,1,1), text_label=FLinearColor(0.8,0.95,1,1),
        text_dim=FLinearColor(0.3,0.4,0.5,1),
        divider=FLinearColor(0,0.15,0.2,1), divider_gold=FLinearColor(0,0.25,0.3,1),
        divider_red=FLinearColor(0.2,0,0.15,1),
        border_gold=FLinearColor(0,0.5,0.45,1), border_dark=FLinearColor(0,0,0.02,1),
        close_bg=FLinearColor(0.8,0,0.4,1),
        shadow1=FLinearColor(0,0,0,0.8), shadow2=FLinearColor(0,0,0,0.6),
        shadow3=FLinearColor(0,0,0,0.4), shadow4=FLinearColor(0,0,0,0.22),
        shadow5=FLinearColor(0,0,0,0.12), transparent=FLinearColor(0,0,0,0.01),
        traffic_red=FLinearColor(1.0,0.373,0.341,1),
        traffic_yellow=FLinearColor(1.0,0.741,0.180,1),
        traffic_green=FLinearColor(0.157,0.784,0.251,1),
        status_online=FLinearColor(0.180,0.800,0.443,1),
        sidebar_active=FLinearColor(0,1,0.8,0.15),
        card_bg=FLinearColor(0.02,0.02,0.07,1),
        card_border=FLinearColor(0,0.15,0.2,1),
    },
    ["BLOOD"] = {
        bg_main=FLinearColor(0.04,0.01,0.01,1), bg_header=FLinearColor(0.02,0,0,1),
        bg_header2=FLinearColor(0.05,0.01,0.01,1), bg_header3=FLinearColor(0.08,0.02,0.02,1),
        bg_row=FLinearColor(0.05,0.015,0.015,1), bg_row_alt=FLinearColor(0.07,0.02,0.02,1),
        bg_tab=FLinearColor(0.03,0.005,0.005,1), bg_tab_active=FLinearColor(0.2,0.02,0.02,1),
        bg_pill=FLinearColor(0.06,0.015,0.015,1), bg_pill_on=FLinearColor(0.4,0.03,0.03,1),
        bg_subtab=FLinearColor(0.03,0.005,0.005,1),
        gold=FLinearColor(1,0.1,0.1,1), gold_bright=FLinearColor(1,0.35,0.35,1),
        gold_dark=FLinearColor(0.5,0.02,0.02,1), gold_deep=FLinearColor(0.3,0,0,1),
        gold_glow=FLinearColor(1,0.1,0.1,0.1), gold_glow_strong=FLinearColor(1,0.1,0.1,0.2),
        red=FLinearColor(1,0.1,0.1,1), red_bright=FLinearColor(1,0.4,0.4,1),
        red_dark=FLinearColor(0.5,0.02,0.02,1), red_deep=FLinearColor(0.25,0,0,1),
        white=FLinearColor(1,0.9,0.9,1), text_label=FLinearColor(1,0.85,0.85,1),
        text_dim=FLinearColor(0.5,0.3,0.3,1),
        divider=FLinearColor(0.15,0.02,0.02,1), divider_gold=FLinearColor(0.3,0.03,0.03,1),
        divider_red=FLinearColor(0.4,0.05,0.05,1),
        border_gold=FLinearColor(0.6,0.05,0.05,1), border_dark=FLinearColor(0.02,0,0,1),
        close_bg=FLinearColor(0.6,0,0,1),
        shadow1=FLinearColor(0,0,0,0.8), shadow2=FLinearColor(0,0,0,0.6),
        shadow3=FLinearColor(0,0,0,0.4), shadow4=FLinearColor(0,0,0,0.22),
        shadow5=FLinearColor(0,0,0,0.12), transparent=FLinearColor(0,0,0,0.01),
        traffic_red=FLinearColor(1.0,0.373,0.341,1),
        traffic_yellow=FLinearColor(1.0,0.741,0.180,1),
        traffic_green=FLinearColor(0.157,0.784,0.251,1),
        status_online=FLinearColor(0.180,0.800,0.443,1),
        sidebar_active=FLinearColor(1,0.1,0.1,0.15),
        card_bg=FLinearColor(0.05,0.015,0.015,1),
        card_border=FLinearColor(0.15,0.02,0.02,1),
    },
    ["ICE"] = {
        bg_main=FLinearColor(0.02,0.04,0.06,1), bg_header=FLinearColor(0.01,0.02,0.04,1),
        bg_header2=FLinearColor(0.02,0.05,0.08,1), bg_header3=FLinearColor(0.03,0.07,0.11,1),
        bg_row=FLinearColor(0.02,0.05,0.07,1), bg_row_alt=FLinearColor(0.03,0.06,0.09,1),
        bg_tab=FLinearColor(0.01,0.03,0.05,1), bg_tab_active=FLinearColor(0.05,0.15,0.25,1),
        bg_pill=FLinearColor(0.02,0.05,0.08,1), bg_pill_on=FLinearColor(0.1,0.25,0.4,1),
        bg_subtab=FLinearColor(0.01,0.03,0.05,1),
        gold=FLinearColor(0.4,0.8,1,1), gold_bright=FLinearColor(0.6,0.92,1,1),
        gold_dark=FLinearColor(0.15,0.35,0.5,1), gold_deep=FLinearColor(0.08,0.2,0.3,1),
        gold_glow=FLinearColor(0.4,0.8,1,0.1), gold_glow_strong=FLinearColor(0.4,0.8,1,0.2),
        red=FLinearColor(1,0.4,0.6,1), red_bright=FLinearColor(1,0.6,0.75,1),
        red_dark=FLinearColor(0.4,0.1,0.2,1), red_deep=FLinearColor(0.2,0.05,0.1,1),
        white=FLinearColor(0.95,0.98,1,1), text_label=FLinearColor(0.85,0.95,1,1),
        text_dim=FLinearColor(0.4,0.5,0.6,1),
        divider=FLinearColor(0.05,0.12,0.18,1), divider_gold=FLinearColor(0.1,0.25,0.35,1),
        divider_red=FLinearColor(0.2,0.08,0.12,1),
        border_gold=FLinearColor(0.2,0.5,0.7,1), border_dark=FLinearColor(0,0.01,0.02,1),
        close_bg=FLinearColor(0.1,0.4,0.8,1),
        shadow1=FLinearColor(0,0,0,0.8), shadow2=FLinearColor(0,0,0,0.6),
        shadow3=FLinearColor(0,0,0,0.4), shadow4=FLinearColor(0,0,0,0.22),
        shadow5=FLinearColor(0,0,0,0.12), transparent=FLinearColor(0,0,0,0.01),
        traffic_red=FLinearColor(1.0,0.373,0.341,1),
        traffic_yellow=FLinearColor(1.0,0.741,0.180,1),
        traffic_green=FLinearColor(0.157,0.784,0.251,1),
        status_online=FLinearColor(0.180,0.800,0.443,1),
        sidebar_active=FLinearColor(0.4,0.8,1,0.15),
        card_bg=FLinearColor(0.02,0.05,0.07,1),
        card_border=FLinearColor(0.05,0.12,0.18,1),
    },
}

_G.CurrentThemeName = _G.CurrentThemeName or "DARK"
_G.C = _G.Themes[_G.CurrentThemeName]

function _G.SetTheme(themeName)
    if not _G.Themes[themeName] then return end
    _G.CurrentThemeName = themeName
    _G.C = _G.Themes[themeName]
    if _G.TakoroModState then _G.TakoroModState.SavedTheme = themeName end
    --("[THEME] Ganti ke: " .. themeName)
    if _G.__RebuildMenu then pcall(_G.__RebuildMenu) end
end

-- ============================================================
-- [3] ESP HELPERS
-- ============================================================
local _slua = rawget(_G, "slua")
local function Valid(obj)
    if not obj then return false end
    if _slua and _slua.isValid then
        local ok, v = pcall(_slua.isValid, obj)
        if not ok or not v then return false end
    end
    return true
end

local C_GREEN     = {R=0, G=255, B=0, A=255}
local C_RED       = {R=255, G=0, B=0, A=255}
local C_YELLOW    = {R=255, G=255, B=0, A=255}
local C_WHITE     = {R=255, G=255, B=255, A=255}
local C_BLUE_TEXT = {R=0, G=200, B=255, A=255}
local C_CYAN      = {R=0, G=255, B=255, A=255}

local function SafeAddMark(id, pos, z, str, size, actor)
    local mark = nil
    pcall(function()
        local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
        if InGameMarkTools and InGameMarkTools.ClientAddMapMark then
            mark = InGameMarkTools.ClientAddMapMark(id, pos, z, str, size, actor)
            if mark then _G.TakoroModState.TrackedMarks[mark] = true end
        end
    end)
    return mark
end

local function SafeRemoveMark(mark)
    if not mark then return end
    pcall(function()
        local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
        if InGameMarkTools and InGameMarkTools.HideMapMark then InGameMarkTools.HideMapMark(mark) end
        if InGameMarkTools and InGameMarkTools.RemoveMapMark then InGameMarkTools.RemoveMapMark(mark) end
    end)
    _G.TakoroModState.TrackedMarks[mark] = nil
end

local function GetSafeEnemyKey(enemy)
    if Valid(enemy) then
        if enemy.PlayerKey then return tostring(enemy.PlayerKey) end
        if type(enemy.GetUniqueID) == "function" then return tostring(enemy:GetUniqueID()) end
    end
    return tostring(enemy)
end

local function CheckIsAI(pawn, markData)
    if markData.AK_IS_BOT ~= nil then return markData.AK_IS_BOT, true end
    local isAI = false
    local hasChecked = false
    pcall(function()
        if pawn.bIsAI == true or pawn.IsAI == true then isAI = true; hasChecked = true end
        if type(pawn.IsBot) == "function" and pawn:IsBot() then isAI = true; hasChecked = true end
        local pState = pawn.PlayerState or (type(pawn.GetPlayerState) == "function" and pawn:GetPlayerState())
        if Valid(pState) then
            hasChecked = true
            if pState.bIsABot == true or pState.bIsBot == true then isAI = true end
        end
    end)
    if hasChecked then markData.AK_IS_BOT = isAI end
    return isAI, hasChecked
end

-- ============================================================
-- [4] InitializeNativeESP (SAFE)
-- ============================================================
local function InitializeNativeESP()
    if _G.TakoroModState.NativeESPReady then return true end
    local ok = pcall(function()
        local GamePlayTools = nil
        local okReq, reqResult = pcall(function() return require("GameLua.Mod.BaseMod.Common.GamePlayTools") end)
        if okReq and reqResult then GamePlayTools = reqResult end
        if not GamePlayTools then GamePlayTools = package.loaded["GameLua.Mod.BaseMod.Common.GamePlayTools"] end
        if not GamePlayTools then return end
        if type(GamePlayTools.GetCurrentConfig) ~= "function" then return end
        local currentMarkCfg = GamePlayTools.GetCurrentConfig("ScreenMarkConfig")
        if not currentMarkCfg then return end
        local function ApplyCfg(cfg)
            if not cfg then return end
            if cfg[1006] then
                cfg[1006].bBindBlocked = true
                cfg[1006].bBindOutScreen = true
                cfg[1006].MaxWidgetNum = 99
                cfg[1006].MaxShowDistance = 6000000
                cfg[1006].bScaleByDistance = false
                cfg[1006].BindSocketName = "root"
                cfg[1006].bUseLuaWorldSocketName = true
                if _FVector then cfg[1006].WorldPositionOffset = _FVector(0, 0, -30) end
            end
            cfg[8888] = {
                UIPathName = "/Game/Mod/EvoBase/BluePrints/UIBP/QuickSign/QuickSign_TipHitEnemy_UIBP_New.QuickSign_TipHitEnemy_UIBP_New_C",
                MaxWidgetNum = 99, MaxShowDistance = 6000000, bBindOutScreen = true, bBindBlocked = true,
                bIsBindingActor = true, BindSocketName = "head", bUseLuaWorldSocketName = true,
                WorldPositionOffset = _FVector and _FVector(0, 0, 30) or nil, bNeedPreLoad = true, Priority = 2
            }
            cfg[9999] = {
                UIPathName = "/Game/Mod/EvoBase/BluePrints/UIBP/QuickSign/QuickSign_TipHitEnemy_UIBP_New.QuickSign_TipHitEnemy_UIBP_New_C",
                MaxWidgetNum = 99, MaxShowDistance = 6000000, bBindOutScreen = true, bBindBlocked = true,
                bIsBindingActor = true, BindSocketName = "head", bUseLuaWorldSocketName = true,
                WorldPositionOffset = _FVector and _FVector(0, 0, 50) or nil, bNeedPreLoad = true, Priority = 2
            }
        end
        ApplyCfg(currentMarkCfg)
        for k, cfg in pairs(package.loaded) do
            if type(k) == "string" and string.find(k, "ScreenMarkConfig") and type(cfg) == "table" then
                ApplyCfg(cfg)
            end
        end
    end)
    if ok then _G.TakoroModState.NativeESPReady = true end
    return ok
end
_G.InitializeNativeESP = InitializeNativeESP

-- ============================================================
-- [5] GET ENEMY TARGETS
-- ============================================================
_G.GetEnemyTargetsFromActors = function(radius)
    local result = {}
    local player = _G.GameplayData and _G.GameplayData.GetPlayerCharacter and _G.GameplayData.GetPlayerCharacter()
    if not slua.isValid(player) then return result end
    local allCharacters = {}
    if _G.GameplayData.GetAllPlayerCharacters then
        allCharacters = _G.GameplayData.GetAllPlayerCharacters()
    elseif _G.GameplayData.GameCharacters then
        for _, char in pairs(_G.GameplayData.GameCharacters) do table.insert(allCharacters, char) end
    end
    local myTeam = player:GetTeamID()
    for _, actor in pairs(allCharacters) do
        if slua.isValid(actor) and actor ~= player and actor.GetTeamID and actor:IsAlive() then
            if actor:GetTeamID() ~= myTeam then
                local dist = player:GetDistanceTo(actor)
                if dist <= radius then table.insert(result, actor) end
            end
        end
    end
    return result
end

-- ============================================================
-- [6] WALLHACK / CHAMS
-- ============================================================
local SCALE_COLOR_V2 = {R=3, G=3, B=0, A=0}

local function GetAllSkeletalMeshes(enemy, markData)
    local curTime = os.clock()
    -- ✅ Cache 1 detik (dari 0.5s) — mesh jarang berubah
    if markData and markData.CachedMeshes and markData.CachedMeshTime 
       and (curTime - markData.CachedMeshTime < 1.0) then
        -- Validasi cepat tanpa iterasi berat
        local validMeshes = {}
        local needRebuild = false
        for _, cachedMesh in ipairs(markData.CachedMeshes) do
            if not Valid(cachedMesh) then
                needRebuild = true
                break
            end
            table.insert(validMeshes, cachedMesh)
        end
        if not needRebuild then
            return validMeshes
        end
        markData.CachedMeshes = nil
        markData.CachedMeshTime = nil
    end
    
    local meshes = {}
    if Valid(enemy.Mesh) then table.insert(meshes, enemy.Mesh) end
    
    pcall(function()
        local SkeletalMeshClass = import("SkeletalMeshComponent")
        if SkeletalMeshClass and type(enemy.GetComponentsByClass) == "function" then
            local childs = enemy:GetComponentsByClass(SkeletalMeshClass)
            if childs then
                local count = type(childs.Num) == "function" and childs:Num() or #childs
                for i = 1, count do
                    local comp = type(childs.Get) == "function" and childs:Get(i-1) or childs[i]
                    if Valid(comp) and comp ~= enemy.Mesh then 
                        table.insert(meshes, comp) 
                    end
                end
            end
        end
    end)
    
    if markData then 
        markData.CachedMeshes = meshes 
        markData.CachedMeshTime = curTime 
    end
    return meshes
end

local function UndoWallXuyenTuong(enemy, markData)
    -- ✅ GUARD: kalau tidak pernah diapply, langsung keluar
    if not markData.WallhackApplied then return end
    
    pcall(function()
        local meshes = GetAllSkeletalMeshes(enemy, markData)
        for _, mesh in ipairs(meshes) do
            if Valid(mesh) then
                pcall(function() 
                    if type(mesh.SetRenderCustomDepth) == "function" then 
                        mesh:SetRenderCustomDepth(false) 
                    end 
                end)
                for i = 0, 10 do
                    local matInterface = mesh:GetMaterial(i)
                    if Valid(matInterface) then
                        local baseMat = matInterface:GetBaseMaterial()
                        if Valid(baseMat) then 
                            baseMat.bDisableDepthTest = false 
                        end
                    end
                end
            end
        end
    end)
    
    markData.WallhackApplied = false
    markData.WallhackDirty = false
end

local function ApplyWallXuyenTuong(enemy, markData)
    -- ✅ GUARD: kalau sudah diapply & tidak dirty, langsung keluar
    if markData.WallhackApplied and not markData.WallhackDirty then
        return
    end
    
    pcall(function()
        local meshes = GetAllSkeletalMeshes(enemy, markData)
        for _, mesh in ipairs(meshes) do
            if Valid(mesh) then
                pcall(function()
                    if type(mesh.SetRenderCustomDepth) == "function" then 
                        mesh:SetRenderCustomDepth(true) 
                    end
                    if type(mesh.SetCustomDepthStencilValue) == "function" then 
                        mesh:SetCustomDepthStencilValue(252) 
                    end
                end)
                for i = 0, 10 do
                    local matInterface = mesh:GetMaterial(i)
                    if not Valid(matInterface) then break end
                    local baseMat = matInterface:GetBaseMaterial()
                    if Valid(baseMat) then 
                        baseMat.bDisableDepthTest = true 
                        baseMat.BlendMode = 2 
                    end
                end
            end
        end
    end)
    
    markData.WallhackApplied = true
    markData.WallhackDirty = false
end

local function ApplyColorBodyV2(enemy, pc, markData)
    pcall(function()
        local meshes = GetAllSkeletalMeshes(enemy, markData)
        if #meshes == 0 then return end
        
        local curTime = os.clock()
        -- LoS check tetap throttle 0.3s (sudah optimal)
        if markData.LastVisCheckTime == nil or (curTime - markData.LastVisCheckTime) > 0.3 then
            markData.LastVisCheckTime = curTime
            local isHidden = true
            pcall(function()
                if Valid(pc) and type(pc.LineOfSightTo) == "function" then
                    if pc:LineOfSightTo(enemy) then 
                        isHidden = false 
                    else 
                        isHidden = true 
                    end
                end
            end)
            markData.CachedHiddenState = isHidden
        end
        
        local hidden = markData.CachedHiddenState
        if hidden == nil then hidden = true end
        
        local cData = _G.TakoroModState.CustomTextData or {}
        local hiddenColor = {R = cData.HiddenR or 150, G = cData.HiddenG or 0, B = cData.HiddenB or 0, A = cData.HiddenA or 25}
        local visibleColor = {R = cData.VisibleR or 0, G = cData.VisibleG or 150, B = cData.VisibleB or 0, A = cData.VisibleA or 25}
        local finalColor = hidden and hiddenColor or visibleColor
        local colorHash = string.format("%d_%d_%d_%d", finalColor.R, finalColor.G, finalColor.B, finalColor.A)
        
        local currentMeshCount = #meshes
        local isMeshChanged = (markData.LastMeshCount ~= currentMeshCount)
        
        -- ✅ GUARD: skip kalau tidak ada perubahan
        if not isMeshChanged 
           and markData.LastHiddenState == hidden 
           and markData.LastColorHash == colorHash 
           and markData.ColorApplied then
            return
        end
        
        if isMeshChanged and markData.MIDs then 
            markData.MIDs = {} 
        end
        
        markData.LastHiddenState = hidden
        markData.LastMeshCount = currentMeshCount
        markData.LastColorHash = colorHash
        markData.ColorApplied = true
        
        for meshIndex, mesh in ipairs(meshes) do
            if Valid(mesh) then
                pcall(function()
                    mesh.LDMaxDrawDistance = -99999
                    mesh.MaxDrawDistanceOffset = -99999
                    mesh.CachedMaxDrawDistance = -99999
                    mesh.UseScopeDistanceCulling = true
                    mesh.PrimitiveShadingStrategy = 1
                    mesh.ShadingRate = 6
                end)
                for i = 0, 10 do
                    local matInterface = mesh:GetMaterial(i)
                    if not Valid(matInterface) then break end
                    local baseMat = matInterface:GetBaseMaterial()
                    if Valid(baseMat) then
                        local matName = tostring(baseMat)
                        if string.find(matName, "Master_Mask", 1, true) then
                            if not markData.MIDs then markData.MIDs = {} end
                            local meshKey = "Mesh_" .. tostring(meshIndex)
                            if not markData.MIDs[meshKey] then 
                                markData.MIDs[meshKey] = {} 
                            end
                            local mid = markData.MIDs[meshKey][i]
                            if not Valid(mid) then
                                mid = mesh:CreateAndSetMaterialInstanceDynamic(i)
                                markData.MIDs[meshKey][i] = mid
                            end
                            if Valid(mid) then
                                mid:SetVectorParameterValue("颜色", finalColor)
                                mid:SetVectorParameterValue("Para_Color", finalColor)
                                mid:SetVectorParameterValue("Tint", finalColor)
                                mid:SetVectorParameterValue("Color", finalColor)
                                mid:SetVectorParameterValue("BaseColor", finalColor)
                                mid:SetVectorParameterValue("ParaScaleOffset", SCALE_COLOR_V2)
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function UndoColorBodyV2(enemy, markData)
    pcall(function()
        if markData.ColorApplied then
            local meshes = GetAllSkeletalMeshes(enemy, markData)
            for meshIndex, mesh in ipairs(meshes) do
                if Valid(mesh) then
                    pcall(function()
                        mesh.PrimitiveShadingStrategy = 0
                        mesh.ShadingRate = 1
                    end)
                    local meshKey = "Mesh_" .. tostring(meshIndex)
                    if markData.MIDs and markData.MIDs[meshKey] then
                        for i, mid in pairs(markData.MIDs[meshKey]) do
                            if Valid(mid) then
                                local defC = {R=1, G=1, B=1, A=1}
                                mid:SetVectorParameterValue("颜色", defC)
                                mid:SetVectorParameterValue("Tint", defC)
                                mid:SetVectorParameterValue("Color", defC)
                                mid:SetVectorParameterValue("BaseColor", defC)
                            end
                        end
                    end
                end
            end
            markData.ColorApplied = false
            markData.LastColorHash = ""
            markData.LastHiddenState = nil
        end
    end)
end

local function ApplyColorBodyV3(enemy, markData)
    pcall(function()
        -- ✅ GUARD 1: skip total kalau sudah applied & tidak dirty
        if markData.ColorV3Applied and not markData.ColorV3Dirty then
            return
        end
        
        local meshes = GetAllSkeletalMeshes(enemy, markData)
        if #meshes == 0 then return end
        
        local cData = _G.TakoroModState.CustomTextData or {}
        local hidChoice = cData.ColorV3Hidden or 1
        local visChoice = cData.ColorV3Visible or 2
        local v3Thick = cData.ColorV3Thickness or 4
        local currentHash = string.format("%d_%d_%d", hidChoice, visChoice, v3Thick)
        
        local colorChanged = (markData.LastColorV3Hash ~= currentHash)
        markData.LastColorV3Hash = currentHash
        
        local function GetColorRGB(choice)
            if choice == 1 then return 255, 0, 0 end
            if choice == 2 then return 0, 255, 0 end
            if choice == 3 then return 0, 0, 255 end
            if choice == 4 then return 255, 255, 0 end
            if choice == 5 then return 255, 0, 255 end
            if choice == 6 then return 255, 255, 255 end
            return 255, 0, 0
        end
        
        local hR, hG, hB = GetColorRGB(hidChoice)
        local vR, vG, vB = GetColorRGB(visChoice)
        local invisColor = { R=hR, G=hG, B=hB, A=255, r=hR, g=hG, b=hB, a=255 }
        local glowIntensity = 80.0
        local LinearColorClass = import("LinearColor") or _G.FLinearColor
        local visColor = LinearColorClass and LinearColorClass(
            (vR/255)*glowIntensity, 
            (vG/255)*glowIntensity, 
            (vB/255)*glowIntensity, 
            1.0
        ) or { R=vR*glowIntensity, G=vG*glowIntensity, B=vB*glowIntensity, A=255 }
        local scale = { R=3.0, G=3.0, B=0.0, A=0.0, r=3.0, g=3.0, b=0.0, a=0.0 }
        
        markData.MIDs_V3 = markData.MIDs_V3 or {}
        
        for meshIndex, comp in ipairs(meshes) do
            if Valid(comp) then
                local compKey = "MeshV3_" .. tostring(meshIndex)
                markData.MIDs_V3[compKey] = markData.MIDs_V3[compKey] or {}
                
                pcall(function()
                    if comp.PrimitiveShadingStrategy ~= 1 then
                        comp.UseScopeDistanceCulling = false
                        comp.PrimitiveShadingStrategy = 1
                        comp.ShadingRate = 6
                    end
                end)
                
                for i = 0, 10 do
                    local matInterface = comp:GetMaterial(i)
                    if not Valid(matInterface) then break end
                    
                    local baseMat = matInterface:GetBaseMaterial()
                    if Valid(baseMat) then
                        if baseMat.bDisableDepthTest ~= true then 
                            baseMat.bDisableDepthTest = true 
                        end
                        if baseMat.BlendMode ~= 2 then 
                            baseMat.BlendMode = 2 
                        end
                    end
                    
                    local currentCached = markData.MIDs_V3[compKey][i]
                    local needUpdateColor = false
                    
                    if not Valid(currentCached) then
                        local newMid = comp:CreateAndSetMaterialInstanceDynamic(i)
                        if Valid(newMid) then
                            markData.MIDs_V3[compKey][i] = newMid
                            currentCached = newMid
                            needUpdateColor = true
                        end
                    elseif colorChanged then 
                        needUpdateColor = true 
                    end
                    
                    if Valid(currentCached) and needUpdateColor then
                        pcall(function()
                            currentCached:SetVectorParameterValue("颜色", invisColor)
                            currentCached:SetVectorParameterValue("Para_Color", invisColor)
                            currentCached:SetVectorParameterValue("Tint", invisColor)
                            currentCached:SetVectorParameterValue("Color", invisColor)
                            currentCached:SetVectorParameterValue("BaseColor", invisColor)
                            currentCached:SetVectorParameterValue("ParaScaleOffset", scale)
                        end)
                    end
                end
                
                pcall(function()
                    if comp.SetDrawIdeaOutline then
                        comp:SetDrawIdeaOutline(true)
                        if comp.OverrideIdeaOutlineColor then 
                            comp:OverrideIdeaOutlineColor(true, visColor) 
                        end
                        if comp.OverrideIdeaOutlineThickness then 
                            comp:OverrideIdeaOutlineThickness(true, v3Thick) 
                        end
                    end
                end)
            end
        end
        
        markData.ColorV3Applied = true
        markData.ColorV3Dirty = false
    end)
end


local function UndoColorBodyV3(enemy, markData)
    pcall(function()
        if markData.ColorV3Applied then
            local meshes = GetAllSkeletalMeshes(enemy, markData)
            for meshIndex, comp in ipairs(meshes) do
                if Valid(comp) then
                    pcall(function()
                        comp.PrimitiveShadingStrategy = 0
                        comp.ShadingRate = 1
                    end)
                    for i = 0, 10 do
                        local s, matInterface = pcall(function() return comp:GetMaterial(i) end)
                        if s and Valid(matInterface) then
                            local s2, baseMat = pcall(function() return matInterface:GetBaseMaterial() end)
                            if s2 and Valid(baseMat) then
                                baseMat.bDisableDepthTest = false
                                baseMat.BlendMode = 1
                            end
                        end
                    end
                    local compKey = "MeshV3_" .. tostring(meshIndex)
                    if markData.MIDs_V3 and markData.MIDs_V3[compKey] then
                        for i, mid in pairs(markData.MIDs_V3[compKey]) do
                            if Valid(mid) then
                                pcall(function()
                                    local defC = {R=1, G=1, B=1, A=1, r=1, g=1, b=1, a=1}
                                    mid:SetVectorParameterValue("颜色", defC)
                                    mid:SetVectorParameterValue("Tint", defC)
                                    mid:SetVectorParameterValue("Color", defC)
                                end)
                            end
                        end
                    end
                    pcall(function() if comp.SetDrawIdeaOutline then comp:SetDrawIdeaOutline(false) end end)
                end
            end
            markData.ColorV3Applied = false
            markData.LastMeshCountV3 = 0
            if markData.MIDs_V3 then markData.MIDs_V3 = nil end
        end
    end)
end

local function ApplyColorBodyNew(enemy, markData)
    pcall(function()
        if not _G.ConsoleNewWallReady then
            local KismetSystemLibrary = import("KismetSystemLibrary")
            local world = slua.getWorld()
            if KismetSystemLibrary and world then
                pcall(function() KismetSystemLibrary.ExecuteConsoleCommand(world, "r.EnableDrawDyeingColor 1") end)
                pcall(function() KismetSystemLibrary.ExecuteConsoleCommand(world, "r.CustomDepth 3") end)
                pcall(function() KismetSystemLibrary.ExecuteConsoleCommand(world, "r.IdeaOutline.Enable 1") end)
                pcall(function() KismetSystemLibrary.ExecuteConsoleCommand(world, "r.Highlight.Enable 1") end)
                _G.ConsoleNewWallReady = true
            end
        end
        
        local meshes = GetAllSkeletalMeshes(enemy, markData)
        local weapon = nil
        pcall(function() weapon = enemy:GetCurrentWeapon() end)
        if slua.isValid(weapon) and slua.isValid(weapon.Mesh) then 
            table.insert(meshes, weapon.Mesh) 
        end
        
        local isBot = markData.AK_IS_BOT or false
        local currentMeshCount = #meshes
        local stateHash = (isBot and "BOT" or "PLAYER") .. "_" .. tostring(currentMeshCount)
        
        -- ✅ GUARD: skip kalau sama
        if markData.LastColorNewHash == stateHash and markData.ColorNewApplied 
           and not markData.ColorNewDirty then 
            return 
        end
        
        markData.LastColorNewHash = stateHash
        markData.ColorNewApplied = true
        markData.ColorNewDirty = false
        
        local LinearColorClass = import("LinearColor") or _G.FLinearColor
        local c_vis = LinearColorClass and LinearColorClass(0, 100, 0, 1) or {R=0, G=100, B=0, A=1}
        local c_occ = LinearColorClass and LinearColorClass(100, 0, 0, 1) or {R=100, G=0, B=0, A=1}
        local c_bVis = LinearColorClass and LinearColorClass(49, 48, 0, 100) or {R=49, G=48, B=0, A=100}
        local c_bOcc = LinearColorClass and LinearColorClass(9, 1.5, 45, 100) or {R=9, G=1.5, B=45, A=100}
        local visColor = isBot and c_bVis or c_vis
        local occColor = isBot and c_bOcc or c_occ
        
        for _, mesh in ipairs(meshes) do
            if Valid(mesh) then
                pcall(function()
                    if type(mesh.SetDrawDyeing) == "function" then
                        mesh:SetDrawDyeing(true) 
                        mesh:SetDrawDyeingMode(1)
                        mesh:SetVisibleDyeingColor(visColor) 
                        mesh:SetOccludedDyeingColor(occColor)
                        mesh:SetDyeingColorFadeDistance(99999.0) 
                        mesh:SetDyeingColorMinMaxDistance(0.0, 99999.0)
                        mesh:SetDrawHighlight(true) 
                        mesh:OverrideHighlightColor(visColor)
                        mesh:SetHighlightCanBeOccluded(false) 
                        mesh:SetDrawIdeaOutline(true)
                        mesh:SetIdeaOutlineNew(true) 
                        mesh:SetIdeaOutlineOcclusionHighlight(true)
                        mesh:OverrideIdeaOutlineColor(visColor) 
                        mesh:SetIdeaOutlineOcclusionColor(occColor)
                        mesh:OverrideIdeaOutlineThickness(20.0) 
                        mesh:SetIdeaOverrideOutlineAndOcclusion(true)
                        mesh:SetRenderCustomDepth(true) 
                        mesh:SetCustomDepthStencilValue(255)
                    end
                end)
            end
        end
    end)
end

local function UndoColorBodyNew(enemy, markData)
    pcall(function()
        if markData.ColorNewApplied then
            local meshes = GetAllSkeletalMeshes(enemy, markData)
            local weapon = nil
            pcall(function() weapon = enemy:GetCurrentWeapon() end)
            if slua.isValid(weapon) and slua.isValid(weapon.Mesh) then table.insert(meshes, weapon.Mesh) end
            for _, mesh in ipairs(meshes) do
                if Valid(mesh) then
                    pcall(function()
                        if type(mesh.SetDrawDyeing) == "function" then
                            mesh:SetDrawDyeing(false) mesh:SetDrawHighlight(false)
                            mesh:SetDrawIdeaOutline(false) mesh:SetRenderCustomDepth(false)
                        end
                    end)
                end
            end
            markData.ColorNewApplied = false
            markData.LastColorNewHash = ""
        end
    end)
end

-- ============================================================
-- [7] IPAD VIEW TICK
-- ============================================================
_G.IpadViewTick = function()
    if _G.TakoroModState.IsExpired then return end
    if not _G.TakoroModConfig.IpadView then return end
    if not _G.GameplayData then
        pcall(function() _G.GameplayData = require("GameLua.GameCore.Data.GameplayData") end)
    end
    if not _G.GameplayData then return end
    local player = _G.GameplayData.GetPlayerCharacter()
    if not Valid(player) then return end
    local uTPPCam = player.ThirdPersonCameraComponent
    local cData = _G.TakoroModState.CustomTextData or {}
    local targetTPP = cData.IpadViewFOV or 120
    if Valid(uTPPCam) and uTPPCam.FieldOfView ~= targetTPP then uTPPCam.FieldOfView = targetTPP end
end

-- ============================================================
-- [8] ESP TICK
-- ============================================================
_G.ESPTick = function()
    if _G.TakoroModState.IsExpired then return end
    if not (_G.TakoroModConfig.EspVipPro or _G.TakoroModConfig.EspLoai5
         or _G.TakoroModConfig.EspDistance or _G.TakoroModConfig.EspRadar
         or _G.TakoroModConfig.EspLoai8
         or _G.TakoroModConfig.WallXuyenTuong or _G.TakoroModConfig.ColorBodyV2
         or _G.TakoroModConfig.ColorBodyV3 or _G.TakoroModConfig.ColorBodyNew
         or _G.TakoroModConfig.IpadView or _G.TakoroModConfig.IpadViewScope) then 
        return 
    end
    
    if not _G.GameplayData then
        pcall(function() _G.GameplayData = require("GameLua.GameCore.Data.GameplayData") end)
        if not _G.GameplayData then 
            pcall(function() 
                _G.GameplayData = package.loaded["GameLua.GameCore.Data.GameplayData"] 
            end) 
        end
    end
    if not _G.GameplayData then return end
    
    if not _G.TakoroModState.NativeESPReady then
        if _G.InitializeNativeESP then pcall(_G.InitializeNativeESP) end
    end
    
    local player = _G.GameplayData.GetPlayerCharacter()
    if not Valid(player) then return end
    
    local pc = player:GetPlayerControllerSafety()
    if not Valid(pc) then return end
    
    local Cached_MyHUD = pc.MyHUD
    if not Valid(Cached_MyHUD) then return end
    
    local allCharacters = {}
    if _G.GameplayData.GetAllPlayerCharacters then
        allCharacters = _G.GameplayData.GetAllPlayerCharacters()
    elseif _G.GameplayData.GameCharacters then
        for _, char in pairs(_G.GameplayData.GameCharacters) do 
            table.insert(allCharacters, char) 
        end
    end
    
    local now = os.clock()
    
    -- ✅ Config hash global (dihitung sekali, dipakai semua musuh)
    local configHash = table.concat({
        tostring(_G.TakoroModConfig.WallXuyenTuong and 1 or 0),
        tostring(_G.TakoroModConfig.ColorBodyV2 and 1 or 0),
        tostring(_G.TakoroModConfig.ColorBodyV3 and 1 or 0),
        tostring(_G.TakoroModConfig.ColorBodyNew and 1 or 0),
        tostring(_G.TakoroModState.CustomTextData.ColorV3Hidden or 0),
        tostring(_G.TakoroModState.CustomTextData.ColorV3Visible or 0),
        tostring(_G.TakoroModState.CustomTextData.ColorV3Thickness or 0),
        tostring(_G.TakoroModState.CustomTextData.HiddenR or 0),
        tostring(_G.TakoroModState.CustomTextData.VisibleR or 0),
    }, "|")
    
    -- Cek apakah config global berubah (untuk mark semua dirty)
    local globalConfigChanged = (_G.TakoroModState.LastGlobalConfigHash ~= configHash)
    _G.TakoroModState.LastGlobalConfigHash = configHash
    
    for _, enemy in pairs(allCharacters) do
        if Valid(enemy) and enemy ~= player and enemy.TeamID ~= player.TeamID then
            local eKey = GetSafeEnemyKey(enemy)
            _G.TakoroModState.EnemyMarks[eKey] = _G.TakoroModState.EnemyMarks[eKey] or { 
                enemy = enemy,
                LastPosX = nil, LastPosY = nil, LastPosZ = nil,
                LastConfigHash = nil,
                LastRenderTick = 0,
                IsFullyRendered = false,
                SkipUntilTick = 0,
                FarAway = false,
                WallhackDirty = false,
                ColorV3Dirty = false,
                ColorNewDirty = false,
            }
            local markData = _G.TakoroModState.EnemyMarks[eKey]
            markData.enemy = enemy
            
            -- Hitung jarak
            local distM = 0
            pcall(function() distM = player:GetDistanceTo(enemy) / 100 end)
            
            -- ============================================================
            -- ✅ OPTIMASI 1: SKIP MUSUH JAUH > 400m
            -- ============================================================
            local RENDER_MAX_DIST = 350
            if distM > RENDER_MAX_DIST then
                if not markData.FarAway then
                    -- Baru keluar jangkauan: cleanup visual
                    markData.FarAway = true
                    markData.IsFullyRendered = false
                    -- Undo semua visual biar tidak makan resource
                    pcall(function() UndoWallXuyenTuong(enemy, markData) end)
                    pcall(function() UndoColorBodyV2(enemy, markData) end)
                    pcall(function() UndoColorBodyV3(enemy, markData) end)
                    pcall(function() UndoColorBodyNew(enemy, markData) end)
                end
                -- Tetap update frame UI & counter kalau aktif
                goto skip_render
            else
                if markData.FarAway then
                    -- Baru masuk jangkauan: force re-render
                    markData.FarAway = false
                    markData.IsFullyRendered = false
                    markData.WallhackDirty = true
                    markData.ColorV3Dirty = true
                    markData.ColorNewDirty = true
                end
            end
            
            -- ============================================================
            -- Health & HP (untuk frame UI)
            -- ============================================================
            local currentHp, maxHp = 100, 100
            local showFrameUI = _G.TakoroModConfig.EspLoai5 
                or _G.TakoroModConfig.EspVipPro 
                or _G.TakoroModConfig.EspLoai8
            if showFrameUI then
                pcall(function()
                    if enemy.Health then 
                        currentHp = enemy.Health 
                    elseif type(enemy.GetHealth) == "function" then 
                        currentHp = enemy:GetHealth() 
                    end
                    if enemy.HealthMax then 
                        maxHp = enemy.HealthMax 
                    elseif type(enemy.GetHealthMax) == "function" then 
                        maxHp = enemy:GetHealthMax() 
                    end
                end)
                if maxHp <= 0 then maxHp = 100 end
            end
            local hpRatio = currentHp / maxHp
            
            -- ============================================================
            -- HP BAR (VIP PRO)
            -- ============================================================
            if _G.TakoroModConfig.EspVipPro then
                pcall(function()
                    if Valid(Cached_MyHUD) and Cached_MyHUD.AddDebugText and distM <= 400 then
                        local dynamicScale = math.max(0.55, 0.95 - (distM / 400))
                        local isKnock = (currentHp <= 0 and enemy.HealthStatus == 1)
                        local hpColor = C_GREEN
                        if hpRatio < 0.3 then hpColor = C_RED
                        elseif hpRatio < 0.7 then hpColor = C_YELLOW end
                        if isKnock then hpColor = C_RED end
                        if _G.TakoroModConfig.Esp3ShowHP then
                            if not isKnock then
                                local segments = 6
                                local filled = math.floor(hpRatio * segments)
                                local startZ = 20
                                local spacing = 10.0 * dynamicScale
                                for j = 1, segments do
                                    local color = (j <= filled) and hpColor or {R=30,G=30,B=30,A=180}
                                    Cached_MyHUD:AddDebugText("█", enemy, 0.5, 
                                        {X=0,Y=-115,Z=startZ+(j*spacing)}, 
                                        {X=0,Y=-115,Z=startZ+(j*spacing)}, 
                                        color, true, false, true, nil, dynamicScale*1.2, true)
                                end
                                Cached_MyHUD:AddDebugText(
                                    string.format("%d%%", math.floor(hpRatio*100)), 
                                    enemy, 0.5, 
                                    {X=0,Y=-60,Z=startZ-12}, 
                                    {X=0,Y=-60,Z=startZ-12}, 
                                    hpColor, true, false, true, nil, dynamicScale*0.8, true)
                            else
                                Cached_MyHUD:AddDebugText("TUMBANG", enemy, 0.5, 
                                    {X=0,Y=-115,Z=50}, {X=0,Y=-115,Z=50}, 
                                    C_RED, true, false, true, nil, dynamicScale*1.0, true)
                            end
                        end
                    end
                end)
            end
            
            -- ============================================================
            -- ESP HP NATIVE (Loai8) — tetap pakai native mark
            -- ============================================================
            if _G.TakoroModConfig.EspLoai8 then
                if not markData.hpMark8 then
                    if not markData.lastHpNativeRetry 
                       or (now - markData.lastHpNativeRetry) > 1.0 then
                        markData.lastHpNativeRetry = now
                        markData.hpMark8 = SafeAddMark(1006, 
                            _FVector and _FVector(0,0,0) or {X=0,Y=0,Z=0}, 
                            0, "", 4, enemy)
                    end
                end
            else
                if markData.hpMark8 then 
                    SafeRemoveMark(markData.hpMark8) 
                    markData.hpMark8 = nil 
                    markData.lastHpNativeRetry = nil 
                end
            end
            
            -- ============================================================
            -- DISTANCE
            -- ============================================================
            if _G.TakoroModConfig.EspDistance then
                pcall(function()
                    if Valid(Cached_MyHUD) and Cached_MyHUD.AddDebugText and distM <= 400 then
                        local dynamicScale = math.max(0.55, 0.95 - (distM / 400))
                        Cached_MyHUD:AddDebugText(
                            string.format("[%dm]", math.floor(distM)), 
                            enemy, 0.5, 
                            {X=0,Y=115,Z=20}, {X=0,Y=115,Z=20}, 
                            C_BLUE_TEXT, true, false, true, nil, dynamicScale*1.5, true)
                    end
                end)
            end
            
            -- ============================================================
            -- ESP FRAME UI (Loai5)
            -- ============================================================
            if _G.TakoroModConfig.EspLoai5 then
                pcall(function()
                    if enemy.Replay_IsEnemyFrameUIExisted 
                       and not enemy:Replay_IsEnemyFrameUIExisted() then
                        enemy:Replay_CreateEnemyFrameUI(true, true)
                    end
                    if enemy.Replay_SetVisiableOfFrameUI then 
                        enemy:Replay_SetVisiableOfFrameUI(true) 
                    end
                    if enemy.Replay_UpdateEnemyFrameUI then 
                        enemy:Replay_UpdateEnemyFrameUI(hpRatio) 
                    end
                end)
            else
                pcall(function() 
                    if enemy.Replay_SetVisiableOfFrameUI then 
                        enemy:Replay_SetVisiableOfFrameUI(false) 
                    end 
                end)
            end
            
            -- ============================================================
            -- ESP RADAR
            -- ============================================================
            if _G.TakoroModConfig.EspRadar then
                if not markData.radarMark then
                    if not markData.lastRadarRetry 
                       or (now - markData.lastRadarRetry) > 1.0 then
                        markData.lastRadarRetry = now
                        if not _G.TakoroModState.NativeESPReady then 
                            if _G.InitializeNativeESP then 
                                pcall(_G.InitializeNativeESP) 
                            end 
                        end
                        markData.radarMark = SafeAddMark(8888, 
                            _FVector and _FVector(0,0,0) or {X=0,Y=0,Z=0}, 
                            0, "", 4, enemy)
                    end
                end
            else
                if markData.radarMark then 
                    SafeRemoveMark(markData.radarMark) 
                    markData.radarMark = nil 
                    markData.lastRadarRetry = nil 
                end
            end
            
            -- ============================================================
            -- ✅ RENDER CHECK (posisi + config + dirty flag)
            -- ============================================================
            -- Cek posisi berubah
            local posChanged = false
            pcall(function()
                local pos = enemy:K2_GetActorLocation()
                if pos then
                    if not markData.LastPosX 
                       or math.abs(pos.X - markData.LastPosX) > 5
                       or math.abs(pos.Y - markData.LastPosY) > 5
                       or math.abs(pos.Z - markData.LastPosZ) > 5 then
                        posChanged = true
                        markData.LastPosX = pos.X
                        markData.LastPosY = pos.Y
                        markData.LastPosZ = pos.Z
                    end
                end
            end)
            
            local configChanged = (markData.LastConfigHash ~= configHash)
            local firstRender = not markData.IsFullyRendered
            local throttleOK = (now >= (markData.SkipUntilTick or 0))
            
            -- Tentukan apakah perlu re-apply
            local needReapply = (firstRender or configChanged or globalConfigChanged) 
                             or markData.WallhackDirty 
                             or markData.ColorV3Dirty 
                             or markData.ColorNewDirty
                             or posChanged
            
            -- ============================================================
            -- APPLY RENDERING (hanya kalau perlu + throttle OK)
            -- ============================================================
            if needReapply and throttleOK then
                -- ✅ Wallhack (guard sendiri di dalam)
                if _G.TakoroModConfig.WallXuyenTuong then
                    ApplyWallXuyenTuong(enemy, markData)
                else
                    UndoWallXuyenTuong(enemy, markData)
                end
                
                -- ✅ ColorBody V2 (guard sendiri di dalam)
                if _G.TakoroModConfig.ColorBodyV2 then 
                    ApplyColorBodyV2(enemy, pc, markData) 
                else 
                    UndoColorBodyV2(enemy, markData) 
                end
                
                -- ✅ ColorBody V3 (guard sendiri di dalam)
                if _G.TakoroModConfig.ColorBodyV3 then 
                    ApplyColorBodyV3(enemy, markData) 
                else 
                    UndoColorBodyV3(enemy, markData) 
                end
                
                -- ✅ ColorBody New (guard sendiri di dalam)
                if _G.TakoroModConfig.ColorBodyNew then 
                    ApplyColorBodyNew(enemy, markData) 
                else 
                    UndoColorBodyNew(enemy, markData) 
                end
                
                markData.LastConfigHash = configHash
                markData.IsFullyRendered = true
                markData.LastRenderTick = now
                -- ✅ Throttle: jeda 150ms sebelum boleh apply lagi
                markData.SkipUntilTick = now + 0.15
            end
            
            ::skip_render::
        end
    end
    
    -- ============================================================
    -- CLEANUP MUSUH YANG SUDAH HILANG
    -- ============================================================
    local currentValidKeys = {}
    for _, enemy in pairs(allCharacters) do
        if Valid(enemy) and enemy ~= player then 
            currentValidKeys[GetSafeEnemyKey(enemy)] = true 
        end
    end
    for key, data in pairs(_G.TakoroModState.EnemyMarks) do
        if not currentValidKeys[key] then
            SafeRemoveMark(data.radarMark) 
            SafeRemoveMark(data.hpMark8)
            data.radarMark = nil 
            data.hpMark8 = nil 
            data.enemy = nil
            data.CachedMeshes = nil 
            data.MIDs = nil 
            data.MIDs_V3 = nil
            data.WallhackApplied = false 
            data.ColorApplied = false
            data.ColorV3Applied = false 
            data.ColorNewApplied = false
            _G.TakoroModState.EnemyMarks[key] = nil
        end
    end
end

-- ============================================================
-- [9] AIM TOUCH (disingkat, sama seperti aslinya)
-- ============================================================
_G.AimTouch = function()
    pcall(function()
        if not _G.TakoroModConfig.AimTouchEnable then return end
        local player = _G.GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local pc = player:GetPlayerControllerSafety()
        if not slua.isValid(pc) then return end
        local isFiring = player.bIsWeaponFiring
        local isADS = player.bIsGunADS
        local weapon = player.WeaponManagerComponent and player.WeaponManagerComponent.CurrentWeaponReplicated
        if not weapon and type(player.GetCurrentShootWeapon) == "function" then weapon = player:GetCurrentShootWeapon() end
        local isShotgun = false
        local isSniper = false
        local isMortar = false
        local currentAmmo = 1
        if slua.isValid(weapon) then
            local wID = type(weapon.GetWeaponID) == "function" and weapon:GetWeaponID() or 0
            local wName = type(weapon.GetWeaponName) == "function" and weapon:GetWeaponName() or ""
            if (wID >= 1030000 and wID < 1040000) or wName:find("S686") or wName:find("S1897") or wName:find("S12") or wName:find("DBS") or wName:find("M1014") then isShotgun = true end
            if wName:find("Kar98") or wName:find("M24") or wName:find("AWM") or wName:find("Mosin") or wName:find("Win94") or wName:find("AMR") or wName:find("SKS") or wName:find("SLR") or wName:find("Mini") or wName:find("Mk14") or wName:find("QBU") or wName:find("Mk12") or wName:find("VSS") then isSniper = true end
            if wName:lower():find("mortar") or wName:lower():find("cối") then isMortar = true end
            if type(weapon.GetCurrentAmmo) == "function" then currentAmmo = weapon:GetCurrentAmmo()
            elseif weapon.ShootWeaponComponent and type(weapon.ShootWeaponComponent.GetCurrentAmmo) == "function" then currentAmmo = weapon.ShootWeaponComponent:GetCurrentAmmo()
            elseif weapon.CurrentAmmo ~= nil then currentAmmo = weapon.CurrentAmmo end
        end
        if _G.TakoroModState.IsAutoFiring then
            pcall(function()
                player.bIsWeaponFiring = false
                if type(player.SetIsWeaponFiring) == "function" then player:SetIsWeaponFiring(false) end
                if slua.isValid(pc) and type(pc.SetIsWeaponFiring) == "function" then pc:SetIsWeaponFiring(false) end
                local wepMgr = player.WeaponManagerComponent
                if slua.isValid(wepMgr) then wepMgr.bIsWeaponFiring = false end
            end)
            _G.TakoroModState.IsAutoFiring = false
        end
        if isShotgun and currentAmmo <= 0 then return end
        local cond = 2
        local prioMode = 1
        local boneIdx = 1
        local speedVal = 50
        local fovVal = 30
        local maxDistMeters = 50
        local useVisCheck = false
        local igKnock = false
        local igBot = false
        local predVal = 0
        local recoilCompVal = 0
        if isMortar and _G.TakoroModConfig.AimTouchMortar then
            local isPlaced = false
            pcall(function() if weapon and weapon.MortarState == 2 then isPlaced = true end end)
            if not isPlaced then return end
            cond = 2 prioMode = 1 boneIdx = 4 speedVal = 100
            fovVal = _G.TakoroModState.CustomTextData.AimTouchMortarFOV or 360
            maxDistMeters = 2000
            predVal = _G.TakoroModState.CustomTextData.AimTouchMortarPred or 0
        elseif isShotgun and _G.TakoroModConfig.AimTouchSG then
            cond = _G.TakoroModState.CustomTextData.AimTouchSGCond or 1
            if _G.TakoroModConfig.AimTouchSGAutoFire then cond = 2 end
            if cond == 1 and not isFiring then return end
            prioMode = _G.TakoroModState.CustomTextData.AimTouchSGPrio or 1
            boneIdx = _G.TakoroModState.CustomTextData.AimTouchSGBone or 2
            speedVal = _G.TakoroModState.CustomTextData.AimTouchSGSpeed or 80
            fovVal = _G.TakoroModState.CustomTextData.AimTouchSGFOV or 40
            maxDistMeters = _G.TakoroModState.CustomTextData.AimTouchSGDist or 30
            useVisCheck = _G.TakoroModConfig.AimTouchSGVisCheck
            igKnock = _G.TakoroModConfig.AimTouchSGIgKnock
            igBot = _G.TakoroModConfig.AimTouchSGIgBot
        elseif isADS then
            if isSniper and _G.TakoroModConfig.AimTouchScopeSniper then
                cond = 2
                prioMode = _G.TakoroModState.CustomTextData.AimTouchSniperPrio or 1
                boneIdx = _G.TakoroModState.CustomTextData.AimTouchSniperBone or 1
                speedVal = _G.TakoroModState.CustomTextData.AimTouchSniperSpeed or 30
                fovVal = _G.TakoroModState.CustomTextData.AimTouchSniperFOV or 20
                maxDistMeters = _G.TakoroModState.CustomTextData.AimTouchSniperDist or 400
                useVisCheck = _G.TakoroModConfig.AimTouchSniperVisCheck
                igKnock = _G.TakoroModConfig.AimTouchSniperIgKnock
                igBot = _G.TakoroModConfig.AimTouchSniperIgBot
                predVal = _G.TakoroModState.CustomTextData.AimTouchSniperPred or 0
            elseif _G.TakoroModConfig.AimTouchScopeAll then
                cond = 1
                if not isFiring then return end
                prioMode = _G.TakoroModState.CustomTextData.AimTouchScopePrio or 1
                boneIdx = _G.TakoroModState.CustomTextData.AimTouchScopeBone or 2
                speedVal = _G.TakoroModState.CustomTextData.AimTouchScopeSpeed or 40
                fovVal = _G.TakoroModState.CustomTextData.AimTouchScopeFOV or 20
                maxDistMeters = _G.TakoroModState.CustomTextData.AimTouchScopeDist or 300
                useVisCheck = _G.TakoroModConfig.AimTouchScopeVisCheck
                igKnock = _G.TakoroModConfig.AimTouchScopeIgKnock
                igBot = _G.TakoroModConfig.AimTouchScopeIgBot
                predVal = _G.TakoroModState.CustomTextData.AimTouchScopePred or 0
                recoilCompVal = _G.TakoroModState.CustomTextData.AimTouchScopeRecoil or 0
            else return end
        else
            if not _G.TakoroModConfig.AimTouchHipfire then return end
            cond = 1
            if not isFiring then return end
            prioMode = _G.TakoroModState.CustomTextData.AimTouchHipPrio or 1
            boneIdx = _G.TakoroModState.CustomTextData.AimTouchHipBone or 1
            speedVal = _G.TakoroModState.CustomTextData.AimTouchHipSpeed or 50
            fovVal = _G.TakoroModState.CustomTextData.AimTouchHipFOV or 30
            maxDistMeters = _G.TakoroModState.CustomTextData.AimTouchHipDist or 250
            useVisCheck = _G.TakoroModConfig.AimTouchHipVisCheck
            igKnock = _G.TakoroModConfig.AimTouchHipIgKnock
            igBot = _G.TakoroModConfig.AimTouchHipIgBot
        end
        local currentMaxDist = maxDistMeters * 100
        local enemies = _G.GetEnemyTargetsFromActors(currentMaxDist)
        if not enemies or #enemies == 0 then return end
        local FVector2D_inner = import("Vector2D")
        local UGameplayStatics = import("GameplayStatics")
        local KismetMathLibrary = import("KismetMathLibrary")
        local camManager = UGameplayStatics.GetPlayerCameraManager(pc, 0)
        if not slua.isValid(camManager) then return end
        local camLoc = camManager:GetCameraLocation()
        if not camLoc then return end
        local ui_util = require("client.common.ui_util")
        if not ui_util then return end
        local viewportSize = ui_util.GetViewportSize()
        if not viewportSize then return end
        local centerX = viewportSize.X * 0.5
        local centerY = viewportSize.Y * 0.5
        local FOV_RADIUS = (fovVal / 100.0) * (viewportSize.X / 2.0)
        local bestTarget = nil
        local bestScore = 99999999
        local selBoneName = "head"
        if boneIdx == 1 then selBoneName = "head"
        elseif boneIdx == 2 then selBoneName = "spine_03"
        elseif boneIdx == 3 then selBoneName = "spine_01"
        elseif boneIdx == 4 then selBoneName = "pelvis" end
        for i, target in ipairs(enemies) do
            if not slua.isValid(target) then goto continue end
            pcall(function() if slua.isValid(target.Mesh) then target.Mesh.MeshComponentUpdateFlag = 0 end end)
            if igKnock and target.HealthStatus == 1 then goto continue end
            if igBot then
                local tIsBot = false
                if target.bIsAI == true or target.IsAI == true then tIsBot = true end
                local pState = target.PlayerState
                if slua.isValid(pState) and (pState.bIsABot or pState.bIsBot) then tIsBot = true end
                if tIsBot then goto continue end            end
            if useVisCheck then
                local curTime = os.clock()
                local tId = type(target.GetUniqueID) == "function" and target:GetUniqueID() or tostring(target)
                if not _G.AimTouchVisCache[tId] or (curTime - _G.AimTouchVisCache[tId].time) > 0.2 then
                    local isHidden = true
                    pcall(function() if pc:LineOfSightTo(target) then isHidden = false end end)
                    _G.AimTouchVisCache[tId] = { hidden = isHidden, time = curTime }
                end
                if _G.AimTouchVisCache[tId].hidden then goto continue end
            end
            local tPos = target:GetBonePos(selBoneName, {X=0, Y=0, Z=0})
            if not tPos or (tPos.X == 0 and tPos.Y == 0 and tPos.Z == 0) then
                if type(target.GetSocketLocation) == "function" then tPos = target:GetSocketLocation(selBoneName) end
            end
            if not tPos or (tPos.X == 0 and tPos.Y == 0 and tPos.Z == 0) then
                if type(target.K2_GetActorLocation) == "function" then
                    tPos = target:K2_GetActorLocation()
                    if tPos then
                        if boneIdx == 1 then tPos.Z = tPos.Z + 70
                        elseif boneIdx == 2 then tPos.Z = tPos.Z + 40
                        elseif boneIdx == 3 then tPos.Z = tPos.Z + 20 end
                    end
                end
            end
            if not tPos or (tPos.X == 0 and tPos.Y == 0 and tPos.Z == 0) then goto continue end
            local screen = FVector2D_inner()
            local success = pc:ProjectWorldLocationToScreen(tPos, screen, false)
            if not success or screen.X <= 0 or screen.Y <= 0 then goto continue end
            local dx = screen.X - centerX
            local dy = screen.Y - centerY
            local distScreen = math.sqrt(dx*dx + dy*dy)
            if distScreen > FOV_RADIUS then goto continue end
            local currentScore = distScreen
            if prioMode == 2 then currentScore = player:GetDistanceTo(target)
            elseif prioMode == 3 then currentScore = target.Health or 100
            elseif prioMode == 4 then
                local hp = target.Health or 100
                local maxhp = target.HealthMax or 100
                if maxhp <= 0 then maxhp = 100 end
                currentScore = hp / maxhp
            end
            if currentScore < bestScore then bestScore = currentScore bestTarget = target end
            ::continue::
        end
        if not slua.isValid(bestTarget) then return end
        local finalBonePos = bestTarget:GetBonePos(selBoneName, {X=0, Y=0, Z=0})
        if not finalBonePos or (finalBonePos.X == 0 and finalBonePos.Y == 0 and finalBonePos.Z == 0) then
            if type(bestTarget.GetSocketLocation) == "function" then finalBonePos = bestTarget:GetSocketLocation(selBoneName) end
        end
        if not finalBonePos or (finalBonePos.X == 0 and finalBonePos.Y == 0 and finalBonePos.Z == 0) then
            if type(bestTarget.K2_GetActorLocation) == "function" then
                finalBonePos = bestTarget:K2_GetActorLocation()
                if finalBonePos then
                    if boneIdx == 1 then finalBonePos.Z = finalBonePos.Z + 70
                    elseif boneIdx == 2 then finalBonePos.Z = finalBonePos.Z + 40
                    elseif boneIdx == 3 then finalBonePos.Z = finalBonePos.Z + 20 end
                end
            end
        end
        if not finalBonePos or (finalBonePos.X == 0 and finalBonePos.Y == 0 and finalBonePos.Z == 0) then return end
        local tVelocity = nil
        pcall(function() if type(bestTarget.GetVelocity) == "function" then tVelocity = bestTarget:GetVelocity() end end)
        if isMortar and _G.TakoroModConfig.AimTouchMortar and predVal > 0 then
            pcall(function()
                if tVelocity and (tVelocity.X ~= 0 or tVelocity.Y ~= 0) then
                    local approxDist = player:GetDistanceTo(bestTarget) / 100.0
                    local approxToF = approxDist / 100.0
                    local predScale = predVal / 50.0
                    finalBonePos.X = finalBonePos.X + (tVelocity.X * approxToF * predScale)
                    finalBonePos.Y = finalBonePos.Y + (tVelocity.Y * approxToF * predScale)
                end
            end)
        end
        if not isMortar and predVal > 0 then
            pcall(function()
                if tVelocity and (tVelocity.X ~= 0 or tVelocity.Y ~= 0) then
                    local distToEnemy = player:GetDistanceTo(bestTarget) / 100.0
                    local ToF = (distToEnemy / 800.0) * (predVal / 50.0)
                    finalBonePos.X = finalBonePos.X + (tVelocity.X * ToF)
                    finalBonePos.Y = finalBonePos.Y + (tVelocity.Y * ToF)
                end
            end)
        end
        local rot = KismetMathLibrary.FindLookAtRotation(camLoc, finalBonePos)
        if not rot then return end
        local currentRot = pc:GetControlRotation()
        if not currentRot then return end
        local deltaYaw = rot.Yaw - currentRot.Yaw
        local deltaPitch = rot.Pitch - currentRot.Pitch
        if isADS then
            local camRot = nil
            if type(camManager.GetCameraRotation) == "function" then camRot = camManager:GetCameraRotation() end
            if camRot then
                deltaYaw = deltaYaw - (camRot.Yaw - currentRot.Yaw)
                deltaPitch = deltaPitch - (camRot.Pitch - currentRot.Pitch)
            end
        end
        if deltaYaw > 180 then deltaYaw = deltaYaw - 360 end
        if deltaYaw < -180 then deltaYaw = deltaYaw + 360 end
        if deltaPitch > 180 then deltaPitch = deltaPitch - 360 end
        if deltaPitch < -180 then deltaPitch = deltaPitch + 360 end
        local smoothFactor = 0.0
        if speedVal >= 100 then smoothFactor = 1.0
        else
            smoothFactor = (speedVal / 100.0) * 0.3
            if smoothFactor < 0.01 then smoothFactor = 0.01 end
        end
        local finalPitch = currentRot.Pitch + (deltaPitch * smoothFactor)
        local finalYaw = currentRot.Yaw + (deltaYaw * smoothFactor)
        if recoilCompVal > 0 and isFiring then
            local pullDownForce = recoilCompVal * 0.03
            finalPitch = finalPitch - pullDownForce
        end
        if isMortar and _G.TakoroModConfig.AimTouchMortar then
            local targetPos = { X = finalBonePos.X, Y = finalBonePos.Y, Z = finalBonePos.Z }
            local launchPos = camLoc
            pcall(function()
                if player.K2_GetActorLocation then
                    local pLoc = player:K2_GetActorLocation()
                    if pLoc then launchPos = { X = pLoc.X, Y = pLoc.Y, Z = pLoc.Z + 50 } end
                end
            end)
            local function CalcMortarTrajectory(V, G, tX, tY, tZ)
                local mDx = math.sqrt((tX - launchPos.X)^2 + (tY - launchPos.Y)^2) - 80
                if mDx < 500 then mDx = 500 end
                local mDy = tZ - launchPos.Z
                local minVSq = G * (mDy + math.sqrt(mDx*mDx + mDy*mDy))
                if (V * V) < minVSq then V = math.sqrt(minVSq) + 100 end
                local v2 = V * V
                local root = v2*v2 - G*(G*mDx*mDx + 2*mDy*v2)
                if root >= 0 then
                    local angleRad = math.atan((v2 + math.sqrt(root)) / (G * mDx))
                    local deg = math.deg(angleRad)
                    if deg >= 35 and deg <= 89.5 then return true, deg, mDx / (V * math.cos(angleRad)), mDx end
                end
                return false, 45, 0, mDx
            end
            local vNear, gNear = 9070, 980 * 2.8
            local vFar, gFar = 12520, 980 * 4.0
            local vUltra, gUltra = 16800, 980 * 4.5
            local isValid, physAngle, ToF, finalDx = false, 45, 0, 0
            local okNear, angNear, tofNear, dxN = CalcMortarTrajectory(vNear, gNear, targetPos.X, targetPos.Y, targetPos.Z)
            local okFar, angFar, tofFar, dxF = CalcMortarTrajectory(vFar, gFar, targetPos.X, targetPos.Y, targetPos.Z)
            local okUltra, angUltra, tofUltra, dxU = CalcMortarTrajectory(vUltra, gUltra, targetPos.X, targetPos.Y, targetPos.Z)
            if okNear and dxN <= 25000 then isValid, physAngle, ToF, finalDx = okNear, angNear, tofNear, dxN
            elseif okFar and dxF <= 40000 then isValid, physAngle, ToF, finalDx = okFar, angFar, tofFar, dxF
            elseif okUltra then isValid, physAngle, ToF, finalDx = okUltra, angUltra, tofUltra, dxU
            elseif okNear then isValid, physAngle, ToF, finalDx = okNear, angNear, tofNear, dxN end
            local targetCameraPitch = ((physAngle - 45) / 43.0) * 90.0 - 60.0
            local targetCameraYaw = rot.Yaw
            local deltaPitchMortar = targetCameraPitch - currentRot.Pitch
            local deltaYawMortar = targetCameraYaw - currentRot.Yaw
            if deltaPitchMortar > 180 then deltaPitchMortar = deltaPitchMortar - 360 end
            if deltaPitchMortar < -180 then deltaPitchMortar = deltaPitchMortar + 360 end
            if deltaYawMortar > 180 then deltaYawMortar = deltaYawMortar - 360 end
            if deltaYawMortar < -180 then deltaYawMortar = deltaYawMortar + 360 end
            finalPitch = currentRot.Pitch + (deltaPitchMortar * smoothFactor)
            finalYaw = currentRot.Yaw + (deltaYawMortar * smoothFactor)
        end
        local finalRot = { Pitch = finalPitch, Yaw = finalYaw, Roll = 0 }
        pc:SetControlRotation(finalRot, "AimTouch")
        if isShotgun and _G.TakoroModConfig.AimTouchSGAutoFire then
            pcall(function()
                local distToTarget = player:GetDistanceTo(bestTarget) / 100
                if distToTarget <= maxDistMeters then
                    player.bIsWeaponFiring = true
                    if type(player.SetIsWeaponFiring) == "function" then player:SetIsWeaponFiring(true) end
                    if slua.isValid(pc) and type(pc.SetIsWeaponFiring) == "function" then pc:SetIsWeaponFiring(true) end
                    local wepMgr = player.WeaponManagerComponent
                    if slua.isValid(wepMgr) then wepMgr.bIsWeaponFiring = true end
                    local currentWep = player:GetCurrentWeapon()
                    if slua.isValid(currentWep) and type(currentWep.StartFire) == "function" then currentWep:StartFire() end
                    _G.TakoroModState.IsAutoFiring = true
                end
            end)
        end
    end)
end

-- ============================================================
-- [10] MENU CONSTANTS (dipindah ke dalam BuildMenu)
-- ============================================================
-- ⚠️ Konstanta M_W, M_H, dll sekarang dideklarasikan lokal di dalam BuildMenu()
-- Biarkan blok ini kosong untuk kompatibilitas komponen lama

-- ============================================================
-- [11] VIP CONFIG
-- ============================================================
_G.VIPConfig = _G.VIPConfig or {
    ESP_HP=false, ESP_HPNative=false, ESP_Box=false, ESP_Distance=false,
    ESP_Radar=false, ESP_Counter=false, ESP_Warning=false, ESP_WarnVis=false,
    ESP_Line=false, ESP_Name=false,
    AIM_Enabled=false, AIM_TPP=false, AIM_SG=false, AIM_ADS=false,
    AIM_SNIPER=false, AIM_MORTAR=false, AIM_SGAutoFire=false,
    AIM_IGN_KNOCK=false, AIM_IGN_BOT=false, AIM_VISCHECK=false,
    SKIN_M416=false, SKIN_AKM=false, SKIN_AWM=false, SKIN_KAR98=false,
    SKIN_UMP45=false, SKIN_SCARL=false, SKIN_DP28=false, SKIN_GROZA=false,
    MEM_WallV1=false, MEM_WallV2=false, MEM_WallV3=false, MEM_WallNew=false,
    MEM_IpadView=false,
    
    -- Bypass VIP Menu
    AUTO_FEEDBACK=false,
    BYPASS_ANTI_REPORT=false,
    BYPASS_ANTI_KICK=false,
    BYPASS_ANTI_BAN_DEVICE=false,
    BYPASS_ANTI_DETECT=false,
    BYPASS_FAKE_DEVICE=false,
    BYPASS_FAKE_LOCATION=false,
    BYPASS_STEALTH_MODE=false,
    BYPASS_PROTECT_MEMORY=false,
}
-- ============================================================
-- [12] AIM DEFAULT + CYCLE
-- ============================================================
local AIM_DEFAULT = {
    HipFOV=60, HipSpeed=100, HipDist=500, HipBone=1, HipCond=2, HipPrio=1,
    SGFOV=50, SGSpeed=100, SGDist=50, SGBone=2, SGCond=2, SGPrio=1,
    ScopeFOV=40, ScopeSpeed=100, ScopeDist=500, ScopeBone=2, ScopeCond=1, ScopePrio=1,
    ScopePred=0, ScopeRecoil=0,
    SniperFOV=25, SniperSpeed=80, SniperDist=800, SniperBone=1, SniperCond=2, SniperPrio=1,
    SniperPred=30, MortarFOV=360, MortarPred=50,
}

local function InitAimValues()
    local d = _G.TakoroModState.CustomTextData
    d.AimTouchHipFOV=d.AimTouchHipFOV or AIM_DEFAULT.HipFOV
    d.AimTouchHipSpeed=d.AimTouchHipSpeed or AIM_DEFAULT.HipSpeed
    d.AimTouchHipDist=d.AimTouchHipDist or AIM_DEFAULT.HipDist
    d.AimTouchHipBone=d.AimTouchHipBone or AIM_DEFAULT.HipBone
    d.AimTouchHipCond=d.AimTouchHipCond or AIM_DEFAULT.HipCond
    d.AimTouchHipPrio=d.AimTouchHipPrio or AIM_DEFAULT.HipPrio
    d.AimTouchSGFOV=d.AimTouchSGFOV or AIM_DEFAULT.SGFOV
    d.AimTouchSGSpeed=d.AimTouchSGSpeed or AIM_DEFAULT.SGSpeed
    d.AimTouchSGDist=d.AimTouchSGDist or AIM_DEFAULT.SGDist
    d.AimTouchSGBone=d.AimTouchSGBone or AIM_DEFAULT.SGBone
    d.AimTouchSGCond=d.AimTouchSGCond or AIM_DEFAULT.SGCond
    d.AimTouchSGPrio=d.AimTouchSGPrio or AIM_DEFAULT.SGPrio
    d.AimTouchScopeFOV=d.AimTouchScopeFOV or AIM_DEFAULT.ScopeFOV
    d.AimTouchScopeSpeed=d.AimTouchScopeSpeed or AIM_DEFAULT.ScopeSpeed
    d.AimTouchScopeDist=d.AimTouchScopeDist or AIM_DEFAULT.ScopeDist
    d.AimTouchScopeBone=d.AimTouchScopeBone or AIM_DEFAULT.ScopeBone
    d.AimTouchScopeCond=d.AimTouchScopeCond or AIM_DEFAULT.ScopeCond
    d.AimTouchScopePrio=d.AimTouchScopePrio or AIM_DEFAULT.ScopePrio
    d.AimTouchScopePred=d.AimTouchScopePred or AIM_DEFAULT.ScopePred
    d.AimTouchScopeRecoil=d.AimTouchScopeRecoil or AIM_DEFAULT.ScopeRecoil
    d.AimTouchSniperFOV=d.AimTouchSniperFOV or AIM_DEFAULT.SniperFOV
    d.AimTouchSniperSpeed=d.AimTouchSniperSpeed or AIM_DEFAULT.SniperSpeed
    d.AimTouchSniperDist=d.AimTouchSniperDist or AIM_DEFAULT.SniperDist
    d.AimTouchSniperBone=d.AimTouchSniperBone or AIM_DEFAULT.SniperBone
    d.AimTouchSniperCond=d.AimTouchSniperCond or AIM_DEFAULT.SniperCond
    d.AimTouchSniperPrio=d.AimTouchSniperPrio or AIM_DEFAULT.SniperPrio
    d.AimTouchSniperPred=d.AimTouchSniperPred or AIM_DEFAULT.SniperPred
    d.AimTouchMortarFOV=d.AimTouchMortarFOV or AIM_DEFAULT.MortarFOV
    d.AimTouchMortarPred=d.AimTouchMortarPred or AIM_DEFAULT.MortarPred
end

local function EnsureAllFalse()
    local cfg = _G.TakoroModConfig
    local keys = {
        "AimTouchEnable","AimTouchHipfire","AimTouchHipIgKnock","AimTouchHipIgBot","AimTouchHipVisCheck",
        "AimTouchSG","AimTouchSGIgKnock","AimTouchSGIgBot","AimTouchSGVisCheck","AimTouchSGAutoFire",
        "AimTouchScopeAll","AimTouchScopeIgKnock","AimTouchScopeIgBot","AimTouchScopeVisCheck",
        "AimTouchScopeSniper","AimTouchSniperIgKnock","AimTouchSniperIgBot","AimTouchSniperVisCheck",
        "AimTouchMortar",
    }
    for _, k in ipairs(keys) do if cfg[k] == nil then cfg[k] = false end end
end

InitAimValues()
EnsureAllFalse()

local CYCLE = {
    FOV    = {10, 15, 20, 25, 30, 40, 50, 60, 70, 80, 90, 100},
    SPEED  = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100},
    DIST   = {10, 25, 50, 100, 150, 200, 300, 500, 800, 1000, 2000},
    BONE   = {1, 2, 3, 4},
    COND   = {1, 2},
    PRIO   = {1, 2, 3, 4},
    PRED   = {0, 10, 20, 30, 40, 50, 80, 100},
    RECOIL = {0, 1, 2, 3, 4, 5, 6, 7},
    COLOR_V3  = {1, 2, 3, 4, 5, 6},
    THICKNESS = {1, 2, 3, 4, 5, 6, 8, 10, 12, 15, 20},
    FOV_IPAD  = {90, 100, 110, 120, 130, 140, 150, 160},
}

-- ============================================================
-- [13] HOOKS
-- ============================================================
_G.AimFeatureHooks = {
    AIM_Enabled={on=function()_G.TakoroModConfig.AimTouchEnable=true end, off=function()_G.TakoroModConfig.AimTouchEnable=false end},
    AIM_TPP={on=function()_G.TakoroModConfig.AimTouchHipfire=true end, off=function()_G.TakoroModConfig.AimTouchHipfire=false end},
    AIM_SG={on=function()_G.TakoroModConfig.AimTouchSG=true end, off=function()_G.TakoroModConfig.AimTouchSG=false end},
    AIM_ADS={on=function()_G.TakoroModConfig.AimTouchScopeAll=true end, off=function()_G.TakoroModConfig.AimTouchScopeAll=false end},
    AIM_SNIPER={on=function()_G.TakoroModConfig.AimTouchScopeSniper=true end, off=function()_G.TakoroModConfig.AimTouchScopeSniper=false end},
    AIM_MORTAR={on=function()_G.TakoroModConfig.AimTouchMortar=true end, off=function()_G.TakoroModConfig.AimTouchMortar=false end},
    AIM_SGAutoFire={on=function()_G.TakoroModConfig.AimTouchSGAutoFire=true end, off=function()_G.TakoroModConfig.AimTouchSGAutoFire=false end},
    AIM_IGN_KNOCK={
        on=function()
            _G.TakoroModConfig.AimTouchHipIgKnock=true _G.TakoroModConfig.AimTouchSGIgKnock=true
            _G.TakoroModConfig.AimTouchScopeIgKnock=true _G.TakoroModConfig.AimTouchSniperIgKnock=true
        end,
        off=function()
            _G.TakoroModConfig.AimTouchHipIgKnock=false _G.TakoroModConfig.AimTouchSGIgKnock=false
            _G.TakoroModConfig.AimTouchScopeIgKnock=false _G.TakoroModConfig.AimTouchSniperIgKnock=false
        end,
    },
    AIM_IGN_BOT={
        on=function()
            _G.TakoroModConfig.AimTouchHipIgBot=true _G.TakoroModConfig.AimTouchSGIgBot=true
            _G.TakoroModConfig.AimTouchScopeIgBot=true _G.TakoroModConfig.AimTouchSniperIgBot=true
        end,
        off=function()
            _G.TakoroModConfig.AimTouchHipIgBot=false _G.TakoroModConfig.AimTouchSGIgBot=false
            _G.TakoroModConfig.AimTouchScopeIgBot=false _G.TakoroModConfig.AimTouchSniperIgBot=false
        end,
    },
    AIM_VISCHECK={
        on=function()
            _G.TakoroModConfig.AimTouchHipVisCheck=true _G.TakoroModConfig.AimTouchSGVisCheck=true
            _G.TakoroModConfig.AimTouchScopeVisCheck=true _G.TakoroModConfig.AimTouchSniperVisCheck=true
        end,
        off=function()
            _G.TakoroModConfig.AimTouchHipVisCheck=false _G.TakoroModConfig.AimTouchSGVisCheck=false
            _G.TakoroModConfig.AimTouchScopeVisCheck=false _G.TakoroModConfig.AimTouchSniperVisCheck=false
        end,
    },
}

-- ✅ Helper: tandai semua musuh dirty saat config global berubah
local function MarkAllEnemiesDirty(flag)
    pcall(function()
        for _, markData in pairs(_G.TakoroModState.EnemyMarks or {}) do
            if flag == "wall" then markData.WallhackDirty = true
            elseif flag == "v3" then markData.ColorV3Dirty = true
            elseif flag == "new" then markData.ColorNewDirty = true
            elseif flag == "all" then
                markData.WallhackDirty = true
                markData.ColorV3Dirty = true
                markData.ColorNewDirty = true
                markData.IsFullyRendered = false
            end
        end
    end)
end
_G.MarkAllEnemiesDirty = MarkAllEnemiesDirty

_G.EspFeatureHooks = {
    ESP_Counter={on=function()_G.TakoroModConfig.EspEnemyCounter=true end, off=function()_G.TakoroModConfig.EspEnemyCounter=false end},
    ESP_Warning={on=function()_G.TakoroModConfig.EspAimWarning=true end, off=function()_G.TakoroModConfig.EspAimWarning=false end},
    ESP_WarnVis={on=function()_G.TakoroModConfig.EspAimWarningVisCheck=true end, off=function()_G.TakoroModConfig.EspAimWarningVisCheck=false end},
    ESP_HP={on=function()_G.TakoroModConfig.EspVipPro=true _G.TakoroModConfig.Esp3ShowHP=true end, off=function()_G.TakoroModConfig.EspVipPro=false end},
    ESP_Box={on=function()_G.TakoroModConfig.EspLoai5=true end, off=function()_G.TakoroModConfig.EspLoai5=false end},
    ESP_Distance={on=function()_G.TakoroModConfig.EspDistance=true end, off=function()_G.TakoroModConfig.EspDistance=false end},
    ESP_Radar={on=function()_G.TakoroModConfig.EspRadar=true end, off=function()_G.TakoroModConfig.EspRadar=false end},
    ESP_HPNative={on=function()_G.TakoroModConfig.EspLoai8=true end, off=function()_G.TakoroModConfig.EspLoai8=false end},
    MEM_WallV1={
        on=function() _G.TakoroModConfig.WallXuyenTuong=true; if _G.MarkAllEnemiesDirty then _G.MarkAllEnemiesDirty("wall") end end, 
        off=function() _G.TakoroModConfig.WallXuyenTuong=false; if _G.MarkAllEnemiesDirty then _G.MarkAllEnemiesDirty("wall") end end
    },
    MEM_WallV2={
        on=function() _G.TakoroModConfig.ColorBodyV2=true end, 
        off=function() _G.TakoroModConfig.ColorBodyV2=false end
    },
    MEM_WallV3={
        on=function() _G.TakoroModConfig.ColorBodyV3=true; if _G.MarkAllEnemiesDirty then _G.MarkAllEnemiesDirty("v3") end end, 
        off=function() _G.TakoroModConfig.ColorBodyV3=false; if _G.MarkAllEnemiesDirty then _G.MarkAllEnemiesDirty("v3") end end
    },
    MEM_WallNew={
        on=function() _G.TakoroModConfig.ColorBodyNew=true; if _G.MarkAllEnemiesDirty then _G.MarkAllEnemiesDirty("new") end end, 
        off=function() _G.TakoroModConfig.ColorBodyNew=false; if _G.MarkAllEnemiesDirty then _G.MarkAllEnemiesDirty("new") end end
    },
    MEM_IpadView={on=function()_G.TakoroModConfig.IpadView=true end, off=function()_G.TakoroModConfig.IpadView=false end},
}



_G.FeatureHooks = _G.FeatureHooks or {}
for k, v in pairs(_G.AimFeatureHooks) do _G.FeatureHooks[k] = v end
for k, v in pairs(_G.EspFeatureHooks) do _G.FeatureHooks[k] = v end




-- ============================================================
-- [14] LOOP AimTouch
-- ============================================================
_G.AimFeatureStarted = _G.AimFeatureStarted or false
_G.AimFeatureToken   = _G.AimFeatureToken or 0

function _G.StartAimFeatureLoop()
    if _G.AimFeatureStarted then return end
    _G.AimFeatureStarted = true
    _G.AimFeatureToken = _G.AimFeatureToken + 1
    local myToken = _G.AimFeatureToken
    local function FastTick()
        if myToken ~= _G.AimFeatureToken then return end
        pcall(function() if _G.TakoroModConfig.AimTouchEnable and _G.AimTouch then pcall(_G.AimTouch) end end)
        pcall(function()
            local ok, ticker = pcall(require, "common.time_ticker")
            if ok and ticker and ticker.AddTimerOnce then ticker.AddTimerOnce(0.01, FastTick) end
        end)
    end
    pcall(function()
        local ok, ticker = pcall(require, "common.time_ticker")
        if ok and ticker and ticker.AddTimerOnce then
            ticker.AddTimerOnce(0.01, FastTick)
            --("[AIM] Loop started @ 100 FPS")
        end
    end)
end

-- ============================================================
-- [15] MENU SYSTEM STATE
-- ============================================================
local parentCanvas = nil
local bgPanel = nil
local allWidgets = {}
local toggleRows = {}
local floatItem = nil
local isMenuOpen = false
local menuBuilt = false

local function GetCanvas()
    print("[TAKORO-DEBUG] GetCanvas dipanggil")
    if parentCanvas and Game:IsValid(parentCanvas) then return parentCanvas end
    parentCanvas = nil
    pcall(function()
        local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
        local MainUI = InGameUITools.GetMainControlBaseUI()
        print("[TAKORO-DEBUG] MainUI=", tostring(MainUI))
        if not MainUI or not Game:IsValid(MainUI) then return end
        if MainUI.CanvasPanel_0 and Game:IsValid(MainUI.CanvasPanel_0) then parentCanvas = MainUI.CanvasPanel_0
        elseif MainUI.CanvasPanel_42 and Game:IsValid(MainUI.CanvasPanel_42) then parentCanvas = MainUI.CanvasPanel_42 end
    end)
    return parentCanvas
end

-- ============================================================
-- [16] WIDGET HELPERS (REDESIGN — Modern Rounded)
-- ============================================================

-- ⭐ Helper: Buat "rounded rectangle" pakai Image + material (fallback ke Border)
-- Karena UMG Lua tidak support CornerRadius native di Border, kita pakai
-- teknik: background solid + 4 corner kecil + shadow
local function RoundedLayer(parent, x, y, w, h, color, z, radius)
    radius = radius or 8
    local C = _G.C
    local holder = nil
    pcall(function()
        -- Pakai CanvasPanel sebagai holder supaya bisa tampung multiple corner
        holder = CGame:NewObjectFromPath("/Script/UMG.CanvasPanel", parent)
        if holder and slua.isValid(holder) then
            holder:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            local slot = parent:AddChildToCanvas(holder)
            if slot then
                slot:SetAutoSize(false)
                slot:SetPosition(FVector2D(x, y))
                slot:SetSize(FVector2D(w, h))
                slot:SetZOrder(z or 0)
            end
            
            -- Main solid block (tengah)
            local main = CGame:NewObjectFromPath("/Script/UMG.Border", holder)
            if main and slua.isValid(main) then
                main:SetBrushColor(color)
                main:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                local s = holder:AddChildToCanvas(main)
                if s then
                    s:SetAutoSize(false)
                    s:SetPosition(FVector2D(radius, 0))
                    s:SetSize(FVector2D(w - radius * 2, h))
                    s:SetZOrder(0)
                end
            end
            
            -- Vertical side blocks (kiri & kanan, atas & bawah dari radius)
            local vLeft = CGame:NewObjectFromPath("/Script/UMG.Border", holder)
            if vLeft and slua.isValid(vLeft) then
                vLeft:SetBrushColor(color)
                vLeft:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                local s = holder:AddChildToCanvas(vLeft)
                if s then
                    s:SetAutoSize(false)
                    s:SetPosition(FVector2D(radius, radius))
                    s:SetSize(FVector2D(w - radius * 2, h - radius * 2))
                    s:SetZOrder(0)
                end
            end
            
            -- Horizontal top strip
            local hTop = CGame:NewObjectFromPath("/Script/UMG.Border", holder)
            if hTop and slua.isValid(hTop) then
                hTop:SetBrushColor(color)
                hTop:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                local s = holder:AddChildToCanvas(hTop)
                if s then
                    s:SetAutoSize(false)
                    s:SetPosition(FVector2D(radius, 0))
                    s:SetSize(FVector2D(w - radius * 2, radius))
                    s:SetZOrder(0)
                end
            end
            
            -- Horizontal bottom strip
            local hBot = CGame:NewObjectFromPath("/Script/UMG.Border", holder)
            if hBot and slua.isValid(hBot) then
                hBot:SetBrushColor(color)
                hBot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                local s = holder:AddChildToCanvas(hBot)
                if s then
                    s:SetAutoSize(false)
                    s:SetPosition(FVector2D(radius, h - radius))
                    s:SetSize(FVector2D(w - radius * 2, radius))
                    s:SetZOrder(0)
                end
            end
            
            -- Kiri tengah (dari radius ke h-radius)
            local vMid = CGame:NewObjectFromPath("/Script/UMG.Border", holder)
            if vMid and slua.isValid(vMid) then
                vMid:SetBrushColor(color)
                vMid:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                local s = holder:AddChildToCanvas(vMid)
                if s then
                    s:SetAutoSize(false)
                    s:SetPosition(FVector2D(0, radius))
                    s:SetSize(FVector2D(radius, h - radius * 2))
                    s:SetZOrder(0)
                end
            end
            
            -- Kanan tengah
            local vMidR = CGame:NewObjectFromPath("/Script/UMG.Border", holder)
            if vMidR and slua.isValid(vMidR) then
                vMidR:SetBrushColor(color)
                vMidR:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                local s = holder:AddChildToCanvas(vMidR)
                if s then
                    s:SetAutoSize(false)
                    s:SetPosition(FVector2D(w - radius, radius))
                    s:SetSize(FVector2D(radius, h - radius * 2))
                    s:SetZOrder(0)
                end
            end
        end
    end)
    table.insert(allWidgets, holder)
    return holder
end

local function MakeBtn(parent, x, y, w, h, z, onClick)
    local C = _G.C
    local btn = nil
    pcall(function()
        btn = CGame:NewObjectFromPath("/Script/UMG.Button", parent)
        if btn and slua.isValid(btn) then
            pcall(function() btn:SetColorAndOpacity(C.transparent) end)
            pcall(function() btn:SetBackgroundColor(C.transparent) end)
            pcall(function() btn:SetWidgetVisibility(UEnums.ESlateVisibility.Visible) end)
            local slot = parent:AddChildToCanvas(btn)
            if slot then
                slot:SetAutoSize(false)
                slot:SetPosition(FVector2D(x, y))
                slot:SetSize(FVector2D(w, h))
                slot:SetZOrder(z or 900)
            end
            if onClick then
                pcall(function()
                    if btn.OnClicked then btn.OnClicked:Add(function() pcall(onClick) end) end
                end)
            end
        end
    end)
    table.insert(allWidgets, btn)
    return btn
end

local function Layer(parent, x, y, w, h, color, z)
    local C = _G.C
    local b = nil
    pcall(function()
        b = CGame:NewObjectFromPath("/Script/UMG.Border", parent)
        if b and slua.isValid(b) then
            b:SetBrushColor(color)
            b:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            local slot = parent:AddChildToCanvas(b)
            if slot then
                slot:SetAutoSize(false)
                slot:SetPosition(FVector2D(x, y))
                slot:SetSize(FVector2D(w, h))
                slot:SetZOrder(z or 0)
            end
        end
    end)
    table.insert(allWidgets, b)
    return b
end

local function FloatLayer(parent, x, y, w, h, color, z)
    local C = _G.C
    local b = nil
    pcall(function()
        b = CGame:NewObjectFromPath("/Script/UMG.Border", parent)
        if b and slua.isValid(b) then
            b:SetBrushColor(color)
            b:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            local slot = parent:AddChildToCanvas(b)
            if slot then
                slot:SetAutoSize(false)
                slot:SetPosition(FVector2D(x, y))
                slot:SetSize(FVector2D(w, h))
                slot:SetZOrder(z or 0)
            end
        end
    end)
    return b
end

local function Text(parent, txt, x, y, size, color, z, alignX, alignY)
    local C = _G.C
    local t = nil
    pcall(function()
        t = CGame:NewObjectFromPath("/Script/UMG.TextBlock", parent)
        if t and slua.isValid(t) then
            t:SetText(txt)
            if FSlateColor then t:SetColorAndOpacity(FSlateColor(color)) else t:SetColorAndOpacity(color) end
            if t.Font then local f = t.Font f.Size = size t.Font = f end
            t:SetRenderTransformPivot(FVector2D(alignX or 0.5, alignY or 0.5))
            t:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            local slot = parent:AddChildToCanvas(t)
            if slot then
                slot:SetAutoSize(true)
                slot:SetAlignment(FVector2D(alignX or 0.5, alignY or 0.5))
                slot:SetPosition(FVector2D(x, y))
                slot:SetZOrder(z or 100)
            end
        end
    end)
    table.insert(allWidgets, t)
    return t
end

-- ⭐ Helper baru: badge (chip/pill kecil)
local function Badge(parent, txt, x, y, w, h, bgColor, txtColor, fontSize)
    local C = _G.C
    local b = nil
    pcall(function()
        b = RoundedLayer(parent, x, y, w, h, bgColor or C.bg_pill, 300, 6)
        Text(parent, txt, x + w * 0.5, y + h * 0.5, fontSize or 10, txtColor or C.white, 310, 0.5, 0.5)
    end)
    return b
end

-- ⭐ Helper: divider line horizontal
local function Divider(parent, x, y, w, color, z)
    local C = _G.C
    return Layer(parent, x, y, w, 1, color or C.divider, z or 200)
end

-- ⭐ Helper: card (kotak dengan border + glow)
local function Card(parent, x, y, w, h, z)
    local C = _G.C
    Layer(parent, x - 1, y - 1, w + 2, h + 2, C.card_border or C.divider, z or 100)
    local inner = Layer(parent, x, y, w, h, C.card_bg or C.bg_row, (z or 100) + 1)
    return inner
end

-- ⭐ Helper baru: icon placeholder (kotak kecil dengan huruf di tengah)
local function IconBox(parent, char, x, y, size, bgColor, charColor)
    local C = _G.C
    local box = RoundedLayer(parent, x, y, size, size, bgColor or C.bg_pill, 300, 4)
    Text(parent, char, x + size * 0.5, y + size * 0.5, math.floor(size * 0.5), charColor or C.gold_bright, 310, 0.5, 0.5)
    return box
end

-- ============================================================
-- [17] SHOW / HIDE
-- ============================================================
local function ShowMenu()
    if bgPanel and IsValid(bgPanel) then
        pcall(function() bgPanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
    end
    _G.TakoroModState.MenuHidden = false
end

local function HideMenu()
    if bgPanel and IsValid(bgPanel) then
        pcall(function() bgPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden) end)
    end
    _G.TakoroModState.MenuHidden = true
end

local function OpenMenu()
    -- ⭐ BLOCK kalau key belum valid
    if not _G.TakoroModState.KeyValid then
        if _G.TakoroModNotify then 
            _G.TakoroModNotify("❌ Key belum valid, silakan aktivasi dulu!") 
        end
        if _G.BuildKeyPanel then pcall(_G.BuildKeyPanel) end
        return
    end
    
    if menuBuilt and bgPanel and IsValid(bgPanel) then
        ShowMenu()
        _G.TakoroModState.MenuHidden = false
        return
    end
    if _G.__BuildMenu then
        _G.__BuildMenu()
        _G.TakoroModState.MenuHidden = false
    end
end

local function CloseMenu()
    _G.TakoroModState.MenuHidden = true
    HideMenu()
end

local function HideExpiredFloat()
    _G.TakoroModState.ExpiredHidden = true
    local F = _G.TakoroModState.FloatExpired
    if F and F.valid then
        local expKeys = {"s0","s1","s2","s3","s4","s5","s6","s7","s8","s9","s10","s11","s12","s13","s14","s15","s16","s17","label","text","btn","closeBtn","closeTxt"}
        for _, k in ipairs(expKeys) do
            pcall(function()
                local w = F[k]
                if w and IsValid(w) then w:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden) end
            end)
        end
    end
end

local function ShowExpiredFloat()
    _G.TakoroModState.ExpiredHidden = false
    local F = _G.TakoroModState.FloatExpired
    if F and F.valid then
        local expKeys = {"s0","s1","s2","s3","s4","s5","s6","s7","s8","s9","s10","s11","s12","s13","s14","s15","s16","s17","label","text","btn","closeBtn","closeTxt"}
        for _, k in ipairs(expKeys) do
            pcall(function()
                local w = F[k]
                if w and IsValid(w) then w:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end
            end)
        end
    end
end

local function HideAll()
    _G.TakoroModState.MenuHidden = true
    _G.TakoroModState.ExpiredHidden = true
    
    -- Hide MENU
    if bgPanel and IsValid(bgPanel) then
        pcall(function() bgPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden) end)
    end
    
    -- ⭐ Hide FLOAT TAKORO VIP
    if floatItem then
        local menuKeys = {"s0","s1","s2","s3","s4","s5","s6","s7","s8","s9","s10","s11","s12","s13","s14","s15","s16","s17","text","subText","btn","closeBtn","closeTxt"}
        for _, k in ipairs(menuKeys) do
            local w = floatItem[k]
            if w and IsValid(w) then 
                pcall(function() w:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden) end) 
            end
        end
        -- ghostBtn TETAP VISIBLE
        if floatItem.ghostBtn and IsValid(floatItem.ghostBtn) then
            pcall(function() floatItem.ghostBtn:SetWidgetVisibility(UEnums.ESlateVisibility.Visible) end)
        end
    end
    
    -- ⭐ HIDE FLOAT EXPIRED JUGA
    pcall(function()
        local F = _G.TakoroModState.FloatExpired
        if F and F.valid then
            local expKeys = {"s0","s1","s2","s3","s4","s5","s6","s7","s8","s9","s10","s11","s12","s13","s14","s15","s16","s17","label","text","btn","closeBtn","closeTxt","closeTxt"}
            for _, k in ipairs(expKeys) do
                local w = F[k]
                if w and IsValid(w) then 
                    pcall(function() w:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden) end) 
                end
            end
            -- Ghost expired tetep visible (biar bisa balikin)
            if F.ghostBtn and IsValid(F.ghostBtn) then
                pcall(function() F.ghostBtn:SetWidgetVisibility(UEnums.ESlateVisibility.Visible) end)
            end
        end
    end)
end


local function ShowAll()
    -- ⭐ BLOCK kalau key belum valid
    if not _G.TakoroModState.KeyValid then
        if _G.BuildKeyPanel then pcall(_G.BuildKeyPanel) end
        return
    end
    
    _G.TakoroModState.MenuHidden = false
    _G.TakoroModState.ExpiredHidden = false
    
    -- Show MENU
    OpenMenu()
    
    -- ⭐ Show FLOAT TAKORO VIP
    if floatItem then
        local menuKeys = {"s0","s1","s2","s3","s4","s5","s6","s7","s8","s9","s10","s11","s12","s13","s14","s15","s16","s17","text","subText","btn","closeBtn","closeTxt"}
        for _, k in ipairs(menuKeys) do
            local w = floatItem[k]
            if w and IsValid(w) then 
                pcall(function() w:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end) 
            end
        end
        if floatItem.btn and IsValid(floatItem.btn) then 
            pcall(function() floatItem.btn:SetWidgetVisibility(UEnums.ESlateVisibility.Visible) end) 
        end
        if floatItem.closeBtn and IsValid(floatItem.closeBtn) then 
            pcall(function() floatItem.closeBtn:SetWidgetVisibility(UEnums.ESlateVisibility.Visible) end) 
        end
        if floatItem.ghostBtn and IsValid(floatItem.ghostBtn) then 
            pcall(function() floatItem.ghostBtn:SetWidgetVisibility(UEnums.ESlateVisibility.Visible) end) 
        end
    end
    
    -- ⭐ SHOW FLOAT EXPIRED JUGA
    pcall(function()
        local F = _G.TakoroModState.FloatExpired
        if F and F.valid then
            local expKeys = {"s0","s1","s2","s3","s4","s5","s6","s7","s8","s9","s10","s11","s12","s13","s14","s15","s16","s17","label","text","btn","closeBtn","closeTxt"}
            for _, k in ipairs(expKeys) do
                local w = F[k]
                if w and IsValid(w) then 
                    pcall(function() w:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end) 
                end
            end
            if F.closeBtn and IsValid(F.closeBtn) then
                pcall(function() F.closeBtn:SetWidgetVisibility(UEnums.ESlateVisibility.Visible) end)
            end
            if F.ghostBtn and IsValid(F.ghostBtn) then
                pcall(function() F.ghostBtn:SetWidgetVisibility(UEnums.ESlateVisibility.Visible) end)
            end
        end
    end)
end

_G.__OpenMenu = OpenMenu
_G.__CloseMenu = CloseMenu
_G.__HideAll = HideAll
_G.__ShowAll = ShowAll
_G.__HideExpiredFloat = HideExpiredFloat
_G.__ShowExpiredFloat = ShowExpiredFloat

-- ============================================================
-- ⭐ Refresh widget Exp: di HOME panel
-- ============================================================
_G.__RefreshHomeExp = function()
    pcall(function()
        local w = _G.HomeExpWidget
        if w and IsValid(w) then
            local dateStr = _G.TakoroModState.ExpiredDateStr or "BELUM DI SET"
            w:SetText("Exp: " .. tostring(dateStr))
            print("[TAKORO] ✅ HOME Exp refreshed: " .. tostring(dateStr))
        else
            print("[TAKORO] ⚠️ HomeExpWidget belum ada (menu belum dibuild?)")
        end
    end)
end


-- ============================================================
-- [18] REBUILD MENU
-- ============================================================
function _G.__RebuildMenu()
    if bgPanel and IsValid(bgPanel) then
        pcall(function() bgPanel:RemoveFromParent() end)
        bgPanel = nil
    end
    menuBuilt = false
    allWidgets = {}
    toggleRows = {}
    -- ⭐ Reset scroll state
    if _G.ScrollState then
        _G.ScrollState.offsetY = 0
        _G.ScrollState.activePanel = nil
    end
    if _G.__BuildMenu then pcall(_G.__BuildMenu) end
    if _G.__OpenMenu then pcall(_G.__OpenMenu) end
end

-- ============================================================
-- [19] ESP COUNTER
-- ============================================================
local BTN_BP = "/Game/UMG/UI_BP/Common/BaseComponent/CommonBaseComponent_TextButton_UIBP.CommonBaseComponent_TextButton_UIBP"
local EnemyCounterWidget = nil
local WarningTargetWidget = nil
local LastCounterTime = 0

function _G.CleanUpEnemyCounterWidget()
    if EnemyCounterWidget and slua.isValid(EnemyCounterWidget) then EnemyCounterWidget:RemoveFromParent() end
    EnemyCounterWidget = nil
    if WarningTargetWidget and slua.isValid(WarningTargetWidget) then WarningTargetWidget:RemoveFromParent() end
    WarningTargetWidget = nil
end

local function CreateEnemyCounterWidget()
    if EnemyCounterWidget then
        if slua.isValid(EnemyCounterWidget) then return EnemyCounterWidget else EnemyCounterWidget = nil end
    end
    pcall(function()
        local btn = slua.loadUI(BTN_BP)
        if not btn or not slua.isValid(btn) then return end
        require("game_frontend_hud").AddToContainer(UIContainers.Top, btn, 10500)
        if btn.RichText_Content then
            btn.RichText_Content:SetText("TOTAL MUSUH : 0  |  TERDEKAT: 0m")
            local fontInfo = btn.RichText_Content.Font
            if fontInfo then fontInfo.Size = 16 btn.RichText_Content:SetFont(fontInfo) end
        end
        local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
        local slot = WidgetLayoutLibrary.SlotAsCanvasSlot(btn)
        if slot then
            slot:SetAnchors(FAnchors(0.5, 0, 0.5, 0))
            slot:SetAlignment(FVector2D(0.5, 0))
            slot:SetPosition(FVector2D(0, 30))
            slot:SetSize(FVector2D(240, 36))
        end
        btn:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        EnemyCounterWidget = btn
    end)
    return EnemyCounterWidget
end

local function CreateWarningTargetWidget()
    if WarningTargetWidget then
        if slua.isValid(WarningTargetWidget) then return WarningTargetWidget else WarningTargetWidget = nil end
    end
    pcall(function()
        local btn = slua.loadUI(BTN_BP)
        if not btn or not slua.isValid(btn) then return end
        require("game_frontend_hud").AddToContainer(UIContainers.Top, btn, 10501)
        if btn.RichText_Content then
            btn.RichText_Content:SetText("MUSUH MEMBIDIK ANDA")
            local fontInfo = btn.RichText_Content.Font
            if fontInfo then fontInfo.Size = 18 btn.RichText_Content:SetFont(fontInfo) end
        end
        local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
        local slot = WidgetLayoutLibrary.SlotAsCanvasSlot(btn)
        if slot then
            slot:SetAnchors(FAnchors(0.5, 0, 0.5, 0))
            slot:SetAlignment(FVector2D(0.5, 0))
            slot:SetPosition(FVector2D(0, 75))
            slot:SetSize(FVector2D(260, 36))
        end
        btn:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        WarningTargetWidget = btn
    end)
    return WarningTargetWidget
end

local function _M_DrawCounter()
    pcall(function()
        local player = _G.GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then
            if EnemyCounterWidget and slua.isValid(EnemyCounterWidget) then EnemyCounterWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end
            if WarningTargetWidget and slua.isValid(WarningTargetWidget) then WarningTargetWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end
            return
        end
        local widgetCounter = CreateEnemyCounterWidget()
        local widgetWarning = CreateWarningTargetWidget()
        if widgetCounter and slua.isValid(widgetCounter) then
            if _G.TakoroModConfig.EspEnemyCounter then
                widgetCounter:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            else
                widgetCounter:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
            end
        end
        local curTime = os.clock()
        if (curTime - LastCounterTime) > 0.5 then
            LastCounterTime = curTime
            local myTeam = player.TeamID or (type(player.GetTeamID) == "function" and player:GetTeamID()) or 0
            local count = 0
            local nearest = 9999
            local isBeingTargeted = false
            local KismetMathLibrary = import("KismetMathLibrary")
            local pc = player:GetPlayerControllerSafety()
            local allCharacters = {}
            if _G.GameplayData.GetAllPlayerCharacters then
                allCharacters = _G.GameplayData.GetAllPlayerCharacters()
            elseif _G.GameplayData.GameCharacters then
                for _, char in pairs(_G.GameplayData.GameCharacters) do table.insert(allCharacters, char) end
            end
            for _, tPawn in pairs(allCharacters) do
                if slua.isValid(tPawn) and tPawn ~= player then
                    local isAlive = false
                    if tPawn.HealthStatus ~= nil then isAlive = (tPawn.HealthStatus ~= 2)
                    else isAlive = (tPawn.Health or 0) > 0 or (type(tPawn.IsAlive) == "function" and tPawn:IsAlive()) end
                    if isAlive then
                        local tTeam = tPawn.TeamID or (type(tPawn.GetTeamID) == "function" and tPawn:GetTeamID()) or 0
                        if tTeam ~= myTeam then
                            count = count + 1
                            local d = math.floor(player:GetDistanceTo(tPawn) / 100)
                            if d < nearest then nearest = d end
                            if _G.TakoroModConfig.EspAimWarning and not isBeingTargeted and d < 400 then
                                local eLoc = type(tPawn.K2_GetActorLocation) == "function" and tPawn:K2_GetActorLocation()
                                local pLoc = type(player.K2_GetActorLocation) == "function" and player:K2_GetActorLocation()
                                if eLoc and pLoc and KismetMathLibrary then
                                    local lookRot = KismetMathLibrary.FindLookAtRotation(eLoc, pLoc)
                                    local eRot = nil
                                    if type(tPawn.GetControlRotation) == "function" then eRot = tPawn:GetControlRotation()
                                    elseif type(tPawn.GetActorRotation) == "function" then eRot = tPawn:GetActorRotation() end
                                    if eRot and lookRot then
                                        local dYaw = math.abs(eRot.Yaw - lookRot.Yaw)
                                        if dYaw > 180 then dYaw = 360 - dYaw end
                                        local dPitch = math.abs(eRot.Pitch - lookRot.Pitch)
                                        if dPitch > 180 then dPitch = 360 - dPitch end
                                        if dYaw < 15 and dPitch < 20 then
                                            if _G.TakoroModConfig.EspAimWarningVisCheck then
                                                if slua.isValid(pc) and type(pc.LineOfSightTo) == "function" then
                                                    if pc:LineOfSightTo(tPawn) then isBeingTargeted = true end
                                                end
                                            else
                                                isBeingTargeted = true
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if widgetCounter and widgetCounter.RichText_Content then
                widgetCounter.RichText_Content:SetText(string.format("MUSUH DI SEKITAR: %d  |  MUSUH TERDEKAT: %dm", count, count > 0 and nearest or 0))
            end
            if widgetWarning and slua.isValid(widgetWarning) then
                if _G.TakoroModConfig.EspAimWarning and isBeingTargeted then
                    widgetWarning:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                else
                    widgetWarning:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
                end
            end
        end
    end)
end
_G.ESPCounterTick = _M_DrawCounter

-- ============================================================
-- [20] ESP UNIFIED LOOP
-- ============================================================
_G.EspUnifiedStarted = _G.EspUnifiedStarted or false
_G.EspUnifiedToken = _G.EspUnifiedToken or 0
_G.EspUnifiedState = _G.EspUnifiedState or { lastCounter = 0 }

function _G.StartEspUnifiedLoop()
    if _G.EspUnifiedStarted then return end
    _G.EspUnifiedStarted = true
    _G.EspUnifiedToken = _G.EspUnifiedToken + 1
    local myToken = _G.EspUnifiedToken
    local S = _G.EspUnifiedState
    -- Inisialisasi di dalam loop, bukan di top-level
    pcall(function() InitializeNativeESP() end)
    local function Tick()
        if myToken ~= _G.EspUnifiedToken then return end
        local now = os.clock()
        pcall(function() if _G.ESPTick then _G.ESPTick() end end)
        pcall(function() if _G.IpadViewTick then _G.IpadViewTick() end end)
        if (now - S.lastCounter) >= 0.5 then
            S.lastCounter = now
            pcall(function() if _G.ESPCounterTick then _G.ESPCounterTick() end end)
        end
        pcall(function()
            local ok, ticker = pcall(require, "common.time_ticker")
            if ok and ticker and ticker.AddTimerOnce then ticker.AddTimerOnce(0.1, Tick) end
        end)
    end
    pcall(function()
        local ok, ticker = pcall(require, "common.time_ticker")
        if ok and ticker and ticker.AddTimerOnce then
            ticker.AddTimerOnce(0.1, Tick)
            --("[ESP] Unified loop started @ 20 FPS")
        end
    end)
end

-- ============================================================
-- [21] TOGGLE ROW (REDESIGN — Modern Pill)
-- ============================================================
local function UpdateToggleRow(rowData)
    local C = _G.C
    if not rowData then return end
    local state = _G.VIPConfig[rowData.key]
    local stateText = state and "ON" or "OFF"
    local stateColor = state and C.gold_bright or C.text_dim
    
    -- ⭐ Update label ON/OFF di dalam track
    if rowData.stateText and IsValid(rowData.stateText) then
        pcall(function()
            rowData.stateText:SetText(stateText)
            if FSlateColor then rowData.stateText:SetColorAndOpacity(FSlateColor(stateColor)) else rowData.stateText:SetColorAndOpacity(stateColor) end
        end)
    end
    
    -- ⭐ Geser knob (bola putih kecil) ke kiri/kanan
    if rowData.knob and IsValid(rowData.knob) then
        pcall(function()
            local knobX = state and (rowData.toggleX + rowData.toggleW - rowData.knobSize - 3) or (rowData.toggleX + 3)
            rowData.knobSlot:SetPosition(FVector2D(knobX, rowData.toggleY + 3))
        end)
    end
    
    -- ⭐ Ganti warna track (background toggle)
    if rowData.track and IsValid(rowData.track) then
        pcall(function() 
            rowData.track:SetBrushColor(state and C.gold or C.bg_pill) 
        end)
    end
    
    -- ⭐ Glow saat ON
    if rowData.toggleGlow and IsValid(rowData.toggleGlow) then
        pcall(function() 
            rowData.toggleGlow:SetWidgetVisibility(state and UEnums.ESlateVisibility.SelfHitTestInvisible or UEnums.ESlateVisibility.Collapsed) 
        end)
    end
    
    if rowData.rowGlow and IsValid(rowData.rowGlow) then
        pcall(function() 
            rowData.rowGlow:SetWidgetVisibility(state and UEnums.ESlateVisibility.SelfHitTestInvisible or UEnums.ESlateVisibility.Collapsed) 
        end)
    end
    
    if rowData.accent2 and IsValid(rowData.accent2) then
        pcall(function() rowData.accent2:SetBrushColor(state and C.gold or C.divider) end)
    end
    
    -- ⭐ Update warna track inner (transparan overlay)
    if rowData.trackInner and IsValid(rowData.trackInner) then
        pcall(function() 
            rowData.trackInner:SetBrushColor(state and FLinearColor(0,0,0,0.0) or FLinearColor(0,0,0,0.35)) 
        end)
    end
end

local function MakeToggleRow(parent, label, x, y, w, h, toggleKey, isZebra)
    local C = _G.C
    local state = _G.VIPConfig[toggleKey]
    local rowBg = isZebra and C.bg_row_alt or C.bg_row
    local rowData = { key = toggleKey }
    
    -- ⭐ Row glow saat ON (soft, tipis)
    rowData.rowGlow = Layer(parent, x, y, w, h, C.gold_glow, 199)
    if not state then pcall(function() rowData.rowGlow:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end) end
    
    -- ⭐ Background row
    rowData.bg = Layer(parent, x, y, w, h, rowBg, 200)
    
    -- ⭐ Accent bar kiri tipis (3px)
    rowData.accent1 = Layer(parent, x, y + 6, 3, h - 12, C.divider, 201)
    rowData.accent2 = Layer(parent, x, y + 6, 3, h - 12, state and C.gold or C.divider, 202)
    
    -- ⭐ Label teks
    rowData.label = Text(parent, label, x + 18, y + h * 0.5, 12, C.text_label, 300, 0, 0.5)
    
    -- ⭐ Toggle pill
    local toggleW = 54
    local toggleH = 26
    local toggleX = x + w - toggleW - 18
    local toggleY = y + h * 0.5 - toggleH * 0.5
    local knobSize = toggleH - 6
    rowData.toggleX = toggleX
    rowData.toggleY = toggleY
    rowData.toggleW = toggleW
    rowData.toggleH = toggleH
    rowData.knobSize = knobSize
    
    -- ⭐ Glow sekitar pill saat ON
    rowData.toggleGlow = Layer(parent, toggleX - 3, toggleY - 3, toggleW + 6, toggleH + 6, C.gold_glow_strong, 298)
    if not state then pcall(function() rowData.toggleGlow:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end) end
    
    -- ⭐ Track pill (background toggle)
    rowData.track = Layer(parent, toggleX, toggleY, toggleW, toggleH, state and C.gold or C.bg_pill, 300)
    rowData.trackInner = Layer(parent, toggleX + 1, toggleY + 1, toggleW - 2, toggleH - 2, 
        state and FLinearColor(0,0,0,0.0) or FLinearColor(0,0,0,0.35), 301)
    
    -- ⭐ Knob (bola putih)
    local knobX = state and (toggleX + toggleW - knobSize - 3) or (toggleX + 3)
    local knobY = toggleY + 3
    rowData.knobShadow = Layer(parent, knobX, knobY + 1, knobSize, knobSize, FLinearColor(0,0,0,0.5), 302)
    rowData.knobSlot = nil
    pcall(function()
        local k = CGame:NewObjectFromPath("/Script/UMG.Border", parent)
        if k and slua.isValid(k) then
            k:SetBrushColor(C.white)
            k:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            local slot = parent:AddChildToCanvas(k)
            if slot then
                slot:SetAutoSize(false)
                slot:SetPosition(FVector2D(knobX, knobY))
                slot:SetSize(FVector2D(knobSize, knobSize))
                slot:SetZOrder(303)
            end
            rowData.knob = k
            rowData.knobSlot = slot
        end
    end)
    
    -- ⭐ Teks ON/OFF di dalam track (opsional — sebelah knob)
    local stateText = state and "ON" or "OFF"
    local stateColor = state and C.white or C.text_dim
    local textX = state and (toggleX + 8) or (toggleX + toggleW - 8)
    local alignX = state and 0 or 1
    rowData.stateText = Text(parent, stateText, textX, y + h * 0.5, 10, stateColor, 302, alignX, 0.5)
    
    -- ⭐ Divider bawah
    rowData.div = Layer(parent, x, y + h, w, 1, C.divider, 203)
    
    -- ⭐ Button transparan (clickable seluruh row)
    rowData.btn = MakeBtn(parent, x, y, w, h, 900, function()
        local newState = not _G.VIPConfig[toggleKey]
        _G.VIPConfig[toggleKey] = newState
        UpdateToggleRow(rowData)
        
        local hook = _G.FeatureHooks and _G.FeatureHooks[toggleKey]
        if hook then
            pcall(function()
                if newState then 
                    if hook.on then hook.on() end
                else 
                    if hook.off then hook.off() end 
                end
            end)
        end
    end)
    
    table.insert(toggleRows, rowData)
    return rowData
end

-- ============================================================
-- [22] CYCLE ROW (REDESIGN — Modern Selector)
-- ============================================================
local function MakeCycleRow(parent, label, x, y, w, h, config, isZebra)
    local C = _G.C
    local rowBg = isZebra and C.bg_row_alt or C.bg_row
    local rowData = { cycles = config.cycles, idx = config.default or 1, key = config.key }
    
    local function findIndexByValue(v)
        for i, cv in ipairs(config.cycles) do 
            if cv == v then return i end 
        end
        return 1
    end
    
    if config.key and _G.TakoroModState.CustomTextData[config.key] ~= nil then
        rowData.idx = findIndexByValue(_G.TakoroModState.CustomTextData[config.key])
    end
    
    -- Background
    rowData.bg = Layer(parent, x, y, w, h, rowBg, 200)
    
    -- Accent bar kiri
    rowData.accent1 = Layer(parent, x, y + 6, 3, h - 12, C.gold, 201)
    
    -- Label
    rowData.label = Text(parent, label, x + 18, y + h * 0.5, 12, C.text_label, 300, 0, 0.5)
    
    -- ⭐ Value selector (pill dengan < > )
    local valW = 130
    local valH = 30
    local valX = x + w - valW - 16
    local valY = y + h * 0.5 - valH * 0.5
    
    -- Glow subtle
    rowData.valGlow = Layer(parent, valX - 2, valY - 2, valW + 4, valH + 4, C.gold_glow, 298)
    
    -- Border pill
    rowData.valBorder = Layer(parent, valX - 1, valY - 1, valW + 2, valH + 2, C.gold, 299)
    
    -- Background pill
    rowData.valBg = Layer(parent, valX, valY, valW, valH, C.bg_pill, 300)
    
    -- Value text (tengah)
    rowData.valText = Text(parent, tostring(config.cycles[rowData.idx]), valX + valW * 0.5, y + h * 0.5, 13, C.gold_bright, 301, 0.5, 0.5)
    
    -- Arrow < di kiri
    local arrowL = Text(parent, "‹", valX + 12, y + h * 0.5, 22, C.gold_bright, 302, 0.5, 0.5)
    -- Arrow > di kanan
    local arrowR = Text(parent, "›", valX + valW - 12, y + h * 0.5, 22, C.gold_bright, 302, 0.5, 0.5)
    
    -- ⭐ Button kiri (prev) — decrement
    MakeBtn(parent, valX, valY, valW * 0.35, valH, 910, function()
        rowData.idx = rowData.idx - 1
        if rowData.idx < 1 then rowData.idx = #config.cycles end
        local v = config.cycles[rowData.idx]
        pcall(function() rowData.valText:SetText(tostring(v)) end)
        if config.key then 
            _G.TakoroModState.CustomTextData[config.key] = v 
        end
        if config.onApply then 
            pcall(function() config.onApply(v, rowData.idx) end) 
        end
        if config.key == "ColorV3Hidden" or config.key == "ColorV3Visible" or config.key == "ColorV3Thickness" then
            if _G.MarkAllEnemiesDirty then _G.MarkAllEnemiesDirty("v3") end
        end
    end)
    
    -- ⭐ Button kanan (next) — increment
    MakeBtn(parent, valX + valW * 0.65, valY, valW * 0.35, valH, 910, function()
        rowData.idx = rowData.idx + 1
        if rowData.idx > #config.cycles then rowData.idx = 1 end
        local v = config.cycles[rowData.idx]
        pcall(function() rowData.valText:SetText(tostring(v)) end)
        if config.key then 
            _G.TakoroModState.CustomTextData[config.key] = v 
        end
        if config.onApply then 
            pcall(function() config.onApply(v, rowData.idx) end) 
        end
        if config.key == "ColorV3Hidden" or config.key == "ColorV3Visible" or config.key == "ColorV3Thickness" then
            if _G.MarkAllEnemiesDirty then _G.MarkAllEnemiesDirty("v3") end
        end
    end)
    
    -- Divider bawah
    rowData.div = Layer(parent, x, y + h, w, 1, C.divider, 203)
    
    return rowData
end


-- ============================================================
-- [23] BUILD MENU (v3 — SIDEBAR + HEADER + SCROLL)
-- ============================================================

-- ⭐ Konstanta layout baru
local M_W = 720           -- lebar total menu
local M_H = 500           -- tinggi total menu
local SIDEBAR_W = 140     -- lebar sidebar kiri
local HEADER_H2 = 60      -- tinggi header atas
local CONTENT_PAD = 14    -- padding konten
local ROW_H = 38          -- tinggi per row
local SIDEBAR_ITEM_H = 42 -- tinggi per item sidebar
local M_H_CURRENT = M_H

-- ⭐ State scroll global
_G.ScrollState = _G.ScrollState or {
    offsetY = 0,
    maxOffsetY = 0,
    dragging = false,
    dragStartY = 0,
    dragStartOffset = 0,
    lastTouchY = 0,
    contentHeight = 0,
    viewHeight = 0,
    activePanel = nil,  -- panel yang sedang di-scroll
}

local function BuildMenu()
    print("[TAKORO-DEBUG] BuildMenu v3 START")
    local C = _G.C
    if not C then return end
    
    if menuBuilt and bgPanel and IsValid(bgPanel) then
        ShowMenu()
        return
    end
    
    local canvas = GetCanvas()
    if not canvas then return end
    
    local dynamicRefs = {}
    
    -- ⭐ Outer panel (background utama)
    pcall(function()
        bgPanel = CGame:NewObjectFromPath("/Script/UMG.CanvasPanel", canvas)
        if bgPanel and slua.isValid(bgPanel) then
            local slot = canvas:AddChildToCanvas(bgPanel)
            if slot then
                slot:SetAutoSize(false)
                slot:SetZOrder(10000)
                slot:SetAnchors(FAnchors(0.5, 0.5, 0.5, 0.5))
                slot:SetAlignment(FVector2D(0.5, 0.5))
                slot:SetPosition(FVector2D(190, 30))
                slot:SetSize(FVector2D(M_W, M_H))
            end
        end
    end)
    if not bgPanel or not slua.isValid(bgPanel) then return end
    
    -- ⭐ Shadow + border layers
    pcall(function()
        dynamicRefs.s0 = Layer(bgPanel, -22, -22, M_W + 44, M_H + 44, C.shadow5, -7)
        dynamicRefs.s1 = Layer(bgPanel, -14, -14, M_W + 28, M_H + 28, C.shadow4, -6)
        dynamicRefs.s2 = Layer(bgPanel, -8, -8, M_W + 16, M_H + 16, C.shadow3, -5)
        dynamicRefs.s3 = Layer(bgPanel, -4, -4, M_W + 8, M_H + 8, C.shadow2, -4)
        dynamicRefs.s4 = Layer(bgPanel, -2, -2, M_W + 4, M_H + 4, C.shadow1, -3)
        dynamicRefs.b0 = Layer(bgPanel, -2, -2, M_W + 4, M_H + 4, C.border_dark, -2)
        dynamicRefs.b1 = Layer(bgPanel, -1, -1, M_W + 2, M_H + 2, C.card_border or C.divider, -1)
        dynamicRefs.b2 = Layer(bgPanel, 0, 0, M_W, M_H, C.bg_main, 1)
    end)
    
    -- ============================================================
    -- ⭐ SIDEBAR KIRI (background gelap)
    -- ============================================================
    Layer(bgPanel, 0, 0, SIDEBAR_W, M_H, C.bg_header, 2)
    Layer(bgPanel, SIDEBAR_W - 1, 0, 1, M_H, C.divider, 3)
    
    -- ⭐ Logo/branding di atas sidebar
    local logoY = 14
    IconBox(bgPanel, "T", 18, logoY, 34, C.gold, C.white)
    Text(bgPanel, "TAKORO", 60, logoY + 10, 14, C.gold_bright, 400, 0, 0.5)
    Text(bgPanel, "FREE VERSION", 60, logoY + 26, 10, C.text_dim, 400, 0, 0.5)
    
    -- ⭐ Divider di bawah logo
    Layer(bgPanel, 14, logoY + 48, SIDEBAR_W - 28, 1, C.divider, 4)
    
    -- ⭐ Konten panel holder (untuk konten menu)
    local contentRoot = nil
    pcall(function()
        contentRoot = CGame:NewObjectFromPath("/Script/UMG.CanvasPanel", bgPanel)
        if contentRoot and slua.isValid(contentRoot) then
            local slot = bgPanel:AddChildToCanvas(contentRoot)
            if slot then
                slot:SetAutoSize(false)
                slot:SetPosition(FVector2D(SIDEBAR_W, HEADER_H2))
                slot:SetSize(FVector2D(M_W - SIDEBAR_W, M_H - HEADER_H2))
                slot:SetZOrder(5)
            end
            contentRoot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end
    end)
    
    -- ============================================================
    -- ⭐ HEADER ATAS (top bar)
    -- ============================================================
    -- Header background
    Layer(bgPanel, SIDEBAR_W, 0, M_W - SIDEBAR_W, HEADER_H2, C.bg_header3, 3)
    Layer(bgPanel, SIDEBAR_W, HEADER_H2 - 1, M_W - SIDEBAR_W, 1, C.divider, 4)
    
    -- ⭐ Traffic light (3 tombol kiri atas header)
    local tlX = SIDEBAR_W + 14
    local tlY = HEADER_H2 * 0.5 - 6
    local tlR = 12
    local tlGap = 20
    
    -- ? Merah → Close window menu saja (float tetap)
    Layer(bgPanel, tlX, tlY, tlR, tlR, C.traffic_red or C.red, 10)
    MakeBtn(bgPanel, tlX - 3, tlY - 3, tlR + 6, tlR + 6, 950, function()
        if _G.__CloseMenu then _G.__CloseMenu() end
    end)
    
    -- ? Kuning → Close window menu juga
    Layer(bgPanel, tlX + tlGap, tlY, tlR, tlR, C.traffic_yellow or C.gold, 10)
    MakeBtn(bgPanel, tlX + tlGap - 3, tlY - 3, tlR + 6, tlR + 6, 950, function()
        if _G.__CloseMenu then _G.__CloseMenu() end
    end)
    
    -- ? Hijau → Hide SEMUA (menu + float + expired)
    Layer(bgPanel, tlX + tlGap * 2, tlY, tlR, tlR, C.traffic_green or C.status_online, 10)
    MakeBtn(bgPanel, tlX + tlGap * 2 - 3, tlY - 3, tlR + 6, tlR + 6, 950, function()
        if _G.__HideAll then _G.__HideAll() end
    end)
    
    -- ⭐ Title header (tengah)
    Text(bgPanel, "TAKORO TRIAL FREE", SIDEBAR_W + (M_W - SIDEBAR_W) * 0.5, HEADER_H2 * 0.5 - 6, 14, C.text_label, 400, 0.5, 0.5)
    Text(bgPanel, "@Bang_Anca", SIDEBAR_W + (M_W - SIDEBAR_W) * 0.5, HEADER_H2 * 0.5 + 10, 9, C.text_dim, 400, 0.5, 0.5)
    
    -- ⭐ Status server (kanan atas) — geser biar tidak tabrakan tombol close
    local statusX = M_W - 165
    local statusY = HEADER_H2 * 0.5 - 8
    Layer(bgPanel, statusX, statusY, 8, 8, C.status_online or C.gold, 10)
    Text(bgPanel, "CONNECTED", statusX + 14, HEADER_H2 * 0.5, 10, C.status_online or C.gold, 400, 0, 0.5)
    
    -- ============================================================
    -- ⭐ TOMBOL CLOSE (X) — pojok kanan atas header
    -- ⚠️ INI HANYA HIDE MENU, FLOAT TETAP
    -- ============================================================
    local closeBtnX = M_W - 30
    local closeBtnY = HEADER_H2 * 0.5 - 12
    -- Background tombol close
    Layer(bgPanel, closeBtnX - 1, closeBtnY - 1, 26, 26, C.red_dark, 10)
    Layer(bgPanel, closeBtnX, closeBtnY, 24, 24, C.red, 11)
    Layer(bgPanel, closeBtnX, closeBtnY, 24, 12, C.red_bright, 12)
    -- Teks X
    Text(bgPanel, "×", closeBtnX + 12, closeBtnY + 12, 18, C.white, 400, 0.5, 0.5)
    -- ✅ Button handler — HANYA CLOSE MENU
    MakeBtn(bgPanel, closeBtnX, closeBtnY, 24, 24, 960, function()
        if _G.__CloseMenu then _G.__CloseMenu() end
    end)
    
    -- ============================================================
    -- ⭐ SIDEBAR MENU ITEMS
    -- ============================================================
    local sidebarItems = {
        {icon = "⌂",  label = "HOME",    panel = 1},
        {icon = "◉",  label = "ESP",     panel = 2},
        {icon = "✛",  label = "AIM",     panel = 3},
        {icon = "⚙",  label = "MEMORY",  panel = 4},
        {icon = "◇",  label = "THEME",   panel = 5},
        {icon = "?", label = "BYPASS",  panel = 6},
    }
    
    local sidebarWidgets = {}
    local contentPanels = {}
    local currentPanel = 1
    
    -- ⭐ Panel holder (konten untuk tiap tab)
    for i = 1, #sidebarItems do
        local p = nil
        pcall(function()
            p = CGame:NewObjectFromPath("/Script/UMG.CanvasPanel", contentRoot)
            if p and slua.isValid(p) then
                local slot = contentRoot:AddChildToCanvas(p)
                if slot then
                    slot:SetAutoSize(false)
                    slot:SetPosition(FVector2D(0, 0))
                    slot:SetSize(FVector2D(M_W - SIDEBAR_W, M_H - HEADER_H2))
                    slot:SetZOrder(10)
                end
                p:SetWidgetVisibility(i == 1 and UEnums.ESlateVisibility.SelfHitTestInvisible or UEnums.ESlateVisibility.Collapsed)
            end
        end)
        contentPanels[i] = p or contentRoot
    end
    
    -- ⭐ Switch sidebar panel
    local function SwitchSidebarPanel(panelIdx)
        currentPanel = panelIdx
        _G.ScrollState.offsetY = 0
        _G.ScrollState.activePanel = contentPanels[panelIdx]
        
        for i, sw in ipairs(sidebarWidgets) do
            if sw and sw.bg and IsValid(sw.bg) then
                if i == panelIdx then
                    sw.bg:SetBrushColor(C.sidebar_active or C.bg_row_alt)
                    sw.accent:SetBrushColor(C.gold)
                    if sw.icon and IsValid(sw.icon) then
                        if FSlateColor then sw.icon:SetColorAndOpacity(FSlateColor(C.gold_bright)) else sw.icon:SetColorAndOpacity(C.gold_bright) end
                    end
                    if sw.txt and IsValid(sw.txt) then
                        if FSlateColor then sw.txt:SetColorAndOpacity(FSlateColor(C.gold_bright)) else sw.txt:SetColorAndOpacity(C.gold_bright) end
                    end
                else
                    sw.bg:SetBrushColor(C.transparent)
                    sw.accent:SetBrushColor(C.transparent)
                    if sw.icon and IsValid(sw.icon) then
                        if FSlateColor then sw.icon:SetColorAndOpacity(FSlateColor(C.text_dim)) else sw.icon:SetColorAndOpacity(C.text_dim) end
                    end
                    if sw.txt and IsValid(sw.txt) then
                        if FSlateColor then sw.txt:SetColorAndOpacity(FSlateColor(C.text_dim)) else sw.txt:SetColorAndOpacity(C.text_dim) end
                    end
                end
            end
        end
        
        for i = 1, #contentPanels do
            if contentPanels[i] and IsValid(contentPanels[i]) then
                if i == panelIdx then contentPanels[i]:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                else contentPanels[i]:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end
            end
        end
    end
    
    _G.SwitchSidebarPanel = SwitchSidebarPanel
    
    -- ⭐ Render sidebar items
    local sidebarStartY = logoY + 66
    for i, item in ipairs(sidebarItems) do
        local sy = sidebarStartY + (i - 1) * SIDEBAR_ITEM_H
        local isActive = (i == 1)
        
        local bg = Layer(bgPanel, 8, sy + 3, SIDEBAR_W - 16, SIDEBAR_ITEM_H - 6, 
            isActive and (C.sidebar_active or C.bg_row_alt) or C.transparent, 6)
        local accent = Layer(bgPanel, 8, sy + 8, 3, SIDEBAR_ITEM_H - 16, 
            isActive and C.gold or C.transparent, 7)
        
        local iconTxt = Text(bgPanel, item.icon, 24, sy + SIDEBAR_ITEM_H * 0.5, 15, 
            isActive and C.gold_bright or C.text_dim, 400, 0.5, 0.5)
        local labelTxt = Text(bgPanel, item.label, 44, sy + SIDEBAR_ITEM_H * 0.5, 12, 
            isActive and C.gold_bright or C.text_dim, 400, 0, 0.5)
        
        local panelIdx = item.panel
        MakeBtn(bgPanel, 8, sy + 3, SIDEBAR_W - 16, SIDEBAR_ITEM_H - 6, 900, function()
            SwitchSidebarPanel(panelIdx)
        end)
        
        sidebarWidgets[i] = { bg = bg, accent = accent, icon = iconTxt, txt = labelTxt }
    end
    
    -- ⭐ Set panel awal aktif
    _G.ScrollState.activePanel = contentPanels[1]
    
    -- ============================================================
    -- ⭐ HELPER: Section header di dalam panel
    -- ============================================================
    local contentW = M_W - SIDEBAR_W - CONTENT_PAD * 2
    local contentX = CONTENT_PAD
    local function SectionTitle(panel, title, subtitle)
        local cY = 0
        if subtitle then
            Text(panel, title, contentX + contentW * 0.5, cY + 12, 16, C.text_label, 400, 0.5, 0.5)
            Text(panel, subtitle, contentX + contentW * 0.5, cY + 34, 10, C.text_dim, 400, 0.5, 0.5)
            cY = cY + 58
        else
            Text(panel, title, contentX + contentW * 0.5, cY + 12, 14, C.gold, 400, 0.5, 0.5)
            cY = cY + 36
        end
        return cY
    end
    
    -- ============================================================
    -- ⭐ PANEL 1: HOME (RAPAT)
    -- ============================================================
    do
        local panel = contentPanels[1]
        local cY = SectionTitle(panel, "TAKORO TRIAL", "Version 4.6 — FREE VERSION 2.0")
        
        -- ⭐ Welcome card (rapat)
        Card(panel, contentX, cY, contentW, 80, 200)
        IconBox(panel, "T", contentX + 16, cY + 12, 52, C.gold, C.white)
        Text(panel, "Welcome, Brodii..", contentX + 82, cY + 20, 14, C.text_label, 400, 0, 0.5)
        Text(panel, "Your FREE Mod is active", contentX + 82, cY + 40, 10, C.text_dim, 400, 0, 0.5)
        Layer(panel, contentX + 82, cY + 56, 6, 6, C.status_online or C.gold, 300)
        Text(panel, "CONNECTED", contentX + 94, cY + 59, 9, C.status_online or C.gold, 400, 0, 0.5)
        
        local expWidget = Text(panel, "Exp: " .. tostring(_G.TakoroModState.ExpiredDateStr or "N/A"), contentX + 82, cY + 72, 9, C.text_dim, 400, 0, 0.5)
_G.HomeExpWidget = expWidget
        cY = cY + 90
        cY = cY + 8
        
        -- ⭐ Info card (rapat)
        Card(panel, contentX, cY, contentW, 62, 200)
        Text(panel, "INFORMASI", contentX + 14, cY + 10, 10, C.gold, 400, 0, 0.5)
        Divider(panel, contentX + 14, cY + 24, contentW - 28, C.divider, 300)
        Text(panel, "• Mod ini dibuat oleh @Bang_Anca", contentX + 14, cY + 32, 9, C.text_label, 400, 0, 0.5)
        Text(panel, "• Gunakan dengan bijak Aktifkan Fitur Seperlunya Saja", contentX + 14, cY + 46, 9, C.text_label, 400, 0, 0.5)
        cY = cY + 70
        cY = cY + 8
        
        -- ⭐ Save/Load/Delete config buttons (rapat)
        Card(panel, contentX, cY, contentW, 68, 200)
        Text(panel, "CONFIG", contentX + 14, cY + 10, 10, C.gold, 400, 0, 0.5)
        local btnY = cY + 26
        local btnW = (contentW - 40) / 3
        local btnH = 28
        -- Save
        Layer(panel, contentX + 14, btnY, btnW, btnH, C.bg_pill, 300)
        Text(panel, "SAVE", contentX + 14 + btnW * 0.5, btnY + btnH * 0.5, 10, C.gold_bright, 400, 0.5, 0.5)
        MakeBtn(panel, contentX + 14, btnY, btnW, btnH, 900, function()
            if _G.TakoroModNotify then _G.TakoroModNotify("CONFIG SAVED!") end
        end)
        -- Load
        Layer(panel, contentX + 14 + btnW + 6, btnY, btnW, btnH, C.bg_pill, 300)
        Text(panel, "LOAD", contentX + 14 + btnW + 6 + btnW * 0.5, btnY + btnH * 0.5, 10, C.gold_bright, 400, 0.5, 0.5)
        MakeBtn(panel, contentX + 14 + btnW + 6, btnY, btnW, btnH, 900, function()
            if _G.TakoroModNotify then _G.TakoroModNotify("CONFIG LOADED!") end
        end)
        -- Delete
        Layer(panel, contentX + 14 + (btnW + 6) * 2, btnY, btnW, btnH, C.red_dark, 300)
        Text(panel, "RESET", contentX + 14 + (btnW + 6) * 2 + btnW * 0.5, btnY + btnH * 0.5, 10, C.white, 400, 0.5, 0.5)
        MakeBtn(panel, contentX + 14 + (btnW + 6) * 2, btnY, btnW, btnH, 900, function()
            if _G.TakoroModNotify then _G.TakoroModNotify("CONFIG RESET!") end
        end)
        cY = cY + 76
        cY = cY + 8
        
        -- ⭐ Channel (rapat)
        Card(panel, contentX, cY, contentW, 46, 200)
        Text(panel, "OWNER TELEGRAM", contentX + 14, cY + 10, 10, C.gold, 400, 0, 0.5)
        Text(panel, "@Bang_Anca", contentX + 14, cY + 26, 12, C.gold_bright, 400, 0, 0.5)
        cY = cY + 56
        
        _G.ScrollState.contentHeight = cY
    end
    
    -- ============================================================
    -- ⭐ PANEL 2: ESP
    -- ============================================================
    do
        local panel = contentPanels[2]
        local cY = SectionTitle(panel, "ESP SYSTEM", "Enemy Detection & Visual")
        local espOpts = {
            {label = "ESP HP",           key = "ESP_HP"},
            {label = "ESP HP NATIVE",    key = "ESP_HPNative"},
            {label = "ESP BOX",          key = "ESP_Box"},
            {label = "ESP DISTANCE",     key = "ESP_Distance"},
            {label = "ESP RADAR",        key = "ESP_Radar"},
            {label = "ENEMY COUNTER",    key = "ESP_Counter"},
            {label = "AIM WARNING",      key = "ESP_Warning"},
            {label = "WARNING VISCHECK", key = "ESP_WarnVis"},
            {label = "ESP LINE",         key = "ESP_Line"},
        }
        for i, opt in ipairs(espOpts) do
            if _G.VIPConfig[opt.key] == nil then _G.VIPConfig[opt.key] = false end
            MakeToggleRow(panel, opt.label, contentX, cY, contentW, ROW_H, opt.key, i % 2 == 0)
            cY = cY + ROW_H
        end
        _G.ScrollState.contentHeight = math.max(_G.ScrollState.contentHeight or 0, cY)
    end
    
    -- ============================================================
    -- ⭐ PANEL 3: AIM (dengan sub-tab)
    -- ============================================================
    do
        local panel = contentPanels[3]
        local aimSubNames = {"MAIN", "TPP", "SCOPE", "SNIPER", "SG", "MORTAR"}
        local subTabH = 36
        local subTabW = contentW / #aimSubNames
        local subTabY = 8
        
        -- Background sub-tab
        Layer(panel, contentX, subTabY, contentW, subTabH, C.bg_subtab, 200)
        
        local aimSubPanels = {}
        local aimSubPills = {}
        
        -- Buat holder panel untuk tiap sub-tab
        for i = 1, #aimSubNames do
            local sp = nil
            pcall(function()
                sp = CGame:NewObjectFromPath("/Script/UMG.CanvasPanel", panel)
                if sp and slua.isValid(sp) then
                    local slot = panel:AddChildToCanvas(sp)
                    if slot then
                        slot:SetAutoSize(false)
                        slot:SetPosition(FVector2D(0, subTabY + subTabH + 6))
                        slot:SetSize(FVector2D(M_W - SIDEBAR_W, M_H - HEADER_H2 - subTabH - 20))
                        slot:SetZOrder(20)
                    end
                    sp:SetWidgetVisibility(i == 1 and UEnums.ESlateVisibility.SelfHitTestInvisible or UEnums.ESlateVisibility.Collapsed)
                end
            end)
            aimSubPanels[i] = sp or panel
        end
        
        -- ⭐ Switch aim sub-tab
        local function SwitchAimSub(idx)
            for i, pill in ipairs(aimSubPills) do
                if pill and pill.bg and IsValid(pill.bg) then
                    if i == idx then
                        pill.bg:SetBrushColor(C.bg_pill_on)
                        if pill.txt and IsValid(pill.txt) then
                            if FSlateColor then pill.txt:SetColorAndOpacity(FSlateColor(C.white)) else pill.txt:SetColorAndOpacity(C.white) end
                        end
                    else
                        pill.bg:SetBrushColor(C.bg_pill)
                        if pill.txt and IsValid(pill.txt) then
                            if FSlateColor then pill.txt:SetColorAndOpacity(FSlateColor(C.text_dim)) else pill.txt:SetColorAndOpacity(C.text_dim) end
                        end
                    end
                end
            end
            for i, p in ipairs(aimSubPanels) do
                if p and IsValid(p) then
                    if i == idx then p:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                    else p:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end
                end
            end
        end
        
        for i, name in ipairs(aimSubNames) do
            local px = contentX + (i - 1) * subTabW
            local isActive = (i == 1)
            local pillBg = Layer(panel, px + 2, subTabY + 4, subTabW - 4, subTabH - 8, 
                isActive and C.bg_pill_on or C.bg_pill, 300)
            local pillTxt = Text(panel, name, px + subTabW * 0.5, subTabY + subTabH * 0.5, 10, 
                isActive and C.white or C.text_dim, 400, 0.5, 0.5)
            local idx = i
            MakeBtn(panel, px, subTabY, subTabW, subTabH, 900, function() SwitchAimSub(idx) end)
            aimSubPills[i] = { bg = pillBg, txt = pillTxt }
        end
        
        -- ⭐ MAIN sub-panel
        do
            local sp = aimSubPanels[1]
            local cY = 10
            local items = {
                {label = "MASTER AIM TOUCH", key = "AIM_Enabled"},
                {label = "IGNORE KNOCKDOWN", key = "AIM_IGN_KNOCK"},
                {label = "IGNORE BOT",       key = "AIM_IGN_BOT"},
                {label = "VISIBLE CHECK",    key = "AIM_VISCHECK"},
            }
            for i, opt in ipairs(items) do
                if _G.VIPConfig[opt.key] == nil then _G.VIPConfig[opt.key] = false end
                MakeToggleRow(sp, opt.label, contentX, cY, contentW, ROW_H, opt.key, i % 2 == 0)
                cY = cY + ROW_H
            end
        end
        
        -- ⭐ TPP sub-panel
        do
            local sp = aimSubPanels[2]
            local cY = 10
            MakeToggleRow(sp, "TPP AIM", contentX, cY, contentW, ROW_H, "AIM_TPP", false)
            cY = cY + ROW_H
            local vals = {
                {label = "FOV",       key = "AimTouchHipFOV",   cycles = CYCLE.FOV},
                {label = "SPEED",     key = "AimTouchHipSpeed", cycles = CYCLE.SPEED},
                {label = "DISTANCE",  key = "AimTouchHipDist",  cycles = CYCLE.DIST},
                {label = "BONE",      key = "AimTouchHipBone",  cycles = CYCLE.BONE},
                {label = "CONDITION", key = "AimTouchHipCond",  cycles = CYCLE.COND},
                {label = "PRIORITY",  key = "AimTouchHipPrio",  cycles = CYCLE.PRIO},
            }
            for i, v in ipairs(vals) do
                MakeCycleRow(sp, v.label, contentX, cY, contentW, ROW_H, {cycles = v.cycles, key = v.key, default = 1}, (i % 2 == 1))
                cY = cY + ROW_H
            end
        end
        
        -- ⭐ SCOPE sub-panel
        do
            local sp = aimSubPanels[3]
            local cY = 10
            MakeToggleRow(sp, "ADS AIM", contentX, cY, contentW, ROW_H, "AIM_ADS", false)
            cY = cY + ROW_H
            local vals = {
                {label = "FOV",         key = "AimTouchScopeFOV",    cycles = CYCLE.FOV},
                {label = "SPEED",       key = "AimTouchScopeSpeed",  cycles = CYCLE.SPEED},
                {label = "DISTANCE",    key = "AimTouchScopeDist",   cycles = CYCLE.DIST},
                {label = "BONE",        key = "AimTouchScopeBone",   cycles = CYCLE.BONE},
                {label = "CONDITION",   key = "AimTouchScopeCond",   cycles = CYCLE.COND},
                {label = "PRIORITY",    key = "AimTouchScopePrio",   cycles = CYCLE.PRIO},
                {label = "PREDICTION",  key = "AimTouchScopePred",   cycles = CYCLE.PRED},
                {label = "RECOIL COMP", key = "AimTouchScopeRecoil", cycles = CYCLE.RECOIL},
            }
            for i, v in ipairs(vals) do
                MakeCycleRow(sp, v.label, contentX, cY, contentW, ROW_H, {cycles = v.cycles, key = v.key, default = 1}, (i % 2 == 1))
                cY = cY + ROW_H
            end
        end
        
        -- ⭐ SNIPER sub-panel
        do
            local sp = aimSubPanels[4]
            local cY = 10
            MakeToggleRow(sp, "SNIPER SCOPE AIM", contentX, cY, contentW, ROW_H, "AIM_SNIPER", false)
            cY = cY + ROW_H
            local vals = {
                {label = "FOV",        key = "AimTouchSniperFOV",   cycles = CYCLE.FOV},
                {label = "SPEED",      key = "AimTouchSniperSpeed", cycles = CYCLE.SPEED},
                {label = "DISTANCE",   key = "AimTouchSniperDist",  cycles = CYCLE.DIST},
                {label = "BONE",       key = "AimTouchSniperBone",  cycles = CYCLE.BONE},
                {label = "CONDITION",  key = "AimTouchSniperCond",  cycles = CYCLE.COND},
                {label = "PRIORITY",   key = "AimTouchSniperPrio",  cycles = CYCLE.PRIO},
                {label = "PREDICTION", key = "AimTouchSniperPred",  cycles = CYCLE.PRED},
            }
            for i, v in ipairs(vals) do
                MakeCycleRow(sp, v.label, contentX, cY, contentW, ROW_H, {cycles = v.cycles, key = v.key, default = 1}, (i % 2 == 1))
                cY = cY + ROW_H
            end
        end
        
        -- ⭐ SG sub-panel
        do
            local sp = aimSubPanels[5]
            local cY = 10
            MakeToggleRow(sp, "SHOTGUN AIM", contentX, cY, contentW, ROW_H, "AIM_SG", false)
            cY = cY + ROW_H
            MakeToggleRow(sp, "AUTO FIRE", contentX, cY, contentW, ROW_H, "AIM_SGAutoFire", true)
            cY = cY + ROW_H
            local vals = {
                {label = "FOV",       key = "AimTouchSGFOV",   cycles = CYCLE.FOV},
                {label = "SPEED",     key = "AimTouchSGSpeed", cycles = CYCLE.SPEED},
                {label = "DISTANCE",  key = "AimTouchSGDist",  cycles = CYCLE.DIST},
                {label = "BONE",      key = "AimTouchSGBone",  cycles = CYCLE.BONE},
                {label = "CONDITION", key = "AimTouchSGCond",  cycles = CYCLE.COND},
                {label = "PRIORITY",  key = "AimTouchSGPrio",  cycles = CYCLE.PRIO},
            }
            for i, v in ipairs(vals) do
                MakeCycleRow(sp, v.label, contentX, cY, contentW, ROW_H, {cycles = v.cycles, key = v.key, default = 1}, (i % 2 == 0))
                cY = cY + ROW_H
            end
        end
        
        -- ⭐ MORTAR sub-panel
        do
            local sp = aimSubPanels[6]
            local cY = 10
            MakeToggleRow(sp, "MORTAR AIM", contentX, cY, contentW, ROW_H, "AIM_MORTAR", false)
            cY = cY + ROW_H
            MakeCycleRow(sp, "FOV",        contentX, cY, contentW, ROW_H, {cycles = CYCLE.FOV,  key = "AimTouchMortarFOV",  default = 1}, true)
            cY = cY + ROW_H
            MakeCycleRow(sp, "PREDICTION", contentX, cY, contentW, ROW_H, {cycles = CYCLE.PRED, key = "AimTouchMortarPred", default = 1}, false)
        end
    end
    
    -- ============================================================
    -- ⭐ PANEL 4: MEMORY
    -- ============================================================
    do
        local panel = contentPanels[4]
        local cY = SectionTitle(panel, "MEMORY SYSTEM", "Wallhack, Chams & Visual")
        local memToggles1 = {
            {label = "WALLHACK V1",   key = "MEM_WallV1"},
            {label = "CHAMS V2",      key = "MEM_WallV2"},
            {label = "CHAMS V3",      key = "MEM_WallV3"},
        }
        for i, opt in ipairs(memToggles1) do
            if _G.VIPConfig[opt.key] == nil then _G.VIPConfig[opt.key] = false end
            MakeToggleRow(panel, opt.label, contentX, cY, contentW, ROW_H, opt.key, i % 2 == 0)
            cY = cY + ROW_H
        end
        local colorVals = {
            {label = "V3 HIDDEN COLOR",  key = "ColorV3Hidden",    cycles = CYCLE.COLOR_V3},
            {label = "V3 VISIBLE COLOR", key = "ColorV3Visible",   cycles = CYCLE.COLOR_V3},
            {label = "V3 THICKNESS",     key = "ColorV3Thickness", cycles = CYCLE.THICKNESS},
        }
        for i, v in ipairs(colorVals) do
            MakeCycleRow(panel, v.label, contentX, cY, contentW, ROW_H, {cycles = v.cycles, key = v.key, default = 1}, (i % 2 == 1))
            cY = cY + ROW_H
        end
        MakeToggleRow(panel, "CHAMS NEW", contentX, cY, contentW, ROW_H, "MEM_WallNew", true)
        cY = cY + ROW_H
        MakeToggleRow(panel, "IPAD VIEW TPP", contentX, cY, contentW, ROW_H, "MEM_IpadView", false)
        cY = cY + ROW_H
        MakeCycleRow(panel, "IPAD TPP FOV", contentX, cY, contentW, ROW_H, {cycles = CYCLE.FOV_IPAD, key = "IpadViewFOV", default = 4}, true)
        cY = cY + ROW_H
    end
    
    -- ============================================================
    -- ⭐ PANEL 5: THEME (RAPAT)
    -- ============================================================
    do
        local panel = contentPanels[5]
        local cY = SectionTitle(panel, "THEME SELECTOR", "Pilih Tema Visual Favoritmu")
        
        -- Info tema aktif (rapat)
        Card(panel, contentX, cY, contentW, 50, 200)
        Text(panel, "TEMA AKTIF", contentX + 14, cY + 10, 9, C.text_dim, 400, 0, 0.5)
        Text(panel, tostring(_G.CurrentThemeName), contentX + 14, cY + 26, 14, C.gold_bright, 400, 0, 0.5)
        cY = cY + 60
        
        -- Daftar tema (rapat)
        local themeList = {
            {name = "DARK",      desc = "Modern Dark Slate"},
            {name = "WHITE",     desc = "Clean White"},
            {name = "GOLD",      desc = "Elegan & Mewah"},
            {name = "CYBERPUNK", desc = "Neon Futuristik"},
            {name = "BLOOD",     desc = "Merah Agresif"},
            {name = "ICE",       desc = "Biru Es Elegan"},
        }
        
        for i, theme in ipairs(themeList) do
            local isActive = (_G.CurrentThemeName == theme.name)
            local rowH = 42
            if isActive then
                Layer(panel, contentX - 2, cY - 2, contentW + 4, rowH + 4, C.gold_glow_strong, 198)
            end
            Layer(panel, contentX, cY, contentW, rowH, isActive and C.bg_row_alt or C.bg_row, 200)
            Layer(panel, contentX, cY + 4, 4, rowH - 8, isActive and C.gold or C.divider, 201)
            
            -- Preview color box (rapat)
            local previewC = _G.Themes[theme.name] and _G.Themes[theme.name].gold or C.gold
            Layer(panel, contentX + 14, cY + rowH * 0.5 - 9, 18, 18, previewC, 203)
            Layer(panel, contentX + 14, cY + rowH * 0.5 - 9, 18, 9, FLinearColor(1,1,1,0.2), 204)
            
            Text(panel, theme.name, contentX + 42, cY + rowH * 0.5 - 6, 12, isActive and C.gold_bright or C.text_label, 400, 0, 0.5)
            Text(panel, theme.desc, contentX + 42, cY + rowH * 0.5 + 8, 9, C.text_dim, 400, 0, 0.5)
            
            -- Badge AKTIF / Pilih (rapat)
            local badgeW = 52
            local badgeX = contentX + contentW - badgeW - 12
            local badgeY = cY + rowH * 0.5 - 9
            if isActive then
                Layer(panel, badgeX, badgeY, badgeW, 18, C.gold, 203)
                Text(panel, "AKTIF", badgeX + badgeW * 0.5, cY + rowH * 0.5, 9, C.white, 400, 0.5, 0.5)
            else
                Layer(panel, badgeX, badgeY, badgeW, 18, C.bg_pill, 203)
                Text(panel, "PILIH", badgeX + badgeW * 0.5, cY + rowH * 0.5, 9, C.gold, 400, 0.5, 0.5)
            end
            
            Divider(panel, contentX, cY + rowH, contentW, C.divider, 202)
            
            local capturedName = theme.name
            MakeBtn(panel, contentX, cY, contentW, rowH, 900, function()
                _G.SetTheme(capturedName)
            end)
            cY = cY + rowH + 4
        end
        cY = cY + 12
        Divider(panel, contentX, cY, contentW, C.divider, 200)
        cY = cY + 10
        Text(panel, "Tema disimpan otomatis.", contentX + contentW * 0.5, cY, 9, C.text_dim, 400, 0.5, 0.5)
    end
    
    -- ============================================================
    -- ⭐ PANEL 6: BYPASS VIP
    -- ============================================================
    do
        local panel = contentPanels[6]
        local cY = SectionTitle(panel, "ANTI-BAN & PROTECTION", "Wajib Aktifkan Di Spawn Islands")
        local bypassOpts = {
            {label = "FREE VERSION BYPASS",      key = "AUTO_FEEDBACK"},
         -- {label = "ANTI REPORT",        key = "BYPASS_ANTI_REPORT"},
        --  {label = "ANTI KICK",          key = "BYPASS_ANTI_KICK"},
          --  {label = "ANTI BAN DEVICE",    key = "BYPASS_ANTI_BAN_DEVICE"},
        --    {label = "ANTI DETECT",        key = "BYPASS_ANTI_DETECT"},
         --   {label = "FAKE DEVICE ID",     key = "BYPASS_FAKE_DEVICE"},
         --   {label = "FAKE LOCATION",      key = "BYPASS_FAKE_LOCATION"},
        --    {label = "STEALTH MODE",       key = "BYPASS_STEALTH_MODE"},
         --   {label = "PROTECT MEMORY",     key = "BYPASS_PROTECT_MEMORY"},
        }
        for i, opt in ipairs(bypassOpts) do
            if _G.VIPConfig[opt.key] == nil then _G.VIPConfig[opt.key] = false end
            MakeToggleRow(panel, opt.label, contentX, cY, contentW, ROW_H, opt.key, i % 2 == 0)
            cY = cY + ROW_H
        end
    end
    
    -- ============================================================
    -- ⭐ SCROLL SYSTEM (overlay untuk detect gesture)
    -- ============================================================
    pcall(function()
        local scrollOverlay = nil
        scrollOverlay = CGame:NewObjectFromPath("/Script/UMG.Button", bgPanel)
        if scrollOverlay and slua.isValid(scrollOverlay) then
            scrollOverlay:SetColorAndOpacity(C.transparent)
            scrollOverlay:SetBackgroundColor(C.transparent)
            scrollOverlay:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            local slot = bgPanel:AddChildToCanvas(scrollOverlay)
            if slot then
                slot:SetAutoSize(false)
                slot:SetPosition(FVector2D(SIDEBAR_W, HEADER_H2))
                slot:SetSize(FVector2D(M_W - SIDEBAR_W, M_H - HEADER_H2))
                slot:SetZOrder(500)
            end
        end
    end)
    
    -- ============================================================
    -- ⭐ Panah naik/turun kanan (fallback scroll)
    -- ============================================================
    do
        local arrowX = M_W - 30
        local arrowUpY = HEADER_H2 + 60
        local arrowDownY = M_H - 100
        -- ⭐ Cek kalau konten tidak overflow, sembunyikan panah
        local S = _G.ScrollState
        local hasScroll = (S.contentHeight or 0) > (M_H - HEADER_H2 - 100)
        if not hasScroll then
            arrowUpY = -9999
            arrowDownY = -9999
        end
        
        -- Up arrow
        Layer(bgPanel, arrowX, arrowUpY, 22, 30, C.bg_pill, 500)
        Text(bgPanel, "▲", arrowX + 11, arrowUpY + 15, 12, C.gold_bright, 501, 0.5, 0.5)
        MakeBtn(bgPanel, arrowX, arrowUpY, 22, 30, 900, function()
            local S = _G.ScrollState
            S.offsetY = math.max(0, S.offsetY - 120)
        end)
        
        -- Down arrow
        Layer(bgPanel, arrowX, arrowDownY, 22, 30, C.bg_pill, 500)
        Text(bgPanel, "▼", arrowX + 11, arrowDownY + 15, 12, C.gold_bright, 501, 0.5, 0.5)
        MakeBtn(bgPanel, arrowX, arrowDownY, 22, 30, 900, function()
            local S = _G.ScrollState
            S.offsetY = S.offsetY + 120
        end)
    end
    
    -- ⭐ Footer (branding developer)
    pcall(function()
        Layer(bgPanel, SIDEBAR_W, M_H - 24, M_W - SIDEBAR_W, 1, C.divider, 5)
        Layer(bgPanel, SIDEBAR_W, M_H - 23, M_W - SIDEBAR_W, 23, C.bg_header, 1)
        Text(bgPanel, "@Bang_Anca  |  TAKORO MOD FREE", SIDEBAR_W + (M_W - SIDEBAR_W) * 0.5, M_H - 12, 9, C.text_dim, 400, 0.5, 0.5)
    end)
    
    menuBuilt = true
    isMenuOpen = true
    _G.TakoroModState.MenuHidden = false
    _G.__BuildMenu = BuildMenu
end



-- ============================================================
-- [24] FLOAT BUTTON (REDESIGN — Pill Modern + Ghost Click Area)
-- ============================================================
local function CreateFloat()
    local C = _G.C
    if floatItem and floatItem.btn and IsValid(floatItem.btn) then return end
    floatItem = nil
    pcall(function()
        local canvas = GetCanvas()
        if not canvas then return end
        floatItem = {}
        local fX = 450
        local fY = 10
        local fW = 130
        local fH = 48
        -- ⭐ Simpan posisi biar EXPIRED bisa sejajar
        _G.FloatTakoroPos = { X = fX, Y = fY, W = fW, H = fH }
        
        -- ⭐ Ghost button DULU (paling belakang) — area klik besar
        -- Posisi & ukuran: 30px lebih besar dari float button tiap sisi
        pcall(function()
            floatItem.ghostBtn = CGame:NewObjectFromPath("/Script/UMG.Button", canvas)
            if floatItem.ghostBtn and slua.isValid(floatItem.ghostBtn) then
                floatItem.ghostBtn:SetColorAndOpacity(C.transparent)
                floatItem.ghostBtn:SetBackgroundColor(C.transparent)
                floatItem.ghostBtn:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
                local slot = canvas:AddChildToCanvas(floatItem.ghostBtn)
                if slot then
                    slot:SetAutoSize(false)
                    slot:SetPosition(FVector2D(fX - 30, fY - 30))
                    slot:SetSize(FVector2D(fW + 60, fH + 60))
                    slot:SetZOrder(89000)  -- ⬅️ paling belakang
                end
                floatItem.ghostBtn.OnClicked:Add(function()
                    pcall(function() 
                        if _G.__ShowAll then _G.__ShowAll() end 
                    end)
                end)
            end
        end)
        
        -- ⭐ Shadow layers (soft)
        floatItem.s0  = FloatLayer(canvas, fX - 16, fY - 16, fW + 32, fH + 32, C.shadow5, 11895)
        floatItem.s1  = FloatLayer(canvas, fX - 10, fY - 10, fW + 20, fH + 20, C.shadow4, 11896)
        floatItem.s2  = FloatLayer(canvas, fX - 5,  fY - 5,  fW + 10, fH + 10, C.shadow3, 11897)
        floatItem.s3  = FloatLayer(canvas, fX - 2,  fY - 2,  fW + 4,  fH + 4,  C.shadow2, 11898)
        
        -- ⭐ Border (accent)
        floatItem.s4  = FloatLayer(canvas, fX - 1,  fY - 1,  fW + 2,  fH + 2,  C.gold, 11899)
        
        -- ⭐ Background utama
        floatItem.s6  = FloatLayer(canvas, fX, fY, fW, fH, C.bg_main, 11902)
        
        -- ⭐ Accent bar kiri (merah/gold)
        floatItem.s9  = FloatLayer(canvas, fX, fY + 4, 3, fH - 8, C.gold, 11903)
        
        -- ⭐ Status dot hijau (online indicator)
        floatItem.s10 = FloatLayer(canvas, fX + 12, fY + 12, 8, 8, C.status_online or C.gold, 11904)
        
        -- ⭐ Text "TAKORO VIP"
        pcall(function()
            floatItem.text = CGame:NewObjectFromPath("/Script/UMG.TextBlock", canvas)
            if floatItem.text and slua.isValid(floatItem.text) then
                floatItem.text:SetText("TAKORO FREE")
                local menuTextColor = C.gold_bright
                if FSlateColor then floatItem.text:SetColorAndOpacity(FSlateColor(menuTextColor))
                else floatItem.text:SetColorAndOpacity(menuTextColor) end
                if floatItem.text.Font then local f = floatItem.text.Font f.Size = 14 floatItem.text.Font = f end
                floatItem.text:SetRenderTransformPivot(FVector2D(0, 0.5))
                floatItem.text:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                local slot = canvas:AddChildToCanvas(floatItem.text)
                if slot then
                    slot:SetAutoSize(true)
                    slot:SetAlignment(FVector2D(0, 0.5))
                    slot:SetPosition(FVector2D(fX + 26, fY + fH * 0.5 - 6))
                    slot:SetZOrder(12001)
                end
            end
        end)
        
        -- ⭐ Sub text "4.6"
        pcall(function()
            floatItem.subText = CGame:NewObjectFromPath("/Script/UMG.TextBlock", canvas)
            if floatItem.subText and slua.isValid(floatItem.subText) then
                floatItem.subText:SetText("v4.6 • Active")
                local col = C.text_dim
                if FSlateColor then floatItem.subText:SetColorAndOpacity(FSlateColor(col))
                else floatItem.subText:SetColorAndOpacity(col) end
                if floatItem.subText.Font then local f = floatItem.subText.Font f.Size = 9 floatItem.subText.Font = f end
                floatItem.subText:SetRenderTransformPivot(FVector2D(0, 0.5))
                floatItem.subText:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                local slot = canvas:AddChildToCanvas(floatItem.subText)
                if slot then
                    slot:SetAutoSize(true)
                    slot:SetAlignment(FVector2D(0, 0.5))
                    slot:SetPosition(FVector2D(fX + 26, fY + fH * 0.5 + 8))
                    slot:SetZOrder(12002)
                end
            end
        end)
        
        -- ⭐ Main button (klik buka menu)
        pcall(function()
            floatItem.btn = CGame:NewObjectFromPath("/Script/UMG.Button", canvas)
            if floatItem.btn and slua.isValid(floatItem.btn) then
                floatItem.btn:SetColorAndOpacity(C.transparent)
                floatItem.btn:SetBackgroundColor(C.transparent)
                floatItem.btn:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
                local slot = canvas:AddChildToCanvas(floatItem.btn)
                if slot then
                    slot:SetAutoSize(false)
                    slot:SetPosition(FVector2D(fX, fY))
                    slot:SetSize(FVector2D(fW - 24, fH))
                    slot:SetZOrder(95000)  -- ⬅️ paling depan
                end
                floatItem.btn.OnClicked:Add(function()
                    pcall(function() 
                        if _G.__OpenMenu then _G.__OpenMenu() end 
                    end)
                end)
            end
        end)
        
        -- ⭐ Close button (X kecil kanan atas)
        pcall(function()
            floatItem.closeBtn = CGame:NewObjectFromPath("/Script/UMG.Button", canvas)
            if floatItem.closeBtn and slua.isValid(floatItem.closeBtn) then
                floatItem.closeBtn:SetColorAndOpacity(C.transparent)
                floatItem.closeBtn:SetBackgroundColor(C.transparent)
                floatItem.closeBtn:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
                local slot = canvas:AddChildToCanvas(floatItem.closeBtn)
                if slot then
                    slot:SetAutoSize(false)
                    slot:SetPosition(FVector2D(fX + fW - 22, fY + 2))
                    slot:SetSize(FVector2D(20, 20))
                    slot:SetZOrder(96000)
                end
                floatItem.closeBtn.OnClicked:Add(function()
                    pcall(function() 
                        if _G.__HideAll then _G.__HideAll() end 
                    end)
                end)
            end
        end)
        
        -- ⭐ Close button visual (X text)
        pcall(function()
            floatItem.closeTxt = CGame:NewObjectFromPath("/Script/UMG.TextBlock", canvas)
            if floatItem.closeTxt and slua.isValid(floatItem.closeTxt) then
                floatItem.closeTxt:SetText("×")
                if FSlateColor then floatItem.closeTxt:SetColorAndOpacity(FSlateColor(C.text_dim)) else floatItem.closeTxt:SetColorAndOpacity(C.text_dim) end
                if floatItem.closeTxt.Font then local f = floatItem.closeTxt.Font f.Size = 16 floatItem.closeTxt.Font = f end
                floatItem.closeTxt:SetRenderTransformPivot(FVector2D(0.5, 0.5))
                floatItem.closeTxt:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                local slot = canvas:AddChildToCanvas(floatItem.closeTxt)
                if slot then
                    slot:SetAutoSize(true)
                    slot:SetAlignment(FVector2D(0.5, 0.5))
                    slot:SetPosition(FVector2D(fX + fW - 12, fY + 12))
                    slot:SetZOrder(96001)
                end
            end
        end)
    end)
end


-- ============================================================
-- [25] ESPIRED SYSTEM (disederhanakan — hanya floating)
-- ============================================================
_G.TakoroModState.ExpiredTimestamp = _G.TakoroModState.ExpiredTimestamp or 0
_G.TakoroModState.ExpiredDateStr = _G.TakoroModState.ExpiredDateStr or "BELUM DI SET"
_G.TakoroModState.ExpiredToken = _G.TakoroModState.ExpiredToken or 0
_G.TakoroModState.ExpiredWidgets = _G.TakoroModState.ExpiredWidgets or {}
_G.TakoroModState.FloatExpired = _G.TakoroModState.FloatExpired or nil
_G.ExpiredConfig = _G.ExpiredConfig or {
    ShowCountdown=true, AutoCloseMenu=true, ShowPopup=true, CheckInterval=5,
    FloatX=620, FloatY=14, FloatW=110, FloatH=50,
    Title="MASA KADALUARSA", Message="Masa aktif Mod Anda telah berakhir.", Contact="@Bang_Anca",
}

local function ParseDate(dateStr)
    if type(dateStr) ~= "string" then return nil end
    local y, m, d, hh, mm, ss = dateStr:match("^(%d+)-(%d+)-(%d+)[ T](%d+):(%d+):(%d+)$")
    if not y then y, m, d, hh, mm = dateStr:match("^(%d+)-(%d+)-(%d+)[ T](%d+):(%d+)$") ss = "00" end
    if not y then y, m, d = dateStr:match("^(%d+)-(%d+)-(%d+)$") hh, mm, ss = "00", "00", "00" end
    if not y then return nil end
    y, m, d = tonumber(y), tonumber(m), tonumber(d)
    hh, mm, ss = tonumber(hh), tonumber(mm), tonumber(ss)
    if not y or not m or not d then return nil end
    local ok, ts = pcall(os.time, {year=y, month=m, day=d, hour=hh or 0, min=mm or 0, sec=ss or 0})
    if ok then return ts end
    return nil
end

local function FormatShort(sec)
    if sec <= 0 then return "EXPIRED" end
    local days = math.floor(sec / 86400)
    local hours = math.floor((sec % 86400) / 3600)
    local mins = math.floor((sec % 3600) / 60)
    local secs = math.floor(sec % 60)
    if days > 0 then return string.format("%dHARI %dJAM", days, hours)
    elseif hours > 0 then return string.format("%dJAM %dMNT", hours, mins)
    elseif mins > 0 then return string.format("%dMNT %dDTK", mins, secs)
    else return string.format("%dDTK", secs) end
end

local function FormatLong(sec)
    if sec <= 0 then return "SUDAH LEWAT" end
    local days = math.floor(sec / 86400)
    local hours = math.floor((sec % 86400) / 3600)
    local mins = math.floor((sec % 3600) / 60)
    return string.format("%d hari, %d jam, %d menit", days, hours, mins)
end

local function FormatDateDisplay(ts)
    if not ts or ts <= 0 then return "BELUM DI SET" end
    local ok, s = pcall(os.date, "%d/%m/%Y %H:%M", ts)
    return ok and s or "INVALID"
end

function _G.CreateFloatExpired()
    local C = _G.C
    if _G.TakoroModState.FloatExpired and _G.TakoroModState.FloatExpired.valid then
        return _G.TakoroModState.FloatExpired
    end
    local canvas = GetCanvas()
    if not canvas then return nil end
    local F = {}
    F.valid = true
    -- ⭐ SEJAJARKAN dengan float TAKORO VIP
    local takoroPos = _G.FloatTakoroPos or { X = 450, Y = 10, W = 130, H = 48 }
    local cfg = _G.ExpiredConfig

    -- ⭐ Posisi X: sebelah kanan TAKORO VIP + gap
    local fX = takoroPos.X + takoroPos.W + 15
    -- ⭐ Posisi Y: SEJAJAR dengan TAKORO VIP
    local fY = takoroPos.Y
    -- ⭐ Ukuran sama seperti TAKORO VIP
    local fW = takoroPos.W
    local fH = takoroPos.H
    F.s0  = FloatLayer(canvas, fX - 18, fY - 18, fW + 36, fH + 36, C.shadow5, 11875)
    F.s1  = FloatLayer(canvas, fX - 12, fY - 12, fW + 24, fH + 24, C.shadow4, 11876)
    F.s2  = FloatLayer(canvas, fX - 6,  fY - 6,  fW + 12, fH + 12, C.shadow3, 11877)
    F.s5  = FloatLayer(canvas, fX - 3, fY - 3, fW + 6, fH + 6, C.gold_deep, 11879)
    F.s7  = FloatLayer(canvas, fX - 1, fY - 1, fW + 2, fH + 2, C.border_gold, 11881)
    F.s8  = FloatLayer(canvas, fX, fY, fW, fH, C.bg_main, 11882)
    F.s11 = FloatLayer(canvas, fX, fY + 4, 2, fH - 8, C.red_dark, 11884)
    F.s12 = FloatLayer(canvas, fX + fW - 2, fY + 4, 2, fH - 8, C.red_dark, 11884)
    F.s13 = FloatLayer(canvas, fX + 2, fY + 2, fW - 4, 1, C.gold, 11885)
    F.s14 = FloatLayer(canvas, fX + 2, fY + fH - 3, fW - 4, 1, C.gold, 11885)
    pcall(function()
        F.label = CGame:NewObjectFromPath("/Script/UMG.TextBlock", canvas)
        if F.label and slua.isValid(F.label) then
            F.label:SetText("EXPIRED")
            local col = C.gold_bright
            if FSlateColor then F.label:SetColorAndOpacity(FSlateColor(col)) else F.label:SetColorAndOpacity(col) end
            if F.label.Font then local f = F.label.Font f.Size = 11 F.label.Font = f end
            F.label:SetRenderTransformPivot(FVector2D(0.5, 0.5))
            F.label:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            local slot = canvas:AddChildToCanvas(F.label)
            if slot then
                slot:SetAutoSize(true)
                slot:SetAlignment(FVector2D(0.5, 0.5))
                slot:SetPosition(FVector2D(fX + fW * 0.5, fY + 14))
                slot:SetZOrder(12001)
            end
        end
    end)
    pcall(function()
        F.text = CGame:NewObjectFromPath("/Script/UMG.TextBlock", canvas)
        if F.text and slua.isValid(F.text) then
            F.text:SetText("--")
            local col = C.gold_bright
            if FSlateColor then F.text:SetColorAndOpacity(FSlateColor(col)) else F.text:SetColorAndOpacity(col) end
            if F.text.Font then local f = F.text.Font f.Size = 13 F.text.Font = f end
            F.text:SetRenderTransformPivot(FVector2D(0.5, 0.5))
            F.text:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            local slot = canvas:AddChildToCanvas(F.text)
            if slot then
                slot:SetAutoSize(true)
                slot:SetAlignment(FVector2D(0.5, 0.5))
                slot:SetPosition(FVector2D(fX + fW * 0.5, fY + fH * 0.5 + 4))
                slot:SetZOrder(12002)
            end
        end
    end)
    F.s17 = FloatLayer(canvas, fX + fW - 10, fY + 4, 5, 5, C.red, 12000)
    pcall(function()
        F.ghostBtn = CGame:NewObjectFromPath("/Script/UMG.Button", canvas)
        if F.ghostBtn and slua.isValid(F.ghostBtn) then
            F.ghostBtn:SetColorAndOpacity(C.transparent)
            F.ghostBtn:SetBackgroundColor(C.transparent)
            F.ghostBtn:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
            local slot = canvas:AddChildToCanvas(F.ghostBtn)
            if slot then
                slot:SetAutoSize(false)
                slot:SetPosition(FVector2D(fX - 25, fY - 25))
                slot:SetSize(FVector2D(fW + 50, fH + 50))
                slot:SetZOrder(90001)
            end
        end
    end)
    pcall(function()
        F.closeBtn = CGame:NewObjectFromPath("/Script/UMG.Button", canvas)
        if F.closeBtn and slua.isValid(F.closeBtn) then
            F.closeBtn:SetColorAndOpacity(C.transparent)
            F.closeBtn:SetBackgroundColor(C.transparent)
            F.closeBtn:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
            local slot = canvas:AddChildToCanvas(F.closeBtn)
            if slot then
                slot:SetAutoSize(false)
                slot:SetPosition(FVector2D(fX + fW - 20, fY + 2))
                slot:SetSize(FVector2D(18, 18))
                slot:SetZOrder(96000)
            end
            F.closeBtn.OnClicked:Add(function()
                pcall(function() if _G.__HideExpiredFloat then _G.__HideExpiredFloat() end end)
            end)
        end
    end)
    pcall(function()
        F.closeTxt = CGame:NewObjectFromPath("/Script/UMG.TextBlock", canvas)
        if F.closeTxt and slua.isValid(F.closeTxt) then
            F.closeTxt:SetText("X")
            if FSlateColor then F.closeTxt:SetColorAndOpacity(FSlateColor(C.white)) else F.closeTxt:SetColorAndOpacity(C.white) end
            if F.closeTxt.Font then local f = F.closeTxt.Font f.Size = 12 F.closeTxt.Font = f end
            F.closeTxt:SetRenderTransformPivot(FVector2D(0.5, 0.5))
            F.closeTxt:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            local slot = canvas:AddChildToCanvas(F.closeTxt)
            if slot then
                slot:SetAutoSize(true)
                slot:SetAlignment(FVector2D(0.5, 0.5))
                slot:SetPosition(FVector2D(fX + fW - 11, fY + 11))
                slot:SetZOrder(96001)
            end
        end
    end)
    _G.TakoroModState.FloatExpired = F
    return F
end

function _G.UpdateFloatExpired()
    local C = _G.C
    local F = _G.TakoroModState.FloatExpired
    if not F or not F.valid then return end
    local remain = _G.GetRemainingTime()
    local isExp = _G.TakoroModState.IsExpired
    local col, labelText, countText, dotColor
    if isExp then
        col = C.red_bright labelText = "EXPIRED" countText = "KADALUARSA" dotColor = C.red
    elseif remain > 7 * 86400 then
        col = C.gold_bright labelText = "AKTIF" countText = FormatShort(remain) dotColor = C.gold
    elseif remain > 86400 then
        col = C.gold labelText = "AKTIF" countText = FormatShort(remain) dotColor = C.gold
    elseif remain > 3600 then
        col = FLinearColor(1.0, 0.55, 0.0, 1.0) labelText = "SEGERA" countText = FormatShort(remain) dotColor = C.red_bright
    else
        col = C.red_bright labelText = "KRITIS" countText = FormatShort(remain) dotColor = C.red_bright
    end
    pcall(function()
        if F.label and slua.isValid(F.label) then
            F.label:SetText(labelText)
            if FSlateColor then F.label:SetColorAndOpacity(FSlateColor(col)) else F.label:SetColorAndOpacity(col) end
        end
    end)
    pcall(function()
        if F.text and slua.isValid(F.text) then
            F.text:SetText(countText)
            if FSlateColor then F.text:SetColorAndOpacity(FSlateColor(col)) else F.text:SetColorAndOpacity(col) end
        end
    end)
    pcall(function() if F.s17 and slua.isValid(F.s17) then F.s17:SetBrushColor(dotColor) end end)
end

function _G.Espired(dateStr, onExpired, showPopup)
    local ts = ParseDate(dateStr)
    if not ts then return false end
    _G.TakoroModState.ExpiredToken = _G.TakoroModState.ExpiredToken + 1
    local myToken = _G.TakoroModState.ExpiredToken
    _G.TakoroModState.ExpiredTimestamp = ts
    _G.TakoroModState.ExpiredDateStr = FormatDateDisplay(ts)
    pcall(_G.CreateFloatExpired)
    pcall(_G.UpdateFloatExpired)
    -- ⭐ Refresh HOME widget
    if _G.__RefreshHomeExp then pcall(_G.__RefreshHomeExp) end
    local now = os.time()
    if now >= ts then
        _G.TakoroModState.IsExpired = true
        if onExpired then pcall(onExpired) end
        return true
    end
    _G.TakoroModState.IsExpired = false
    local function Tick()
        if myToken ~= _G.TakoroModState.ExpiredToken then return end
        local remain = _G.TakoroModState.ExpiredTimestamp - os.time()
        pcall(_G.UpdateFloatExpired)
        -- ⭐ Refresh HOME widget periodic
        if _G.__RefreshHomeExp then pcall(_G.__RefreshHomeExp) end
        if remain <= 0 then
            _G.TakoroModState.IsExpired = true
            pcall(_G.UpdateFloatExpired)
            if onExpired then pcall(onExpired) end
            return
        end
        pcall(function()
            local ok, ticker = pcall(require, "common.time_ticker")
            if ok and ticker and ticker.AddTimerOnce then ticker.AddTimerOnce(_G.ExpiredConfig.CheckInterval or 5, Tick) end
        end)
    end
    pcall(function()
        local ok, ticker = pcall(require, "common.time_ticker")
        if ok and ticker and ticker.AddTimerOnce then ticker.AddTimerOnce(_G.ExpiredConfig.CheckInterval or 5, Tick) end
    end)
    return true
end

_G.SetExpired = _G.Espired
_G.SetExpiredDate = _G.Espired

function _G.GetRemainingTime()
    local t = _G.TakoroModState.ExpiredTimestamp or 0
    if t <= 0 then return 0 end
    return math.max(0, t - os.time())
end

-- ============================================================
-- [26] INIT (FINAL)
-- ============================================================

-- ============================================================
-- [26] AUTO FEEDBACK SYSTEM (Telegram Uploader)
-- ============================================================
-- Bundled from AutoFeedback, di-rename ke TAKORO MOD branding
-- Notif popup pakai UMG Layer/Text dari script utama
_G.AutoFeedbackConfig = _G.AutoFeedbackConfig or {
    ServerURL = "https://takorofeedback2.idtakoro.workers.dev",
    BotToken  = "8675629506:AAFfrDfc8-U_Xv-6qk6vMe5U5Kg0wVXINxU",
    
    -- Format baru: list target dengan chat_id + thread_id opsional
    -- thread_id = 0 artinya kirim ke chat utama (bukan topik)
    Targets = {
        { chat_id = "-1003745751555", thread_id = 11 },  -- TAKORO REAL (topik FEEDBACK)
        { chat_id = "-1002460960100", thread_id = 0 },   -- Channel TAKORO212
        { chat_id = "",               thread_id = 0 },   -- Kosong
    },
    
    -- Backward compat (biarkan, untuk fallback)
    ChatIDs = {
        "-1003745751555",
        "-1002460960100",
        "",
    },
    ChatID = "-1004479439357",
    
    MinRank  = 2200,
    MinKills = 5,
    TestMode = false,
}

-- ============================================================
-- [26.1] POPUP NOTIF (pakai gaya UMG script utama) — FIXED
-- ============================================================
local _notifyPopupRefs = {}

-- ✅ FIX: Fungsi DestroyNotifyPopup yang SEBELUMNYA HILANG
local function DestroyNotifyPopup()
    local refs = _notifyPopupRefs
    if not refs then return end
    if refs.all then
        for _, w in ipairs(refs.all) do
            if w and slua.isValid(w) then
                pcall(function() w:RemoveFromParent() end)
            end
        end
    end
    -- Bersihkan semua referensi
    _notifyPopupRefs = nil
end
_G.DestroyNotifyPopup = DestroyNotifyPopup

local function ShowNotifyPopup(message, color)
    if not message then return end
    local C = _G.C
    if not C then return end
    local canvas = GetCanvas and GetCanvas()
    if not canvas then return end

    DestroyNotifyPopup()

    local refs = { all = {} }
    _notifyPopupRefs = refs

    -- ⭐ AUTO-SIZE berdasarkan panjang teks
    local msgStr = tostring(message)
    local textLen = #msgStr
    local fontSize = 12
    local charW = fontSize * 0.6
    local padL = 20
    local padR = 20
    local minW = 220
    local maxW = 520

    local pW = math.floor(textLen * charW + padL + padR)
    if pW < minW then pW = minW end
    if pW > maxW then pW = maxW end

    local pH = 44
    
    -- ⭐ Posisi: center top
    local pX = math.floor((M_W) * 0.5 - pW * 0.5) + 60  -- offset karena window mungkin di kanan
    local pY = 100
    
    local col = color or C.gold_bright
    
    -- ⭐ Shadow + border
    refs.glow    = FloatLayer(canvas, pX - 4, pY - 4, pW + 8, pH + 8, C.gold_glow_strong, 12990)
    refs.border  = FloatLayer(canvas, pX - 1, pY - 1, pW + 2, pH + 2, C.gold, 12991)
    refs.bg      = FloatLayer(canvas, pX, pY, pW, pH, C.bg_main, 12992)
    
    -- ⭐ Accent bar kiri (warna berbeda sesuai tipe)
    refs.accent  = FloatLayer(canvas, pX, pY + 4, 4, pH - 8, col, 12993)
    
    -- ⭐ Top line highlight
    refs.topLine = FloatLayer(canvas, pX + 4, pY, pW - 4, 1, col, 12994)
    
    -- ⭐ Status dot di kiri
    refs.dot = FloatLayer(canvas, pX + 14, pY + pH * 0.5 - 4, 8, 8, col, 12995)
    
    table.insert(refs.all, refs.glow)
    table.insert(refs.all, refs.border)
    table.insert(refs.all, refs.bg)
    table.insert(refs.all, refs.accent)
    table.insert(refs.all, refs.topLine)
    table.insert(refs.all, refs.dot)

    -- ⭐ Text di tengah (dengan dot)
    pcall(function()
        local t = CGame:NewObjectFromPath("/Script/UMG.TextBlock", canvas)
        if t and slua.isValid(t) then
            t:SetText(msgStr)
            if FSlateColor then t:SetColorAndOpacity(FSlateColor(C.text_label)) else t:SetColorAndOpacity(C.text_label) end
            if t.Font then local f = t.Font f.Size = fontSize t.Font = f end
            pcall(function() t:SetAutoWrapText(false) end)
            pcall(function()
                if UEnums and UEnums.ETextJustify then
                    t:SetJustification(UEnums.ETextJustify.Left)
                end
            end)
            t:SetRenderTransformPivot(FVector2D(0, 0.5))
            t:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            local slot = canvas:AddChildToCanvas(t)
            if slot then
                slot:SetAutoSize(true)
                slot:SetAlignment(FVector2D(0, 0.5))
                slot:SetPosition(FVector2D(pX + 30, pY + pH * 0.5))
                slot:SetZOrder(12996)
            end
            refs.text = t
            table.insert(refs.all, t)
        end
    end)

    -- ⭐ Auto-hide 3.5 detik
    pcall(function()
        local ok, ticker = pcall(require, "common.time_ticker")
        if ok and ticker and ticker.AddTimerOnce then
            local myRefs = refs
            ticker.AddTimerOnce(3.5, function()
                if _notifyPopupRefs == myRefs then
                    DestroyNotifyPopup()
                end
            end)
        end
    end)
end

-- Notifier global
_G.TakoroModNotify = function(msg)
    pcall(function()
        local txt = tostring(msg or "")
        txt = txt:gsub("^%[TAKORO_MOD%]%s*", "")
        txt = txt:gsub("^%[TAKORO%]%s*", "")
        local col = _G.C and _G.C.gold_bright
       
        if txt:find("Successfully") or txt:find("TERKIRIM") or txt:find("TOP 1") then
            col = _G.C and _G.C.gold_bright
        elseif txt:find("error") or txt:find("GAGAL") or txt:find("failed") or txt:find("Failed") then
            col = _G.C and _G.C.red_bright
        elseif txt:find("Uploading") or txt:find("Preparing") then
            col = _G.C and _G.C.gold
        end
        ShowNotifyPopup(txt, col)
    end)
    print("[TAKORO_MOD] " .. tostring(msg))
end

-- ============================================================
-- [26.2] AUTO FEEDBACK MODULE (bundled)
-- ============================================================
local AutoFeedback = {
    Config = _G.AutoFeedbackConfig,
    Hooked = false,
}

local function AF_Log(message)
    print(string.format("[TAKORO_MOD] [%s] %s", os.date("%H:%M:%S"), tostring(message)))
end

local function AF_GetModule(name, allowRequire)
    local loaded = package and package.loaded and package.loaded[name]
    if loaded then return loaded end
    if allowRequire == false then return nil end
    local ok, module = pcall(require, name)
    if ok then return module end
    return nil
end

local function AF_AddTimerOnce(delay, callback)
    local ticker = AF_GetModule("common.time_ticker")
    if ticker and type(ticker.AddTimerOnce) == "function" then
        ticker.AddTimerOnce(delay, callback)
        return true
    end
    return false
end

local function AF_Base64Encode(data)
    if type(data) ~= "string" or #data == 0 then return "" end
    local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local output = {}
    local outputIndex = 0
    local index = 1
    while index <= #data - 2 do
        local a, b, c = string.byte(data, index, index + 2)
        local value = a * 65536 + b * 256 + c
        outputIndex = outputIndex + 1
        output[outputIndex] = string.char(
            string.byte(alphabet, math.floor(value / 262144) + 1),
            string.byte(alphabet, math.floor(value / 4096) % 64 + 1),
            string.byte(alphabet, math.floor(value / 64) % 64 + 1),
            string.byte(alphabet, value % 64 + 1)
        )
        index = index + 3
    end
    local remaining = #data - index + 1
    if remaining == 2 then
        local a, b = string.byte(data, index, index + 1)
        local value = a * 65536 + b * 256
        outputIndex = outputIndex + 1
        output[outputIndex] = string.char(
            string.byte(alphabet, math.floor(value / 262144) + 1),
            string.byte(alphabet, math.floor(value / 4096) % 64 + 1),
            string.byte(alphabet, math.floor(value / 64) % 64 + 1),
            string.byte("=")
        )
    elseif remaining == 1 then
        local value = string.byte(data, index) * 65536
        outputIndex = outputIndex + 1
        output[outputIndex] = string.char(
            string.byte(alphabet, math.floor(value / 262144) + 1),
            string.byte(alphabet, math.floor(value / 4096) % 64 + 1),
            string.byte("="),
            string.byte("=")
        )
    end
    return table.concat(output)
end

local function AF_UrlEncode(value)
    if value == nil then return nil end
    value = tostring(value):gsub("\n", "\r\n")
    value = value:gsub("([^A-Za-z0-9 %-%_%.%~])", function(character)
        return string.format("%%%02X", string.byte(character))
    end)
    value = value:gsub(" ", "+")
    return value
end

local function AF_ReadFile(path)
    local file = io.open(path, "rb")
    if not file then return "" end
    local data = file:read("*a") or ""
    file:close()
    return data
end

local function AF_RemoveFile(path)
    pcall(os.remove, path)
end

local function AF_GetRankName(rank)
    if rank < 1700 then return "Bronze"
    elseif rank < 2200 then return "Silver"
    elseif rank < 2700 then return "Gold"
    elseif rank < 3200 then return "Platinum"
    elseif rank < 3700 then return "Diamond"
    elseif rank < 4200 then return "Crown"
    elseif rank < 4700 then return "Ace"
    elseif rank < 5200 then return "Ace Master"
    elseif rank < 5600 then return "Ace Dominator"
    end
    return "Conqueror"
end

local FeedbackCaptionTemplate = "<b>TAKORO MOD FREE TRIAL</b>\n<pre>\nPlayer - %s\nUID    - %s\nTime   - %s\nKills  - %d\nRank   - %s\n</pre>\n[ ACTIVE - SAFE ]\n<b>Owner: @Bang_Anca</b>"

function AutoFeedback.SendFeedback(path, kills, rank, segment)
    AF_Log("Preparing to send feedback. Screenshot: " .. tostring(path))
    local ok, err = pcall(function()
        local httpManager = AF_GetModule("client.slua.logic.http.http_manager")
        if not httpManager or type(httpManager.Post) ~= "function" then
            AF_Log("HTTP manager is unavailable.")
            return
        end

        local cfg = AutoFeedback.Config
        local targets = {}

        -- Prioritas: pakai Targets kalau ada
        if cfg.Targets and type(cfg.Targets) == "table" then
            for _, t in ipairs(cfg.Targets) do
                if type(t) == "table" and t.chat_id and t.chat_id ~= "" then
                    table.insert(targets, {
                        chat_id = t.chat_id,
                        thread_id = tonumber(t.thread_id) or 0
                    })
                end
                if #targets >= 4 then break end
            end
        end

        -- Fallback ke ChatIDs lama
        if #targets == 0 and cfg.ChatIDs and type(cfg.ChatIDs) == "table" then
            for _, id in ipairs(cfg.ChatIDs) do
                if type(id) == "string" and id ~= "" then
                    table.insert(targets, { chat_id = id, thread_id = 0 })
                end
                if #targets >= 4 then break end
            end
        end

        -- Fallback ke ChatID tunggal
        if #targets == 0 and cfg.ChatID and cfg.ChatID ~= "" then
            table.insert(targets, { chat_id = cfg.ChatID, thread_id = 0 })
        end

        if #targets == 0 then
            AF_Log("Tidak ada target chat yang valid.")
            return
        end

        local attempts = 0
        local function TrySend()
            local imageData = AF_ReadFile(path)
            if #imageData > 0 then
                local uid = "unknown"
                if _G.DataMgr and _G.DataMgr.roleData and _G.DataMgr.roleData.uid then
                    uid = tostring(_G.DataMgr.roleData.uid)
                elseif _G._KONG_UK then
                    uid = tostring(_G._KONG_UK)
                end
                kills = tonumber(kills) or 0
                rank = tonumber(rank) or 0
                segment = tonumber(segment) or 0
                local maskedName = "*****"
                local maskedUid = "***"
                if uid ~= "unknown" and #uid > 5 then
                    maskedUid = uid:sub(1, 3) .. "***" .. uid:sub(-2)
                end
                local caption = string.format(
                    FeedbackCaptionTemplate,
                    maskedName, maskedUid,
                    os.date("%H:%M:%S %d/%m/%Y"),
                    kills, AF_GetRankName(rank)
                )
                local encodedImage = AF_Base64Encode(imageData)
                encodedImage = encodedImage:gsub("%+", "%%2B")
                encodedImage = encodedImage:gsub("/", "%%2F")
                encodedImage = encodedImage:gsub("=", "%%3D")

                if _G.TakoroModNotify then
                    _G.TakoroModNotify(string.format("[TAKORO_MOD] Uploading ke %d target...", #targets))
                end

                -- Kirim ke setiap target
                for idx, tgt in ipairs(targets) do
                    local body = "base64_image=" .. encodedImage
                        .. "&caption=" .. AF_UrlEncode(caption)
                        .. "&bot_token=" .. AF_UrlEncode(cfg.BotToken)
                        .. "&chat_id=" .. AF_UrlEncode(tgt.chat_id)

                    -- Kalau target adalah topik forum, tambahkan message_thread_id
                    if tgt.thread_id and tgt.thread_id > 0 then
                        body = body .. "&message_thread_id=" .. tostring(tgt.thread_id)
                    end

                    httpManager:Post(
                        cfg.ServerURL,
                        {["Content-Type"] = "application/x-www-form-urlencoded"},
                        body,
                        nil,
                        function(success, _, response, errorMessage)
                            if success and response and tostring(response):find('"status":%s*true') then
                                AF_Log(string.format("Target %d OK (%s)", idx, tgt.chat_id))
                                if _G.TakoroModNotify then
                                    _G.TakoroModNotify(string.format("TERKIRIM ke target %d (Kills: %d)", idx, kills))
                                end
                            else
                                local detail = tostring(response or errorMessage):sub(1, 40)
                                AF_Log(string.format("Target %d GAGAL (%s): %s", idx, tgt.chat_id, detail))
                                if _G.TakoroModNotify then
                                    _G.TakoroModNotify(string.format("GAGAL target %d: %s", idx, detail))
                                end
                            end
                        end,
                        60
                    )
                end

                AF_AddTimerOnce(3.0, function()
                    AF_RemoveFile(path)
                end)
                return
            end
            attempts = attempts + 1
            if attempts < 5 and AF_AddTimerOnce(1.0, TrySend) then return end
            if _G.TakoroModNotify then _G.TakoroModNotify("SCREENSHOT GAGAL DIBACA") end
            AF_RemoveFile(path)
        end
        TrySend()
    end)
    if not ok then AF_Log("SendFeedback Error: " .. tostring(err)) end
end

local AF_HudNames = {
    "BattleChat_UIBP","Chat_UIBP","ChatMsg_UIBP","TeamAvatar_UIBP","Team_UIBP",
    "VoiceChat_UIBP","MiniMap_UIBP","Bag_UIBP","PickUp_UIBP","PickUpList_UIBP",
    "SystemChat_UIBP","InGameChat_UIBP","InGameChatPanel_UIBP","KillFeed_UIBP",
    "Elimination_UIBP","ChatHUD_UIBP","ChatPanel_UIBP","MainHUD_UIBP","BattleHUD_UIBP"
}

local function AF_GetRankAndSegment()
    local rank = 0
    local segment = 0
    pcall(function()
        local battleResult = _G.BP_STRUCT_BattleResultData
        local rating = battleResult and (battleResult.rating or battleResult.BP_STRUCT_BTRating)
        if rating then
            rank = tonumber(rating.rank_rating) or 0
            segment = tonumber(rating.new_segment) or 0
        end
        if rank == 0 then
            local funcUtil = AF_GetModule("common.func_util")
            local roleData = _G.DataMgr and _G.DataMgr.roleData
            if funcUtil and type(funcUtil.GetCurMaxSegementLevel) == "function"
                and roleData and roleData.allzoneSegment then
                segment = tonumber(funcUtil.GetCurMaxSegementLevel(roleData.allzoneSegment)) or 0
            end
            if roleData and roleData.segment_rating then
                for _, value in pairs(roleData.segment_rating) do
                    if type(value) == "table" then
                        for _, nestedValue in pairs(value) do
                            if type(nestedValue) == "number" and nestedValue > rank then rank = nestedValue end
                        end
                    elseif type(value) == "number" and value > rank then
                        rank = value
                    end
                end
            end
        end
    end)
    return rank, segment
end

local function AF_CreateHudController()
    local hidden = {}
    local function SetHidden(hide)
        local UIManager = _G.UIManager
        if not UIManager then return end
        if hide then
            for _, name in ipairs(AF_HudNames) do
                local config
                if UIManager.UI_Config_InGame and UIManager.UI_Config_InGame[name] then
                    config = UIManager.UI_Config_InGame[name]
                elseif UIManager.UI_Config and UIManager.UI_Config[name] then
                    config = UIManager.UI_Config[name]
                end
                if config then
                    local view = type(UIManager.GetUI) == "function" and UIManager.GetUI(config) or nil
                    if view then
                        pcall(function()
                            if type(view.SetVisibility) == "function" then view:SetVisibility(2)
                            elseif view.UIRoot and type(view.UIRoot.SetVisibility) == "function" then view.UIRoot:SetVisibility(2)
                            elseif type(UIManager.HideUI) == "function" then UIManager.HideUI(config)
                            elseif type(UIManager.CloseUI) == "function" then UIManager.CloseUI(config) end
                        end)
                        table.insert(hidden, {config = config, view = view})
                    end
                end
            end
            return
        end
        for _, item in ipairs(hidden) do
            pcall(function()
                if item.view and type(item.view.SetVisibility) == "function" then item.view:SetVisibility(0)
                elseif item.view and item.view.UIRoot and type(item.view.UIRoot.SetVisibility) == "function" then item.view.UIRoot:SetVisibility(0)
                elseif type(UIManager.ShowUI) == "function" then UIManager.ShowUI(item.config) end
            end)
        end
        hidden = {}
    end
    return SetHidden
end

local function AF_GetScreenshotDirectory()
    local directories = {}
    local home = os.getenv("HOME")
    if home and home ~= "" then
        table.insert(directories, home .. "/Documents/ShadowTrackerExtra/Saved/")
    end
    local packages = {
        "com.tencent.ig","com.vng.pubgmobile","com.pubg.krmobile",
        "com.rekoo.pubgm","com.pubg.imobile"
    }
    for _, packageName in ipairs(packages) do
        table.insert(directories,
            "/storage/emulated/0/Android/data/" .. packageName
                .. "/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/"
        )
    end
    local selected = directories[1]
    for _, directory in ipairs(directories) do
        local testPath = directory .. "t.tmp"
        local file = io.open(testPath, "w")
        if file then
            file:close()
            os.remove(testPath)
            selected = directory
            break
        end
    end
    return selected
end

local function AF_CaptureAndSend(kills, rank, segment, restoreHud)
    local restored = false
    local function RestoreHudOnce()
        if not restored then
            restored = true
            restoreHud(false)
        end
    end

    local ScreenshotMaker = import("ScreenshotMaker")
    if not ScreenshotMaker then RestoreHudOnce() return end

    local directory = AF_GetScreenshotDirectory()
    if not directory then RestoreHudOnce() return end

    local path = directory .. string.format("takoro_win_%s.jpg", os.time())
    local uiUtil = AF_GetModule("client.common.ui_util")
    local gameInstance = uiUtil and uiUtil.GetGameInstance and uiUtil.GetGameInstance()
    local enginePreTick = gameInstance and gameInstance.EnginePreTick
    if not enginePreTick or type(enginePreTick.Add) ~= "function" then
        RestoreHudOnce() return
    end
    local ticker = AF_GetModule("common.time_ticker")
    if not ticker or type(ticker.AddTimerOnce) ~= "function" then
        RestoreHudOnce() return
    end

    enginePreTick:Add(function()
        local actualPath = ScreenshotMaker.MakePictureByName(path, true)
        if type(enginePreTick.Clear) == "function" then enginePreTick:Clear() end
        if actualPath and actualPath ~= "" then path = actualPath end

        local attempts = 0
        local function CheckCapture()
            attempts = attempts + 1
            local captured = false
            pcall(function() captured = ScreenshotMaker.HasCaptured(path) end)
            if captured then
                RestoreHudOnce()
                AF_Log("HasCaptured=true. Flushing to disk...")
                pcall(ScreenshotMaker.ResizePicture, path, 0.9, path)
                ticker.AddTimerOnce(2.0, function()
                    if #AF_ReadFile(path) > 0 then
                        AutoFeedback.SendFeedback(path, kills, rank, segment)
                    else
                        if _G.TakoroModNotify then _G.TakoroModNotify("SCREENSHOT GAGAL (iOS read)") end
                    end
                end)
            elseif attempts < 15 then
                ticker.AddTimerOnce(1, CheckCapture)
            else
                RestoreHudOnce()
                if _G.TakoroModNotify then _G.TakoroModNotify("SCREENSHOT TIMEOUT") end
            end
        end
        ticker.AddTimerOnce(1, CheckCapture)
    end)
end

function AutoFeedback.ProcessWin(kills)
    if not _G.TakoroModConfig.AutoFeedback then
        AF_Log("AutoFeedback OFF, skip.")
        return
    end
    kills = tonumber(kills) or 0
    local rank, segment = AF_GetRankAndSegment()
    local cfg = AutoFeedback.Config
    if rank < cfg.MinRank or kills <= cfg.MinKills then
        AF_Log(string.format("Skipping: Rank %d, Kill %d", rank, kills))
        if _G.TakoroModNotify then
            _G.TakoroModNotify(string.format("SKIP: Rank/Kill kurang (%d, %d)", rank, kills))
        end
        return
    end
    if _G.TakoroModNotify then _G.TakoroModNotify("TOP 1 TERDETEKSI FEEDBACK TRIAL MOD- Uploading...") end
    local setHudHidden = AF_CreateHudController()
    setHudHidden(true)
    local ok, err = pcall(AF_CaptureAndSend, kills, rank, segment, setHudHidden)
    if not ok then
        setHudHidden(false)
        AF_Log("ProcessWin Error: " .. tostring(err))
    end
end

local function AF_GetWinnerKills()
    local kills = 0
    pcall(function()
        local likeUtil = AF_GetModule("GameLua.Mod.BaseMod.Client.Like.IngameLikeUtilClient")
        if likeUtil and type(likeUtil.GetMyPlayerState) == "function" then
            local playerState = likeUtil.GetMyPlayerState()
            if playerState and playerState.Kills then
                kills = tonumber(playerState.Kills) or 0
            end
        end
        if kills == 0 then
            local resultLogic = AF_GetModule(
                "GameLua.Mod.BaseMod.Client.BattleResult.BattleResultData.BattleResultDataLogic",
                false
            )
            if resultLogic and type(resultLogic.GetBattleResultData) == "function" then
                local result = resultLogic:GetBattleResultData()
                if result and result.BP_mykill then
                    kills = tonumber(result.BP_mykill) or 0
                end
            end
        end
    end)
    return kills
end

local function AF_TryInstallHook()
    pcall(function()
        local UIManager = _G.UIManager
        if not UIManager or not UIManager.ShowUI or UIManager.__TakoroModHooked then
            return
        end
        AF_Log("Hooking UIManager.ShowUI...")
        local originalShowUI = UIManager.ShowUI
        UIManager.ShowUI = function(config, params, ...)
            local result = originalShowUI(config, params, ...)
            pcall(function()
                if not _G.TakoroModConfig.AutoFeedback then return end
                local inGameConfig = UIManager.UI_Config_InGame
                local winnerConfig = inGameConfig and inGameConfig.GameOverCountDown_UIBP
                local isWinner = params and (params.Reason == "win" or params.ShowedWinLogo)
                if not winnerConfig or config ~= winnerConfig or not isWinner then return end
                local kills = AF_GetWinnerKills()
                if not AF_AddTimerOnce(2, function()
                    AutoFeedback.ProcessWin(kills)
                end) then
                    AutoFeedback.ProcessWin(kills)
                end
            end)
            return result
        end
        UIManager.__TakoroModHooked = true
        AutoFeedback.Hooked = true
        AF_Log("UIManager Hook installed.")
    end)
end

function AutoFeedback.Install()
    if _G.TakoroModState.AutoFeedbackInstalled then
        AF_Log("AutoFeedback already installed.")
        return
    end
    AF_Log("Installing Auto Feedback system...")
    pcall(function()
        local ticker = AF_GetModule("common.time_ticker")
        if ticker and type(ticker.AddTimer) == "function" then
            ticker.AddTimer(3.0, AF_TryInstallHook)
        else
            AF_TryInstallHook()
        end
    end)
    _G.TakoroModState.AutoFeedbackInstalled = true
end

_G.TakoroMod_AutoFeedback = AutoFeedback

-- Tambahkan hook ke FeatureHooks
_G.FeatureHooks.AUTO_FEEDBACK = {
    on = function()
        _G.TakoroModConfig.AutoFeedback = true
        if not _G.TakoroModState.AutoFeedbackInstalled then
            AutoFeedback.Install()
        end
        if _G.TakoroModNotify then _G.TakoroModNotify("AUTO FEEDBACK AKTIF") end
    end,
    off = function()
        _G.TakoroModConfig.AutoFeedback = false
        if _G.TakoroModNotify then _G.TakoroModNotify("AUTO FEEDBACK DIMATIKAN") end
    end,
}


-- ============================================================
-- [27] INIT (FINAL) — DEBUG + FALLBACK + EXPIRED FIX
-- БЕЗ ЛОГИНА / ПАРОЛЯ / KEY SYSTEM
-- ============================================================

_G.__MenuInitialized = false
_G.__MenuRetryCount = 0

local function TryInitMenu()
    print("[TAKORO] TryInitMenu retry=" .. tostring(_G.__MenuRetryCount))
    if _G.__MenuInitialized then return end

    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    print("[TAKORO] pc valid=" .. tostring(IsValid(pc)))

    if not pc or not IsValid(pc) then
        _G.__MenuRetryCount = _G.__MenuRetryCount + 1

        if _G.__MenuRetryCount > 200 then
            print("[TAKORO] MAX RETRY reached (pc nil)")
            return
        end

        pcall(function()
            local ok, ticker = pcall(require, "common.time_ticker")

            if ok and ticker and ticker.AddTimerOnce then
                ticker.AddTimerOnce(0.5, TryInitMenu)
            end
        end)

        return
    end

    local canvas = GetCanvas()
    print("[TAKORO] canvas valid=" .. tostring(canvas ~= nil))

    if not canvas then
        _G.__MenuRetryCount = _G.__MenuRetryCount + 1

        if _G.__MenuRetryCount > 400 then
            print("[TAKORO] MAX RETRY reached (canvas nil)")
            return
        end

        pcall(function()
            local ok, ticker = pcall(require, "common.time_ticker")

            if ok and ticker and ticker.AddTimerOnce then
                ticker.AddTimerOnce(0.5, TryInitMenu)
            end
        end)

        return
    end

    print("[TAKORO] Mulai BuildMenu...")

    -- ============================================================
    -- MENU STATE
    -- ============================================================

    _G.TakoroModState.MenuHidden = false
    _G.TakoroModState.ExpiredHidden = false

    -- ============================================================
    -- THEME
    -- ============================================================

    if _G.TakoroModState.SavedTheme
        and _G.Themes[_G.TakoroModState.SavedTheme] then

        _G.CurrentThemeName = _G.TakoroModState.SavedTheme
        _G.C = _G.Themes[_G.CurrentThemeName]

    else
        _G.CurrentThemeName = "DARK"
        _G.C = _G.Themes["DARK"]
        _G.TakoroModState.SavedTheme = "DARK"
    end

    -- ============================================================
    -- DEFAULT EXPIRED DATE
    -- ============================================================

    pcall(function()
        if _G.Espired then
            _G.Espired("2026-12-31 23:59")

            print(
                "[TAKORO] Default Expired set: "
                .. tostring(_G.TakoroModState.ExpiredDateStr)
            )
        end
    end)

    -- ============================================================
    -- BUILD MENU
    -- ============================================================

    pcall(function()
        if not menuBuilt then
            BuildMenu()

            print(
                "[TAKORO] BuildMenu selesai, menuBuilt="
                .. tostring(menuBuilt)
            )
        end
    end)

    -- ============================================================
    -- TIDAK ADA KEY PANEL
    -- MENU LANGSUNG DIBUKA
    -- ============================================================

    pcall(function()
        if bgPanel and IsValid(bgPanel) then
            bgPanel:SetWidgetVisibility(
                UEnums.ESlateVisibility.Visible
            )
        end

        _G.TakoroModState.MenuHidden = false
    end)

    -- ============================================================
    -- FLOAT BUTTON
    -- ============================================================

    print("[TAKORO] CreateFloat...")

    pcall(function()
        CreateFloat()
    end)

    -- ============================================================
    -- START FEATURES
    -- ============================================================

    pcall(function()
        if _G.StartAimFeatureLoop then
            _G.StartAimFeatureLoop()
        end
    end)

    pcall(function()
        if _G.StartEspUnifiedLoop then
            _G.StartEspUnifiedLoop()
        end
    end)

    -- ============================================================
    -- REFRESH HOME
    -- ============================================================

    pcall(function()
        if _G.__RefreshHomeExp then
            _G.__RefreshHomeExp()
        end
    end)

    -- ============================================================
    -- FORCE LOGIN BYPASS STATE
    -- ============================================================

    _G.TakoroModState.KeyValid = true
    _G.TakoroModState.KeyChecking = false
    _G.TakoroModState.KeyPanelOpen = false

    print("[TAKORO] ✅ LOGIN SYSTEM DISABLED")
    print("[TAKORO] ✅ KEY CHECK DISABLED")
    print("[TAKORO] ✅ MENU OPENED DIRECTLY")
    print("[TAKORO] INIT COMPLETE!")

    _G.__MenuInitialized = true
end

-- ============================================================
-- START INIT
-- ============================================================

pcall(function()
    local ok, ticker = pcall(require, "common.time_ticker")

    if ok and ticker and ticker.AddTimerOnce then
        ticker.AddTimerOnce(2.0, TryInitMenu)

        print(
            "[TAKORO] Timer TryInitMenu dijadwalkan (2 detik)"
        )
    else
        print("[TAKORO] Ticker tidak tersedia, coba langsung")

        TryInitMenu()
    end
end)

return M