const std = @import("std");
const ArrayList = std.ArrayList;

pub fn FunMode() type {
    return struct {
        var on_funmode: bool = false;
        var max_Hp: u32 = 0;

        pub fn FunMode() bool {
            return on_funmode;
        }
        pub fn SetFunMode(set: bool) void {
            on_funmode = set;
        }
        pub fn SetHp(Hp: u32) void {
            max_Hp = Hp;
        }
        pub fn GetHp() u32 {
            return max_Hp;
        }
    };
}

pub fn Challenge() type {
    return struct {
        var challenge_blessing: std.ArrayList(u32) = std.ArrayList(u32).init(std.heap.page_allocator);

        var on_challenge: bool = false;

        var challenge_mode: u32 = 0;

        var challenge_planeID: u32 = 0;
        var challenge_floorID: u32 = 0;
        var challenge_entryID: u32 = 0;
        var challenge_worldID: u32 = 0;
        var challenge_monsterID: u32 = 0;
        var challenge_eventID: u32 = 0;
        var challenge_groupID: u32 = 0;
        var challenge_maze_groupID: u32 = 0;
        var challenge_stageID: u32 = 0;

        var challengeID: u32 = 0;
        var challenge_buffID: u32 = 0;

        var challenge_peak_hard: bool = true;
        var on_peak_king_stage: bool = false;
        var on_challenge_peak: bool = false;
        var challenge_peak_id: u32 = 0;

        var avatar_list: std.ArrayList(u32) = std.ArrayList(u32).init(std.heap.page_allocator);
        var first_lineup: std.ArrayList(u32) = std.ArrayList(u32).init(std.heap.page_allocator);
        var second_lineup: std.ArrayList(u32) = std.ArrayList(u32).init(std.heap.page_allocator);

        var challenge_buff_one: u32 = 0;
        var challenge_buff_two: u32 = 0;
        var in_second_half: bool = false;
        var challenge_score_one: u32 = 0;
        var challenge_score_two: u32 = 0;

        pub fn GetAvatarIDs() std.ArrayList(u32) {
            return avatar_list;
        }
        pub fn AddAvatar(ids: []const u32) !void {
            for (ids) |id| {
                try avatar_list.append(id);
            }
        }

        pub fn SetChallengeLineups(first: []const u32, second: []const u32) !void {
            _ = first_lineup.clearRetainingCapacity();
            _ = second_lineup.clearRetainingCapacity();
            try first_lineup.appendSlice(first);
            try second_lineup.appendSlice(second);
        }
        pub fn HasSecondLineup() bool {
            return second_lineup.items.len != 0;
        }
        pub fn UseFirstLineup() !void {
            _ = avatar_list.clearRetainingCapacity();
            try avatar_list.appendSlice(first_lineup.items);
            in_second_half = false;
        }
        pub fn UseSecondLineup() !void {
            _ = avatar_list.clearRetainingCapacity();
            try avatar_list.appendSlice(second_lineup.items);
            in_second_half = true;
        }
        pub fn InSecondHalf() bool {
            return in_second_half;
        }

        pub fn SetChallengeBuffs(buff_one: u32, buff_two: u32) void {
            challenge_buff_one = buff_one;
            challenge_buff_two = buff_two;
        }
        pub fn GetChallengeBuffOne() u32 {
            return challenge_buff_one;
        }
        pub fn GetChallengeBuffTwo() u32 {
            return challenge_buff_two;
        }
        pub fn SetChallengeScore(score: u32) void {
            if (in_second_half) {
                challenge_score_two = score;
            } else {
                challenge_score_one = score;
            }
        }
        pub fn GetChallengeScoreOne() u32 {
            return challenge_score_one;
        }
        pub fn GetChallengeScoreTwo() u32 {
            return challenge_score_two;
        }
        pub fn GetChallengeScoreTotal() u32 {
            return challenge_score_one + challenge_score_two;
        }

        pub fn resetChallengeState() void {
            on_challenge = false;
            challenge_mode = 0;
            challenge_planeID = 0;
            challenge_floorID = 0;
            challenge_entryID = 0;
            challenge_worldID = 0;
            challenge_monsterID = 0;
            challenge_eventID = 0;
            challenge_groupID = 0;
            challenge_maze_groupID = 0;
            challenge_stageID = 0;
            challengeID = 0;
            challenge_buffID = 0;
            challenge_buff_one = 0;
            challenge_buff_two = 0;
            challenge_score_one = 0;
            challenge_score_two = 0;
            in_second_half = false;
            on_peak_king_stage = false;
            on_challenge_peak = false;
            challenge_peak_id = 0;
            _ = challenge_blessing.clearRetainingCapacity();
            _ = avatar_list.clearRetainingCapacity();
            _ = first_lineup.clearRetainingCapacity();
            _ = second_lineup.clearRetainingCapacity();
        }

        var saved_peak_lineups: std.AutoHashMap(u32, std.ArrayList(u32)) = std.AutoHashMap(u32, std.ArrayList(u32)).init(std.heap.page_allocator);

        pub fn SavePeakLineup(peak_id: u32, list: []const u32) !void {
            var avatar_copy = std.ArrayList(u32).init(std.heap.page_allocator);
            try avatar_copy.appendSlice(list);
            try saved_peak_lineups.put(peak_id, avatar_copy);
        }
        pub fn LoadPeakLineup(peak_id: u32) !void {
            if (saved_peak_lineups.get(peak_id)) |saved_list| {
                try AddAvatar(saved_list.items);
            }
        }

        pub fn ChallengeMode() bool {
            return on_challenge;
        }
        pub fn SetChallenge() void {
            on_challenge = true;
        }
        pub fn SetPeakBoss(set: bool) void {
            on_peak_king_stage = set;
        }
        pub fn SetChallengePeakActive(set: bool) void {
            on_challenge_peak = set;
        }
        pub fn ChallengePeakMode() bool {
            return on_challenge_peak;
        }
        pub fn SetChallengePeakID(id: u32) void {
            challenge_peak_id = id;
        }
        pub fn GetChallengePeakID() u32 {
            return challenge_peak_id;
        }
        pub fn ChallengePeakHard() bool {
            return challenge_peak_hard and on_peak_king_stage;
        }
        pub fn SetChallengePeakHard(set: bool) void {
            challenge_peak_hard = set;
        }
        pub fn GetChallengeID() u32 {
            return challengeID;
        }
        pub fn SetChallengeID(id: u32) void {
            challengeID = id;
        }
        pub fn SetChallengeMode(mode: u32) void {
            challenge_mode = mode;
        }
        pub fn FoundStage() bool {
            return challenge_stageID != 0;
        }
        pub fn GetChallengeStageID() u32 {
            return challenge_stageID;
        }
        pub fn GetChallengeBuffID() u32 {
            return challenge_buffID;
        }
        pub fn SetChallengeBuffID(id: u32) void {
            challenge_buffID = id;
        }
        pub fn GetChallengeMode() u32 {
            return challenge_mode;
        }
        pub fn GameModePF() bool {
            return challengeID > 20000 and challengeID < 30000;
        }
        pub fn GameModeAS() bool {
            return challengeID > 30000;
        }
        pub fn GetChallengeBlessingID() []const u32 {
            return challenge_blessing.items;
        }
        pub fn AddBlessing(id: []const u32) !void {
            try challenge_blessing.appendSlice(id);
        }
        pub fn GetCurChallengeStatus() void {
            std.debug.print("CURRENT CHALLENGE STAGE ID:{}\n", .{challenge_stageID});
            std.debug.print("CURRENT CHALLENGE LINEUP AVATAR ID:{}\n", .{GetAvatarIDs()});
            std.debug.print("CURRENT CHALLENGE MONSTER ID:{}\n", .{challenge_monsterID});

            switch (challenge_mode) {
                0 => std.debug.print("CURRENT CHALLENGE: MOC\n", .{}),
                1 => {
                    std.debug.print("CURRENT CHALLENGE: PF\n", .{});
                    if (challenge_blessing.items.len >= 2) {
                        std.debug.print("CURRENT CHALLENGE STAGE BLESSING ID:{}, SELECTED BLESSING ID:{}\n", .{ challenge_blessing.items[0], challenge_blessing.items[1] });
                    }
                },
                else => {
                    std.debug.print("CURRENT CHALLENGE: AS\n", .{});
                    if (challenge_blessing.items.len >= 2) {
                        std.debug.print("CURRENT CHALLENGE STAGE BLESSING ID:{}, SELECTED BLESSING ID:{}\n", .{ challenge_blessing.items[0], challenge_blessing.items[1] });
                    }
                },
            }
        }

        pub fn SetChallengeInfo(
            floor: u32,
            world: u32,
            monster: u32,
            event: u32,
            group: u32,
            maze: u32,
            plane: u32,
            entry: u32,
        ) void {
            challenge_floorID = floor;
            challenge_worldID = world;
            challenge_monsterID = monster;
            challenge_eventID = event;
            challenge_groupID = group;
            challenge_maze_groupID = maze;
            challenge_planeID = plane;
            challenge_entryID = entry;
            challenge_stageID = challenge_eventID;
        }
        pub fn SetChallengePeakInfo(
            floor: u32,
            monster: u32,
            event: u32,
            group: u32,
            maze: u32,
            plane: u32,
            entry: u32,
        ) void {
            challenge_floorID = floor;
            challenge_monsterID = monster;
            challenge_eventID = event;
            challenge_groupID = group;
            challenge_maze_groupID = maze;
            challenge_planeID = plane;
            challenge_entryID = entry;
            challenge_stageID = challenge_eventID;
        }
        pub fn CalChallengePeakEventID(event: u32) u32 {
            return if (ChallengePeakHard())
                event + 1
            else
                event;
        }
        pub fn GetSceneIDs() [8]u32 {
            return .{
                challenge_planeID,
                challenge_floorID,
                challenge_entryID,
                challenge_worldID,
                challenge_monsterID,
                challenge_eventID,
                challenge_groupID,
                challenge_maze_groupID,
            };
        }
        pub fn GetPeakSceneIDs() [7]u32 {
            return .{
                challenge_planeID,
                challenge_floorID,
                challenge_entryID,
                challenge_monsterID,
                challenge_eventID,
                challenge_groupID,
                challenge_maze_groupID,
            };
        }
        pub fn GetCurSceneStatus() void {
            std.debug.print("SEND PLANE ID {} FLOOR ID {} ENTRY ID {} GROUP ID {} MAZE GROUP ID {}\n", .{
                challenge_planeID,
                challenge_floorID,
                challenge_entryID,
                challenge_groupID,
                challenge_maze_groupID,
            });
        }
    };
}

