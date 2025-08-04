local EventSystem = {
    listeners = {}
}

function EventSystem:register(eventName, callback)
    if not self.listeners[eventName] then
        self.listeners[eventName] = {}
    end
    table.insert(self.listeners[eventName], callback)
end

function EventSystem:unregister(eventName, callback)
    local list = self.listeners[eventName]
    if not list then return end
    for i, cb in ipairs(list) do
        if cb == callback then
            table.remove(list, i)
            break
        end
    end
end

function EventSystem:emit(eventName, ...)
    local list = self.listeners[eventName]
    if not list then return end
    for _, cb in ipairs(list) do
        cb(...)
    end
end

return EventSystem
