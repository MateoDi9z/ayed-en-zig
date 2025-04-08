const std = @import("std");

const StackError = error{ StackOverflow, StackUnderflow };

// TODO: iterate over ArrayStack
pub const ArrayStack = struct {
    allocator: std.mem.Allocator,
    elements: []?i32,
    capacity: usize,
    i: usize,

    pub fn init(initialCapacity: usize) !ArrayStack {
        const allocator = std.heap.page_allocator;
        const elements = try allocator.alloc(?i32, initialCapacity);

        // Con un puntero modifico cada elemento
        for (elements) |*e| e.* = null;

        return ArrayStack{
            .allocator = allocator,
            .elements = elements,
            .i = 0,
            .capacity = initialCapacity,
        };
    }

    pub fn push(self: *ArrayStack, element: i32) !void {
        if (self.i == self.elements.len)
            try self.resize(self.capacity * 2);

        self.elements[self.i] = element;
        self.i += 1;
    }

    pub fn pop(self: *ArrayStack) !i32 {
        if (self.i <= self.capacity / 4)
            try self.resize(self.capacity / 2);

        if (self.i == 0) {
            return StackError.StackUnderflow;
        }

        self.i -= 1;
        const last: i32 = self.elements[self.i].?;
        self.elements[self.i] = null; // Avoid Loitering
        return last;
    }

    pub fn size(self: ArrayStack) u32 {
        return self.i;
    }

    // Takes new size and resize elements array
    fn resize(self: *ArrayStack, newCapacity: usize) !void {
        const safeCapacity = @max(newCapacity, 1); // evitar capacidad cero
        const new_elements = try self.allocator.alloc(?i32, safeCapacity);

        // Ajustar la cantidad de elementos a copiar (hasta el nuevo tamaño)
        const limit = @min(self.i, safeCapacity);

        for (0..limit) |idx| {
            new_elements[idx] = self.elements[idx];
        }

        for (limit..safeCapacity) |idx| {
            new_elements[idx] = null;
        }

        self.allocator.free(self.elements);
        self.elements = new_elements;
        self.capacity = newCapacity;
    }

    pub fn see(self: ArrayStack) void {
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

    pub fn deinit(self: *ArrayStack) void {
        self.allocator.free(self.elements);
    }
};