pub fn CustomMode() type {
    return struct {
        var challenge_node: u32 = 0;
        var selected_challenge_id: u32 = 0;
        var selected_buff_id: u32 = 0;
        var custom_mode: bool = false;

        pub fn FirstNode() bool {
            return challenge_node == 0;
        }

        pub fn ChangeNode() []const u8 {
            if (FirstNode()) {
                challenge_node += 1;
                return "Change Challenge Node 2\n";
            } else {
                challenge_node -= 1;
                return "Change Challenge Node 1\n";
            }
        }

        pub fn SelectCustomNode(node: u32) void {
            challenge_node = node - 1;
        }

        pub fn CustomMode() bool {
            return custom_mode;
        }

        pub fn SetCustomMode(check: bool) void {
            custom_mode = check;
        }

        pub fn GetCustomChallengeID() u32 {
            return selected_challenge_id;
        }
        pub fn SetCustomChallengeID(id: u32) void {
            selected_challenge_id = id;
        }

        pub fn GetCustomBuffID() u32 {
            return selected_buff_id;
        }
        pub fn SetCustomBuffID(id: u32) void {
            selected_buff_id = id;
        }
    };
}

pub fn Banner() type {
    return struct {
        var StandardBanner = [_]u32{ 1003, 1004, 1101, 1104, 1209, 1211 };
        var RateUp = [_]u32{1504};
        var RateUpFourStars = [_]u32{1224,1001,1013};

        pub fn GetStandardBanner() []const u32 {
            return &StandardBanner;
        }

        pub fn SetStandardBanner() []u32 {
            return &StandardBanner;
        }

        pub fn GetRateUp() []const u32 {
            return &RateUp;
        }

        pub fn SetRateUp() []u32 {
            return &RateUp;
        }

        pub fn GetRateUpFourStar() []const u32 {
            return &RateUpFourStars;
        }

        pub fn SetRateUpFourStar() []u32 {
            return &RateUpFourStars;
        }
    };
}
pub fn inlist(id: u32, list: []const u32) bool {
    for (list) |item| {
        if (item == id) {
            return true;
        }
    }
    return false;
}
pub fn contains(list: *const std.ArrayListAligned(u32, null), value: u32) bool {
    for (list.items) |item| {
        if (item == value) {
            return true;
        }
    }
    return false;
}
