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

    Menu.Categories = {}
    table.insert(Menu.Categories, { name = currentTop.name })
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
    if not url or url == "" then return end
    if not Susano or not Susano.HttpGet or not Susano.LoadTextureFromBuffer then return end

    if CreateThread then
        CreateThread(function()
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
        end)
    else
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
    if not themeName or type(themeName) ~= "string" then
        themeName = "Black"
    end
    
    local themeLower = string.lower(themeName)
    Menu.CurrentTheme = themeName
    
    if themeLower == "black" then
        Menu.Colors.HeaderPink = { r = 255, g = 0, b = 0 }
        Menu.Colors.SelectedBg = { r = 255, g = 0, b = 0 }
    elseif themeLower == "gray" then
        Menu.Colors.HeaderPink = { r = 128, g = 128, b = 128 }
        Menu.Colors.SelectedBg = { r = 128, g = 128, b = 128 }
    elseif themeLower == "pink" then
        Menu.Colors.HeaderPink = { r = 255, g = 20, b = 147 }
        Menu.Colors.SelectedBg = { r = 255, g = 20, b = 147 }
    else
        Menu.Colors.HeaderPink = { r = 148, g = 0, b = 211 }
        Menu.Colors.SelectedBg = { r = 148, g = 0, b = 211 }
    end

    if Menu.Banner.enabled and Menu.Banner.imageUrl then
        Menu.LoadBannerTexture(Menu.Banner.imageUrl)
    end
end

Menu.Position = {
    x = 50,
    y = 100,
    width = 360,
    itemHeight = 34,
    mainMenuHeight = 26,
    headerHeight = 100,
    footerHeight = 26,
    footerSpacing = 5,
    mainMenuSpacing = 5,
    footerRadius = 4,
    itemRadius = 4,
    scrollbarWidth = 12,
    scrollbarPadding = 3,
    headerRadius = 6
}
Menu.Scale = 1.0

