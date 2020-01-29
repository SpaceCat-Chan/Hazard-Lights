pcall(require,'__debugadapter__/debugadapter.lua')
Temp = require("CommonEntities")

function FindSurfaceOfentity(entity) --gets the surface of an Entity
	for __,Surface in pairs(game.surfaces) do
		local result = Surface.find_entity(entity.name, entity.position)
		if result == nil then
			return game.surfaces[1]
		end
		if result.unit_number == entity.unit_number then
			return Surface
		end
	end
end


--[[
	Entity: Entity ID to make graphics for
	forces: Table of Forces that should be able to see lights
	players: Table of players that should be able to see lights

	return: nil

	note: forces and players operate in an AND fashion
]]
function MakeGraphics(Entity, forces, players)
	--set up Variables
	if(global.Renders[Entity.unit_number] ~= nil) then
		return nil
	end
	if Entity.unit_number == nil then
		if global.CommonEntities[Entity.name] then
			global.CommonEntities[Entity.name] = nil
		end
		return nil
	end
	
	EntityPrototype = Entity.prototype
	Position = Entity.position
	
	local left_x = Position.x + EntityPrototype.collision_box["left_top"].x
	local bottom_y = Position.y + EntityPrototype.collision_box["right_bottom"].y
	local right_x = Position.x + EntityPrototype.collision_box["right_bottom"].x
	local top_y = Position.y + EntityPrototype.collision_box["left_top"].y
	
	Surface = FindSurfaceOfentity(Entity)
	
	global.Renders[Entity.unit_number] = {}

	local Scale, Intensity, Red, Alpha
	Scale = settings.global["HazardLights-Scale"].value
	Intensity = settings.global["HazardLights-Intensity"].value
	Red = settings.global["HazardLights-Red"].value
	Alpha = settings.global["HazardLights-Alpha"].value
	
	--make the actual render objects
	global.Renders[Entity.unit_number]["1"] = rendering.draw_sprite{sprite = "Hazard_Light", render_layer = "higher-object-under", target = {left_x, bottom_y}, surface = Surface, visable = true, forces = forces, players = players}
	global.Renders[Entity.unit_number]["2"] = rendering.draw_sprite{sprite = "Hazard_Light", render_layer = "higher-object-under", target = {left_x, top_y}, surface = Surface, visable = true, forces = forces, players = players}
	global.Renders[Entity.unit_number]["3"] = rendering.draw_sprite{sprite = "Hazard_Light", render_layer = "higher-object-under", target = {right_x, bottom_y}, surface = Surface, visable = true, forces = forces, players = players}
	global.Renders[Entity.unit_number]["4"] = rendering.draw_sprite{sprite = "Hazard_Light", render_layer = "higher-object-under", target = {right_x, top_y}, surface = Surface, visable = true, forces = forces, players = players}
			
	global.Renders[Entity.unit_number]["5"] = rendering.draw_light({sprite = "utility/light_medium", scale = Scale, intensity = Intensity, color = {r = Red, a = Alpha}, target = {left_x, bottom_y}, surface = Surface, visable = true, forces = forces, players = players})
	global.Renders[Entity.unit_number]["6"] = rendering.draw_light({sprite = "utility/light_medium", scale = Scale, intensity = Intensity, color = {r = Red, a = Alpha}, target = {left_x, top_y}, surface = Surface, visable = true, forces = forces, players = players})
	global.Renders[Entity.unit_number]["7"] = rendering.draw_light({sprite = "utility/light_medium", scale = Scale, intensity = Intensity, color = {r = Red, a = Alpha}, target = {right_x, bottom_y}, surface = Surface, visable = true, forces = forces, players = players})
	global.Renders[Entity.unit_number]["8"] = rendering.draw_light({sprite = "utility/light_medium", scale = Scale, intensity = Intensity, color = {r = Red, a = Alpha}, target = {right_x, top_y}, surface = Surface, visable = true, forces = forces, players = players})
	
	global.Renders[Entity.unit_number].players = players
	global.Renders[Entity.unit_number].forces = forces
	global.Renders[Entity.unit_number].Entity = Entity
	
