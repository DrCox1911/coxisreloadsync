--****************************************************
--**                    Dr_Cox1911					**
--**       			  CoxisReloadSync    			**
--**				www.project-zomboid.de			**
--****************************************************

CoxisReloadSyncClient= {};
CoxisReloadSyncClient.debug = true;
CoxisReloadSyncClient.userdifficulty = 0;
CoxisReloadSyncClient.settings = {};
CoxisReloadSyncClient.luanet = nil;
CoxisReloadSyncClient.module = nil;

-- **************************************************************************************
-- initialize the client
-- **************************************************************************************
CoxisReloadSyncClient.init = function()
	print("CoxisReloadSyncClient: initialize...");
	print("CoxisReloadSync: Client is running the mod, proceeding with asking for settings...")

	CoxisReloadSyncClient.userdifficulty = ISReloadManager:getDifficulty();

	--Events.OnServerCommand.Add(CoxisReloadSyncClient.OnServerCommand);
	CoxisReloadSyncClient.luanet = LuaNet:getInstance();
	CoxisReloadSyncClient.module = CoxisReloadSyncClient.luanet.getModule("CoxisReloadSync", CoxisReloadSyncClient.debug);
	CoxisReloadSyncClient.luanet.setDebug(CoxisReloadSyncClient.debug);
	CoxisReloadSyncClient.module.addCommandHandler("reloadsetting", CoxisReloadSyncClient.receiveReloadSetting);

	Events.OnMainMenuEnter.Add(CoxisReloadSyncClient.restore);
	--CoxisReloadSyncClient.okModal("Coxis Reloaddifficulty-Sync!", true, 200, 100, 0, 0, CoxisReloadSyncClient.askSettings);


	if LuaNet:getInstance().isRunning() then
		print("CoxisReloadSyncClient: Luanet running, networking should work, but why doesnt it...")
	else
		print("CoxisReloadSyncClient: Luanet not running!")
	end

	if CoxisReloadSyncClient.debug == true then
		Events.OnKeyPressed.Add(CoxisReloadSyncClient.debugKnock);
	end
	--CoxisReloadSyncClient.askSettings();
end


CoxisReloadSyncClient.receiveReloadSetting = function(_player, _difficulty)

	if _difficulty ~= nil then
		print("CoxisReloadSyncClient: received difficulty from server" .. tostring(_difficulty["difficulty"]));
		CoxisReloadSyncClient.settings = _difficulty;
		ISReloadManager:setDifficulty(_difficulty["difficulty"]);
	else
		print("CoxisReloadSyncClient: received nil for some reason!")
	end
end

CoxisReloadSyncClient.debugKnock = function(_key)
	local key = _key;

	if key == 24 then -- "o"
		--CoxisReloadSyncClient.askSettings();
	elseif key == 38 then -- "l"
		print("Current reload difficulty: " .. tostring(ISReloadManager:getDifficulty()));
	end
end


-- **************************************************************************************
-- CoxisReloadSyncClient: asking for the settings
-- **************************************************************************************
CoxisReloadSyncClient.askSettings = function(_tick)
	if _tick >= 1 then
		print("CoxisReloadSyncClient: asking the server for settings...")
		--sendClientCommand('CoxisReloadSync', 'askSettings', CoxisReloadSyncClient.settings);
		local player = _player;
			if not player then
				player = getPlayer();
			end
			CoxisReloadSyncClient.module.send("reloadsetting", player:getUsername());
		print("CoxisReloadSyncClient: asked for settings")
		Events.OnTick.Remove(CoxisReloadSyncClient.askSettings);
	end
end


-- **************************************************************************************
-- modal dialog, heavily inspired by (=ripped off :D) the one RoboMat has written
-- **************************************************************************************
function CoxisReloadSyncClient.okModal(_text, _centered, _width, _height, _posX, _posY, _func)
    local posX = _posX or 0;
    local posY = _posY or 0;
    local width = _width or 230;
    local height = _height or 120;
    local centered = _centered;
    local txt = _text;
	local func = _func;
    local core = getCore();

    -- center the modal if necessary
    if centered then
        posX = core:getScreenWidth() * 0.5 - width * 0.5;
        posY = core:getScreenHeight() * 0.5 - height * 0.5;
    end

    local modal = ISModalDialog:new(posX, posY, width, height, txt, false, nil, func);
    modal:initialise();
    modal:addToUIManager();
end


-- **************************************************************************************
-- Restores the difficulty set by the user
-- **************************************************************************************
CoxisReloadSyncClient.restore = function()
	print("CoxisReloadSyncClient: Restoring previous user difficulty setting...")
	ISReloadManager:setDifficulty(CoxisReloadSyncClient.userdifficulty);
end


CoxisReloadSyncClient.initClient = function()
	if isClient() then
		LuaNet:getInstance().onInitAdd(CoxisReloadSyncClient.init);
		--LuaNet:getInstance().onInitAdd(CoxisReloadSyncClient.askSettings);
	end
end

-- Events.OnGameStart.Add(CoxisReloadSyncClient.init);
Events.OnConnected.Add(CoxisReloadSyncClient.initClient)
Events.OnTick.Add(CoxisReloadSyncClient.askSettings)
--Events.OnGameTimeLoaded.Add(CoxisReloadSyncClient.askSettings)
