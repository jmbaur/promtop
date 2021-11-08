const std = @import("std");
const linux = std.os.linux;
const os = std.os;
const print = std.debug.print;
const time = std.time;

const vt100 = @import("./vt100.zig");

const OutputError = error{
    NotATty,
    WinSizeError,
};

const max = 1 << 16;

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

    // Default to empty cells
    for (window) |_, idx| {
        window[idx] = ' ';
    }

    // Fill program title
    for ("PromTop") |char, idx| {
        window[idx] = char;
    }

    // Fill line break with dashes
    {
        const start = width;
        const end = start + width;
        var x: u16 = start;
        while (x < end) {
            window[x] = '-';
            x += 1;
        }
    }

    vt100.clearscreen();
    while (true) {
        // Draw to screen
        for (window) |cell, idx| {
            const x = idx % width + 1;
            const y = @divFloor(idx, width) + 1;
            vt100.cursorpos(y, x);
            print("{c}", .{cell});
        }

        time.sleep(time.ns_per_s * 10);
    }
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
