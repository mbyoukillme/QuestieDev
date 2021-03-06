DEFAULT_CHAT_FRAME:AddMessage("load", 0.95, 0.95, 0.5);

function getCurrentMapID()

	-- thanks to mapnotes for this "bug fix"
	local fx, fy = GetPlayerMapPosition("player");
	if ( ( ( fx ) and ( fx == 0 ) ) and ( ( fy ) and ( fy == 0 ) ) ) then
		SetMapToCurrentZone();
	end
	-- thanks mapnotes


	local file = GetMapInfo()
	
	if file == nil then -- thanks optim for finding a null bug here
		return -1
	end
	
	local zid = QuestieZones[file];
	if zid == nil then
		DEFAULT_CHAT_FRAME:AddMessage("ERROR: We are in unknown zone " .. file, 0.95, 0.2, 0.2);
		return -1
	else
		return zid
	end
end

objectiveProcessors = {
	['item'] = function(quest, name, amount, selected, mid)
		--DEFAULT_CHAT_FRAME:AddMessage("derp", 0.95, 0.95, 0.5);
		local itemdata = QuestieItems[name];
		if itemdata == nil then
			--DEFAULT_CHAT_FRAME:AddMessage("ERROR PROCESSING " .. name, 0.95, 0.2, 0.2);
		else
			for k,v in pairs(itemdata) do
				--DEFAULT_CHAT_FRAME:AddMessage(k, 0.95, 0.95, 0.5);
				--DEFAULT_CHAT_FRAME:AddMessage(v, 0.95, 0.95, 0.5);
				if k == "locationCount" then
					for b=1,itemdata['locationCount'] do
						local loc = itemdata['locations'][b];
						if loc[1] == mid then
							MapNotes_CreateQuestNote(name, quest, "", loc[2], loc[3], 3, selected);
						end
					end
				elseif k == "drop" then
					for e,r in pairs(v) do
						--DEFAULT_CHAT_FRAME:AddMessage(e .. " drops " .. name .. " for " .. quest, 0.95, 0.95, 0.5);
						--local monsterdata = QuestRoot['QuestHelper_StaticData']['enUS']['objective']['monster'][e];
						local monsterdata = QuestieMonsters[e];
						if monsterdata == nil then
							--DEFAULT_CHAT_FRAME:AddMessage("   ERROR PROCESSING " .. e, 0.95, 0.2, 0.2);
						else
							--DEFAULT_CHAT_FRAME:AddMessage("   LOOTED: " .. monsterdata['looted'], 0.2, 0.9, 0.2);
							--DEFAULT_CHAT_FRAME:AddMessage("   KNOWNLOCS: " .. monsterdata['locationCount'], 0.2, 0.9, 0.2);
							for b=1,monsterdata['locationCount'] do
								local loc = monsterdata['locations'][b];
								if loc[1] == mid then
									MapNotes_CreateQuestNote(e, name .. " (" .. amount .. ")", quest, loc[2], loc[3], 0, selected);
								end
							end
						end
					end
				end
			end
		end
	end,
	['fish'] = function(quest, name, amount, selected, mid)
		--DEFAULT_CHAT_FRAME:AddMessage("herp", 0.95, 0.95, 0.5);
	end,
	['event'] = function(quest, name, amount, selected, mid)
		local evtdata = QuestieEvents[name]
		if evtdata == nil then
			--DEFAULT_CHAT_FRAME:AddMessage("ERROR: UNKNOWN EVENT: " .. name, 0.95, 0.2, 0.2);
		else
			--DEFAULT_CHAT_FRAME:AddMessage("VALIDEVT: " .. name, 0.2, 0.95, 0.2);
			for b=1,evtdata['locationCount'] do
				local loc = evtdata['locations'][b];
				if loc[1] == mid then
					MapNotes_CreateQuestNote(name, quest, "", loc[2], loc[3], 8, selected);
				end
			end
		end
	end,
	['monster'] = function(quest, name, amount, selected, mid)
		--DEFAULT_CHAT_FRAME:AddMessage("   MONMON: " .. quest .. ", " .. name .. ", " .. amount, 0.95, 0.2, 0.2);
		local monsterdata = QuestieMonsters[name];
		if monsterdata == nil then
			--DEFAULT_CHAT_FRAME:AddMessage("   ERROR PROCESSINGMON " .. name, 0.95, 0.2, 0.2);
		else
			--DEFAULT_CHAT_FRAME:AddMessage("   LOOTED: " .. monsterdata['looted'], 0.2, 0.9, 0.2);
			--DEFAULT_CHAT_FRAME:AddMessage("   KNOWNLOCS: " .. monsterdata['locationCount'], 0.2, 0.9, 0.2);
			for b=1,monsterdata['locationCount'] do
				local loc = monsterdata['locations'][b];
				if loc[1] == mid then
					MapNotes_CreateQuestNote(name, amount, quest, loc[2], loc[3], 5, selected);
				end
			end
		end
	end,
	['object'] = function(quest, name, amount, selected, mid)
		local objdata = QuestObjects[name];
		if objdata == nil then
			-- error message 
		else
			for b=1,objdata['locationCount'] do
				local loc = objdata['locations'][b];
				if loc[1] == mid then
					MapNotes_CreateQuestNote(name, quest, "", loc[2], loc[3], 9, selected);
				end
			end
		end
	end

}

