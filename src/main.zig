const std = @import("std");

pub fn main() anyerror!void {
    while (true) {
        std.debug.print("PromTop\n", .{});
        std.time.sleep(std.time.ns_per_min * 100000);
    }
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
