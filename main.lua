local Menu = {}
Menu.Visible = false
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
Menu.IsLoading = true
Menu.LoadingComplete = false
Menu.LoadingStartTime = nil
Menu.LoadingDuration = 3000

Menu.SelectingKey = false
Menu.SelectedKey = nil
Menu.SelectedKeyName = nil

Menu.SelectingBind = false
Menu.BindingItem = nil
Menu.BindingKey = nil
Menu.BindingKeyName = nil

Menu.ShowKeybinds = false
Menu.CurrentTopTab = 1

function Menu.UpdateCategoriesFromTopTab()
    if not Menu.TopLevelTabs then return end
    local currentTop = Menu.TopLevelTabs[Menu.CurrentTopTab]
    if not currentTop then return end

    Menu.Categories = {{ name = currentTop.name }}
    for _, cat in ipairs(currentTop.categories) do
        table.insert(Menu.Categories, cat)
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

    local loadRoutine = function()
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

    if CreateThread then
        CreateThread(loadRoutine)
    else
        loadRoutine()
    end
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
    a, r, g, b = (a or 1.0), (r or 1.0), (g or 1.0), (b or 1.0)
    if r > 1.0 then r = r / 255.0 end
    if g > 1.0 then g = g / 255.0 end
    if b > 1.0 then b = b / 255.0 end
    if a > 1.0 then a = a / 255.0 end

    if Susano and Susano.DrawFilledRect then
        Susano.DrawFilledRect(x, y, width, height, r, g, b, a)
    elseif Susano and Susano.FillRect then
        Susano.FillRect(x, y, width, height, r, g, b, a)
    elseif Susano and Susano.DrawRect then
        for i = 0, height - 1 do
            Susano.DrawRect(x, y + i, width, 1, r, g, b, a)
        end
    end
end

function Menu.DrawText(x, y, text, size_px, r, g, b, a)
    if not Susano or not Susano.DrawText then return end
    local scale = Menu.Scale or 1.0
    Susano.DrawText(x, y, text, (size_px or 16) * scale, (r or 255) > 1 and r / 255 or (r or 1.0), (g or 255) > 1 and g / 255 or (g or 1.0), (b or 255) > 1 and b / 255 or (b or 1.0), (a or 1.0) > 1 and a / 255 or (a or 1.0))
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
        Menu.DrawText(x + width / 2 - 12, y + height / 2 - 20, "P", 44, 1.0, 1.0, 1.0, 1.0)
    end
end

function Menu.DrawScrollbar(x, startY, visibleHeight, selectedIndex, totalItems, isMainMenu, menuWidth)
    if totalItems < 1 then return end

    local scaledPos = Menu.GetScaledPosition()
    local scrollbarWidth, scrollbarPadding = scaledPos.scrollbarWidth, scaledPos.scrollbarPadding
    local scrollbarX = (Menu.ScrollbarPosition == 2) and (x + (menuWidth or scaledPos.width) + scrollbarPadding) or (x - scrollbarWidth - scrollbarPadding)

    local thumbHeight = visibleHeight
    local thumbY = startY
    
    if totalItems > Menu.ItemsPerPage then
        local scrollOffset = isMainMenu and (Menu.CategoryScrollOffset or 0) or (Menu.ItemScrollOffset or 0)
        local scrollProgress = math.min(1.0, math.max(0.0, scrollOffset / math.max(1, totalItems - Menu.ItemsPerPage)))
        thumbY = math.max(startY, math.min(startY + visibleHeight - thumbHeight, startY + scrollProgress * (visibleHeight - thumbHeight)))
    end

    Menu.scrollbarY = Menu.scrollbarY and (Menu.scrollbarY + (thumbY - Menu.scrollbarY) * 0.15) or thumbY
    Menu.scrollbarHeight = Menu.scrollbarHeight and (Menu.scrollbarHeight + (thumbHeight - Menu.scrollbarHeight) * 0.15) or thumbHeight

    local bgR = (Menu.Colors.SelectedBg.r or 255) / 255.0
    local bgG = (Menu.Colors.SelectedBg.g or 0) / 255.0
    local bgB = (Menu.Colors.SelectedBg.b or 255) / 255.0
    
    if Susano and Susano.DrawRectFilled then
        Susano.DrawRectFilled(scrollbarX + 1, Menu.scrollbarY + 1, scrollbarWidth - 2, Menu.scrollbarHeight - 2, bgR, bgG, bgB, 1.0, (scrollbarWidth - 2) / 2)
    else
        Menu.DrawRoundedRect(scrollbarX + 1, Menu.scrollbarY + 1, scrollbarWidth - 2, Menu.scrollbarHeight - 2, bgR * 255, bgG * 255, bgB * 255, 255, (scrollbarWidth - 2) / 2)
    end
end

function Menu.DrawRoundedRect(x, y, width, height, r, g, b, a, radius)
    radius = radius or 0
    if radius <= 0 then
        Menu.DrawRect(x, y, width, height, r, g, b, a)
        return
    end
    Menu.DrawRect(x + radius, y, width - 2 * radius, height, r, g, b, a)
    Menu.DrawRect(x, y + radius, radius, height - 2 * radius, r, g, b, a)
    Menu.DrawRect(x + width - radius, y + radius, radius, height - 2 * radius, r, g, b, a)
    
    for i = 0, radius - 1 do
        local slice_width = math.ceil(math.sqrt(radius * radius - i * i))
        local top_y = y + radius - 1 - i
        Menu.DrawRect(x + radius - slice_width, top_y, slice_width, 1, r, g, b, a)
        Menu.DrawRect(x + width - radius, top_y, slice_width, 1, r, g, b, a)
        local bottom_y = y + height - radius + i
        Menu.DrawRect(x + radius - slice_width, bottom_y, slice_width, 1, r, g, b, a)
        Menu.DrawRect(x + width - radius, bottom_y, slice_width, 1, r, g, b, a)
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
    end

    if Susano.SubmitFrame then Susano.SubmitFrame() end
end

return Menu
