-- debug_counter = 0
-- local function debug(...)
--   if game and game.players[1] then
--     debug_counter = debug_counter + 1
--     game.players[1].print("DEBUG(" .. string.format("%04d", debug_counter%10000) .. "): " .. serpent.line(...,{comment=false}))
--   end
-- end

local function process_changed_inventory(player, src_inv)
  local qb = player.get_quickbar()
  -- bail if there's no quickbar or it has no filters
  if not (qb and qb.is_filtered()) then return end
  -- loop through each quickbar slot as a potential destination for items
  for dst_n = 1, #qb do
    local src_n = nil
    local item_name = qb.get_filter(dst_n)
    if item_name ~= nil then -- skip unfiltered qb slots
      if not qb[dst_n].valid_for_read then -- skip occupied qb slots
        -- skip slot with filter that matches the cursor
        if not (player.cursor_stack and player.cursor_stack.valid_for_read and player.cursor_stack.name == item_name) then
          -- loop through each slot in the changed inventory as a potential source
          local filtered = src_inv.is_filtered()
          for cnd_n = 1, #src_inv do
            if src_inv[cnd_n].valid_for_read == true then -- skip empty slots
              if not (filtered and src_inv.get_filter(cnd_n)) then -- skip filtered slots
                if src_inv[cnd_n].name == item_name then -- skip slots with the wrong item
                  src_n = cnd_n
                  break
                end
              end
            end
          end
        end
      end
    end
    if src_n then
      if qb[dst_n].set_stack(src_inv[src_n]) then
        src_inv[src_n].clear()
        break -- we can stop early IFF this event fires once per changed item
      end
    end
  end
end

local function on_player_main_inventory_changed(event)
  local player = game.players[event.player_index]
  process_changed_inventory(player, player.get_main_inventory())
end

local function on_player_quickbar_inventory_changed(event)
  local player = game.players[event.player_index]
  process_changed_inventory(player, player.get_quickbar())
end

script.on_event(defines.events.on_player_main_inventory_changed, on_player_main_inventory_changed)
script.on_event(defines.events.on_player_quickbar_inventory_changed, on_player_quickbar_inventory_changed)
