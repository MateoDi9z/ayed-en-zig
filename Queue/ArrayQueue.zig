const std = @import("std");

pub const QueueError = error{ QueueOverflow, QueueUnderflow };

pub const ArrayQueue = struct {
    allocator: std.mem.Allocator,
    elements: []?i32,
    front: usize,
    rear: usize,
    count: usize,

    pub fn init(initialCapacity: usize) !ArrayQueue {
        const allocator = std.heap.page_allocator;
        const elements = try allocator.alloc(?i32, initialCapacity);

        // Con un puntero modifico cada elemento
        for (elements) |*e| e.* = null;

        return ArrayQueue{
            .allocator = allocator,
            .elements = elements,
            .front = 0,
            .rear = 0,
            .count = 0,
        };
    }

    pub fn enqueue(self: *ArrayQueue, element: i32) !void {
        // resize
        if (self.count == self.elements.len)
            try self.resize(self.elements.len * 2);

        self.elements[self.rear] = element; // add to arr
        // increment rear and wrap around
        self.rear = (self.rear + 1) % self.elements.len;
        self.count += 1; // add element
    }

    pub fn dequeue(self: *ArrayQueue) !i32 {
        // Avoid underflow
        if (self.count == 0)
            return QueueError.QueueUnderflow;

        // resize
        if (self.elements.len / 2 >= 1 and self.count == self.elements.len / 4)
            try self.resize(self.elements.len / 2);

        self.count -= 1; // remove element
        const element = self.elements[self.front].?; // Get element
        self.elements[self.front] = null; // Avoid Loitering
        self.front = (self.front + 1) % self.elements.len; // move front
        return element;
    }

    pub fn size(self: ArrayQueue) usize {
        return self.count;
    }

    fn resize(self: *ArrayQueue, new_capacity: usize) !void {
        const safe_capacity = @max(new_capacity, 1); // evitar capacidad cero
        const new_elements = try self.allocator.alloc(?i32, safe_capacity);

        // Ajustar la cantidad de elementos a copiar (hasta el nuevo tamaño)
        const limit = @min(self.count, safe_capacity);

        for (0..limit) |idx| {
            new_elements[idx] = self.elements[(self.front + idx) % self.elements.len];
        }

        for (limit..safe_capacity) |
            idx,
        | {
            new_elements[idx] = null;
        }

        self.allocator.free(self.elements);
        self.elements = new_elements;
        self.front = 0;
        self.rear = limit;
    }

    pub fn deinit(self: *ArrayQueue) void {
        self.allocator.free(self.elements);
    }

    pub fn iterator(self: *ArrayQueue) ArrayQueueIterator {
        return ArrayQueueIterator{
            .queue = self,
            .index = 0,
        };
    }
};

const ArrayQueueIterator = struct {
    queue: *ArrayQueue,
    index: usize,

    pub fn hasNext(self: *ArrayQueueIterator) bool {
        return self.index < self.queue.count;
    }

    pub fn next(self: *ArrayQueueIterator) QueueError!?i32 {
        if (!self.hasNext()) return QueueError.QueueOverflow;

        const real_index = (self.queue.front + self.index) % self.queue.elements.len;
        const val = self.queue.elements[real_index].?;
        self.index += 1;
        return val;
    }
};
