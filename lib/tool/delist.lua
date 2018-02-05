
local function new_list()
    local head
    local tail
    local count = 0

    local list = {}

    function list.pop()
        if count > 0 then
            local item = head
            head = item.next
            item.next = nil
            if head then
                head.front = nil
            end
            count = count - 1
            if count == 0 then
                tail = nil
            end
            return item
        end
    end

    function list.head()
        return head
    end

    function list.push(item)
        if list.has(item) then
            return false
        else
            if tail then
                tail.next = item
            end
            item.front = tail
            tail = item
            count = count + 1
            if not head then
                head = item
            end
            return true
        end
    end

    function list.remove(item)
        if list.has(item) then
            local front = item.front
            local next = item.next
            if front then
                front.next = next
            end
            if next then
                next.front = front
            end
            item.front = nil
            item.next = nil
            if item == head then
                head = next
            end
            if item == tail then
                tail = front
            end
            return true
        else
            return false
        end
    end

    function list.get_all()
        local ret = {}
        local item = head
        while item do
            ret[#ret+1] = item.value
            item = item.next
        end
        return ret
    end

    function list.has(item)
        return item.front or item.next
    end

    function list.count()
        return count
    end

    return list
end

return new_list
