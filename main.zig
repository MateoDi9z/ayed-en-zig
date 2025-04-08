const std = @import("std");

const StackError = error{ StackOverflow, StackUnderflow };

// TODO: resize Stack
// TODO: iterate over Stack
const Stack = struct {
    elements: [20]?i32,
    i: u32,

    pub fn init() Stack {
        return Stack{
            .elements = [_]?i32{null} ** 20,
            .i = 0,
        };
    }

    pub fn push(self: *Stack, element: i32) StackError!void {
        if (self.i == self.elements.len) {
            std.debug.print("The stack is full", .{});
            return StackError.StackOverflow;
        }

        std.debug.print("> Add element \n", .{});
        self.elements[self.i] = element;
        self.i += 1;
    }

    pub fn pop(self: *Stack) StackError!i32 {
        if (self.i == 0) {
            std.debug.print("The stack is empty", .{});
            return StackError.StackUnderflow;
        }

        std.debug.print("> Remove element \n", .{});
        self.i -= 1;
        const last: i32 = self.elements[self.i].?;
        self.elements[self.i] = null; // Avoid Loitering
        return last;
    }

    pub fn size(self: Stack) u32 {
        return self.i;
    }

    pub fn see(self: Stack) void {
        if (self.i == 0) return std.debug.print("Stack is empty. \n", .{});

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

pub fn main() !void {
    // std.debug.print("Hello {s}\n", .{"Word"});

    var miStack = Stack.init();

    miStack.see();
    try miStack.push(1);
    try miStack.push(2);
    try miStack.push(3);
    _ = try miStack.pop();
    _ = try miStack.pop();

    miStack.see();
}
