local Menu = {}
Menu.Visible = true
Menu.CurrentCategory = 2
Menu.CurrentPage = 1
Menu.ItemsPerPage = 9
Menu.scrollbarY = nil
Menu.scrollbarHeight = nil
Menu.OpenedCategory = nil
Menu.CurrentItem = 1
Menu.CurrentTab = 1
Menu.ItemScrollOffset = 0
Menu.CategoryScrollOffset = 0
Menu.EditorDragging = false
Menu.EditorDragOffsetX = 0
Menu.EditorDragOffsetY = 0
Menu.EditorMode = false
Menu.ShowSnowflakes = false
Menu.SelectorY = 0
Menu.CategorySelectorY = 0
Menu.TabSelectorX = 0
Menu.TabSelectorWidth = 0
Menu.SmoothFactor = 0.2
Menu.GradientType = 1
Menu.ScrollbarPosition = 1

Menu.LoadingBarAlpha = 0.0
Menu.KeySelectorAlpha = 0.0
Menu.KeybindsInterfaceAlpha = 0.0

Menu.LoadingProgress = 0.0
Menu.IsLoading = false
Menu.LoadingComplete = true

Menu.SelectingKey = false
Menu.SelectedKey = nil
Menu.SelectedKeyName = nil

Menu.SelectingBind = false
Menu.BindingItem = nil
Menu.BindingKey = nil
Menu.BindingKeyName = nil

Menu.ShowKeybinds = false
Menu.CurrentTopTab = 1
Menu.SelectedPlayer = nil
Menu.BugPlayerMode = "Bug"

-- Full Categories Preserved
Menu.Categories = {
    { name = "Search" },
    { name = "Combat" },
    { name = "Visuals" },
    { name = "Player" },
    { name = "Online" },
    { name = "Spawner" },
    { name = "Vehicles" },
    { name = "Server" },
    { name = "Bypass" },
    { name = "Miscellaneous" },
    { name = "Configs" }
}

function Menu.UpdateCategoriesFromTopTab()
    if not Menu.TopLevelTabs then return end
    local currentTop = Menu.TopLevelTabs[Menu.CurrentTopTab]
    if not currentTop then return end

    Menu.Categories = {{ name = currentTop.name }}
    if currentTop.categories then
        for _, cat in ipairs(currentTop.categories) do
            table.insert(Menu.Categories, cat)
        end
    end
    
    Menu.CurrentCategory = 2
    Menu.CategoryScrollOffset = 0
    Menu.OpenedCategory = nil
    
    if currentTop.autoOpen then
        Menu.OpenedCategory = 2
        Menu.CurrentTab = 1
        Menu.ItemScrollOffset = 0
        Menu.CurrentItem = 1
    end
end

-- Banner Configuration
Menu.Banner = {
    enabled = true,
    imageUrl = "https://i.postimg.cc/4dVYMBbG/CEFAA8F6-A7AA-498F-B952-8F02947D3BE8.png",
    height = 100
}

Menu.bannerTexture = nil
Menu.bannerWidth = 0
Menu.bannerHeight = 0

function Menu.LoadBannerTexture(url)
    if not url or url == "" or not Susano or not Susano.HttpGet or not Susano.LoadTextureFromBuffer then return end

    pcall(function()
        local status, body = Susano.HttpGet(url)
        if status == 200 and body and #body > 0 then
            local textureId, width, height = Susano.LoadTextureFromBuffer(body)
            if textureId and textureId ~= 0 then
                Menu.bannerTexture = textureId
                Menu.bannerWidth = width
                Menu.bannerHeight = height
            end
        end
    end)
end

Menu.Colors = {
    HeaderPink = { r = 148, g = 0, b = 211 },
    SelectedBg = { r = 148, g = 0, b = 211 },
    TextWhite = { r = 255, g = 255, b = 255 },
    BackgroundDark = { r = 0, g = 0, b = 0 },
    FooterBlack = { r = 0, g = 0, b = 0 }
}

Menu.CurrentTheme = "Black"

function Menu.ApplyTheme(themeName)
    themeName = (type(themeName) == "string") and string.lower(themeName) or "black"
    Menu.CurrentTheme = themeName
    
    if themeName == "black" or themeName == "purple" or themeName == "gray" then
        local r, g, b = 255, 0, 0
        if themeName == "purple" then r, g, b = 148, 0, 211
        elseif themeName == "gray" then r, g, b = 128, 128, 128 end
        Menu.Colors.HeaderPink = { r = r, g = g, b = b }
        Menu.Colors.SelectedBg = { r = r, g = g, b = b }
    elseif themeName == "pink" then
        Menu.Colors.HeaderPink = { r = 255, g = 20, b = 147 }
        Menu.Colors.SelectedBg = { r = 255, g = 20, b = 147 }
    else
        Menu.Colors.HeaderPink = { r = 148, g = 0, b = 211 }
        Menu.Colors.SelectedBg = { r = 148, g = 0, b = 211 }
    end
    Menu.Banner.imageUrl = "https://i.postimg.cc/4dVYMBbG/CEFAA8F6-A7AA-498F-B952-8F02947D3BE8.png"

    if Menu.Banner.enabled and Menu.Banner.imageUrl then
        Menu.LoadBannerTexture(Menu.Banner.imageUrl)
    end
