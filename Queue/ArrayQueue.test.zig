const std = @import("std");
const testing = std.testing;

const QueueError = @import("ArrayQueue.zig").QueueError;
const Queue = @import("ArrayQueue.zig").ArrayQueue;

test "Queue initializes and is empty" {
    var queue = try Queue.init(4);
    defer queue.deinit();

    try testing.expectEqual(@as(usize, 0), queue.size());
    try testing.expectEqual(@as(usize, 4), 4);
}

test "enqueue adds elementos to queue" {
    var queue = try Queue.init(2);
    defer queue.deinit();

    try queue.enqueue(10);
    try queue.enqueue(20);

    try testing.expectEqual(@as(usize, 2), queue.size());
}

test "Dequeue removes elements in FIFO order" {
    var queue = try Queue.init(4);
    defer queue.deinit();

    try queue.enqueue(10);
    try queue.enqueue(20);

    try testing.expectEqual(@as(i32, 10), try queue.dequeue());
    try testing.expectEqual(@as(i32, 20), try queue.dequeue());
}

test "Dequeue on empty queue returns error" {
    var queue = try Queue.init(4);
    defer queue.deinit();

    const result = queue.dequeue();
    try testing.expectError(QueueError.QueueUnderflow, result);
}

test "Queue resizes up when full" {
    var queue = try Queue.init(4);
    defer queue.deinit();

    try queue.enqueue(10);
    try testing.expectEqual(@as(usize, 4), queue.elements.len);

    try queue.enqueue(20);
    try queue.enqueue(10);
    try queue.enqueue(10);
    try queue.enqueue(10); // -> full => resize

    try testing.expectEqual(@as(usize, 8), queue.elements.len);
}

test "Queue handles circular indexing correctly" {
    var queue = try Queue.init(3);
    defer queue.deinit();

    try queue.enqueue(1);
    try queue.enqueue(2);
    _ = try queue.dequeue(); // Eliminar un elemento
    try queue.enqueue(3);
    try queue.enqueue(4); // Debería usar el espacio liberado

    try testing.expectEqual(@as(i32, 2), try queue.dequeue());
    try testing.expectEqual(@as(i32, 3), try queue.dequeue());
    try testing.expectEqual(@as(i32, 4), try queue.dequeue());
}

test "Queue resizes down when quarter full" {
    var queue = try Queue.init(8);
    defer queue.deinit();

    for (0..8) |i| try queue.enqueue(@intCast(i));
    for (0..7) |_| _ = try queue.dequeue();

    try testing.expect(queue.elements.len < 8);
}

test "Queue iterator works as expected" {
    var queue = try Queue.init(4);
    defer queue.deinit();

    try queue.enqueue(10);
    try queue.enqueue(20);
    try queue.enqueue(30);

    var iter = queue.iterator();
    const expected = [_]i32{ 10, 20, 30 };
    var index: usize = 0;

    while (iter.hasNext()) {
        const val = try iter.next();
        try testing.expectEqual(expected[index], val.?);
        index += 1;
    }

    try testing.expectEqual(expected.len, index);
}

test "Queue handles multiple resizes up and down" {
    var queue = try Queue.init(2);
    defer queue.deinit();

    for (0..20) |i| try queue.enqueue(@intCast(i)); // fuerza varios resizes hacia arriba
    try testing.expect(queue.elements.len >= 20);

    for (0..18) |_| _ = try queue.dequeue(); // debería forzar varios downsizes
    try testing.expect(queue.elements.len < 20);
}

test "Dequeue after wrap-around works correctly" {
    var queue = try Queue.init(3);
    defer queue.deinit();

    try queue.enqueue(1);
    try queue.enqueue(2);
    _ = try queue.dequeue(); // libera posición 0
    try queue.enqueue(3);
    try queue.enqueue(4); // rear debe envolver

    try testing.expectEqual(@as(i32, 2), try queue.dequeue());
    try testing.expectEqual(@as(i32, 3), try queue.dequeue());
    try testing.expectEqual(@as(i32, 4), try queue.dequeue());
}

test "Queue maintains correctness with mixed operations" {
    var queue = try Queue.init(4);
    defer queue.deinit();

    try queue.enqueue(100);
    try queue.enqueue(200);
    _ = try queue.dequeue();
    try queue.enqueue(300);
    try queue.enqueue(400);
    _ = try queue.dequeue();
    try queue.enqueue(500);

    try testing.expectEqual(@as(i32, 300), try queue.dequeue());
    try testing.expectEqual(@as(i32, 400), try queue.dequeue());
    try testing.expectEqual(@as(i32, 500), try queue.dequeue());
}

test "Queue can be deinitialized after usage without errors" {
    var queue = try Queue.init(4);
    try queue.enqueue(1);
    try queue.enqueue(2);
    _ = try queue.dequeue();
    queue.deinit(); // no debería crashear ni filtrar memoria
}

test "Iterator reflects correct order after wrap-around" {
    var queue = try Queue.init(4);
    defer queue.deinit();

    try queue.enqueue(1);
    try queue.enqueue(2);
    _ = try queue.dequeue();
    try queue.enqueue(3);
    try queue.enqueue(4);
    try queue.enqueue(5); // esto provoca wrap-around

    const expected = [_]i32{ 2, 3, 4, 5 };
    var iter = queue.iterator();
    var i: usize = 0;

    while (iter.hasNext()) {
        const val = try iter.next();
        try testing.expectEqual(expected[i], val.?);
        i += 1;
    }

    try testing.expectEqual(expected.len, i);
}