function getQuestFinisherByName(name)

end

function findLast(haystack, needle)
    local i=string.gfind(haystack, ".*"..needle.."()")()
    if i==nil then return nil else return i-1 end
end

function processObjective(quest, desc, typ, selected, mid)
	--DEFAULT_CHAT_FRAME:AddMessage(desc, 0.95, 0.95, 0.5);
	local ref = objectiveProcessors[typ];
	
	if not (ref == nil) then
		--DEFAULT_CHAT_FRAME:AddMessage("HANDLED TYPE: " .. typ .. " for quest " .. quest, 0.2, 0.95, 0.95);
		--- super ugly code time
		if typ == "item" or typ == "monster" then
			local indx = findLast(desc, ":");
			--DEFAULT_CHAT_FRAME:AddMessage(indx, 0.95, 0.95, 0.5);
			local countstr = string.sub(desc, indx+2);
			local namestr = string.sub(desc, 1, indx-1);
			ref(quest, namestr, countstr, selected, mid);
		else
			ref(quest, desc, "", selected, mid);
		end
		--DEFAULT_CHAT_FRAME:AddMessage(countstr, 0.95, 0.95, 0.5);
		--DEFAULT_CHAT_FRAME:AddMessage(namestr, 0.95, 0.95, 0.5);
		--for v=string:len(desc),1 do
		--	DEFAULT_CHAT_FRAME:AddMessage(v, 0.95, 0.95, 0.5);
		--end
		--for k,v in pairs(desc) do
		--	DEFAULT_CHAT_FRAME:AddMessage(k, 0.95, 0.95, 0.5);
		--	DEFAULT_CHAT_FRAME:AddMessage(v, 0.95, 0.95, 0.5);
		--end
		--DEFAULT_CHAT_FRAME:AddMessage(indx, 0.95, 0.95, 0.5);
		
	else
		DEFAULT_CHAT_FRAME:AddMessage("ERROR: UNHALDNED TYPE: " .. typ .. " \"" .. desc .. "\" for quest " .. quest, 0.95, 0.2, 0.2);
	end
end

local objectives = {};

local throttle = 0;

function getQuestHashByName(name)
	return QuestieHashes[name];
end

local throttleOverride = false;

