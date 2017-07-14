--***********************************************************
--**              LEMMY/ROBERT JOHNSON                     **
--**            Screen with all our options                **
--***********************************************************

require "ISUI/ISPanelJoypad"
require "ISUI/ISButton"
require "ISUI/ISControllerTestPanel"
require "ISUI/ISVolumeControl"

require "defines"

MainOptions = ISPanelJoypad:derive("MainOptions");

MainOptions.keys = {};
MainOptions.keyText = {};
MainOptions.keyPress = nil;
MainOptions.alreadySetKeyName = nil;
MainOptions.alreadySetKeyValue = nil;
MainOptions.keyBindingLength = 0;

-- -- -- -- --

local GameOption = ISBaseObject:derive("GameOption")
local GameOptions = ISBaseObject:derive("GameOptions")

function GameOption:new(name, control, arg1, arg2)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.name = name
	o.control = control
	o.arg1 = arg1
	o.arg2 = arg2
	if control.isCombobox then
		control.onChange = self.onChangeComboBox
		control.target = o
	end
	if control.isTickBox then
		control.changeOptionMethod = self.onChangeTickBox
		control.changeOptionTarget = o
	end
	if control.isSlider then
		control.targetFunc = self.onChangeVolumeControl
		control.target = o
	end
	return o
end

function GameOption:toUI()
	print('ERROR: option "'..self.name..'" missing toUI()')
end

function GameOption:apply()
	print('ERROR: option "'..self.name..'" missing apply()')
end

function GameOption:onChangeComboBox(box)
	self.gameOptions:onChange(self)
	if self.onChange then
		self:onChange(box)
	end
end

function GameOption:onChangeTickBox(index, selected)
	self.gameOptions:onChange(self)
	if self.onChange then
		self:onChange(index, selected)
	end
end

function GameOption:onChangeVolumeControl(control, volume)
	self.gameOptions:onChange(self)
	if self.onChange then
		self:onChange(control, volume)
	end
end

-- -- -- -- --

function GameOptions:add(option)
	option.gameOptions = self
	table.insert(self.options, option)
end

function GameOptions:get(optionName)
	for _,option in ipairs(self.options) do
		if option.name == optionName then
			return option
		end
	end
	return nil
end

function GameOptions:apply()
	for _,option in ipairs(self.options) do
		option:apply()
	end
	self.changed = false
end

function GameOptions:toUI()
	for _,option in ipairs(self.options) do
		option:toUI()
	end
	self.changed = false
end

function GameOptions:onChange(option)
	self.changed = true
end

function GameOptions:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.options = {}
	o.changed = false
	return o
end

-- -- -- -- --

function MainOptions:initialise()
	ISPanelJoypad.initialise(self);
end


--************************************************************************--
--** ISPanel:instantiate
--**
--************************************************************************--
function MainOptions:instantiate()
	self.javaObject = UIElement.new(self);
	self.javaObject:setX(self.x);
	self.javaObject:setY(self.y);
	self.javaObject:setHeight(self.height);
	self.javaObject:setWidth(self.width);
	self.javaObject:setAnchorLeft(self.anchorLeft);
	self.javaObject:setAnchorRight(self.anchorRight);
	self.javaObject:setAnchorTop(self.anchorTop);
	self.javaObject:setAnchorBottom(self.anchorBottom);
end

function MainOptions:setResolutionAndFullScreen()
	local box1 = self.gameOptions:get('fullscreen').control
	local box2 = self.gameOptions:get('resolution').control
	if box1.options[box1.selected] and box2.options[box2.selected] then
		local fullscreen = box1.selected == 1
		-- handle (RECOMMENDED)
		local s = box2.options[box2.selected]
		local w,h = string.match(s, '(%d+) x (%d+)')
		getCore():setResolutionAndFullScreen(tonumber(w), tonumber(h), fullscreen)
	end
end

function MainOptions:ControllerReload(button)
	reloadControllerConfigFiles()
end

function MainOptions:addTextPane(x,y,w,h)
    local panel = ISRichTextPanel:new (x+20, y+self.addY, width, height);
end

function MainOptions:addCombo(x, y, w, h, name, options, selected, target, onchange)

	local label = ISLabel:new(x, y + self.addY, h, name, 1, 1, 1, 1, UIFont.Small);
	label:initialise();
	self.mainPanel:addChild(label);
	local panel2 = ISComboBox:new(x+20, y + self.addY + 2, w, h, target, onchange);
	panel2:initialise();

	for i, k in ipairs(options) do
		panel2:addOption(k);
	end

	panel2.selected = selected;
	self.mainPanel:addChild(panel2);
	self.mainPanel:insertNewLineOfButtons(panel2)
	self.addY = self.addY + 26;
	return panel2;
end

function MainOptions:addSpinBox(x, y, w, h, name, options, selected, target, onchange)
	local label = ISLabel:new(x, y + self.addY, h, name, 1, 1, 1, 1, UIFont.Small);
	label:initialise();
	self.mainPanel:addChild(label);
	local panel2 = ISSpinBox:new(x+20, y + self.addY + 2, w, h, target, onchange);
	panel2:initialise();

	for i, k in ipairs(options) do
		panel2:addOption(k);
	end

	panel2.selected = selected;
	panel2.default = selected;
	self.mainPanel:addChild(panel2);
	self.mainPanel:insertNewLineOfButtons(panel2.leftButton, panel2.rightButton)
	self.addY = self.addY + 26;
	return panel2;
end

function MainOptions:addVolumeControl(x, y, w, h, name, volume, target, onchange)
	local label = ISLabel:new(x, y + self.addY, h, name, 1, 1, 1, 1, UIFont.Small);
	label:initialise();
	self.mainPanel:addChild(label);
	local panel2 = ISVolumeControl:new(x+20, y + self.addY + 2, w, h, target, onchange);
	panel2:initialise();
	panel2:setVolume(volume)

	panel2.selected = selected;
	panel2.default = selected;
	self.mainPanel:addChild(panel2);
	self.mainPanel:insertNewLineOfButtons(panel2)
	self.addY = self.addY + 26;
	return panel2;
end

function MainOptions:addMegaVolumeControl(x, y, w, h, name, volume, target, onchange)
	local label = ISLabel:new(x, y + self.addY, h, name, 1, 1, 1, 1, UIFont.Small);
	label:initialise();
	self.mainPanel:addChild(label);
	local panel2 = ISMegaVolumeControl:new(x+20, y + self.addY + 2, w, h, target, onchange);
	panel2:initialise();
	panel2:setVolume(volume)

	panel2.selected = selected;
	panel2.default = selected;
	self.mainPanel:addChild(panel2);
	self.mainPanel:insertNewLineOfButtons(panel2)
	self.addY = self.addY + 26;
	return panel2;
end

function MainOptions:addVolumeIndicator(x, y, w, h, name, volume, target, onchange)
	local label = ISLabel:new(x, y + self.addY, h, name, 1, 1, 1, 1, UIFont.Small);
	label:initialise();
	self.mainPanel:addChild(label);
	local panel2 = ISVolumeIndicator:new(x+20, y + self.addY + 2, w, h, target, onchange);
	panel2:initialise();

	panel2.selected = selected;
	panel2.default = selected;
	self.mainPanel:addChild(panel2);
	self.mainPanel:insertNewLineOfButtons(panel2)
	self.addY = self.addY + 26;
	return panel2;
end

function MainOptions:addPage(name)
	self.mainPanel = ISPanelJoypad:new(0, 48, self:getWidth(), self:getHeight() - (48 * 2) - self.tabs.tabHeight)
	self.mainPanel:initialise()
	self.mainPanel:instantiate()
	self.mainPanel:setAnchorRight(true)
	self.mainPanel:setAnchorLeft(true)
	self.mainPanel:setAnchorTop(true)
	self.mainPanel:setAnchorBottom(true)
	self.mainPanel:noBackground()
	self.mainPanel.borderColor = {r=0, g=0, b=0, a=0};
	self.mainPanel:setScrollChildren(true)

	self.mainPanel.onJoypadDown = MainOptions.onJoypadDownCurrentTab
	self.mainPanel.onGainJoypadFocus = MainOptions.onGainJoypadFocusCurrentTab

	-- rerouting the main panel's pre / render functions so we can add in the stencil stuff there...
	self.mainPanel.render = MainOptions.subPanelRender
	self.mainPanel.prerender = MainOptions.subPanelPreRender

	self.mainPanel:addScrollBars();
	self.tabs:addView(name, self.mainPanel)
end

-- THESE TWO ARE ACTUALLY self.mainPanel's new render / prerender functions...
--
function MainOptions:subPanelPreRender()
    self:setStencilRect(0,0,self:getWidth(),self:getHeight());

    ISPanelJoypad.prerender(self);
end

function MainOptions:subPanelRender()
    ISPanelJoypad.render(self);
    self:clearStencilRect();
end
---------------------------------------------------------------------------------------------

function MainOptions:create()

	local y = 20;
    -- stay away from statics :)
    MainOptions.keyText = {}
    MainOptions.keyText = {};
    MainOptions.keyPress = nil;
    MainOptions.alreadySetKeyName = nil;
    MainOptions.alreadySetKeyValue = nil;
    MainOptions.keyBindingLength = 0;

	self.tabs = ISTabPanel:new(0, 48, self.width, self.height - 48 * 2);
	self.tabs:initialise();
	self.tabs:setAnchorBottom(true);
	self.tabs:setAnchorRight(true);