end

function EntityCreate(event) --Handles when an Entity is added to the world
	local Entity = event.entity or event.created_entity
	if global.CommonEntities[Entity.name] then
		MakeGraphics(Entity)
	end
end

function EntityRemove(event) --Handles when an Entity is removed form the world
	if global.Renders[event.entity.unit_number] then
		RemoveRendersFromEntity(event.entity.unit_number)
	end
end

function PickerDolliesHandler(event)
	if event.moved_entity.valid and event.moved_entity.unit_number then
		if not global.CommonEntities[event.moved_entity.name] then
			return
		end
		local Players, Forces
		Forces = global.Renders[event.moved_entity.unit_number].forces
		Players = global.Renders[event.moved_entity.unit_number].players
		RemoveRendersFromEntity(event.moved_entity.unit_number)
		MakeGraphics(event.moved_entity, Forces, Players)
	end
end

function on_init() --sets up global.Renders and Redoes Rendering
	global.Renders = {}	
	global.CommonEntities = Temp
	RedoRendering()
	if remote.interfaces["PickerDollies"] and remote.interfaces["PickerDollies"]["dolly_moved_entity_id"] then
		script.on_event(remote.call("PickerDollies", "dolly_moved_entity_id"), PickerDolliesHandler)
	end
end

function on_load()
	if remote.interfaces["PickerDollies"] and remote.interfaces["PickerDollies"]["dolly_moved_entity_id"] then
		script.on_event(remote.call("PickerDollies", "dolly_moved_entity_id"), PickerDolliesHandler)
	end
end

function RedoRendering() --Function that goes through all Entities and add rendering to thoese that need it
	for __,Surface in pairs(game.surfaces) do
		local EntityList = Surface.find_entities()
		for __,Entity in pairs(EntityList) do repeat
			if Entity.unit_number == nil then
				global.CommonEntities[Entity.name] = nil
				break
			end
			if global.CommonEntities[Entity.name] and global.Renders[Entity.unit_number] == nil then
				MakeGraphics(Entity)
			end
		until true end
	end	
end

--[[
	Table: list of entity names to add

	return: nil
]]
function AddEntities(Table)
	for __,EntityName in pairs(Table) do
		global.CommonEntities[EntityName] = true
	end
	RedoRendering()
end


--[[
	Table: list of entity names to remove

	return: nil
]]
function RemoveEntities(Table)
	for __,EntityName in pairs(Table) do
		
		global.CommonEntities[EntityName] = nil
	end
	for __,Surface in pairs(game.surfaces) do
		
		Entities = Surface.find_entities_filtered{name=Table}
		for __,Entity in pairs(Entities) do
			if not (global.Renders[Entity.unit_number].Reserved) then
				RemoveRendersFromEntity(Entity.unit_number)
			end
		end
	end
end

--[[
	return: list of all renders

	format: {Entity.unit_number = {Render1, Render2, Render3, Render4, Render5, Render6, Render7, Render8, players = ListOfPlayers, forces = ListOfForces, Entity = ReferenceToEntity}, Entity2.unit_number = {...}}
]]
function GetRenders()
	return global.Renders
end

function GetCommonEntities() --returns CommonEntities
	return global.CommonEntities
end

function RemoveRendersFromEntity(EntityId) --Removes Renders from an Entity. Excpects an EntityId/Entity.unit_number, returns nothing
	for RenderID = 1,8 do
		rendering.destroy(global.Renders[EntityId][tostring(RenderID)])
	end
	global.Renders[EntityId] = nil
end

