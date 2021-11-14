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

const Widget = struct {
    start_x: u16,
    start_y: u16,
    width: u16,
    height: u16,
    buffer: []u8,
    pub fn init(
        allocator: *std.mem.Allocator,
        x: u16,
        y: u16,
        width: u16,
        height: u16,
        default_value: u8,
    ) !@This() {
        var buf = try allocator.alloc(u8, width * height);
        for (buf) |*cell| {
            cell.* = default_value;
        }
        var widget = @This(){
            .start_x = x,
            .start_y = y,
            .width = width,
            .height = height,
            .buffer = buf,
        };
        return widget;
    }
    pub fn draw(self: @This()) void {
        var x: u16 = self.start_x;
        var y: u16 = self.start_y;
        for (self.buffer) |cell| {
            vt100.cursorpos(y, x);
            print("{c}", .{cell});
            if (x < self.width) {
                x += 1;
            } else {
                x = 1;
                y += 1;
            }
        }
    }
};

pub fn main() anyerror!void {
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

    const height = wsz.ws_row;
    const width = wsz.ws_col;

    var buffer: [max]u8 = undefined;
    const allocator = &std.heap.FixedBufferAllocator.init(&buffer).allocator;
    const window = try allocator.alloc(u8, width * height);
    defer allocator.free(window);

    const title = try Widget.init(allocator, 1, 1, width, 1, ' ');
    for ("PromTop") |char, idx| {
        title.buffer[idx] = char;
    }

    const top_line_break = try Widget.init(allocator, 1, 2, width, 1, '-');
    const bottom_line_break = try Widget.init(allocator, 1, height, width, 1, '-');

    vt100.clearscreen();
    while (true) {
        title.draw();
        top_line_break.draw();
        bottom_line_break.draw();
        time.sleep(time.ns_per_s * 10);
    }
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
