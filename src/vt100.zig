const print = @import("std").debug.print;

// pub const setnl = "\x1B[20h"; // LMN             Set new line mode
// pub const setappl = "\x1B[?1h"; // DECCKM        Set cursor key to application
// pub const setansi = "none"; // DECANM        Set ANSI (versus VT52)
// pub const setcol = "\x1B[?3h"; // DECCOLM        Set number of columns to 132
// pub const setsmooth = "\x1B[?4h"; // DECSCLM     Set smooth scrolling
// pub const setrevscrn = "\x1B[?5h"; // DECSCNM    Set reverse video on screen
// pub const setorgrel = "\x1B[?6h"; // DECOM       Set origin to relative
// pub const setwrap = "\x1B[?7h"; // DECAWM        Set auto-wrap mode
// pub const setrep = "\x1B[?8h"; // DECARM         Set auto-repeat mode
// pub const setinter = "\x1B[?9h"; // DECINLM      Set interlacing mode

// pub const setlf = "\x1B[20l"; // LMN             Set line feed mode
// pub const setcursor = "\x1B[?1l"; // DECCKM      Set cursor key to cursor
// pub const setvt52 = "\x1B[?2l"; // DECANM        Set VT52 (versus ANSI)
// pub const resetcol = "\x1B[?3l"; // DECCOLM      Set number of columns to 80
// pub const setjump = "\x1B[?4l"; // DECSCLM       Set jump scrolling
// pub const setnormscrn = "\x1B[?5l"; // DECSCNM   Set normal video on screen
// pub const setorgabs = "\x1B[?6l"; // DECOM       Set origin to absolute
// pub const resetwrap = "\x1B[?7l"; // DECAWM      Reset auto-wrap mode
// pub const resetrep = "\x1B[?8l"; // DECARM       Reset auto-repeat mode
// pub const resetinter = "\x1B[?9l"; // DECINLM    Reset interlacing mode

// pub const altkeypad = "\x1B="; // DECKPAM     Set alternate keypad mode
// pub const numkeypad = "\x1B>"; // DECKPNM     Set numeric keypad mode

// pub const setss2 = "\x1BN"; // SS2            Set single shift 2
// pub const setss3 = "\x1BO"; // SS3            Set single shift 3

// pub const modesoff = "\x1B[m"; // SGR0         Turn off character attributes
// pub const modesoff = "\x1B[0m"; // SGR0         Turn off character attributes
pub const bold = "\x1B[1m"; // SGR1             Turn bold mode on
// pub const lowint = "\x1B[2m"; // SGR2           Turn low intensity mode on
// pub const underline = "\x1B[4m"; // SGR4        Turn underline mode on
// pub const blink = "\x1B[5m"; // SGR5            Turn blinking mode on
// pub const reverse = "\x1B[7m"; // SGR7          Turn reverse video on
// pub const invisible = "\x1B[8m"; // SGR8        Turn invisible text mode on

// pub const setwin = "\x1B[<v>;<v>r"; // DECSTBM        Set top and bottom line#s of a window

pub fn cursorup(n: usize) void {
    print("\x1B[{0d:0>2}A", .{n}); //(n) CUU       Move cursor up n lines
}

pub fn cursordn(n: usize) void {
    print("\x1B[{0d:0>2}B", .{n}); //(n) CUD       Move cursor down n lines
}

// pub const cursorrt = "\x1B[<n>C"; //(n) CUF       Move cursor right n lines
// pub const cursorlf = "\x1B[<n>D"; //(n) CUB       Move cursor left n lines
// pub const cursorhome = "\x1B[H"; //            Move cursor to upper left corner
// pub const cursorhome = "\x1B[;H"; //            Move cursor to upper left corner

//(v,h) CUP    Move cursor to screen location v,h
// Positions are one-indexed
pub fn cursorpos(v: usize, h: usize) void {
    print("\x1B[{0d:0>2};{1d:0>2}H", .{ v, h });
}

// pub const hvhome = "\x1B[f"; //                Move cursor to upper left corner
// pub const hvhome = "\x1B[;f"; //                Move cursor to upper left corner
// pub const hvpos = "\x1B[<v>;<h>f"; //(v,h) CUP        Move cursor to screen location v,h
// pub const index = "\x1BD"; // IND             Move/scroll window up one line
// pub const revindex = "\x1BM"; // RI           Move/scroll window down one line
// pub const nextline = "\x1BE"; // NEL          Move to next line
// pub const savecursor = "\x1B7"; // DECSC      Save cursor position and attributes
// pub const restorecursor = "\x1B8"; // DECSC   Restore cursor position and attributes

// pub const tabset = "\x1BH"; // HTS            Set a tab at the current column
// pub const tabclr = "\x1B[g"; // TBC            Clear a tab at the current column
// pub const tabclr = "\x1B[0g"; // TBC            Clear a tab at the current column
// pub const tabclrall = "\x1B[3g"; // TBC         Clear all tabs

// pub const dhtop = "\x1B#3"; // DECDHL          Double-height letters, top half
// pub const dhbot = "\x1B#4"; // DECDHL          Double-height letters, bottom half
// pub const swsh = "\x1B#5"; // DECSWL           Single width, single height letters
// pub const dwsh = "\x1B#6"; // DECDWL           Double width, single height letters

// pub const cleareol = "\x1B[K"; // EL0          Clear line from cursor right
// pub const cleareol = "\x1B[0K"; // EL0          Clear line from cursor right
// pub const clearbol = "\x1B[1K"; // EL1          Clear line from cursor left
// pub const clearline = "\x1B[2K"; // EL2         Clear entire line

pub const cleareos = "\x1B[J"; // ED0          Clear screen from cursor down
// pub const cleareos = "\x1B[0J"; // ED0          Clear screen from cursor down
pub const clearbos = "\x1B[1J"; // ED1          Clear screen from cursor up

pub fn clearscreen() void {
    print("\x1B[2J", .{}); // ED2       Clear entire screen
}

// pub const devstat = "\x1B5n"; // DSR           Device status report
// pub const termok = "\x1B0n"; // DSR               Response: terminal is OK
// pub const termnok = "\x1B3n"; // DSR              Response: terminal is not OK

// pub const getcursor = "\x1B6n"; // DSR         Get cursor position
// pub const cursorpos = "\x1B<v>;<h>R"; // CPR            Response: cursor is at v,h

// pub const ident = "\x1B[c"; // DA              Identify what terminal type
// pub const ident = "\x1B[0c"; // DA              Identify what terminal type (another)
// pub const gettype = "\x1B[?1;<n>0c"; // DA               Response: terminal type code n

// pub const reset = "\x1Bc"; // RIS             Reset terminal to initial state

// pub const _align = "\x1B#8"; // DECALN          Screen alignment display
// pub const testpu = "\x1B[2;1y"; // DECTST         Confidence power up test
// pub const testlb = "\x1B[2;2y"; // DECTST         Confidence loopback test
// pub const testpurep = "\x1B[2;9y"; // DECTST      Repeat power up test
// pub const testlbrep = "\x1B[2;10y"; // DECTST      Repeat loopback test

// pub const ledsoff = "\x1B[0q"; // DECLL0        Turn off all four leds
// pub const led1 = "\x1B[1q"; // DECLL1           Turn on LED #1
// pub const led2 = "\x1B[2q"; // DECLL2           Turn on LED #2
// pub const led3 = "\x1B[3q"; // DECLL3           Turn on LED #3
// pub const led4 = "\x1B[4q"; // DECLL4           Turn on LED #4
