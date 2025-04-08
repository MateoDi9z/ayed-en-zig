const std = @import("std");
const testing = std.testing;

const StackError = error{ StackOverflow, StackUnderflow };

// Importar la definición del Stack:
const Stack = @import("ArrayStack.zig").ArrayStack;

test "Stack initializes and is empty" {
    var stack = try Stack.init(4);
    defer stack.deinit();

    try testing.expectEqual(@as(usize, 0), stack.i);
    try testing.expectEqual(@as(usize, 4), stack.capacity);
}

test "Push and Pop basic functionality" {
    var stack = try Stack.init(2);
    defer stack.deinit();

    try stack.push(10);
    try stack.push(20);
    try testing.expectEqual(@as(i32, 20), try stack.pop());
    try testing.expectEqual(@as(i32, 10), try stack.pop());
}

test "Stack resizes up when full" {
    var stack = try Stack.init(2);
    defer stack.deinit();

    try stack.push(1);
    try stack.push(2);
    try stack.push(3); // debería disparar resize a 4

    try testing.expect(stack.capacity >= 3);
    try testing.expectEqual(@as(i32, 3), try stack.pop());
}

test "Stack resizes down when quarter full" {
    var stack = try Stack.init(8);
    defer stack.deinit();

    for (0..8) |i| try stack.push(@intCast(i));
    for (0..7) |_| _ = try stack.pop();

    try testing.expect(stack.capacity < 8);
}

test "Underflow returns proper error" {
    var stack = try Stack.init(2);
    defer stack.deinit();

    const result = stack.pop();
    try testing.expectError(StackError.StackUnderflow, result);
}
