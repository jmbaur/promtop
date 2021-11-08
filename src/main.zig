const std = @import("std");
const os = std.os;
const linux = std.os.linux;
const print = std.debug.print;
const vt100 = @import("./vt100.zig");

const OutputError = error{
    NotATty,
    WinSizeError,
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

    const msg = "PromTop";

    while (true) {
        const middle = (wsz.ws_col / 2) - (msg.len / 2);
        vt100.clearscreen();
        vt100.cursorpos(1, middle);
        print(msg, .{});
        vt100.cursorpos(wsz.ws_row, wsz.ws_col);
        std.time.sleep(std.time.ns_per_min * 100000);
    }
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
