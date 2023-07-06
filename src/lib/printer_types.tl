local type Vector3 = {integer, integer, integer}

local record BlockEntry 
    pos: Vector3
    block: string
end

local function NewBlockEntry(pos: Vector3, block: string): BlockEntry 
    return {
        pos = pos,
        block = block,
    }
end

local function VerifyBlockEntry(entry: BlockEntry): Error
    if #entry.pos ~= 3 then 
        return "Position of block is not of valid type Vector3" 
    end

    for i=1, 3 do
        local field = entry.pos[i]

        if not (type(field) == "integer" or type(field) == "number") then
            return "Field is not a number" 
        end

        if field % 1 ~= 0 then 
            return "Field is not an integer"
        end
    end

    if not (type(entry.block) == "string") then
        return "Block is not of type 'string'"
    end
end

local record Model
    blocks: {BlockEntry}
    size: Vector3
end

local function NewModel(blockEntries: {BlockEntry}): Model
    local function findSizeAndExtremes(blocks: {BlockEntry}): (Vector3, Vector3)
        local lowest_extremes: Vector3  = {}
        local highest_extremes: Vector3 = {}

        for _, block in ipairs(blocks) do
            for i, pos in ipairs(block.pos) do 
                if lowest_extremes[i] == nil then lowest_extremes[i] = pos end  
                if highest_extremes[i] == nil then highest_extremes[i] = pos end  
                local currentLowest = lowest_extremes[i]
                local currentHighest = highest_extremes[i]
                if pos < currentLowest then lowest_extremes[i] = pos end
                if pos > currentHighest then highest_extremes[i] = pos end
            end
        end

        local size: Vector3 = {
            highest_extremes[1] - lowest_extremes[1] + 1,
            highest_extremes[2] - lowest_extremes[2] + 1,
            highest_extremes[3] - lowest_extremes[3] + 1,
        }

        return size, lowest_extremes
    end

    local function transposeToZero(blocks: {BlockEntry}, extremes: Vector3): {BlockEntry}
        local transposedBlocks: {BlockEntry} = {}
        for _, b in ipairs(blocks) do 
            local pos: Vector3 = {
                b.pos[1] - extremes[1],
                b.pos[2] - extremes[2],
                b.pos[3] - extremes[3],
            }

            local block = b.block

            table.insert(transposedBlocks, NewBlockEntry(pos, block))
        end
        
        return transposedBlocks
    end

    local size, lowest_extremes = findSizeAndExtremes(blockEntries)
    local blocks = transposeToZero(blockEntries, lowest_extremes)

    return {
        blocks = blocks,
        size = size
    }
end

return {
    Vector3 = Vector3,
    BlockEntry = BlockEntry,
    NewBlockEntry = NewBlockEntry,
    VerifyBlockEntry = VerifyBlockEntry,
    Model = Model,
    NewModel = NewModel,
}