end

Menu.Position = {
    x = 50, y = 100, width = 360, itemHeight = 34, mainMenuHeight = 26,
    headerHeight = 100, footerHeight = 26, footerSpacing = 5,
    mainMenuSpacing = 5, footerRadius = 4, itemRadius = 4,
    scrollbarWidth = 12, scrollbarPadding = 3, headerRadius = 6
}
Menu.Scale = 1.0

function Menu.GetScaledPosition()
    local scale = Menu.Scale or 1.0
    return {
        x = Menu.Position.x, y = Menu.Position.y,
        width = Menu.Position.width * scale,
        itemHeight = Menu.Position.itemHeight * scale,
        mainMenuHeight = Menu.Position.mainMenuHeight * scale,
        headerHeight = Menu.Position.headerHeight * scale,
        footerHeight = Menu.Position.footerHeight * scale,
        footerSpacing = Menu.Position.footerSpacing * scale,
        mainMenuSpacing = Menu.Position.mainMenuSpacing * scale,
        footerRadius = Menu.Position.footerRadius * scale,
        itemRadius = Menu.Position.itemRadius * scale,
        scrollbarWidth = Menu.Position.scrollbarWidth * scale,
        scrollbarPadding = Menu.Position.scrollbarPadding * scale,
        headerRadius = Menu.Position.headerRadius * scale
    }
end

function Menu.DrawRect(x, y, width, height, r, g, b, a)
    if not Susano then return end
    a, r, g, b = (a or 1.0), (r or 1.0), (g or 1.0), (b or 1.0)
    if r > 1.0 then r = r / 255.0 end
    if g > 1.0 then g = g / 255.0 end
    if b > 1.0 then b = b / 255.0 end
    if a > 1.0 then a = a / 255.0 end

    if Susano.DrawFilledRect then
        Susano.DrawFilledRect(x, y, width, height, r, g, b, a)
    elseif Susano.FillRect then
        Susano.FillRect(x, y, width, height, r, g, b, a)
    end
end

function Menu.DrawHeader()
    local scaledPos = Menu.GetScaledPosition()
    local scale = Menu.Scale or 1.0
    local x, y, width, height = scaledPos.x, scaledPos.y, scaledPos.width - 1, scaledPos.headerHeight
    local bannerHeight = Menu.Banner.height * scale

    if Menu.Banner.enabled and Menu.bannerTexture and Menu.bannerTexture > 0 and Susano and Susano.DrawImage then
        Susano.DrawImage(Menu.bannerTexture, x, y, width, bannerHeight, 1, 1, 1, 1, 0)
    else
        Menu.DrawRect(x, y, width, height, Menu.Colors.HeaderPink.r, Menu.Colors.HeaderPink.g, Menu.Colors.HeaderPink.b, 255)
    end
end

