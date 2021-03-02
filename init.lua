dynamicpics = {} 
dynamicpics.providers = {}


-- Example: dynamic.pics.register_provider("mymod:pics", { func = function(player, pos, size) })
dynamicpics.register_provider = function (name, def)
    
    assert( type(def.func) == "function", "Function provider must be specified for " .. name)
       
    table.insert(dynamicpics.providers, def)
end


-- still pictures
dofile(minetest.get_modpath("dynamicpics").."/still.lua")


-- Returns an ItemStack containing the passed picture
dynamicpics.get_picture = function (texturename, size)
    size = size or ""
    assert(texturename ~= nil, "dynamicpics.get_picture : Nil texture passed!")
    assert(size == "" or size == "big" or size == "thin", "dynamicpics.get_picture : Invalid picture size specified : " .. size)
    local stack = ItemStack("dynamicpics:picture" .. size .. " 1")
    stack:set_metadata(texturename)
    return stack
end
 

-- Migrate Gemalde over to dynamicpics
minetest.register_alias("gemalde:node_1","dynamicpics:picture") 