--	self.tabs.borderColor = { r = 0, g = 0, b = 0, a = 0};
--	self.tabs.onActivateView = ISCraftingUI.onActivateView;
	self.tabs.target = self;
	self.tabs:setEqualTabWidth(false)
	self.tabs.tabPadX = 40
	self.tabs:setCenterTabs(true)
--	self.tabs.tabHeight = self.tabs.tabHeight + 12
	self:addChild(self.tabs);

	self.backButton = ISButton:new(self.width / 2 - 100 / 2 - 10 - 100, self.height-30, 100, 25, getText("UI_btn_back"), self, MainOptions.onOptionMouseDown);
	self.backButton.internal = "BACK";
	self.backButton:initialise();
	self.backButton:instantiate();
	self.backButton:setAnchorLeft(true);
	self.backButton:setAnchorTop(false);
	self.backButton:setAnchorBottom(true);
	self.backButton.borderColor = {r=1, g=1, b=1, a=0.1};
	self.backButton:setFont(UIFont.Small);
	self.backButton:ignoreWidthChange();
	self.backButton:ignoreHeightChange();
	self:addChild(self.backButton);

	self.acceptButton = ISButton:new(self.width / 2 - 100 / 2, self.height-30, 100, 25, getText("UI_btn_accept"), self, MainOptions.onOptionMouseDown);
	self.acceptButton.internal = "ACCEPT";
	self.acceptButton:initialise();
	self.acceptButton:instantiate();
	self.acceptButton:setAnchorRight(false);
	self.acceptButton:setAnchorLeft(false);
	self.acceptButton:setAnchorTop(false);
	self.acceptButton:setAnchorBottom(true);
	self.acceptButton.borderColor = {r=1, g=1, b=1, a=0.1};
	self.acceptButton:setFont(UIFont.Small);
	self.acceptButton:ignoreWidthChange();
	self.acceptButton:ignoreHeightChange();
	self:addChild(self.acceptButton);

	self.saveButton = ISButton:new(self.width / 2 + 100 / 2 + 10, self.height-30, 100, 25, getText("UI_btn_apply"), self, MainOptions.onOptionMouseDown);
	self.saveButton.internal = "SAVE";
	self.saveButton:initialise();
	self.saveButton:instantiate();
	self.saveButton:setAnchorRight(false);
	self.saveButton:setAnchorLeft(false);
	self.saveButton:setAnchorTop(false);
	self.saveButton:setAnchorBottom(true);
	self.saveButton.borderColor = {r=1, g=1, b=1, a=0.1};
	self.saveButton:setFont(UIFont.Small);
	self.saveButton:ignoreWidthChange();
	self.saveButton:ignoreHeightChange();
	self:addChild(self.saveButton);

	local lbl = ISLabel:new((self.width / 2) - (getTextManager():MeasureStringX(UIFont.Medium, getText("UI_optionscreen_gameoption")) / 2), 10, 30, getText("UI_optionscreen_gameoption"), 1, 1, 1, 1, UIFont.Medium, true);
	lbl:initialise();
	self:addChild(lbl);

	self:addPage(getText("UI_optionscreen_display"))

	----- FULLSCREEN -----
	local modes = getCore():getScreenModes();

	table.sort(modes, MainOptions.sortModes);
	local splitpoint = self:getWidth() / 3;
	local comboWidth = self:getWidth()-splitpoint - 100
	local comboWidth = 300
	local full = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_fullscreen"), {getText("UI_Yes"), getText("UI_No")}, 1);

	local gameOption = GameOption:new('fullscreen', full)
	function gameOption.toUI(self)
		local box = self.control
		if getCore():isFullScreen() then
			box.selected = 1
		else
			box.selected = 2
		end
	end
	function gameOption.apply(self)
		MainOptions.instance:setResolutionAndFullScreen()
	end
	self.gameOptions:add(gameOption)

	----- BORDERLESS -----
	local combo = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_borderless"), {getText("UI_Yes"), getText("UI_No")}, 1);
	combo:setToolTipMap({defaultTooltip = getText("UI_optionscreen_borderless_tt")});

	gameOption = GameOption:new('borderless', combo)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionBorderlessWindow() and 1 or 2
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setOptionBorderlessWindow(box.selected == 1)
		end
	end
	self.gameOptions:add(gameOption)

	----- VSYNC -----
	local vsync = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_vsync"), {getText("UI_Yes"), getText("UI_No")}, 1)

	gameOption = GameOption:new('vsync', vsync)
	function gameOption.toUI(self)
		local box = self.control
		if getCore():getOptionVSync() then
			box.selected = 1
		else
			box.selected = 2
		end
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setOptionVSync(box.selected == 1)
		end
	end
	self.gameOptions:add(gameOption)

	----- MULTICORE -----
	local map = {};
	map["defaultTooltip"] = getText("UI_optionscreen_needreboot");

    local multithread;
    multithread = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_multicore"), {getText("UI_Yes"), getText("UI_No")}, 1);
    multithread:setToolTipMap(map);

	gameOption = GameOption:new('multicore', multithread)
	function gameOption.toUI(self)
		local box = self.control
		if getCore():isMultiThread() then
			box.selected = 1
		else
			box.selected = 2
		end
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setMultiThread(box.selected == 1)
		end
	end
	self.gameOptions:add(gameOption)

	----- SHADERS -----
    local shader;
	shader = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_shaders"), {getText("UI_Yes"), getText("UI_No")}, 1);

	gameOption = GameOption:new('shaders', shader)
	function gameOption.toUI(self)
		local box = self.control
		if getCore():getUseShaders() then
			box.selected = 1;
		else
			box.selected = 2;
		end
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setUseShaders(box.selected == 1)
			if MainScreen.instance.inGame then
				getCore():shadersOptionChanged()
			end
		end
	end
	self.gameOptions:add(gameOption)

	----- RESOLUTION -----
--	for i=1,#modes do
--		if modes[i] == "1280 x 720" then
--			modes[i] = modes[i] .. " (" .. getText("UI_optionscreen_recommended") .. ")"
--			break
--		end
--	end
	table.insert(modes, 1, "CURRENT")
    local res = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_resolution"), modes, 1);

	gameOption = GameOption:new('resolution', res)
	function gameOption.toUI(self)
		local box = self.control
		local w = getCore():getScreenWidth()
		local h = getCore():getScreenHeight()
		box.options[1] = getText("UI_optionscreen_CurrentResolution", w .. " x " .. h)
		box.selected = 1
--		if w == 1280 and h == 720 then
--			box:select(w.." x "..h.. " (" .. getText("UI_optionscreen_recommended") .. ")")
--		else
			box:select(w.." x "..h)
