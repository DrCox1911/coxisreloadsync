--****************************************************
--**                    Dr_Cox1911									**
--**       				  	CoxisReloadSync								**
--**							www.project-zomboid.de						**
--****************************************************

CoxisReloadSyncServer = {};
CoxisReloadSyncServer.debug = true;
CoxisReloadSyncServer.settings = {};
CoxisReloadSyncServer.luanet = nil;
CoxisReloadSyncServer.module = nil;


-- **************************************************************************************
-- initialize the server
-- **************************************************************************************
CoxisReloadSyncServer.init = function()
	print("CoxisReloadSyncServer: initialize...");
	if isClient() then
		print("CoxisReloadSync: Client is running the mod, exiting server-lua...")
		return true;
	end
	print("CoxisReloadSync: Server is running the mod, proceeding with settings loading...")
	CoxisReloadSyncServer.loadSettings();
	CoxisReloadSyncServer.luanet = LuaNet:getInstance();
	CoxisReloadSyncServer.module = CoxisReloadSyncServer.luanet.getModule("CoxisReloadSync", true);
	LuaNet:getInstance().setDebug( true );
	CoxisReloadSyncServer.module.addCommandHandler("reloadsetting", CoxisReloadSyncServer.sendReloadSetting);
end

CoxisReloadSyncServer.sendReloadSetting = function(_player, _username)
			local players 		= getOnlinePlayers();
			local array_size 	= players:size();
			for i=0, array_size-1, 1 do
				local player = players:get(i);
				print(tostring(player:getUsername()));
				if _username == player:getUsername() then
					print(tostring(instanceof(player, "IsoPlayer" )));
					CoxisReloadSyncServer.module.sendPlayer(player, "reloadsetting", CoxisReloadSyncServer.settings);
				end
			end
end

-- **************************************************************************************
-- CoxisReloadSyncServer.loadSettings: reads the reload-difficulty
-- **************************************************************************************
CoxisReloadSyncServer.loadSettings = function()
	local settingsFile = getModFileReader("Cox_ReloadSync", "reloadsettings.ini", true);
	-- we fetch our file to bind our keys (load the file)
	local line = nil;
	-- we read each line of our file
	while true do
		line = settingsFile:readLine();
		if line == nil then
			settingsFile:close();
			break;
		end
		if not luautils.stringStarts(line, "[") and not luautils.stringStarts(line, ";") then
			local splitedLine = string.split(line, "=")
			local name = splitedLine[1]
			local key = tonumber(splitedLine[2])
			-- ignore obsolete bindings, override the default key
				CoxisReloadSyncServer.settings[name] = key
				print(CoxisReloadSyncServer.settings[name]);
		end
	end
end


CoxisReloadSyncServer.initMP = function()
	if isServer() then
		LuaNet:getInstance().onInitAdd(CoxisReloadSyncServer.init);
	end
end

Events.OnGameBoot.Add(CoxisReloadSyncServer.initMP)
