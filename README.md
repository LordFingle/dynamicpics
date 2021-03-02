Dynamic Pics
-------------
Make your minetest dwellings beautiful, show paintings on the wall using any texture file.

They are large (3x3)

Download at https://github.com/eidy/dynamicpics/archive/master.zip
 
Very efficient, using the same technique as signs_lib.

Features:
- pictures overlap (bigger than one node; like in... you know)
- maximal size: 3x3 nodes
- maximal size in pixel: none
- adding more paintings is very easy (no lua required)
- switch through paintings by rightclick on it
- unlimited number of paintings

To use, use the following command

/giveme dynamicpics:picture

Use the RMB menu to set a texturename.  eg "heart.png" 
 
API
---
dynamicpics.register_provider(name, def)
 
-- Example: 
dynamic.pics.register_provider("mymod:pics", 
             { func = function(player, pos, size) return "default_stone.png" end})


dynamicpics.get_picture(texturename, size)
Returns an ItemStack containing the passed picture


dynamicpics.settexture(pos,texturename)

Programatically set the texture.  Can be used from a timer to provide animation.


This mod was inspired by gemalde, but rewritten in in the same way as signs_lib, using entities for the image.

Licence: Apache 2.0
Github: https://github.com/eidy/dynamicpics