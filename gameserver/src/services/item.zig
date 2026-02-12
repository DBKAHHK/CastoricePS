const std = @import("std");
const protocol = @import("protocol");
const Session = @import("../Session.zig");
const Packet = @import("../Packet.zig");
const Data = @import("../data.zig");
const GameConfig = @import("../data/game_config.zig");
const LineupManager = @import("../manager/lineup_mgr.zig");
const AvatarManager = @import("../manager/avatar_mgr.zig");
const ConfigManager = @import("../manager/config_mgr.zig");

const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const CmdID = protocol.CmdID;

const config = &ConfigManager.global_game_config_cache.game_config;

pub fn onGetBag(session: *Session, _: ?*const Packet, allocator: Allocator) !void {
    var rsp = protocol.GetBagScRsp.init(allocator);
    rsp.equipment_list = std.ArrayList(protocol.Equipment).init(allocator);
    rsp.relic_list = std.ArrayList(protocol.Relic).init(allocator);

    for (Data.ItemList) |tid| {
        try rsp.material_list.append(.{ .tid = tid, .num = 100 });
    }
    for (Data.PlayerOutfitList) |tid| {
        try rsp.material_list.append(.{ .tid = tid, .num = 1 });
    }
    try rsp.material_list.append(.{ .tid = 101, .num = 9999 });

    for (config.avatar_config.items) |avatarConf| {
        if (avatarConf.lightcone.id != 0) {
            const lc = try AvatarManager.createEquipment(avatarConf.lightcone, avatarConf.id);
            try rsp.equipment_list.append(lc);
        }
        for (avatarConf.relics.items, 0..) |input, slot| {
            if (input.id == 0) continue;
            const relic = try AvatarManager.createRelic(allocator, input, avatarConf.id, @intCast(slot));
            try rsp.relic_list.append(relic);
        }
    }

    try session.send(CmdID.CmdGetBagScRsp, rsp);
}

pub fn syncBag(session: *Session, allocator: Allocator) !void {
    try onGetBag(session, null, allocator);
}

pub fn onUseItem(session: *Session, packet: *const Packet, allocator: Allocator) !void {
    const req = try packet.getProto(protocol.UseItemCsReq, allocator);
    defer req.deinit();

    var rsp = protocol.UseItemScRsp.init(allocator);
    rsp.use_item_id = req.use_item_id;
    rsp.use_item_count = req.use_item_count;
    rsp.retcode = 0;

    rsp.retcode = 0;

    // maintain legacy behavior: also sync lineup notify
    var sync = protocol.SyncLineupNotify.init(allocator);
    var lineup_mgr = LineupManager.LineupManager.init(allocator);
    const lineup = try lineup_mgr.createLineup();
    sync.lineup = lineup;
    try session.send(CmdID.CmdSyncLineupNotify, sync);

    try session.send(CmdID.CmdUseItemScRsp, rsp);
}

fn mergePileItems(allocator: Allocator, items: []const protocol.PileItem) !std.ArrayList(protocol.PileItem) {
    var merged = std.ArrayList(protocol.PileItem).init(allocator);
    if (items.len == 0) return merged;

    var map = std.AutoHashMap(u32, u32).init(allocator);
    defer map.deinit();

    for (items) |it| {
        const existing = map.get(it.item_id) orelse 0;
        map.put(it.item_id, existing + it.item_num) catch {};
    }

    var it = map.iterator();
    while (it.next()) |entry| {
        try merged.append(.{ .item_id = entry.key_ptr.*, .item_num = entry.value_ptr.* });
    }
    return merged;
}

pub fn grantItems(session: *Session, allocator: Allocator, items: []const protocol.PileItem) !void {
    var merged = try mergePileItems(allocator, items);
    defer merged.deinit();

    if (session.player_state) |*state| {
        var dirty = false;
        for (merged.items) |it| {
            switch (it.item_id) {
                1 => {
                    state.mcoin += it.item_num;
                    dirty = true;
                },
                2 => {
                    state.scoin += it.item_num;
                    dirty = true;
                },
                else => {},
            }
        }
        if (dirty) {
            const PlayerStateMod = @import("../player_state.zig");
            try PlayerStateMod.save(state);
        }
    }

    var notify = protocol.PlayerSyncScNotify.init(allocator);
    for (merged.items) |it| {
        try notify.material_list.append(.{ .tid = it.item_id, .num = it.item_num });
    }
    try session.send(CmdID.CmdPlayerSyncScNotify, notify);
    try syncBag(session, allocator);
}
