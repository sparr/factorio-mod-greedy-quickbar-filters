-- local function debug(...)
--   if game and game.players[1] then
--     game.players[1].print("DEBUG: " .. serpent.line(...,{comment=false}))
--   end
-- end

local function process_changed_inventory(player, src_inv)
  -- debug(src_inv.index)
  -- get the player's whole quickbar
  local qb = player.get_inventory(defines.inventory.player_quickbar)
  if qb == nil or qb.is_filtered() == false then return end
  -- loop through each quickbar slot as a potential destination for items
  for dst_n = 1, #qb do
    local src_n = nil
    local item_name = qb.get_filter(dst_n)
    if qb[dst_n].valid_for_read == false and -- skip empty qb slots
       item_name ~= nil then -- skip unfiltered qb slots
      -- loop through each slot in the changed inventory as a potential source
      -- debug(item_name)
      for cnd_n = 1, #src_inv do
        if src_inv[cnd_n].valid_for_read == true and -- skip empty slots
           ( (not src_inv.supports_filters()) or src_inv.get_filter(cnd_n) == nil) and -- skip filtered slots
           src_inv[cnd_n].name == item_name then -- skip slots with the wrong item
          src_n = cnd_n
          break
        end
      end
    end
    if src_n ~= nil then
      -- debug('moving')
      if qb[dst_n].set_stack(src_inv[src_n]) then
        -- debug('moved')
        src_inv[src_n].clear()
        break -- we can stop early IFF this event fires once per changed item
      end
    end
  end
end

local function opmic(event)
  local player = game.players[event.player_index]
  process_changed_inventory(player, player.get_inventory(defines.inventory.player_main))
end

local function opqic(event)
  local player = game.players[event.player_index]
  process_changed_inventory(player, player.get_inventory(defines.inventory.player_quickbar))
end

script.on_event(defines.events.on_player_main_inventory_changed, opmic)
script.on_event(defines.events.on_player_quickbar_inventory_changed, opqic)
