const std = @import("std");
const io = std.io;
const linux = std.os.linux;
const math = std.math;
const os = std.os;
const print = std.debug.print;
const time = std.time;

const vt100 = @import("./vt100.zig");

const OutputError = error{
    NotATty,
    WinSizeError,
};

const max = 1 << 16;

const Size = struct { width: u16, height: u16 };

const stdout = std.io.getStdOut().writer();

const Widget = struct {
    start_x: u16,
    start_y: u16,
    size: Size,
    buffer: []u8,
    update_interval: i8,
    last_updated: u8,
    drawn: bool,
    pub fn init(
        allocator: *std.mem.Allocator,
        x: u16,
        y: u16,
        size: Size,
        update_interval: i8,
        default_value: u8,
    ) !@This() {
        var buf = try allocator.alloc(u8, size.width * size.height);
        for (buf) |*cell| {
            cell.* = default_value;
        }
        var widget = @This(){
            .start_x = x,
            .start_y = y,
            .size = size,
            .update_interval = update_interval,
            .last_updated = 0,
            .drawn = false,
            .buffer = buf,
        };
        return widget;
    }
    pub fn update(self: @This(), contents: []const u8) void {
        for (self.buffer) |*cell, idx| {
            if (contents.len < idx + 1) {
                break;
            }
            cell.* = contents[idx];
        }
    }
    pub fn draw(self: @This()) void {
        while (true) {
            suspend {
                var x: u16 = 1;
                var y: u16 = 1;
                for (self.buffer) |cell| {
                    // TODO(jared): make program flag for controlling this
                    // time.sleep(time.ns_per_s * 0.05);
                    vt100.cursorpos(y + self.start_y, x + self.start_x);
                    stdout.print("{c}", .{cell}) catch {};
                    if (x < self.size.width) {
                        x += 1;
                    } else {
                        x = 1;
                        y += 1;
                    }
                }
            }
        }
    }
};

fn win_size() !Size {
    const handle = try os.open("/dev/stdout", os.O.RDONLY, 0);

    if (!os.isatty(handle)) {
        return OutputError.NotATty;
    }

    var wsz: linux.winsize = undefined;
    const fd = @bitCast(usize, @as(isize, handle));
    const rc = linux.syscall3(.ioctl, fd, linux.T.IOCGWINSZ, @ptrToInt(&wsz));
    if (linux.getErrno(rc) != linux.E.SUCCESS) {
        return OutputError.WinSizeError;
    }

    return Size{ .height = wsz.ws_row, .width = wsz.ws_col };
}

pub fn main() anyerror!void {
    const wsz = try win_size();

    var buffer: [max]u8 = undefined;
    const allocator = &std.heap.FixedBufferAllocator.init(&buffer).allocator;

    var title = try Widget.init(allocator, 0, 0, Size{ .width = wsz.width, .height = 1 }, -1, ' ');
    title.update("PromTop");

    var top_line_break = try Widget.init(allocator, 0, 1, Size{ .width = wsz.width, .height = 1 }, -1, '-');
    var middle_line_partition = try Widget.init(allocator, (wsz.width / 2) - 1, 2, Size{ .width = 1, .height = wsz.height - 3 }, -1, '|');
    var bottom_line_break = try Widget.init(allocator, 0, wsz.height - 1, Size{ .width = wsz.width, .height = 1 }, -1, '-');

    var title_frame = async title.draw();
    var tlb_frame = async top_line_break.draw();
    var mlp_frame = async middle_line_partition.draw();
    var blb_frame = async bottom_line_break.draw();

    vt100.clearscreen();
    while (true) {
        if (!title.drawn or title.last_updated == title.update_interval) {
            title.last_updated = 0;
            title.drawn = true;
            print("Updating title\n", .{});
            resume title_frame;
        } else {
            title.last_updated += 1;
        }
        if (!top_line_break.drawn or top_line_break.last_updated == top_line_break.update_interval) {
            top_line_break.last_updated = 0;
            top_line_break.drawn = true;
            print("Updating TLB\n", .{});
            resume tlb_frame;
        } else {
            top_line_break.last_updated += 1;
        }
        if (!middle_line_partition.drawn or middle_line_partition.last_updated == middle_line_partition.update_interval) {
            middle_line_partition.last_updated = 0;
            middle_line_partition.drawn = true;
            print("Updating MLP\n", .{});
            resume mlp_frame;
        } else {
            middle_line_partition.last_updated += 1;
        }
        if (!bottom_line_break.drawn or bottom_line_break.last_updated == bottom_line_break.update_interval) {
            bottom_line_break.last_updated = 0;
            bottom_line_break.drawn = true;
            print("Updating BLB\n", .{});
            resume blb_frame;
        } else {
            bottom_line_break.last_updated += 1;
        }
        // Place cursor at bottom right after each draw
        vt100.cursorpos(wsz.height, wsz.width);
        time.sleep(time.ns_per_s * 1);
    }
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
