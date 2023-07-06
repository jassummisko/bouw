local function SelectItemByName(item: string): boolean, Error
    local currentSlot = turtle.getItemDetail()
    if not (currentSlot is nil) and currentSlot.name == item then
        return true
    else
        for i=1, 16 do
            currentSlot = turtle.getItemDetail(i)
            if not (currentSlot is nil) then
                if currentSlot.name == item then
                    turtle.select(i)
                    return true
                end
            end
        end
        return false, "Item not fount"
    end
end

local function writeTable(t: {any}) 
    local s = "{ "
    for _, e in ipairs(t) do 
        s = s .. tostring(e) .. " "
    end
    s = s .. "}"

    io.write(s)
end

return {
    writeTable = writeTable,
    SelectItemByName = SelectItemByName,
}