function Menu.GetScaledPosition()
    local scale = Menu.Scale or 1.0
    return {
        x = Menu.Position.x,
        y = Menu.Position.y,
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
    a = a or 1.0
    r = r or 1.0
    g = g or 1.0
    b = b or 1.0

    if r > 1.0 then r = r / 255.0 end
    if g > 1.0 then g = g / 255.0 end
    if b > 1.0 then b = b / 255.0 end
    if a > 1.0 then a = a / 255.0 end

    if Susano.DrawFilledRect then
        Susano.DrawFilledRect(x, y, width, height, r, g, b, a)
    elseif Susano.FillRect then
        Susano.FillRect(x, y, width, height, r, g, b, a)
    elseif Susano.DrawRect then
        for i = 0, height - 1 do
            Susano.DrawRect(x, y + i, width, 1, r, g, b, a)
        end
    end
end

function Menu.DrawText(x, y, text, size_px, r, g, b, a)
    local scale = Menu.Scale or 1.0
    size_px = (size_px or 16) * scale
    r = r or 1.0
    g = g or 1.0
    b = b or 1.0
    a = a or 1.0

    if r > 1.0 then r = r / 255.0 end
    if g > 1.0 then g = g / 255.0 end
    if b > 1.0 then b = b / 255.0 end
    if a > 1.0 then a = a / 255.0 end

    Susano.DrawText(x, y, text, size_px, r, g, b, a)
end

function Menu.DrawHeader()
    local scaledPos = Menu.GetScaledPosition()
    local x = scaledPos.x
    local y = scaledPos.y
    local width = scaledPos.width - 1
    local height = scaledPos.headerHeight
    local scale = Menu.Scale or 1.0
    local bannerHeight = Menu.Banner.height * scale

    if Menu.Banner.enabled and Menu.bannerTexture and Menu.bannerTexture > 0 and Susano and Susano.DrawImage then
        Susano.DrawImage(Menu.bannerTexture, x, y, width, bannerHeight, 1, 1, 1, 1, 0)
    else
        Menu.DrawRect(x, y, width, height, Menu.Colors.HeaderPink.r, Menu.Colors.HeaderPink.g, Menu.Colors.HeaderPink.b, 255)
        local logoX = x + width / 2 - 12
        local logoY = y + height / 2 - 20
        Menu.DrawText(logoX, logoY, "P", 44, 1.0, 1.0, 1.0, 1.0)
    end
end

function Menu.DrawScrollbar(x, startY, visibleHeight, selectedIndex, totalItems, isMainMenu, menuWidth)
    if totalItems < 1 then return end

    local scaledPos = Menu.GetScaledPosition()
    local scrollbarWidth = scaledPos.scrollbarWidth
    local scrollbarPadding = scaledPos.scrollbarPadding
    local width = menuWidth or scaledPos.width

    local scrollbarX = (Menu.ScrollbarPosition == 2) and (x + width + scrollbarPadding) or (x - scrollbarWidth - scrollbarPadding)
    local thumbHeight = visibleHeight  
    local thumbY
    
    if totalItems <= Menu.ItemsPerPage then
        thumbY = startY
    else
        local scrollOffset = not isMainMenu and Menu.ItemScrollOffset or Menu.CategoryScrollOffset
        local totalScrollable = totalItems - Menu.ItemsPerPage
        local scrollProgress = math.min(1.0, math.max(0.0, scrollOffset / math.max(1, totalScrollable)))
        local maxThumbY = startY + visibleHeight - thumbHeight
        thumbY = math.max(startY, math.min(maxThumbY, startY + scrollProgress * (visibleHeight - thumbHeight)))
    end

    if not Menu.scrollbarY then Menu.scrollbarY = thumbY end
    if not Menu.scrollbarHeight then Menu.scrollbarHeight = thumbHeight end

    Menu.scrollbarY = Menu.scrollbarY + (thumbY - Menu.scrollbarY) * 0.15
    Menu.scrollbarHeight = Menu.scrollbarHeight + (thumbHeight - Menu.scrollbarHeight) * 0.15

    local thumbPadding = 2
    local bgR = (Menu.Colors.SelectedBg.r / 255.0)
    local bgG = (Menu.Colors.SelectedBg.g / 255.0)
    local bgB = (Menu.Colors.SelectedBg.b / 255.0)
    
    if Susano and Susano.DrawRectFilled then
        Susano.DrawRectFilled(scrollbarX + thumbPadding - 1, Menu.scrollbarY + thumbPadding - 1, scrollbarWidth - (thumbPadding * 2) + 2, Menu.scrollbarHeight - (thumbPadding * 2) + 2, bgR * 0.3, bgG * 0.3, bgB * 0.3, 0.4, (scrollbarWidth - (thumbPadding * 2) + 2) / 2)
        Susano.DrawRectFilled(scrollbarX + thumbPadding, Menu.scrollbarY + thumbPadding, scrollbarWidth - (thumbPadding * 2), Menu.scrollbarHeight - (thumbPadding * 2), bgR, bgG, bgB, 1.0, (scrollbarWidth - (thumbPadding * 2)) / 2)
    end
end

-- Reduced step counts significantly across all drawing functions to remove render lag
function Menu.DrawGradientBox(x, y, width, height, baseR, baseG, baseB, horizontal)
    local gradientSteps = 15 -- Drastically lowered from 50/120 to fix rendering spikes
    local stepSize = (horizontal and width or height) / gradientSteps

    for step = 0, gradientSteps - 1 do
        local stepFactor = step / (gradientSteps - 1)
        local stepDarken = stepFactor * 0.4
        local stepR = math.max(0, baseR - stepDarken)
        local stepG = math.max(0, baseG - stepDarken)
        local stepB = math.max(0, baseB - stepDarken)

        local drawX = horizontal and (x + (step * stepSize)) or x
        local drawY = horizontal and y or (y + (step * stepSize))
        local drawW = horizontal and stepSize or width
        local drawH = horizontal and height or stepSize

        if Susano and Susano.DrawRectFilled then
            Susano.DrawRectFilled(drawX, drawY, drawW + 0.5, drawH + 0.5, stepR, stepG, stepB, 0.95, 0.0)
        end
    end
end

function Menu.DrawTabs(category, x, startY, width, tabHeight)
    local scale = Menu.Scale or 1.0
    if not category or not category.hasTabs or not category.tabs then return end

    local numTabs = #category.tabs
    local tabWidth = width / numTabs
    local currentX = x

    for i, tab in ipairs(category.tabs) do
        local currentTabWidth = (i == numTabs) and ((x + width) - currentX) or (tabWidth + (0.5 * scale))
        local isSelected = (i == Menu.CurrentTab)

        if isSelected then
            if Menu.TabSelectorX == 0 then
                Menu.TabSelectorX = currentX
                Menu.TabSelectorWidth = currentTabWidth
            end

            Menu.TabSelectorX = Menu.TabSelectorX + (currentX - Menu.TabSelectorX) * Menu.SmoothFactor
            Menu.TabSelectorWidth = Menu.TabSelectorWidth + (currentTabWidth - Menu.TabSelectorWidth) * Menu.SmoothFactor

            local baseR = Menu.Colors.SelectedBg.r / 255.0
            local baseG = Menu.Colors.SelectedBg.g / 255.0
            local baseB = Menu.Colors.SelectedBg.b / 255.0

            Menu.DrawGradientBox(Menu.TabSelectorX, startY, Menu.TabSelectorWidth, tabHeight, baseR, baseG, baseB, false)
            Menu.DrawRect(Menu.TabSelectorX, startY, (3 * scale), tabHeight, Menu.Colors.SelectedBg.r, Menu.Colors.SelectedBg.g, Menu.Colors.SelectedBg.b, 255)
        end

        Menu.DrawRect(currentX, startY, currentTabWidth, tabHeight, Menu.Colors.BackgroundDark.r, Menu.Colors.BackgroundDark.g, Menu.Colors.BackgroundDark.b, isSelected and 0 or 50)

        local textSize = 17 * scale
        local textWidth = Susano and Susano.GetTextWidth and Susano.GetTextWidth(tab.name, textSize) or (string.len(tab.name) * 9 * scale)
        local textX = currentX + (currentTabWidth / 2) - (textWidth / 2)
        local textY = startY + tabHeight / 2 - (textSize / 2)
        
        Menu.DrawText(textX, textY, tab.name, 17, Menu.Colors.TextWhite.r / 255.0, Menu.Colors.TextWhite.g / 255.0, Menu.Colors.TextWhite.b / 255.0, 1.0)
        currentX = currentX + tabWidth
    end
end

function Menu.DrawItem(x, itemY, width, itemHeight, item, isSelected)
    local scale = Menu.Scale or 1.0
    
    if item.isSeparator then
        Menu.DrawRect(x, itemY, width, itemHeight, Menu.Colors.BackgroundDark.r, Menu.Colors.BackgroundDark.g, Menu.Colors.BackgroundDark.b, 50)
        if item.separatorText then
            local textSize = 14 * scale
            local textWidth = Susano and Susano.GetTextWidth and Susano.GetTextWidth(item.separatorText, textSize) or (string.len(item.separatorText) * 8 * scale)
            local textX = x + (width / 2) - (textWidth / 2)
            local textY = itemY + itemHeight / 2 - (7 * scale)
            Menu.DrawText(textX, textY, item.separatorText, 14, Menu.Colors.TextWhite.r / 255.0, Menu.Colors.TextWhite.g / 255.0, Menu.Colors.TextWhite.b / 255.0, 1.0)
        end
        return
    end

    Menu.DrawRect(x, itemY, width, itemHeight, Menu.Colors.BackgroundDark.r, Menu.Colors.BackgroundDark.g, Menu.Colors.BackgroundDark.b, 50)

    if isSelected then
        if Menu.SelectorY == 0 then Menu.SelectorY = itemY end
        Menu.SelectorY = Menu.SelectorY + (itemY - Menu.SelectorY) * Menu.SmoothFactor

        local baseR = Menu.Colors.SelectedBg.r / 255.0
        local baseG = Menu.Colors.SelectedBg.g / 255.0
        local baseB = Menu.Colors.SelectedBg.b / 255.0

        Menu.DrawGradientBox(x, Menu.SelectorY, width - 1, itemHeight, baseR, baseG, baseB, Menu.GradientType == 2)
        Menu.DrawRect(x, Menu.SelectorY, 3, itemHeight, Menu.Colors.SelectedBg.r, Menu.Colors.SelectedBg.g, Menu.Colors.SelectedBg.b, 255)
    end

    local textX = x + (16 * scale)
    local textY = itemY + itemHeight / 2 - (8 * scale)
    Menu.DrawText(textX, textY, item.name, 17, Menu.Colors.TextWhite.r / 255.0, Menu.Colors.TextWhite.g / 255.0, Menu.Colors.TextWhite.b / 255.0, 1.0)

    if item.type == "toggle" then
        local toggleWidth, toggleHeight = 36 * scale, 16 * scale
        local toggleX = x + width - toggleWidth - (16 * scale)
        local toggleY = itemY + (itemHeight / 2) - (toggleHeight / 2)
        local tR = item.value and (Menu.Colors.SelectedBg.r / 255.0) or 0.2
        local tG = item.value and (Menu.Colors.SelectedBg.g / 255.0) or 0.2
        local tB = item.value and (Menu.Colors.SelectedBg.b / 255.0) or 0.2

        if Susano and Susano.DrawRectFilled then
            Susano.DrawRectFilled(toggleX, toggleY, toggleWidth, toggleHeight, tR, tG, tB, 0.95, toggleHeight / 2)
            local circleSize = toggleHeight - 4
            local circleX = item.value and (toggleX + toggleWidth - circleSize - 2) or (toggleX + 2)
            Susano.DrawRectFilled(circleX, toggleY + 2, circleSize, circleSize, 1.0, 1.0, 1.0, 1.0, circleSize / 2)
        end
    end
end

function Menu.DrawCategories()
    if Menu.OpenedCategory then
        local category = Menu.Categories[Menu.OpenedCategory]
        if not category or not category.hasTabs or not category.tabs then
            Menu.OpenedCategory = nil
            return
        end

        local scaledPos = Menu.GetScaledPosition()
        local x, startY, width, itemHeight, mainMenuHeight, mainMenuSpacing = scaledPos.x, scaledPos.y + scaledPos.headerHeight, scaledPos.width, scaledPos.itemHeight, scaledPos.mainMenuHeight, scaledPos.mainMenuSpacing

        Menu.DrawTabs(category, x, startY, width, mainMenuHeight)

        local currentTab = category.tabs[Menu.CurrentTab]
        if currentTab and currentTab.items then
            local itemY = startY + mainMenuHeight + mainMenuSpacing
            local totalItems = #currentTab.items
            local maxVisible = Menu.ItemsPerPage
            local nonSeparatorCount = 0

            for _, item in ipairs(currentTab.items) do
                if not item.isSeparator then nonSeparatorCount = nonSeparatorCount + 1 end
            end

            if Menu.CurrentItem > Menu.ItemScrollOffset + maxVisible then
                Menu.ItemScrollOffset = Menu.CurrentItem - maxVisible
            elseif Menu.CurrentItem <= Menu.ItemScrollOffset then
                Menu.ItemScrollOffset = math.max(0, Menu.CurrentItem - 1)
            end

            local actualVisibleCount = 0
            for i = 1, math.min(maxVisible, totalItems) do
                local itemIndex = i + Menu.ItemScrollOffset
                if itemIndex <= totalItems then
                    actualVisibleCount = actualVisibleCount + 1
                    Menu.DrawItem(x, itemY + (i - 1) * itemHeight, width, itemHeight, currentTab.items[itemIndex], itemIndex == Menu.CurrentItem)
                end
            end

            if nonSeparatorCount > 0 then
                Menu.DrawScrollbar(x, itemY, actualVisibleCount * itemHeight, Menu.CurrentItem, nonSeparatorCount, false, width)
            end
        end
        return
    end

    local scaledPos = Menu.GetScaledPosition()
    local scale = Menu.Scale or 1.0
    local x, startY, width, itemHeight, mainMenuHeight, mainMenuSpacing = scaledPos.x, scaledPos.y + (Menu.Banner.enabled and (Menu.Banner.height * scale) or scaledPos.headerHeight), scaledPos.width, scaledPos.itemHeight, scaledPos.mainMenuHeight, scaledPos.mainMenuSpacing
    local totalCategories = #Menu.Categories - 1
    local maxVisible = Menu.ItemsPerPage

    if Menu.CurrentCategory > Menu.CategoryScrollOffset + maxVisible + 1 then
        Menu.CategoryScrollOffset = Menu.CurrentCategory - maxVisible - 1
    elseif Menu.CurrentCategory <= Menu.CategoryScrollOffset + 1 then
        Menu.CategoryScrollOffset = math.max(0, Menu.CurrentCategory - 2)
    end

    Menu.DrawGradientBox(x, startY, width, mainMenuHeight, Menu.Colors.HeaderPink.r / 255.0, Menu.Colors.HeaderPink.g / 255.0, Menu.Colors.HeaderPink.b / 255.0, false)

    local actualVisibleCount = 0
    for displayIndex = 1, math.min(maxVisible, totalCategories) do
        local categoryIndex = displayIndex + Menu.CategoryScrollOffset + 1
        if categoryIndex <= #Menu.Categories then
            actualVisibleCount = actualVisibleCount + 1
            local category = Menu.Categories[categoryIndex]
            local itemY = startY + mainMenuHeight + mainMenuSpacing + (displayIndex - 1) * itemHeight
            
            Menu.DrawItem(x, itemY, width, itemHeight, {name = category.name}, categoryIndex == Menu.CurrentCategory)
        end
    end

    if totalCategories > 0 then
        Menu.DrawScrollbar(x, startY + mainMenuHeight + mainMenuSpacing, actualVisibleCount * itemHeight, Menu.CurrentCategory, totalCategories, true, width)
    end
end

function Menu.DrawBackground()
    local scaledPos = Menu.GetScaledPosition()
    local x, y, width = scaledPos.x, scaledPos.y, scaledPos.width - 1
    local scale = Menu.Scale or 1.0
    local bannerHeight = Menu.Banner.enabled and (Menu.Banner.height * scale) or scaledPos.headerHeight
    local itemsY = y + bannerHeight + scaledPos.mainMenuHeight + scaledPos.mainMenuSpacing
    
    local itemsH = 0
    if Menu.OpenedCategory then
        local category = Menu.Categories[Menu.OpenedCategory]
        if category and category.hasTabs and category.tabs then
            local currentTab = category.tabs[Menu.CurrentTab]
            if currentTab and currentTab.items then
                itemsH = math.min(Menu.ItemsPerPage, #currentTab.items) * scaledPos.itemHeight
            end
        end
    else
        itemsH = math.min(Menu.ItemsPerPage, #Menu.Categories - 1) * scaledPos.itemHeight
    end

    -- Single clean background draw optimization instead of multiple nested loops
    if Susano and Susano.DrawRectFilled then
        Susano.DrawRectFilled(x, itemsY, width, itemsH, 0.0, 0.0, 0.0, 1.0, 0)
    end
end

function Menu.Render()
    if Menu.TopLevelTabs and not Menu.Categories then
        Menu.UpdateCategoriesFromTopTab()
    end

    if not (Susano and Susano.BeginFrame) then return end

    local dt = GetFrameTime and GetFrameTime() or 0.016
    local animSpeed = 5.0 * dt

    Menu.LoadingBarAlpha = Menu.IsLoading and math.min(1.0, Menu.LoadingBarAlpha + animSpeed) or math.max(0.0, Menu.LoadingBarAlpha - animSpeed)
    Menu.KeySelectorAlpha = (Menu.SelectingKey or Menu.SelectingBind) and math.min(1.0, Menu.KeySelectorAlpha + animSpeed) or math.max(0.0, Menu.KeySelectorAlpha - animSpeed)
    Menu.KeybindsInterfaceAlpha = Menu.ShowKeybinds and math.min(1.0, Menu.KeybindsInterfaceAlpha + animSpeed) or math.max(0.0, Menu.KeybindsInterfaceAlpha - animSpeed)

    Susano.BeginFrame()

    if Menu.Visible then
        if Susano.EnableOverlay then Susano.EnableOverlay(Menu.EditorMode) end
        Menu.DrawBackground()
        Menu.DrawHeader()
        Menu.DrawCategories()
        Menu.DrawFooter()
    end

    if Menu.LoadingBarAlpha > 0 then Menu.DrawLoadingBar(Menu.LoadingBarAlpha) end
    if Menu.KeySelectorAlpha > 0 then Menu.DrawKeySelector(Menu.KeySelectorAlpha) end

    if Susano.SubmitFrame then Susano.SubmitFrame() end
end

function Menu.DrawFooter()
    local scaledPos = Menu.GetScaledPosition()
    local x = scaledPos.x
    local scale = Menu.Scale or 1.0
    local bannerHeight = Menu.Banner.enabled and (Menu.Banner.height * scale) or scaledPos.headerHeight
    local totalHeight = bannerHeight + scaledPos.mainMenuHeight + scaledPos.mainMenuSpacing + (Menu.ItemsPerPage * scaledPos.itemHeight)
    local footerY = scaledPos.y + totalHeight + scaledPos.footerSpacing

    if Susano and Susano.DrawRectFilled then
        Susano.DrawRectFilled(x, footerY, scaledPos.width - 1, scaledPos.footerHeight, 0.0, 0.0, 0.0, 1.0, scaledPos.footerRadius)
    end
    Menu.DrawText(x + 15 * scale, footerY + 5, " https://discord.gg/zP8MaFP9uM ", 13, 1.0, 1.0, 1.0, 1.0)
end

function Menu.DrawLoadingBar(alpha)
    if alpha <= 0 then return end
    local screenWidth = Susano and Susano.GetScreenWidth and Susano.GetScreenWidth() or 1920
    local screenHeight = Susano and Susano.GetScreenHeight and Susano.GetScreenHeight() or 1080
    Menu.DrawText(screenWidth / 2 - 40, screenHeight - 190, "Loading...", 18, 1.0, 1.0, 1.0, alpha)
end

Menu.KeyStates = {}
function Menu.IsKeyJustPressed(keyCode)
    if not (Susano and Susano.GetAsyncKeyState) then return false end
    local down, pressed = Susano.GetAsyncKeyState(keyCode)
    local wasDown = Menu.KeyStates[keyCode] or false
    Menu.KeyStates[keyCode] = (down == true)
    return pressed == true or (down == true and not wasDown)
end

function Menu.HandleInput()
    if Menu.IsLoading or not Menu.LoadingComplete or Menu.InputOpen then return end
    if Susano and Susano.GetAsyncKeyState then
        local down, pressed = Susano.GetAsyncKeyState(0x31)
        if pressed == true or (down == true and not Menu.KeyStates[0x31]) then
            Menu.Visible = not Menu.Visible
        end
        Menu.KeyStates[0x31] = (down == true)
    end
end
