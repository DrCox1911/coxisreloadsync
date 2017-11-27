--****************************************************
--**                    Dr_Cox1911									**
--**       				  	CoxisReloadSync								**
--**							www.project-zomboid.de						**
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
	CoxisReloadSyncClient.luanet = LuaNet:getInstance();
	CoxisReloadSyncClient.module = CoxisReloadSyncClient.luanet.getModule("CoxisReloadSync", CoxisReloadSyncClient.debug);
	CoxisReloadSyncClient.luanet.setDebug(CoxisReloadSyncClient.debug);
	CoxisReloadSyncClient.module.addCommandHandler("reloadsetting", CoxisReloadSyncClient.receiveReloadSetting);

	Events.OnMainMenuEnter.Add(CoxisReloadSyncClient.restore);

	if LuaNet:getInstance().isRunning() then
		print("CoxisReloadSyncClient: Luanet running, networking should work, but why doesnt it...")
	else
		print("CoxisReloadSyncClient: Luanet not running!")
	end
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

-- **************************************************************************************
-- CoxisReloadSyncClient: asking for the settings
-- **************************************************************************************
CoxisReloadSyncClient.askSettings = function(_tick)
	if _tick >= 1 then
		print("CoxisReloadSyncClient: asking the server for settings...")
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
-- Restores the difficulty set by the user
-- **************************************************************************************
CoxisReloadSyncClient.restore = function()
	print("CoxisReloadSyncClient: Restoring previous user difficulty setting...")
	ISReloadManager:setDifficulty(CoxisReloadSyncClient.userdifficulty);
end


CoxisReloadSyncClient.initClient = function()
	if isClient() then
		LuaNet:getInstance().onInitAdd(CoxisReloadSyncClient.init);
	end
end

Events.OnConnected.Add(CoxisReloadSyncClient.initClient)
Events.OnTick.Add(CoxisReloadSyncClient.askSettings)
