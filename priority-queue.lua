local floor = math.floor

local PriorityQueue = {}
PriorityQueue.__index = PriorityQueue

function PriorityQueue.new()
    local self = setmetatable({}, PriorityQueue)
    self:initialize()
    return self
end

function PriorityQueue:initialize()
    self.heap = {}
    self.current_size = 0
end

function PriorityQueue:empty()
    return self.current_size == 0
end

function PriorityQueue:size()
    return self.current_size
end

function PriorityQueue:swim()
    local heap = self.heap
    local i = self.current_size

    while floor(i / 2) > 0 do
        local parent = floor(i / 2)
        if heap[i][2] < heap[parent][2] then
            heap[i], heap[parent] = heap[parent], heap[i]
            i = parent
        else
            break
        end
    end
end

function PriorityQueue:put(value, priority)
    self.current_size = self.current_size + 1
    self.heap[self.current_size] = {value, priority}
    self:swim()
end

function PriorityQueue:sink()
    local size = self.current_size
    local heap = self.heap
    local i = 1

    while (i * 2) <= size do
        local min_child = self:min_child(i)
        if heap[i][2] > heap[min_child][2] then
            heap[i], heap[min_child] = heap[min_child], heap[i]
            i = min_child
        else
            break
        end
    end
end

function PriorityQueue:min_child(i)
    local left_child = i * 2
    local right_child = i * 2 + 1

    if right_child > self.current_size then
        return left_child
    else
        return self.heap[left_child][2] < self.heap[right_child][2] 
            and left_child 
            or right_child
    end
end

function PriorityQueue:pop()
    if self:empty() then
        return nil
    end

    local heap = self.heap
    local min_value = heap[1][1]
    
    heap[1] = heap[self.current_size]
    heap[self.current_size] = nil
    self.current_size = self.current_size - 1
    
    if self.current_size > 0 then
        self:sink()
    end
    
    return min_value
end


function PriorityQueue:peek()
    if self:empty() then
        return nil, nil
    end
    return self.heap[1][1], self.heap[1][2]
end

function PriorityQueue:list()
    local result = {}
    for i = 1, self.current_size do
        table.insert(result, {self.heap[i][1], self.heap[i][2]})
    end
    table.sort(result, function(a, b) return a[2] < b[2] end)
    return result
end

function PriorityQueue:clear()
    self:initialize()
end

return PriorityQueue
