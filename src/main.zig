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

const max = 1 << 8;

const bounded_row = std.BoundedArray(u8, max);

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

    var buffer: [max * max]u8 = undefined;
    const allocator = &std.heap.FixedBufferAllocator.init(&buffer).allocator;
    const rows = try allocator.alloc(bounded_row, wsz.ws_row + 1);
    defer allocator.free(rows);

    var x: u16 = undefined;
    var y: u16 = undefined;

    y = 0;
    while (y < rows.len) {
        const cols = try bounded_row.init(wsz.ws_col + 1);
        rows[y] = cols;
        y += 1;
    }

    for ("PromTop") |char, idx| {
        rows[1].set(idx + 1, char);
    }

    x = 0;
    while (x < wsz.ws_col) {
        rows[2].set(x + 1, '-');
        rows[rows.len - 1].set(x + 1, '-');
        x += 1;
    }

    vt100.clearscreen();

    while (true) {
        // Draw to screen
        for (rows) |cols, row_idx| {
            for (cols.constSlice()) |cell, col_idx| {
                vt100.cursorpos(row_idx, col_idx);
                print("{c}", .{cell});
            }
        }
        time.sleep(time.ns_per_s * 10);
    }
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