function questieevt(event)
	--DEFAULT_CHAT_FRAME:AddMessage("evt " .. event .. " " .. GetQuestLogSelection(), 0.95, 0.95, 0.5);
	--DEFAULT_CHAT_FRAME:AddMessage(event, 0.95, 0.95, 0.5);-
	if (event == "QUEST_LOG_UPDATE") or (event == "ZONE_CHANGED") then
		local sind = GetQuestLogSelection();
		local mid = getCurrentMapID();
		if not throttleOverride then
			if throttle == math.floor(GetTime()) then
				return
			else
				throttle = math.floor(GetTime())
			end
		else
			throttleOverride = false;
		end
		--DEFAULT_CHAT_FRAME:AddMessage(throttle, 0.95, 0.95, 0.5);
		MapNotes_DeleteLandMarks();
		--DEFAULT_CHAT_FRAME:AddMessage(QuestHelper_StaticData['deDE']['flight_instructors'][1]["Allerias Feste, Wälder von Terokkar"], 0.95, 0.95, 0.5);
		--DEFAULT_CHAT_FRAME:AddMessage(QuestHelper_StaticData['enUS']['flight_instructors'][1]["Allerian Stronghold, Terokkar Forest"], 0.95, 0.95, 0.5);
		--DEFAULT_CHAT_FRAME:AddMessage("durp", 0.95, 0.95, 0.5);
		local numEntries, numQuests = GetNumQuestLogEntries()
		--DEFAULT_CHAT_FRAME:AddMessage(numEntries .. " entries containing " .. numQuests .. " quests in your quest log.");
		--GetQuestLogTitle
		for v=1,numEntries do
			local q = GetQuestLogTitle(v);
			if not (getQuestHashByName(q) == nil) then

				SelectQuestLogEntry(v);
				local count =  GetNumQuestLeaderBoards();
				--DEFAULT_CHAT_FRAME:AddMessage(q);
				--if q == "Bashal'Aran" then
				--	DEFAULT_CHAT_FRAME:AddMessage("KNOWN QUEST: " .. q .. " " .. count, 0.2, 0.85, 0.2);
				--end 
				for r=1,count do
					local desc, typ, done = GetQuestLogLeaderBoard(r);
					--DEFAULT_CHAT_FRAME:AddMessage(desc, 0.95, 0.95, 0.5);
					local finisher = QuestieFinishers[q]
					local selected = v == sind;
					
					if not (finisher == nil) and selected then
						local monsterdata = QuestieMonsters[finisher];
						if monsterdata == nil then
							--DEFAULT_CHAT_FRAME:AddMessage("   ERROR PROCESSINGMON " .. name, 0.95, 0.2, 0.2);
						else
							--DEFAULT_CHAT_FRAME:AddMessage("   LOOTED: " .. monsterdata['looted'], 0.2, 0.9, 0.2);
							--DEFAULT_CHAT_FRAME:AddMessage("   KNOWNLOCS: " .. monsterdata['locationCount'], 0.2, 0.9, 0.2);
							for b=1,monsterdata['locationCount'] do
								local loc = monsterdata['locations'][b];
								if loc[1] == mid then
									MapNotes_CreateQuestNote(finisher, "Quest Finisher", q, loc[2], loc[3], 4, selected);
								end
							end
						end
					end
					
					if not done then
						
						if selected then
							--DEFAULT_CHAT_FRAME:AddMessage("SELECTED " .. q, 0.95, 0.1, 0.95);
						else
							--DEFAULT_CHAT_FRAME:AddMessage("NOTSELECTEd " .. q .. " " .. in, 0.95, 0.1, 0.95);
						end
						processObjective(q, desc, typ, selected, mid)
					end
					---DEFAULT_CHAT_FRAME:AddMessage(typ, 0.95, 0.95, 0.5);
					---DEFAULT_CHAT_FRAME:AddMessage(done, 0.95, 0.95, 0.5);
					
				end
				--DEFAULT_CHAT_FRAME:AddMessage(hash);
			else
				--DEFAULT_CHAT_FRAME:AddMessage("ERROR: UNKNOWN QUEST: " .. q, 0.95, 0.55, 0.2);
			end
		end
		SelectQuestLogEntry(sind);
	end
	
	--objectiveProcessors['item']();
end

function fank()
	DEFAULT_CHAT_FRAME:AddMessage("fank", 0.95, 0.55, 0.2);
end

local oql;

local needsUpdate = false;

function questiepoll()
	if needsUpdate then
		needsUpdate = false;
		throttleOverride = true;
		questieevt("QUEST_LOG_UPDATE");
	end
	--DEFAULT_CHAT_FRAME:AddMessage("QUESTTEXT", 0.95, 0.95, 0.5);
end

function nql()
	--DEFAULT_CHAT_FRAME:AddMessage("QUESTTEXT", 0.95, 0.95, 0.5);
	--questieevt("QUEST_LOG_UPDATE");
	needsUpdate = true;
	return oql();
end

function questieinit()
	DEFAULT_CHAT_FRAME:AddMessage("init", 0.95, 0.95, 0.5);
	this:RegisterEvent("QUEST_LOG_UPDATE");
	this:RegisterEvent("ZONE_CHANGED");
	DEFAULT_CHAT_FRAME:AddMessage("lololpairs", 0.95, 0.95, 0.5);
	for k,v in pairs(QuestLogFrame) do
		DEFAULT_CHAT_FRAME:AddMessage(k, 0.95, 0.95, 0.98);
	end
	oql = GetQuestLogQuestText;
	GetQuestLogQuestText = nql;
	MapNotes_DeleteLandMarks();
end