--		end
	end
	function gameOption.apply(self)
		-- 'fullscreen' option sets both resolution and fullscreen
	end
	self.gameOptions:add(gameOption)


	----- 3D MODELS -----
    local newmodels = nil;

    if getPerformance():getSupports3D() then
        newmodels = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_3DModels"), {getText("UI_optionscreen_None"), getText("UI_optionscreen_PlayerOnly"), getText("UI_optionscreen_Player") .. " +1", getText("UI_optionscreen_Player") .. " +2", getText("UI_optionscreen_Player") .. " +3", getText("UI_optionscreen_Player") .. " +4", getText("UI_optionscreen_Player") .. " +5", getText("UI_optionscreen_Player") .. " +8", getText("UI_optionscreen_Player") .. " +10", getText("UI_optionscreen_Player") .. " +20", getText("UI_optionscreen_All")  }, 1);
		gameOption = GameOption:new('3Dmodels', newmodels)
		function gameOption.toUI(self)
			local box = self.control
			if getPerformance():getModelsEnabled() then
				box.selected = getPerformance():getModels() + 2
			else
				box.selected = 1
			end
		end
		function gameOption.apply(self)
			local box = self.control
			if box.options[box.selected] then
				if box.selected == 1 then
					getPerformance():setModelsEnabled(false)
				else
					getPerformance():setModelsEnabled(true)
					getPerformance():setModels(box.selected-2)
				end
			end
		end
		self.gameOptions:add(gameOption)
    else
        newmodels = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_3DModels"), {getText("UI_optionscreen_NotSupportedByHardware")}, 1);
        getPerformance():setModelsEnabled(false)
		gameOption = GameOption:new('3Dmodels', newmodels)
		function gameOption.apply(self)
		end
		function gameOption.toUI(self)
		end
		self.gameOptions:add(gameOption)
    end


    ----- 3D CORPSES -----
	local corpses = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_corpses"), {getText("UI_Yes"), getText("UI_No")}, 1)

	gameOption = GameOption:new('3Dcorpses', corpses)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getPerformance():getCorpses3D() and 1 or 2
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getPerformance():setCorpses3D(box.selected == 1)
		end
	end
	self.gameOptions:add(gameOption)

    ----- BLOOD DECALS -----
	local options = {}
	for i=0,10 do
		table.insert(options, getText("UI_BloodDecals"..i))
	end
	local combo = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_blood_decals"), options, 1)

	gameOption = GameOption:new('bloodDecals', combo)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionBloodDecals() + 1
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setOptionBloodDecals(box.selected-1)
		end
	end
	self.gameOptions:add(gameOption)

	----- FRAMERATE -----
    local framerate = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_framerate"), {"60", "45", "30"}, 1);

	gameOption = GameOption:new('framerate', framerate)
	function gameOption.toUI(self)
		local box = self.control
		local fps = getPerformance():getFramerate()
		if fps == 60 then
			box.selected = 1
		elseif fps == 45 then
			box.selected = 2
		elseif fps == 30 then
			box.selected = 3
		end
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setFramerate(box.selected)
		end
	end
	self.gameOptions:add(gameOption)

	----- TEXTURE COMPRESSION -----
	local map = {};
	map["defaultTooltip"] = getText("UI_optionscreen_texture_compress_tt");

    local texcompress;
    texcompress = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_texture_compress"), {getText("UI_Yes"), getText("UI_No")}, 1);
    texcompress:setToolTipMap(map);

	gameOption = GameOption:new('texcompress', texcompress)
	function gameOption.toUI(self)
		local box = self.control
		if getCore():getOptionTextureCompression() then
			box.selected = 1
		else
			box.selected = 2
		end
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setOptionTextureCompression(box.selected == 1)
		end
	end
	self.gameOptions:add(gameOption)

	----- DOUBLE SIZED -----
	local map = {};
	map["defaultTooltip"] = getText("UI_optionscreen_texture2x_tt");

    local doubleSize;
    doubleSize = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_texture2x"), {getText("UI_Yes"), getText("UI_No")}, 1);
    doubleSize:setToolTipMap(map);

	gameOption = GameOption:new('doubleSize', doubleSize)
	function gameOption.toUI(self)
		local box = self.control
		if getCore():getOptionTexture2x() then
			box.selected = 1
		else
			box.selected = 2
		end
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setOptionTexture2x(box.selected == 1)
		end
	end
	self.gameOptions:add(gameOption)

	----- LIGHTING QUALITY -----
    local lighting = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_lighting"), {getText("UI_High"), getText("UI_Medium"), getText("UI_Low"), getText("UI_Lowest")}, 1);

	gameOption = GameOption:new('lightingQuality', lighting)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getPerformance():getLightingQuality() + 1
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getPerformance():setLightingQuality(box.selected-1)
		end
	end
	self.gameOptions:add(gameOption)

	----- LIGHTING FPS -----
    local combo = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_lighting_fps"), {'5', '10', '15 (' .. getText("UI_optionscreen_recommended") .. ')', '20', '25', '30', '45', '60'}, 1)
    map = {}
	map["defaultTooltip"] = getText("UI_optionscreen_lighting_fps_tt")
	combo:setToolTipMap(map)

	gameOption = GameOption:new('lightingFPS', combo)
	function gameOption.toUI(self)
		local box = self.control
		local fps = getPerformance():getLightingFPS()
		local selected = 3
		if fps == 5 then selected = 1 end
		if fps == 10 then selected = 2 end
		if fps == 15 then selected = 3 end
		if fps == 20 then selected = 4 end
		if fps == 25 then selected = 5 end
		if fps == 30 then selected = 6 end
		if fps == 45 then selected = 7 end
		if fps == 60 then selected = 8 end
		box.selected = selected
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			-- handle (RECOMMENDED)
			local s = box.options[box.selected]
			local v = s:split(' ')
			getPerformance():setLightingFPS(tonumber(v[1]))
		end
	end
	self.gameOptions:add(gameOption)

	----- ZOOM ON/OFF -----
    local zoom = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_zoom"), {getText("UI_Yes"), getText("UI_No")}, 1)

	gameOption = GameOption:new('zoom', zoom)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionZoom() and 1 or 2
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setOptionZoom(box.selected == 1)
			getCore():zoomOptionChanged(MainScreen.instance.inGame)
		end
	end
	self.gameOptions:add(gameOption)

	----- ZOOM LEVELS -----
	label = ISLabel:new(splitpoint, y + self.addY, 20, getText("UI_optionscreen_zoomlevels"), 1, 1, 1, 1, UIFont.Small, false)
	label:initialise()
	self.mainPanel:addChild(label)
	local zoomLevelsTickBox = ISTickBox:new(splitpoint + 20, y + self.addY, 200, 20, "HELLO?")
	zoomLevelsTickBox.choicesColor = {r=1, g=1, b=1, a=1}
	zoomLevelsTickBox:initialise()
	local zoomLevels = getCore():getDefaultZoomLevels()
	for i = 1,zoomLevels:size() do
		local percent = zoomLevels:get(i-1)
		if percent ~= 100 then
			zoomLevelsTickBox:addOption(getText("IGUI_BackButton_Zoom", percent), tostring(percent))
		end
	end
	self.mainPanel:addChild(zoomLevelsTickBox)
	self.mainPanel:insertNewLineOfButtons(zoomLevelsTickBox)
	self.addY = self.addY + zoomLevelsTickBox:getHeight()

	gameOption = GameOption:new('zoomLevels', zoomLevelsTickBox)
	function gameOption.toUI(self)
		local box = self.control
		local percentsStr = (Core.getTileScale() == 2) and
			getCore():getOptionZoomLevels2x() or
			getCore():getOptionZoomLevels1x()
		local percents = luautils.split(percentsStr, ";")
		for i = 1,#box.options do
			box:setSelected(i, (#percents == 0) or self:tableContains(percents, box.optionData[i]))
		end
	end
	function gameOption.apply(self)
		local box = self.control
		local s = ""
		for i = 1,#box.options do
			if box:isSelected(i) then
				if s ~= "" then s = s .. ";" end
				s = s .. box.optionData[i]
			end
		end
		if Core.getTileScale() == 2 and s ~= getCore():getOptionZoomLevels2x() then
			getCore():setOptionZoomLevels2x(s)
			getCore():zoomLevelsChanged()
		elseif Core.getTileScale() == 1 and s ~= getCore():getOptionZoomLevels1x() then
			getCore():setOptionZoomLevels1x(s)
			getCore():zoomLevelsChanged()
		end
	end
	function gameOption.tableContains(self, table, item)
		for _,v in pairs(table) do
			if v == item then return true end
		end
		return false
	end
	self.gameOptions:add(gameOption)

	----- AUTO-ZOOM -----
	label = ISLabel:new(splitpoint, y + self.addY, 20, getText("UI_optionscreen_autozoom"), 1, 1, 1, 1, UIFont.Small, false)
	label:initialise()
	self.mainPanel:addChild(label)
	local autozoomTickBox = ISTickBox:new(splitpoint + 20, y + self.addY, 200, 20, "HELLO?")
	autozoomTickBox.choicesColor = {r=1, g=1, b=1, a=1}
	autozoomTickBox:initialise();
	for i = 1,4 do
		autozoomTickBox:addOption(getText("UI_optionscreen_player"..i), nil)
	end
	self.mainPanel:addChild(autozoomTickBox)
	self.mainPanel:insertNewLineOfButtons(autozoomTickBox)
	self.addY = self.addY + autozoomTickBox:getHeight()

	gameOption = GameOption:new('autoZoom', autozoomTickBox)
	function gameOption.toUI(self)
		local box = self.control
		for i = 1,4 do
			box:setSelected(i, getCore():getAutoZoom(i-1))
		end
	end
	function gameOption.apply(self)
		local box = self.control
		for i = 1,4 do
			getCore():setAutoZoom(i-1, box:isSelected(i))
		end
	end
	self.gameOptions:add(gameOption)

	----- INVENTORY FONT -----
	local invFont = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_inventory_font"), { getText("UI_optionscreen_Large"), getText("UI_optionscreen_Medium"), getText("UI_optionscreen_Small") }, 2)

	gameOption = GameOption:new('inventoryFont', invFont)
	function gameOption.toUI(self)
		local box = self.control
		if getCore():getOptionInventoryFont() == "Large" then
			box.selected = 1
		elseif getCore():getOptionInventoryFont() == "Small" then
			box.selected = 3
		else
			box.selected = 2
		end
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			local choices = { "Large", "Medium", "Small" }
			getCore():setOptionInventoryFont(choices[box.selected])
			if MainScreen.instance.inGame then
				ISInventoryPage.onInventoryFontChanged()
			end
		end
	end
	self.gameOptions:add(gameOption)

	----- CLOCK FORMAT -----
	local clockFmt = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_clock_format"), { getText("UI_optionscreen_clock_month_day"), getText("UI_optionscreen_clock_day_month") }, 1)

	gameOption = GameOption:new('clockFormat', clockFmt)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionClockFormat()
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setOptionClockFormat(box.selected)
		end
	end
	self.gameOptions:add(gameOption)

	----- CLOCK 24-HOUR -----
	local clock24 = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_clock_24_or_12"), { getText("UI_optionscreen_clock_24_hour"), getText("UI_optionscreen_clock_12_hour") }, 1)

	gameOption = GameOption:new('clock24hour', clock24)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionClock24Hour() and 1 or 2
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setOptionClock24Hour(box.selected == 1)
		end
	end
	self.gameOptions:add(gameOption)

    self.addY = self.addY - 6;

    self.objHighColor = ISButton:new(splitpoint + 20, y + self.addY + 8, 15,15,"", self, MainOptions.onObjHighlightColor);
    self.objHighColor:initialise();
    self.objHighColor.backgroundColor = {r = getCore():getObjectHighlitedColor():getR(), g = getCore():getObjectHighlitedColor():getG(), b = getCore():getObjectHighlitedColor():getB(), a = 1};
    self.mainPanel:addChild(self.objHighColor);

    local lbl = ISLabel:new(self.objHighColor.x + 20, y + self.addY, 30, getText("UI_optionscreen_objHighlightColor"), 1, 1, 1, 1, UIFont.Small, true);
    lbl:initialise();
    self.mainPanel:addChild(lbl);

    self.colorPicker2 = ISColorPicker:new(0, 0)
    self.colorPicker2:initialise()
    self.colorPicker2.pickedTarget = self
    self.colorPicker2.resetFocusTo = self
    self.colorPicker2:setInitialColor(getCore():getObjectHighlitedColor());

    self.addY = self.addY + 26;

	----- LANGUAGE -----
    local availableLanguage = MainOptions.getAvailableLanguage();
    local language = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_language"), availableLanguage, 1);
    language:setToolTipMap(MainOptions.doLanguageToolTip(availableLanguage));

	gameOption = GameOption:new('language', language)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = Translator.getLanguage():index() + 1
        self:onChange(box);
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			local languages = Translator.getAvailableLanguage()
			for i=1,languages:size() do
				if languages:get(i-1):text() == box.options[box.selected] then
					Translator.setLanguage(languages:get(i-1):index())
				end
			end
		end
    end
    function gameOption:onChange(box)
        local panel = MainOptions.instance.tabs:getActiveView();
        local oldH = panel:getScrollHeight()-MainOptions.instance.translatorPane:getHeight();
        local text = getText("UI_optionscreen_general_content").." "..getText("UI_optionscreen_translatedBy"):lower()..": \n";

        for k,v in ipairs(MainOptions.getGeneralTranslators(box.options[box.selected])) do
            text = text .. " - " .. v .. "\n";
        end
        --text = text .. getText("UI_optionscreen_radio_content").." "..getText("UI_optionscreen_translatedBy"):lower()..": \n";--..box.options[box.selected].."\n"; --box.selected .. " - " ..tostring(oldH) .."\n"
        --local names = nil;
        local languages = Translator.getAvailableLanguage()
        local curLang = nil;
        for i=1,languages:size() do
            if languages:get(i-1):text() == box.options[box.selected] then
                --local lang = languages:get(i-1);
                curLang = languages:get(i-1);
                --names = getRadioTranslators(languages:get(i-1)); --tries to read names from translation file, returns ArrayList<String>.
            end
        end
        text = text .. "\n" .. getText("UI_optionscreen_radio_content").." "..getText("UI_optionscreen_translatedBy"):lower()..": \n";
        local names = curLang and getRadioTranslators(curLang) or nil;
        if names and names:size()>0 then
            for i=1,names:size() do
                text = text .." - ".. names:get(i-1).."\n";
            end
        else
            text = text .. " - "..getText("UI_optionscreen_no_translators").." -\n";
        end
        if box.options[box.selected]=="English" then
            text = getText("UI_optionscreen_default_lang");
        end
        MainOptions.instance.translatorPane.text = text;
        --MainOptions.instance.translatorPane.text = "test \ntes test\n aaaa \naaa aa\ntest \ntes test\n aaaa \naaa aa\ntest tes test";
        MainOptions.instance.translatorPane:paginate();
        panel:setScrollHeight(oldH+MainOptions.instance.translatorPane:getHeight())
    end
	self.gameOptions:add(gameOption)

    local communityContentTickBox = ISTickBox:new(splitpoint + 20, y + self.addY, 200, 20, "HELLO?")
    communityContentTickBox.choicesColor = {r=1, g=1, b=1, a=1}
    communityContentTickBox:initialise();
    communityContentTickBox:addOption(getText("UI_optionscreen_tickbox_comlang"), nil)
    self.mainPanel:addChild(communityContentTickBox)
    self.mainPanel:insertNewLineOfButtons(communityContentTickBox)
    self.addY = self.addY + communityContentTickBox:getHeight()

    gameOption = GameOption:new('comlang', communityContentTickBox)
    function gameOption.toUI(self)
        local box = self.control
        box:setSelected(1, getCore():getContentTranslationsEnabled()); -- getCore():getAutoZoom(i-1))
    end
    function gameOption.apply(self)
        local box = self.control
        getCore():setContentTranslationsEnabled(box:isSelected(1))
    end
    self.gameOptions:add(gameOption)

    MainOptions.translatorPane = ISRichTextPanel:new (splitpoint+20, self.addY+22, comboWidth, 0);
    MainOptions.translatorPane:initialise();
    self.mainPanel:addChild(MainOptions.translatorPane);
    MainOptions.translatorPane:paginate();

    self.addY = self.addY+MainOptions.translatorPane:getHeight()+22;

	self.mainPanel:setScrollHeight(y + self.addY + 20)

	-----------------
	----- SOUND -----
	-----------------
	self:addPage(getText("UI_optionscreen_audio"))
	y = 20;
	self.addY = 0

	----- Sound VOLUME -----
	local control = self:addVolumeControl(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_sound_volume"), 0)
	gameOption = GameOption:new('soundVolume', control)
	function gameOption.toUI(self)
		local volume = getCore():getOptionSoundVolume()
		volume = math.min(10, math.max(0, volume))
		self.control:setVolume(volume)
	end
	function gameOption.apply(self)
		getCore():setOptionSoundVolume(self.control:getVolume())
	end
	self.gameOptions:add(gameOption)

	----- MUSIC VOLUME -----
	local control = self:addVolumeControl(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_music_volume"), 0)
	gameOption = GameOption:new('musicVolume', control)
	function gameOption.toUI(self)
		local volume = getCore():getOptionMusicVolume()
		volume = math.min(10, math.max(0, volume))
		self.control:setVolume(volume)
	end
	function gameOption.apply(self)
		getCore():setOptionMusicVolume(self.control:getVolume())
	end
	self.gameOptions:add(gameOption)

    ----- AMBIENT VOLUME -----
    local control = self:addVolumeControl(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_ambient_volume"), 0)
    gameOption = GameOption:new('ambientVolume', control)
    function gameOption.toUI(self)
        local volume = getCore():getOptionAmbientVolume()
        volume = math.min(10, math.max(0, volume))
        self.control:setVolume(volume)
    end
    function gameOption.apply(self)
        getCore():setOptionAmbientVolume(self.control:getVolume())
    end
    self.gameOptions:add(gameOption)

	----- MUSIC LIBRARY -----
	local combo = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_music_library"), { getText("UI_optionscreen_music_library_1"), getText("UI_optionscreen_music_library_2"), getText("UI_optionscreen_music_library_3")}, 1)
	gameOption = GameOption:new('musicLibrary', combo)
	function gameOption.toUI(self)
		local box = self.control
		local library = getCore():getOptionMusicLibrary()
		box.selected = math.min(3, math.max(1, library))
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setOptionMusicLibrary(box.selected)
		end
	end
	self.gameOptions:add(gameOption)

	----- CURRENT MUSIC -----
	local musicLbl = ISLabel:new(splitpoint, y + self.addY, 20, getText("UI_optionscreen_music_track1"), 1, 1, 1, 1, UIFont.Small, false);
--	musicLbl:setAnchorRight(true)
	musicLbl:initialise();
	self.mainPanel:addChild(musicLbl);

	self.currentMusicLabel = ISLabel:new(splitpoint + 20, y + self.addY, 20, "", 1, 1, 1, 1, UIFont.Small, true);
	self.currentMusicLabel:initialise();
	self.mainPanel:addChild(self.currentMusicLabel);
	self.addY = self.addY + 26

	----- HEARTBEAT VOLUME -----
	local control = self:addVolumeControl(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_heart_volume"), 0)
	control.tooltip = getText("UI_optionscreen_heart_volume_tt");
	gameOption = GameOption:new('heartVolume', control)
	function gameOption.toUI(self)
		local volume = getCore():getOptionHeartVolume()
		volume = math.min(10, math.max(0, volume))
		self.control:setVolume(volume)
	end
	function gameOption.apply(self)
		getCore():setOptionHeartVolume(self.control:getVolume())
	end
	self.gameOptions:add(gameOption)

	----- RakVoice -----
	local voiceEnable = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_voiceEnable"), {getText("UI_Yes"), getText("UI_No")}, 1)
	gameOption = GameOption:new('voiceEnable', voiceEnable)
	function gameOption.toUI(self)
		local box = self.control
		if getCore():getOptionVoiceEnable() then
			box.selected = 1
		else
			box.selected = 2
		end
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setOptionVoiceEnable(box.selected == 1)
		end
	end
	self.gameOptions:add(gameOption)

	local listrecorddevices = VoiceManager:RecordDevices();
	local voiceRecordDevice = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_voiceRecordDevice"), listrecorddevices, 0)
	gameOption = GameOption:new('voiceRecordDevice', voiceRecordDevice)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionVoiceRecordDevice()
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionVoiceRecordDevice(box.selected)
	end
	self.gameOptions:add(gameOption)

	local voiceMode = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_voiceMode"), {getText("UI_PPT"), getText("UI_VAD"), getText("UI_Mute")}, 1)
	gameOption = GameOption:new('voiceMode', voiceMode)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionVoiceMode()
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionVoiceMode(box.selected)
	end
	self.gameOptions:add(gameOption)

--    self.voipKey = ISLabel:new(splitpoint + 20, y + self.addY, 20, getText("UI_PPT_Key", getCore():getKey("Enable voice transmit")), 1, 1, 1, 1, UIFont.Small, true);
--    self.voipKey:initialise();
--    self.mainPanel:addChild(self.voipKey);
--    self.addY = self.addY + 26;

	local voiceVADMode = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_voiceVADMode"), {getText("UI_VADMode1_Quality"), getText("UI_VADMode2_LowBitrate"), getText("UI_VADMode3_Aggressive"), getText("UI_VADMode4_VeryAggressive")}, 1)
	gameOption = GameOption:new('voiceVADMode', voiceVADMode)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionVoiceVADMode()
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionVoiceVADMode(box.selected)
	end
	self.gameOptions:add(gameOption)

	local voiceVolumeMic = self:addMegaVolumeControl(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_voiceVolumeMic"), 0)
	voiceVolumeMic.tooltip = getText("UI_optionscreen_voiceVolumeMic_tt");
	gameOption = GameOption:new('voiceVolumeMic', voiceVolumeMic)
	function gameOption.toUI(self)
		local volume = getCore():getOptionVoiceVolumeMic()
		volume = math.min(11, math.max(0, volume))
		self.control:setVolume(volume)
	end
	function gameOption.apply(self)
		getCore():setOptionVoiceVolumeMic(self.control:getVolume())
	end
	self.gameOptions:add(gameOption)


	local voiceVolumeMicIndicator = self:addVolumeIndicator(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_voiceVolumeMicIndicator"), 0)
	voiceVolumeMicIndicator.tooltip = getText("UI_optionscreen_voiceVolumeMicIndicator_tt");

	local voiceVolumePlayers = self:addMegaVolumeControl(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_voiceVolumePlayers"), 0)
	voiceVolumePlayers.tooltip = getText("UI_optionscreen_voiceVolumePlayers_tt");
	gameOption = GameOption:new('voiceVolumePlayers', voiceVolumePlayers)
	function gameOption.toUI(self)
		local volume = getCore():getOptionVoiceVolumePlayers()
		volume = math.min(11, math.max(0, volume))
		self.control:setVolume(volume)
	end
	function gameOption.apply(self)
		getCore():setOptionVoiceVolumePlayers(self.control:getVolume())
	end
	self.gameOptions:add(gameOption)

    y = y + self.addY;

--    local label = ISLabel:new(splitpoint - 1, y, 20, "Mods folder", 1, 1, 1, 1, UIFont.Small, false);
--    label:initialise();
--    self.mainPanel:addChild(label);
--
--    self.modSaveTxt = ISTextEntryBox:new(getCore():getSaveFolder(), splitpoint + 20, y, self:getWidth()-splitpoint - 240, 20);
--    self.modSaveTxt:initialise();
--    self.modSaveTxt:instantiate();
--    self.modSaveTxt:setAnchorLeft(true);
--    self.modSaveTxt:setAnchorRight(true);
--    self.modSaveTxt:setAnchorTop(true);
--    self.modSaveTxt:setAnchorBottom(false);
--    self.mainPanel:addChild(self.modSaveTxt);

	MainOptions.loadKeys();
	--
	self:addPage(getText("UI_optionscreen_keybinding"))
	y = 5;

	local keyTextElement = nil;
	local x = MainOptions.keyBindingLength + 30;
	local left = true;
	for i,v in ipairs(MainOptions.keys) do
		keyTextElement = {};

		if luautils.stringStarts(v.value, "[") then
			y = y + 15;
			if not left then
				y = y + 20;
				left = true
			end
			local label = ISLabel:new(100, y, 30, getText("UI_optionscreen_binding_" .. v.value:gsub("%[", ""):gsub("%]", "")), 1, 1, 1, 1, UIFont.Medium);
			label:setX(50);
			label:initialise();
			label:setAnchorRight(true);
			self.mainPanel:addChild(label);

			keyTextElement.value = v.value;
			table.insert(MainOptions.keyText, keyTextElement);

			x = MainOptions.keyBindingLength + 30;
			y = y + 35;
		else

--            print("UI_optionscreen_binding_" .. v.value .. " = \" " .. v.value .. "\",");
			local splitpoint = self:getWidth() / 2 ;
			local label = ISLabel:new(x, y, 20, v.value, 1, 1, 1, 1, UIFont.Small);
			label:initialise();
			label:setAnchorLeft(false)
			label:setAnchorRight(true);
            label:setTranslation(getText("UI_optionscreen_binding_" .. v.value));
			self.mainPanel:addChild(label);

			local btn = ISButton:new(x + 10, y + 2, 120, 18, Keyboard.getKeyName(tonumber(v.key)), self, MainOptions.onKeyBindingBtnPress);
			btn.internal = v.value;
			btn:initialise();
			btn:instantiate();
--~ 			btn:setAnchorRight(true);
			self.mainPanel:addChild(btn);

			keyTextElement.txt = label;
			keyTextElement.btn = btn;
			keyTextElement.left = left
			table.insert(MainOptions.keyText, keyTextElement);

			if x > MainOptions.keyBindingLength + 30 then
				x = MainOptions.keyBindingLength + 30;
				y = y + 20;
				left = true;
			else
				x = splitpoint + MainOptions.keyBindingLength + 30;
				left = false;
			end
		end
    end
    y = y + 30;
    local toggleToRunTickbox = ISTickBox:new(35, y, 200, 20, "HELLO?")
    toggleToRunTickbox.choicesColor = {r=1, g=1, b=1, a=1}
    toggleToRunTickbox:initialise()
    toggleToRunTickbox:addOption(getText("IGUI_ToggleToRun",  Keyboard.getKeyName(getCore():getKey("Run"))))
    self.mainPanel:addChild(toggleToRunTickbox)
    self.mainPanel:insertNewLineOfButtons(toggleToRunTickbox)
	self.mainPanel:setScrollHeight(y + 50);

    gameOption = GameOption:new('toggleToRun', toggleToRunTickbox)
    function gameOption.toUI(self)
        local box = self.control
        box:setSelected(1,getCore():isToggleToRun())
    end
    function gameOption.apply(self)
        local box = self.control
        getCore():setToggleToRun(box.selected[1])
    end
    self.gameOptions:add(gameOption)

	----- CONTROLLER -----
	self:addPage(getText("UI_optionscreen_controller"))
	y = 20;
	x = 64

	label = ISLabel:new(x, y, 20, getText("UI_optionscreen_controller_tip"), 1, 1, 1, 1, UIFont.Small, true)
	label:initialise()
	self.mainPanel:addChild(label)

    local controllerTickBox = ISTickBox:new(x + 20, label:getY() + label:getHeight() + 10, 200, 20, "HELLO?")
    controllerTickBox.choicesColor = {r=1, g=1, b=1, a=1}
    controllerTickBox:initialise();
	self.mainPanel:insertNewLineOfButtons(controllerTickBox)
    self.mainPanel:addChild(controllerTickBox)
	for i = 0, getControllerCount()-1 do
		local name = getControllerName(i)
		controllerTickBox:addOption(name, nil)
	end

	gameOption = GameOption:new('controllers', controllerTickBox)
	function gameOption.toUI(self)
		local box = self.control
		for i = 1,getControllerCount() do
			local name = getControllerName(i-1)
			local active = getCore():getOptionActiveController(name)
			box:setSelected(i, active)
		end
	end
	function gameOption.apply(self)
		local box = self.control
		for i = 1,getControllerCount() do
			getCore():setOptionActiveController(i-1, box:isSelected(i))
		end
	end
	self.gameOptions:add(gameOption)

    y = controllerTickBox:getY() + controllerTickBox:getHeight()

	local btn = ISButton:new(x, y + 10, 120, 20, getText("UI_optionscreen_controller_reload"), self, MainOptions.ControllerReload)
	btn:initialise()
	btn:instantiate()
	self.mainPanel:insertNewLineOfButtons(btn)
	self.mainPanel:addChild(btn)

	local panel = ISControllerTestPanel:new(self.width / 2, 20, (self.width - 64 - (self.width / 2)), self.mainPanel.height - 20 - 20)
	panel:setAnchorRight(true)
	panel:setAnchorBottom(true)
	panel.drawBorder = true
	panel:initialise()
	self.mainPanel:addChild(panel)
	self.controllerTestPanel = panel

    ----- RELOADING -----
	self:addPage(getText("UI_optionscreen_reloading"))
	y = 20;

	self.addY = 0
    --local difficulties = {getText("UI_optionscreen_easy"), getText("UI_optionscreen_normal"), getText("UI_optionscreen_hardcore")};--> Stormy
		local difficulties = {"forced by server!"}
	MainOptions.reloadLabel = ISLabel:new(self.width / 3 - 150, y, 20, '', 1, 1, 1, 1, UIFont.Small);--> Stormy
	self.mainPanel:addChild(MainOptions.reloadLabel);--> Stormy
	local difficultyCombo = self:addCombo(splitpoint, y + 50, comboWidth, 20, getText("UI_optionscreen_reloadDifficulty"), difficulties, 1);--> Stormy

	gameOption = GameOption:new('reloadDifficulty', difficultyCombo)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionReloadDifficulty()
		MainOptions.instance.reloadLabel.name = ReloadManager[1]:getDifficultyDescription(box.selected):gsub("\\n", "\n")
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setOptionReloadDifficulty(box.selected)
		end
	end
	function gameOption:onChange(box)
		MainOptions.instance.reloadLabel.name = ReloadManager[1]:getDifficultyDescription(box.selected):gsub("\\n", "\n")
	end
	self.gameOptions:add(gameOption)

	----- RACKING PROGRESS -----
	local combo = self:addCombo(splitpoint, y + 50, comboWidth, 20, getText("UI_optionscreen_rack_progress"), {getText("UI_Yes"), getText("UI_No")}, 1)
	local map = {};
	map["defaultTooltip"] = getText("UI_optionscreen_rack_progress_tt");
	combo:setToolTipMap(map);

	gameOption = GameOption:new('rackProgress', combo)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionRackProgress() and 1 or 2
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setOptionRackProgress(box.selected == 1)
		end
	end
	self.gameOptions:add(gameOption)


--    local rect = ISRect:new(30, y + 22, self:getWidth() - 60, 1, 1, 0.3, 0.3, 0.3);
--    rect:initialise();
--    rect:setAnchorRight(true);
--    self.mainPanel:addChild(rect);

   -- local joypad = {"Yes", "No"};--> Stormy
   -- local joypadCombo = self:addCombo(splitpoint, y - 60, self:getWidth()-splitpoint - 100, 20, "Joypad", joypad, 2, self, MainOptions.JoypadChange);--> Stormy

    self:addPage(getText("UI_optionscreen_multiplayer"))

    self.addY = 0;

    local showUsernameTickbox = ISTickBox:new(splitpoint + 20, y + self.addY, 200, 20, "");
    showUsernameTickbox.choicesColor = {r=1, g=1, b=1, a=1};
    showUsernameTickbox:initialise();
    showUsernameTickbox:addOption(getText("UI_optionscreen_showUsername"), getText("UI_optionscreen_showUsername"));
    showUsernameTickbox.tooltip = getText("UI_optionscreen_showUsernameTooltip");
    self.mainPanel:addChild(showUsernameTickbox);
    self.mainPanel:insertNewLineOfButtons(showUsernameTickbox);
    self.addY = self.addY + showUsernameTickbox:getHeight();
    gameOption = GameOption:new('showUsername', showUsernameTickbox)
    function gameOption.toUI(self)
        local box = self.control;
        local selected = true;
        box:setSelected(1, getCore():isShowYourUsername());
    end
    function gameOption.apply(self)
        local box = self.control;
        getCore():setShowYourUsername(box:isSelected(1));
    end
    function gameOption.tableContains(self, table, item)
        for _,v in pairs(table) do
            if v == item then return true end
        end
        return false
    end
    self.gameOptions:add(gameOption)


    self.mpColor = ISButton:new(splitpoint + 20, y + self.addY + 8, 15,15,"", self, MainOptions.onMPColor);
    self.mpColor:initialise();
    self.mpColor.backgroundColor = {r = getCore():getMpTextColor():getR(), g = getCore():getMpTextColor():getG(), b = getCore():getMpTextColor():getB(), a = 1};
    self.mainPanel:addChild(self.mpColor);

    local lbl = ISLabel:new(self.mpColor.x + 20, y + self.addY, 30, getText("UI_optionscreen_personalTextColor"), 1, 1, 1, 1, UIFont.Small, true);
    lbl:initialise();
    self.mainPanel:addChild(lbl);

    self.colorPicker = ISColorPicker:new(0, 0)
    self.colorPicker:initialise()
    self.colorPicker.pickedTarget = self
    self.colorPicker.resetFocusTo = self
    self.colorPicker:setInitialColor(getCore():getMpTextColor());

	self:setVisible(false);

end

function MainOptions:onObjHighlightColor(button)
    self.colorPicker2:setX(100)
    self.colorPicker2:setY(100)
    self.colorPicker2.pickedFunc = MainOptions.pickedObjHighlightColor;
    self.colorPicker2:setInitialColor(getCore():getObjectHighlitedColor());
    self:addChild(self.colorPicker2)
    self.colorPicker2:setVisible(true);
    self.colorPicker2:bringToTop();
end

function MainOptions:onMPColor(button)
    self.colorPicker:setX(button:getX() - self.colorPicker:getWidth())
    self.colorPicker:setY(button:getY() + button:getHeight())
    self.colorPicker.pickedFunc = MainOptions.pickedMPTextColor;
    self.colorPicker:setInitialColor(getCore():getMpTextColor());
    self:addChild(self.colorPicker)
    self.colorPicker:bringToTop();
end

function MainOptions:pickedObjHighlightColor(color, mouseUp)
    MainOptions.instance.objHighColor.backgroundColor = { r=color.r, g=color.g, b=color.b, a = 1 }
    getCore():setObjectHighlitedColor(ColorInfo.new(color.r, color.g, color.b,1));
end

function MainOptions:pickedMPTextColor(color, mouseUp)
    MainOptions.instance.mpColor.backgroundColor = { r=color.r, g=color.g, b=color.b, a = 1 }
    getCore():setMpTextColor(ColorInfo.new(color.r, color.g, color.b,1));
    if isClient() and MainScreen.instance.inGame then
        getPlayer():setSpeakColourInfo(getCore():getMpTextColor());
        sendPersonalColor(getPlayer());
    end
end

function MainOptions:toUI()
	self.gameOptions:toUI()
end

function MainOptions:showConfirmDialog()
	if not self.gameOptions.changed then return false end

	self.tabs:setVisible(false)
	self.backButton:setVisible(false)
	self.acceptButton:setVisible(false)
	self.saveButton:setVisible(false)

	local w,h = 350,120
	self.modal = ISModalDialog:new((getCore():getScreenWidth() / 2) - w / 2,
		(getCore():getScreenHeight() / 2) - h / 2, w, h,
		getText("UI_optionscreen_ConfirmPrompt"), true, self, MainOptions.onConfirmModalClick);
	self.modal:initialise()
	self.modal:setCapture(true)
	self.modal:setAlwaysOnTop(true)
	self.modal:addToUIManager()
	if self.joyfocus then
		self.joyfocus.focus = self.modal
		updateJoypadFocus(self.joyfocus)
	end
	return true
end

function MainOptions:onConfirmModalClick(button)
	self.tabs:setVisible(true)
	self.backButton:setVisible(true)
	self.acceptButton:setVisible(true)
	self.saveButton:setVisible(true)
	self.modal = nil
	if button.internal == "YES" then
		self:apply()
		self:close()
	else
		self.gameOptions.changed = false
		self:onOptionMouseDown(self.backButton, 0, 0)
	end
end

function MainOptions.sortModes(a, b)
	-- Need to handle the (RECOMMENED) string here
	local ax, ay = string.match(a, '(%d+) x (%d+)')
	local bx, by = string.match(b, '(%d+) x (%d+)')
	ax = tonumber(ax)
	ay = tonumber(ay)
	bx = tonumber(bx)
	by = tonumber(by)
	if ax < bx then return true end
	if ax > bx then return false end
	return ay < by
end

function MainOptions:onMouseWheel(del)
	local panel = self.tabs:getActiveView()
	panel:setYScroll(panel:getYScroll() - (del * 40));
	return true;
end


function MainOptions.loadKeys()
	getCore():reinitKeyMaps()
	MainOptions.keys = {}
	MainOptions.keyBindingLength = 0
	local knownKeys = {}
	-- keyBinding comes from keyBinding.lua
	for i=1, #keyBinding do
		bind = {}
		bind.key = keyBinding[i].key
		bind.value = keyBinding[i].value
		if not luautils.stringStarts(keyBinding[i].value, "[") then
			-- we add the key binding to the core (java side), so the game will know the key
            local bindNbr = tonumber(bind.key);
            if getCore():isAzerty() then -- doing azerrty special keyboard, a=q, etc...
                if  bind.value == "Left" then
                    bindNbr = 16;
                elseif bind.value == "Forward" then
                    bindNbr = 44;
                elseif bind.value == "Shout" then
                    bindNbr = 30;
                end
            end
            getCore():addKeyBinding(bind.value, bindNbr)
            bind.key = bindNbr;
            table.insert(MainOptions.keys, bind)
            if getTextManager():MeasureStringX(UIFont.Small, bind.value) > MainOptions.keyBindingLength then
				MainOptions.keyBindingLength = getTextManager():MeasureStringX(UIFont.Small, bind.value)
			end
			knownKeys[bind.value] = bind
        else
            table.insert(MainOptions.keys, bind)
        end
	end

	-- the true boolean is to create the file is it doesn't exist
	local keyFile = getFileReader("keys.ini", true);
	-- we fetch our file to bind our keys (load the file)
	local line = nil;
	-- we read each line of our file
	while true do
		line = keyFile:readLine();
		if line == nil then
			keyFile:close();
			break;
		end
		if not luautils.stringStarts(line, "[") then
			local splitedLine = string.split(line, "=")
			local name = splitedLine[1]
			local key = tonumber(splitedLine[2])
			-- ignore obsolete bindings, override the default key
			if knownKeys[name] then
				knownKeys[name].key = key
				getCore():addKeyBinding(name, key)
			end
		end
	end
end

function MainOptions:prerender()
	ISPanelJoypad.prerender(self);

--	self.mainPanel:setY(self:getYScroll());
--~ 	self.mainPanel:setStencilRect(0,self:getYScroll() + self.mainPanel:getY(),600,300);
--~ 	self:drawRect(0, -self.mainPanel:getYScroll(), self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
--~ 	self.mainPanel:setY(self.mainPanel:getYScroll());
--~ 	self:drawTextCentre("GAME OPTIONS", self.width / 2, 10, 1, 1, 1, 1, UIFont.Large);
--~ 	self:drawText("Display", 30, 60, 1, 1, 1, 1, UIFont.Medium);
--~ 	self:drawRect(30, 80, self.width - 60, 1, 1, 1, 1, 1);
--~ 	self:drawText("Key Bindings", 30, 180, 1, 1, 1, 1, UIFont.Medium);
--~ 	self:drawRect(30, 200, self.width - 60, 1, 1, 1, 1, 1);
--~ 	self:drawText("Reloading", 30, 600, 1, 1, 1, 1, UIFont.Medium); --> Stormy
--~ 	self:drawRect(30, 620, self.width - 60, 1, 1, 1, 1, 1); --> Stormy

	self.saveButton:setEnable(self.gameOptions.changed)
end

function MainOptions:render()
	-- render the change key binding rect
	if MainOptions.keyPress and not MainOptions.alreadySetKeyName then
		self:drawRect(0, -self:getYScroll(), self.width, self.height, 0.18, 1, 1, 1);
		self:drawTextCentre(getText("UI_optionscreen_pressKeyToBind", getText("UI_optionscreen_binding_" .. MainOptions.keyPress)), self.width / 2, (self.height / 2) + (-self:getYScroll()), 1, 1, 1, 1, UIFont.Large);
	end
	-- if we got an error on the key pressed
--	if MainOptions.alreadySetKeyName then
--		self:drawTextCentre(getText("UI_optionscreen_keyAlreadyBinded", MainOptions.alreadySetKeyValue, MainOptions.alreadySetKeyName), self.width / 2, (self.height / 2) + 20 + (-self:getYScroll()), 1, 0, 0, 1, UIFont.Large);
--    end
	--self.mainPanel:clearStencilRect();

	local currentMusic = getSoundManager():getCurrentMusicName()
	if currentMusic then
		local library
		if getSoundManager():getCurrentMusicLibrary() == "official" then
			library = getText("UI_optionscreen_music_library_1")
		else
			library = getText("UI_optionscreen_music_library_2")
		end
		-- TODO: translate filename to full title once Zach names them
		self.currentMusicLabel.name = getText("UI_optionscreen_music_track2", currentMusic:gsub('.ogg', ''), library)
	else
		self.currentMusicLabel.name = ''
	end
end

function MainOptions:onKeyBindingBtnPress(button, x, y)
	MainOptions.keyPress = button.internal;
end

function MainOptions:onOptionMouseDown(button, x, y)
	-- if we back we gonna reinit all our key binding
	if button.internal == "BACK" then
		if self:showConfirmDialog() then
			return
		end
		MainOptions.loadKeys();
		for o,l in ipairs(MainOptions.keyText) do
			-- text
			if not l.value then
				l.btn:setTitle(Keyboard.getKeyName(tonumber(MainOptions.keys[o].key)));
			end
		end
		self:close()
	elseif button.internal == "ACCEPT" then
		self:apply()
		self:close()
	elseif button.internal == "SAVE" then
		self:apply()
	end
end

function MainOptions:apply()
	getCore():reinitKeyMaps()
	-- we erase our previous file (by setting the append boolean to false);
	local fileOutput = getFileWriter("keys.ini", true, false)
	for i,v in ipairs(MainOptions.keyText) do
		-- if it's a label (like [Player Controls])
		if v.value then
			fileOutput:write(v.value .. "\r\n")
		else
			fileOutput:write(v.txt:getName() .. "=" .. Keyboard.getKeyIndex(v.btn:getTitle()) .. "\r\n")
			getCore():addKeyBinding(v.txt:getName(), tonumber(Keyboard.getKeyIndex(v.btn:getTitle())))
		end
	end
	fileOutput:close()

	self.gameOptions:apply()
	getCore():saveOptions()
	self.gameOptions:toUI()
end

function MainOptions:close()
	JoypadState.controllerTest = nil
	self:setVisible(false)
	MainScreen.instance.bottomPanel:setVisible(true)
	if self.joyfocus then
		self.joyfocus.focus = MainScreen.instance
		updateJoypadFocus(self.joyfocus)
	end
end

function MainOptions.keyPressHandler(key)
	if key == 1 then-- if pressed escape, we cancel key binding
		MainOptions.keyPress = nil;
		MainOptions.alreadySetKeyName = nil;
	end
	if MainOptions.keyPress and key > 0 then
		MainOptions.alreadySetKeyName = nil;
		MainOptions.alreadySetKeyValue = nil;
		local keyBinded = nil;
		local error = false;
		for i,v in ipairs(MainOptions.keyText) do
			-- we ignore label (like [Player Control])
			if not v.value then
				if v.txt:getName() == MainOptions.keyPress then -- get our current btn pressed
					keyBinded = v.btn;
				elseif Keyboard.getKeyName(key) == v.btn:getTitle() then -- if the key you pressed is the same as another
                    MainOptions.alreadySetKeyName = v.txt:getName();
                    MainOptions.alreadySetKeyValue = v.btn:getTitle();
                    local modal = ISModalDialog:new((getCore():getScreenWidth() / 2) - 200, (getCore():getScreenHeight()/2) - 100, 400, 200, getText("UI_optionscreen_keyAlreadyBinded", MainOptions.alreadySetKeyValue, getText("UI_optionscreen_binding_" .. MainOptions.alreadySetKeyName)) .. ". " .. getText("UI_optionscreen_replaceKey"), true, MainOptions.instance, MainOptions.onReplaceKey, nil, key, v.btn)
                    modal:initialise();
                    modal:addToUIManager();
--                    MainOptions.keyPress = nil;
					error = true;
					break;
				end
			end
		end
		if not error then
			keyBinded:setTitle(Keyboard.getKeyName(key));
			MainOptions.keyPress = nil;
			MainOptions.instance.gameOptions.changed = true
		end
	end
end

function MainOptions:onReplaceKey(button, key, keyBindedBtn)
    local newBindedKey = nil;
    for i,v in ipairs(MainOptions.keyText) do
        -- we ignore label (like [Player Control])
        if not v.value then
            if v.txt:getName() == MainOptions.keyPress then -- get our current btn pressed
                newBindedKey = v.btn;
            end
        end
    end

    if button.internal == "YES" then
        keyBindedBtn:setTitle(newBindedKey.title);
        newBindedKey:setTitle(Keyboard.getKeyName(key))
        MainOptions.instance.gameOptions.changed = true;
    end
    MainOptions.keyPress = nil;
    MainOptions.alreadySetKeyValue = nil;
    MainOptions.alreadySetKeyName = nil;
end

function MainOptions.doLanguageToolTip(languages)
    local tooltipLanguages = {};
    tooltipLanguages["defaultTooltip"] = getText("UI_optionscreen_needreboot");
    return tooltipLanguages;
end
--MainOptions.getGeneralTranslators(box.options[box.selected])
function MainOptions.getGeneralTranslators(_language)
    if _language == "Francais" then
        return {"Bret","Legumanigo","Peanuts","Marmotte971","Nyoshi","CareBearCorpse","Teesee","Furthick"};
    elseif _language == "Deutsch" then
        return {"RoboMat","Lakorta","Dahugo","Addy","Tuto","Houy Gaming"};
    elseif _language == "Russian" then
        return {"Lev Ivanov","lordixi","Adapt","ArionWT","Konrad Knox"};
    elseif _language == "Norsk" then
        return {"Hans Morgenstierne"};
    elseif _language == "Espanol (ES)" then
        return {"ditoseadio"}; -- removed "RetardedUser","Kalamar","Danny-Dynamita","Pagoru"
    elseif _language == "Italiano" then
        return {"Simone \"fox\" Volpini","Mattia \"d00de\" Geretti"};
    elseif _language == "Polish" then
        return {"Geras","Lord_Venom","adios_1984","Szary_Optymista","Th3FatPanda","Siarczek","pdjakow","voythas","Zorak","Spazmatic","welniok","Svarog","Insers"};
    elseif _language == "Nederlands" then
        return {"Massivekills (Kevin Heuvink)","Raymundo46"};
    elseif _language == "Afrikaans" then
        return {"PsychoEliteNZ (Adrian Jansen)","Viceroy (Stephanus Siebrits Cilliers van Zyl)"};
    elseif _language == "Czech" then
        return {"Jiri \"Rsa Viper\" Prochazka"};
    elseif _language == "Danish" then
        return {"A. Gade"};
    elseif _language == "Portuguese" then
        return {"Penedus"};
    elseif _language == "Turkish" then
        return {"DemirHerif"};
    elseif _language == "Hungarian" then
        return {"sandor.baliko"};
    elseif _language == "Japanese" then
        return {"UENO \"Katzengarten\" Masahiro","Koichi \"Falcon33jp\" Takebe"};
    elseif _language == "Korean" then
        return {"clarke","daden","djcide(tannoy)","ingyer","yoongoon","zepaedori "};
    elseif _language == "Brazilian Portuguese" then
        return {"HiveFuse"};
    elseif _language == "Simplified Chinese" then
        return {"Sky_Orc_Mm"};
    elseif _language == "Thai" then
        return {"Artdekdok"};
    end
    return {getText("UI_optionscreen_no_translators")};
end
--[[
function MainOptions.doLanguageToolTip(languages)
	local tooltipLanguages = {};
	for i,v in pairs(languages) do
		if v == "Francais" then
			tooltipLanguages[v] = getText("UI_optionscreen_needreboot") .. " <LINE> " .. getText("UI_optionscreen_translatedBy") .. " : Bret, Legumanigo, Peanuts, Marmotte971, Nyoshi, CareBearCorpse";
		elseif v == "Deutsch" then
			tooltipLanguages[v] = getText("UI_optionscreen_needreboot") .. " <LINE>  " .. getText("UI_optionscreen_translatedBy") .. " : RoboMat, Lakorta, Dahugo, Addy, Tuto, Houy Gaming";
		elseif v == "Russian" then
			tooltipLanguages[v] = getText("UI_optionscreen_needreboot") .. " <LINE>  " .. getText("UI_optionscreen_translatedBy") .. " : Lev Ivanov, lordixi, Adapt, ArionWT, Konrad Knox";
		elseif v == "Norsk" then
			tooltipLanguages[v] = getText("UI_optionscreen_needreboot") .. " <LINE>  " .. getText("UI_optionscreen_translatedBy") .. " : Hans Morgenstierne";
		elseif v == "Espanol (ES)" then
			tooltipLanguages[v] = getText("UI_optionscreen_needreboot") .. " <LINE>  " .. getText("UI_optionscreen_translatedBy") .. " : RetardedUser, Kalamar, Danny-Dynamita, Pagoru, ditoseadio";
		elseif v == "Italiano" then
			tooltipLanguages[v] = getText("UI_optionscreen_needreboot") .. " <LINE>  " .. getText("UI_optionscreen_translatedBy") .. " : Simone \"fox\" Volpini, Mattia \"d00de\" Geretti";
		elseif v == "Polish" then
			tooltipLanguages[v] = getText("UI_optionscreen_needreboot") .. " <LINE>  " .. getText("UI_optionscreen_translatedBy") .. " : adios_1984, Lord_Venom, Szary_Optymista, Krzysztof \"Geras\" Klaja";
		elseif v == "Nederlands" then
			tooltipLanguages[v] = getText("UI_optionscreen_needreboot") .. " <LINE>  " .. getText("UI_optionscreen_translatedBy") .. " : Massivekills (Kevin Heuvink), Raymundo46";
		elseif v == "Afrikaans" then
			tooltipLanguages[v] = getText("UI_optionscreen_needreboot") .. " <LINE>  " .. getText("UI_optionscreen_translatedBy") .. " : PsychoEliteNZ (Adrian Jansen), Viceroy (Stephanus Siebrits Cilliers van Zyl)";
		elseif v == "Czech" then
			tooltipLanguages[v] = getText("UI_optionscreen_needreboot") .. " <LINE>  " .. getText("UI_optionscreen_translatedBy") .. " : Jiri \"Rsa Viper\" Prochazka";
		elseif v == "Danish" then
			tooltipLanguages[v] = getText("UI_optionscreen_needreboot") .. " <LINE>  " .. getText("UI_optionscreen_translatedBy") .. " : A. Gade";
		elseif v == "Portuguese" then
			tooltipLanguages[v] = getText("UI_optionscreen_needreboot") .. " <LINE>  " .. getText("UI_optionscreen_translatedBy") .. " : Penedus";
        elseif v == "Turkish" then
            tooltipLanguages[v] = getText("UI_optionscreen_needreboot") .. " <LINE>  " .. getText("UI_optionscreen_translatedBy") .. " : DemirHerif";
        elseif v == "Hungarian" then
            tooltipLanguages[v] = getText("UI_optionscreen_needreboot") .. " <LINE>  " .. getText("UI_optionscreen_translatedBy") .. " : sandor.baliko";
        elseif v == "Japanese" then
            tooltipLanguages[v] = getText("UI_optionscreen_needreboot") .. " <LINE>  " .. getText("UI_optionscreen_translatedBy") .. " : UENO \"Katzengarten\" Masahiro, Koichi \"Falcon33jp\" Takebe";
        elseif v == "Korean" then
            tooltipLanguages[v] = getText("UI_optionscreen_needreboot") .. " <LINE>  " .. getText("UI_optionscreen_translatedBy") .. " : clarke, daden, djcide(tannoy), ingyer, yoongoon, zepaedori ";
        elseif v == "Brazilian Portuguese" then
            tooltipLanguages[v] = getText("UI_optionscreen_needreboot") .. " <LINE>  " .. getText("UI_optionscreen_translatedBy") .. " : edusaraiva (Eduardo Saraiva)";
        elseif v == "Simplified Chinese" then
            tooltipLanguages[v] = getText("UI_optionscreen_needreboot") .. " <LINE>  " .. getText("UI_optionscreen_translatedBy") .. " : Sky_Orc_Mm";
        elseif v == "Thai" then
            tooltipLanguages[v] = getText("UI_optionscreen_needreboot") .. " <LINE>  " .. getText("UI_optionscreen_translatedBy") .. " : Artdekdok";
        end
	end
	return tooltipLanguages;
end
--]]
function MainOptions.getAvailableLanguage()
	local result = {};
	for i=0, Translator.getAvailableLanguage():size()-1 do
		table.insert(result, Translator.getAvailableLanguage():get(i):text());
	end
	return result;
end

function MainOptions:onResolutionChange(oldw, oldh, neww, newh)
	local splitPoint = self:getWidth() / 2
	for _,keyTextElement in ipairs(MainOptions.keyText) do
		if keyTextElement.txt then
			local x = MainOptions.keyBindingLength + 30
			if not keyTextElement.left then
				x = x + splitPoint
			end
			keyTextElement.txt:setX(x - keyTextElement.txt.width)
			keyTextElement.btn:setX(x + 10)
		end
	end
	local gameOption = self.gameOptions:get('resolution')
	gameOption.control.options[1] = getText("UI_optionscreen_CurrentResolution", neww .. " x " .. newh)
	self.backButton:setX(self:getWidth() / 2 - 100 / 2 - 10 - 100)
	self.acceptButton:setX(self:getWidth() / 2 - 100 / 2)
	self.saveButton:setX(self:getWidth() / 2 + 100 / 2 + 10)
end

function MainOptions:onGainJoypadFocus(joypadData)
	ISPanelJoypad.onGainJoypadFocus(self, joypadData)
	local panel = self.tabs:getActiveView()
	joypadData.focus = panel
	updateJoypadFocus(joypadData)
MainOptions.instance = self
end

function MainOptions:onGainJoypadFocusCurrentTab(joypadData)
	ISPanelJoypad.onGainJoypadFocus(self, joypadData)
	self:setISButtonForX(MainOptions.instance.acceptButton)
	self:setISButtonForY(MainOptions.instance.saveButton)
	self:setISButtonForB(MainOptions.instance.backButton)
	if self.joypadIndexY == 0 then
		if #self.joypadButtonsY > 0 then
			self.joypadIndex = 1
			self.joypadIndexY = 1
			self.joypadButtons = self.joypadButtonsY[self.joypadIndexY]
			if self.joypadIndex > #self.joypadButtons then
				self.joypadIndex = #self.joypadButtons
			end
			self.joypadButtons[self.joypadIndex]:setJoypadFocused(true, joypadData)
		end
	end
end

function MainOptions:onJoypadDownCurrentTab(button, joypadData)
	if button == Joypad.LBumper or button == Joypad.RBumper then
		if ISComboBox.SharedPopup and UIManager.getUI():contains(ISComboBox.SharedPopup.javaObject) then return end -- hack
		local viewIndex = self.parent:getActiveViewIndex()
		if button == Joypad.LBumper then
			if viewIndex == 1 then
				viewIndex = #self.parent.viewList
			else
				viewIndex = viewIndex - 1
			end
		elseif button == Joypad.RBumper then
			if viewIndex == #self.parent.viewList then
				viewIndex = 1
			else
				viewIndex = viewIndex + 1
			end
		end
		self.parent:activateView(self.parent.viewList[viewIndex].name)
--		self.parent:getActiveView().joypadData = joypadData
		joypadData.focus = self.parent:getActiveView()
		updateJoypadFocus(joypadData)
	else
		ISPanelJoypad.onJoypadDown(self, button, joypadData)
	end
end

function MainOptions:new (x, y, width, height)
	local o = {}
	--o.data = {}
	o = ISPanelJoypad:new(x, y, width, height);
	setmetatable(o, self)
	self.__index = self
	o.x = x;
	o.y = y;
	o.backgroundColor = {r=0, g=0, b=0, a=0.3};
	o.borderColor = {r=1, g=1, b=1, a=0.2};
	o.width = width;
	o.height = height;
	o.anchorLeft = true;
	o.anchorRight = false;
	o.anchorTop = true;
	o.anchorBottom = false;
	o.addY = 0;
	o.gameOptions = GameOptions:new()
	MainOptions.instance = o;
	return o
end

Events.OnKeyPressed.Add(MainOptions.keyPressHandler);

--Events.OnMainMenuEnter.Add(testWorldPanel);