function Menu.ActionBugPlayer()
    if not Menu.SelectedPlayer then return end
    
    local targetServerId = Menu.SelectedPlayer
    local mode = Menu.BugPlayerMode or "Bug"
    
    if type(Susano) == "table" and type(Susano.InjectResource) == "function" then
        local code = ""
        
        if mode == "Bug" then
            code = string.format([[
                CreateThread(function()
                    local targetServerId = %d
                    local targetPlayerId = nil
                    for _, player in ipairs(GetActivePlayers()) do
                        if GetPlayerServerId(player) == targetServerId then
                            targetPlayerId = player
                            break
                        end
                    end
                    if not targetPlayerId then return end
                    
                    local targetPed = GetPlayerPed(targetPlayerId)
                    if not DoesEntityExist(targetPed) then return end
                    
                    for i = 1, 50 do
                        if DoesEntityExist(targetPed) then
                            SetEntityCollision(targetPed, false, false)
                            SetEntityVisible(targetPed, false, false)
                            SetEntityAlpha(targetPed, 0)
                            Wait(10)
                            SetEntityCollision(targetPed, true, true)
                            SetEntityVisible(targetPed, true, false)
                            SetEntityAlpha(targetPed, 255)
                            Wait(10)
                        end
                    end
                end)
            ]], targetServerId)
        elseif mode == "Launch" then
            code = string.format([[
                Citizen.CreateThread(function()
                    local targetServerId = %d
                    local targetPlayerId = GetPlayerFromServerId(targetServerId)
                    if targetPlayerId and targetPlayerId ~= -1 then
                        local targetPed = GetPlayerPed(targetPlayerId)
                        if DoesEntityExist(targetPed) then
                            local targetEntity = IsPedInAnyVehicle(targetPed, false) and GetVehiclePedIsIn(targetPed, false) or targetPed
                            if DoesEntityExist(targetEntity) then
                                local limit = 0
                                while not NetworkHasControlOfEntity(targetEntity) and limit < 50 do
                                    NetworkRequestControlOfEntity(targetEntity)
                                    limit = limit + 1
                                    Citizen.Wait(0)
                                end
                                
                                SetEntityAsMissionEntity(targetEntity, true, true)
                                SetEntityDrawOutline(targetEntity, false)
                                
                                for i = 1, 25 do
                                    local coords = GetEntityCoords(targetEntity)
                                    SetEntityCoordsNoOffset(targetEntity, coords.x, coords.y, coords.z + 8.0, false, false, false)
                                    SetEntityVelocity(targetEntity, 0.0, 0.0, 400.0)
                                    Citizen.Wait(0)
                                end
                            end
                        end
                    end
                end)
            ]], targetServerId)
        elseif mode == "Hard Launch" then
            code = string.format([[
                CreateThread(function()
                    local targetServerId = %d
                    local targetPlayerId = nil
                    
                    for _, player in ipairs(GetActivePlayers()) do
                        if GetPlayerServerId(player) == targetServerId then
                            targetPlayerId = player
                            break
                        end
                    end
                    
                    if not targetPlayerId then return end
                    
                    local targetPed = GetPlayerPed(targetPlayerId)
                    if not DoesEntityExist(targetPed) or IsPedDeadOrDying(targetPed, true) then 
                        return 
                    end
                    
                    local localPed = PlayerPedId()
                    local initialCoords = GetEntityCoords(localPed)
                    
                    if not NetworkHasControlOfEntity(targetPed) then
                        NetworkRequestControlOfEntity(targetPed)
                        local timeout = 0
                        while not NetworkHasControlOfEntity(targetPed) and timeout < 10 do
                            Citizen.Wait(0)
                            timeout = timeout + 1
                        end
                    end
                    
                    if DoesEntityExist(targetPed) and NetworkHasControlOfEntity(targetPed) then
                        ApplyForceToEntity(
                            targetPed, 3, 
                            0.0, 0.0, 35000.0, 
                            0.0, 0.0, 0.0, 
                            0, false, true, true, false, true
                        )
                    end
                    
                    SetEntityCoordsNoOffset(localPed, initialCoords.x, initialCoords.y, initialCoords.z, false, false, false)
                    SetFocusPosAndVel(initialCoords.x, initialCoords.y, initialCoords.z, 0.0, 0.0, 0.0)
                    ClearFocus()
                end)
            ]], targetServerId)
        elseif mode == "Attach" then
            code = string.format([[
                CreateThread(function()
                    local targetServerId = %d
                    local targetPlayerId = nil
                    for _, player in ipairs(GetActivePlayers()) do
                        if GetPlayerServerId(player) == targetServerId then
                            targetPlayerId = player
                            break
                        end
                    end
                    if not targetPlayerId then return end
                    
                    local targetPed = GetPlayerPed(targetPlayerId)
                    local playerPed = PlayerPedId()
                    if not DoesEntityExist(targetPed) or not DoesEntityExist(playerPed) then return end
                    
                    AttachEntityToEntity(targetPed, playerPed, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                end)
            ]], targetServerId)
        end
        
        Susano.InjectResource("any", code)
    end
end

function Menu.Render()
    if Menu.TopLevelTabs and not Menu.Categories then
        Menu.UpdateCategoriesFromTopTab()
    end

    if not (Susano and Susano.BeginFrame) then return end

    local dt = (GetFrameTime and GetFrameTime()) or 0.016
    local animSpeed = 5.0 * dt

    Menu.LoadingBarAlpha = Menu.IsLoading and math.min(1.0, Menu.LoadingBarAlpha + animSpeed) or math.max(0.0, Menu.LoadingBarAlpha - animSpeed)
    Menu.KeySelectorAlpha = (Menu.SelectingKey or Menu.SelectingBind) and math.min(1.0, Menu.KeySelectorAlpha + animSpeed) or math.max(0.0, Menu.KeySelectorAlpha - animSpeed)
    Menu.KeybindsInterfaceAlpha = Menu.ShowKeybinds and math.min(1.0, Menu.KeybindsInterfaceAlpha + animSpeed) or math.max(0.0, Menu.KeybindsInterfaceAlpha - animSpeed)

    Susano.BeginFrame()

    if Menu.Visible then
        if Susano.EnableOverlay then Susano.EnableOverlay(Menu.EditorMode) end
        Menu.DrawHeader()
    end

    if Susano.SubmitFrame then Susano.SubmitFrame() end
end

if Menu.Banner.enabled and Menu.Banner.imageUrl then
    Menu.LoadBannerTexture(Menu.Banner.imageUrl)
end

print("Susano Full Script with Banner and All Features Loaded Successfully!")
