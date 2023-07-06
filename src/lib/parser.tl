local function IterateLine(file: File): function(): (integer, string)
    local i = 0
    return function(): (integer, string)
        i = i + 1
        local line = file.readLine()
        if line then 
            return i, line
        end
    end
end

return {
    IterateLine = IterateLine
}