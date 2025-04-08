const std = @import("std");
const Stack = @import("./Stack/ArrayStack.zig").ArrayStack;

pub fn main() !void {
    var miStack = try Stack.init(8);
    defer miStack.deinit(); // Liberar la memoria al final

    miStack.see();

    for (0..200) |idx| {
        try miStack.push(@intCast(idx));
    }

    miStack.see();

    for (0..190) |_| {
        _ = try miStack.pop();
    }

    miStack.see();
}
