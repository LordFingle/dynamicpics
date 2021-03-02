 
local DEFAULT_DYNAMIC_PICNAME = "dynamicsigns_default.png"
-- Base picture node

 

local def = {
	description = "Picture",
	drawtype = "signlike",
	tiles = {"wool_white.png"},
    visual_scale = 1.0,
	visual_scale_x = 1.0,
    visual_scale_y = 1.0,
	inventory_image = "dynamicpics_node.png",
	wield_image = "dynamicpics_node.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
    stack_max = 1,
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "wallmounted",
	},
	groups = {choppy=2, dig_immediate=3, oddly_breakable_by_hand=3}, 
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        if minetest.check_player_privs(player:get_player_name(), {server = true}) then
            local m = minetest.get_meta(pos)
            local texturename = m:get_string("texturename")
            dynamicpics.showform(player:get_player_name(), pos, texturename)
        end
    end,
    on_construct = function(pos)
		dynamicpics.construct_sign(pos)
	end,
	on_destruct = function(pos)
		dynamicpics.destruct_sign(pos)
	end, 
	on_punch = function(pos, node, puncher)
		dynamicpics.update(pos)
	end,
    after_place_node = function(pos, placer, itemstack, pointed_thing)      
        local placemeta = minetest.get_meta(pos)
        local picstring = itemstack:get_metadata()
     
        if picstring == nil or picstring == "" then picstring = DEFAULT_DYNAMIC_PICNAME end
        placemeta:set_string("texturename", picstring)
        dynamicpics.update(pos)
    end,
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        
        if oldmetadata == nil then return end

        -- Look in inventory for an item without metadata
        local inv = digger:get_inventory()
        local mainlist = inv:get_list("main")
        for i,stack in ipairs(mainlist) do
            
            if stack:get_name():find("dynamicpics:.*picture") then
                metadata = stack:get_metadata()
                if metadata == "" or metadata == nil then 
                    if oldmetadata.fields.texturename ~= nil then
                        stack:set_metadata(oldmetadata.fields.texturename)
                    else
                        stack:set_metadata(DEFAULT_DYNAMIC_PICNAME)
                    end   
                    inv:set_stack("main",i,stack)           
                    break
                end
            end
        end

    end
}

minetest.register_node("dynamicpics:picture", def)
def2 = table.copy(def)
def2.visual_scale = 3.0
def2.visual_scale_x = 3.0
def2.visual_scale_y = 3.0
minetest.register_node("dynamicpics:bigpicture", def2)
def3 = table.copy(def)
def3.visual_scale = 2.0
def3.visual_scale_x = 1.0
def3.visual_scale_y = 2.0
minetest.register_node("dynamicpics:thinpicture", def3)

local function set_obj_picture(obj, texturename, visual_scale_x, visual_scale_y)
 if obj.textures == nil or #obj.textures < 1 or obj.textures[1] ~= texturename then
	    obj:set_properties({
		    textures={texturename},
		    visual_size = {x=visual_scale_x, y=visual_scale_y},
     })
 end

end

dynamicpics_on_activate = function(self)
    local pos = self.object:getpos()
	local meta = minetest.get_meta(pos)
	local texturename = meta:get_string("texturename")
    
	if texturename then
		set_obj_picture(self.object,texturename, minetest.registered_nodes[minetest.get_node(pos).name].visual_scale_x, minetest.registered_nodes[minetest.get_node(pos).name].visual_scale_y )
	end
end

minetest.register_entity("dynamicpics:piccontent", {
    collisionbox = { 0, 0, 0, 0, 0, 0 },
    visual = "upright_sprite",
    textures = {},

	on_activate = dynamicpics_on_activate,
})

minetest.register_abm({
	nodenames = {"dynamicpics:picture"},
	interval = 15,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)      
		dynamicpics.update(pos)
	end
})
 
dynamicpics.construct_sign = function(pos)
    local meta = minetest.get_meta(pos)
	meta:set_string("texturename", "")
end

function dynamicpics.showform(playername, pos, texturename)

      local formspec = "size[8,7]"..
            "image[1,0.5;3,3;" .. texturename .."]"..
            "field[999,1.5;1,1;pos;;" .. minetest.pos_to_string(pos) .. "]" ..
		    "field[1,3;5,3;texturename;Texture Name;" .. texturename .."]"..
            "button[6,3.6;2,1;retrieve;Retrieve]" ..
		    "button_exit[2,5.4;2,1;ok;Write]"
      minetest.show_formspec(playername, "dynamicpics:picture", formspec)

