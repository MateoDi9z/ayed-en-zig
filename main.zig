const std = @import("std");

const Stack = struct {
    elements: [20]?i32,
    i: u32,

    pub fn init() Stack {
        return Stack{
            .elements = [_]?i32{null} ** 20,
            .i = 0,
        };
    }

    // TODO: Handle overflow
    pub fn push(self: *Stack, element: i32) void {
        self.elements[self.i] = element;
        self.i += 1;
    }

    // TODO: Handle underflow
    pub fn pop(self: *Stack) i32 {
        self.i -= 1;
        const last: i32 = self.elements[self.i].?;
        self.elements[self.i] = null; // Avoid Loitering
        return last;
    }

    pub fn size(self: Stack) u32 {
        return self.i;
    }

    pub fn see(self: Stack) void {
        std.debug.print("Elementos: [", .{});

        for (self.elements) |n| {
            if (n) |value| {
                std.debug.print(" {} ", .{value});
            } else {
                std.debug.print(" null ", .{});
            }
        }

        std.debug.print("] \n", .{});
    }
};

pub fn main() void {
    // std.debug.print("Hello {s}\n", .{"Word"});

    var miStack = Stack.init();

    miStack.see();
    miStack.push(1);
    miStack.push(2);
    miStack.push(3);
    _ = miStack.pop();

    miStack.see();
}
