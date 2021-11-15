const std = @import("std");
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

const Widget = struct {
    start_x: u16,
    start_y: u16,
    size: Size,
    buffer: []u8,
    pub fn init(
        allocator: *std.mem.Allocator,
        x: u16,
        y: u16,
        size: Size,
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
                    print("{c}", .{cell});
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

    const title = try Widget.init(allocator, 0, 0, Size{ .width = wsz.width, .height = 1 }, ' ');
    title.update("Proxmox");

    const top_line_break = try Widget.init(allocator, 0, 1, Size{ .width = wsz.width, .height = 1 }, '-');
    const middle_line_partition = try Widget.init(allocator, (wsz.width / 2) - 1, 2, Size{ .width = 1, .height = wsz.height - 3 }, '|');
    const bottom_line_break = try Widget.init(allocator, 0, wsz.height - 1, Size{ .width = wsz.width, .height = 1 }, '-');

    var title_frame = async title.draw();
    var tlb_frame = async top_line_break.draw();
    var mlp_frame = async middle_line_partition.draw();
    var blb_frame = async bottom_line_break.draw();

    vt100.clearscreen();
    while (true) {
        resume title_frame;
        resume tlb_frame;
        resume mlp_frame;
        resume blb_frame;
        // Place cursor at bottom right after each draw
        vt100.cursorpos(wsz.height, wsz.width);
        time.sleep(time.ns_per_s * 10);
    }
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
