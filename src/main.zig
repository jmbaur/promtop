const std = @import("std");
const c = @cImport(@cInclude("ncursesw/curses.h"));

const err = error{CursesError};

const Window = struct { win: *c.WINDOW };

pub fn main() anyerror!void {
    const res = c.initscr();
    if (@ptrToInt(res) == 0) {
        return err.CursesError;
    }
    const scr = Window{ .win = res };

    _ = c.start_color();

    _ = c.mvaddstr(0, 0, "PomTop");

    if (c.has_colors() and c.COLOR_PAIRS >= 13) {
        _ = c.init_pair(1, c.COLOR_RED, c.COLOR_BLACK);
        _ = c.init_pair(2, c.COLOR_GREEN, c.COLOR_BLACK);
        _ = c.init_pair(3, c.COLOR_YELLOW, c.COLOR_BLACK);
        _ = c.init_pair(4, c.COLOR_BLUE, c.COLOR_BLACK);
        _ = c.init_pair(5, c.COLOR_MAGENTA, c.COLOR_BLACK);
        _ = c.init_pair(6, c.COLOR_CYAN, c.COLOR_BLACK);
        _ = c.init_pair(7, c.COLOR_BLUE, c.COLOR_WHITE);
        _ = c.init_pair(8, c.COLOR_WHITE, c.COLOR_RED);
        _ = c.init_pair(9, c.COLOR_BLACK, c.COLOR_GREEN);
        _ = c.init_pair(10, c.COLOR_BLUE, c.COLOR_YELLOW);
        _ = c.init_pair(11, c.COLOR_WHITE, c.COLOR_BLUE);
        _ = c.init_pair(12, c.COLOR_WHITE, c.COLOR_MAGENTA);
        _ = c.init_pair(13, c.COLOR_BLACK, c.COLOR_CYAN);

        var n: i8 = 0;
        while (n <= 13) {
            _ = c.color_set(n, null);
            _ = c.mvaddstr(6 + n, 32, "Hello, World!");
            n = n + 1;
        }
    }

    _ = c.refresh();

    while (true) {
        std.time.sleep(5 * std.time.ns_per_s);
    }

    _ = c.delwin(scr.win);
    _ = c.endwin();
    _ = c.refresh();
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