end
 
minetest.register_on_player_receive_fields(function(player, formname, fields) 
	
    if formname ~= "dynamicpics:picture" then return end

    if fields and fields.pos then
        local pos = minetest.string_to_pos(fields.pos)
	    if fields.texturename and fields.ok then
          dynamicpics.settexture(pos, fields.texturename)
	    end
        if  fields.texturename and fields.retrieve then
          dynamicpics.showform(player:get_player_name(), pos, fields.texturename)
	    end
    end
end)


dynamicpics.destruct_sign = function(pos)
    local objects = minetest.get_objects_inside_radius(pos, 0.5)
    for _, v in ipairs(objects) do
		local e = v:get_luaentity()
        if e and e.name == "dynamicpics:piccontent" then
            v:remove()
        end
    end
end

dynamicpics.model = {
	nodebox = {
		type = "wallmounted",
		wall_side =   { -0.5,    -0.25,   -0.4375, -0.4375,  0.375,  0.4375 },
		wall_bottom = { -0.4375, -0.5,    -0.25,    0.4375, -0.4375, 0.375 },
		wall_top =    { -0.4375,  0.4375, -0.375,   0.4375,  0.5,    0.25 }
	},
--	picpos = {
--		nil,
--		nil,
--		{delta = {x =  0.43,  y = 0.07, z =  0     }, yaw = math.pi / -2},
--		{delta = {x = -0.43,  y = 0.07, z =  0     }, yaw = math.pi / 2},
--		{delta = {x =  0,     y = 0.07, z =  0.43  }, yaw = 0},
--		{delta = {x =  0,     y = 0.07, z = -0.43  }, yaw = math.pi},
--	}
 	picpos = {
		nil,
		nil,
		{delta = {x =  0.43,  y = 0, z =  0     }, yaw = math.pi / -2},
		{delta = {x = -0.43,  y = 0, z =  0     }, yaw = math.pi / 2},
		{delta = {x =  0,     y = 0, z =  0.43  }, yaw = 0},
		{delta = {x =  0,     y = 0, z = -0.43  }, yaw = math.pi},
	}
 
}

dynamicpics.settexture = function(pos, texturename)		 
	  local meta = minetest.get_meta(pos)
	  meta:set_string("texturename", texturename)	
      dynamicpics.update(pos) 
end

dynamicpics.update = function(pos)
    local meta = minetest.get_meta(pos)
	local texturename = meta:get_string("texturename")

    if texturename == "" or texturename == DEFAULT_DYNAMIC_PICNAME then

         local newtexture 
         for _,v in pairs(dynamicpics.providers) do


                -- Get Nearest Player 
                local player = (function ()
                    local player = nil
                    local playerdist = 0
                    for _,p in pairs(minetest.get_connected_players()) do
                        local pdist = vector.distance(p:getpos(), pos)
                        if (pdist < playerdist or player == nil) and pdist < 30 then
                            player = p
                            playerdist = pdist
                        end      
	                end
                    return player
                end) ()
                if player == nil then break end
                newtexture = v.func (player, pos, size)  
                if newtexture ~= nil and newtexture:len() > 0 then 
                    texturename = newtexture
                    meta:set_string("texturename",texturename)
                    break
                end
         end 
    end


    local objects = minetest.get_objects_inside_radius(pos, 0.5)

	local found
	for _, v in ipairs(objects) do
		local e = v:get_luaentity()
		if e and e.name == "dynamicpics:piccontent" then
			if found then
				v:remove()
			else
				set_obj_picture(v, texturename, minetest.registered_nodes[minetest.get_node(pos).name].visual_scale_x, minetest.registered_nodes[minetest.get_node(pos).name].visual_scale_y)
				found = true
			end
		end
	end

    if found then
		return
	end

	-- if there is no entity

	local sign_info
	 
	sign_info = dynamicpics.model.picpos[minetest.get_node(pos).param2 + 1]
		 
	--		sign_info = signs_lib.metal_wall_sign_model.textpos[minetest.get_node(pos).param2 + 1]
	 
	if sign_info == nil then
		return
	end

	local pic = minetest.add_entity({x = pos.x + sign_info.delta.x,
										y = pos.y + sign_info.delta.y,
										z = pos.z + sign_info.delta.z}, "dynamicpics:piccontent")
	pic:setyaw(sign_info.yaw)
 
end 