function SetReserved(Id, EntityId) --Sets the Reserved value for an item in the global.Renders table, arg 1 expects a value (can't be nil or false), arg 2 expects an EntityId/Entity.unit_number, returns nothing
	global.Renders[EntityId].Reserved = Id
end

function RemoveAllRenders(Force) --removes renders from every single entity in the game, except for the ones that are reserved
	for k,v in pairs(global.Renders) do
		if (not v.Reserved) or Force then
			RemoveRendersFromEntity(k)
		end
	end
end

function RefreshRenders(Force)
	RemoveAllRenders(Force)
	RedoRendering()
end

function RemoveInvalidRenders()
	for k,v in pairs(global.Renders) do
		if v.Entity ~= nil then
			if(not v.Entity.valid) then
				RemoveRendersFromEntity(k)
			end
		end
	end
end

function RefrestEvent(event)
	if settings.global["HazardLights-ReScanBool"].value then
		if (event.tick % (settings.global["HazardLights-ReScanTimer"].value * 60)) == 0 then
			RemoveInvalidRenders()
		end
	end
end

function SettingChange(event)
	if event.setting == "HazardLights-Intensity" or event.setting == "HazardLights-Scale" or
		event.setting == "HazardLights-Red" or event.setting == "HazardLights-Alpha" then
		RefreshRenders()
	end
end

remote.add_interface("Hazard-Lights", {AddEntities = AddEntities, RemoveEntities = RemoveEntities, MakeGraphics = MakeGraphics, GetCommonEntities = GetCommonEntities, GetRenders = GetRenders, RemoveRendersFromEntity = RemoveRendersFromEntity, SetReserved = SetReserved, RemoveAllRenders = RemoveAllRenders, RefreshRenders = RefreshRenders, RedoRendering = RedoRendering})
--[[
Interface Instructions and Function List:

	AddEntities: Adds a table of Entities to CommonEntities and Redoes the Rendering. expects a table of Entity names, returns nothing
	
	RemoveEntities: Removes a table of Entities to CommonEntities and Removes Rendering from them. expects a table of Entity names, returns nothing
	
	MakeGraphics: Sets up the Rendring for an Entity. arg 1 Expects an Entity, arg 2 (optional) expects a table of forces, arg 3 (optional) expects a table of players, returns nothing, both force and player have to be fufilled to show light to a player
	
	GetCommonEntities: returns CommonEntities
	
	GetRenders: returns a table of this fromat: {Entity.unit_number = {Reserved = ReservedID, forces = {list of forces}, players = {list of players} Render1, Render2, Render3, Render4, Render5, Render6, Render7, Render8}, Entity2.unit_number = {....}, Entity3.unit_number = ....} contains all Entities that have Renders
	GetRenders: in Renders then both players and forces may be nil
	
	RemoveRendersFromEntity: Removes Renders from an Entity. Excpects an EntityId/Entity.unit_number, returns nothing
	
	SetReserved: Sets the Reserved value for an item in the global.Renders table, arg 1 expects a value (can't be nil or false), arg 2 expects an EntityId/Entity.unit_number, returns nothing

	RemoveAllRenders: Removes Renders from every single Entity, if first argument is true then Reserved Renders will be ignored

	RefreshRenders: Removes and then ReDoes all Renders, if first argument is true then Reserved Renders will be ignored
	
Notice: CommonEntities is a global table (aka saved in the savefile) so you will NOT have to re-add everything everytime that the world loads

Notice: if an entity in global.Renders is marked as reserved then that means the auto deletion logic will not touch it
]]

--Create Event Things
script.on_init(on_init)
script.on_load(on_load)


script.on_event(defines.events.on_built_entity, EntityCreate)
script.on_event(defines.events.on_robot_built_entity, EntityCreate)
script.on_event(defines.events.script_raised_built, EntityCreate)
script.on_event(defines.events.script_raised_revive, EntityCreate)

script.on_event(defines.events.on_pre_player_mined_item, EntityRemove)
script.on_event(defines.events.on_robot_pre_mined, EntityRemove)
script.on_event(defines.events.on_entity_died, EntityRemove)
script.on_event(defines.events.script_raised_destroy, EntityRemove)

script.on_event(defines.events.on_runtime_mod_setting_changed, SettingChange)
script.on_event(defines.events.on_tick, RefrestEvent)
