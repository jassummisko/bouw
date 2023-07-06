local utils = require "lib/utils"
local parser = require "lib/parser"
local pt = require "lib/printer_types"

local function ReadModelFromFile(filename: string): (pt.Model, Error)
    local modelFile, err = fs.open(filename, "r")
    if err then return nil, err end
    local blockHash: {string:string} = {}
    local blockEntries: {pt.BlockEntry} = {}

    for line_number, line_read in parser.IterateLine(modelFile) do
        local definitionLine = line_read:match("%%%s*%w+%s*=%s*.+%s*$")
        if definitionLine then 
            local hashEntry = {}
            for l in line_read:gmatch("[^%%^=^%s]+") do
                table.insert(hashEntry, l) 
            end 
            if #hashEntry ~= 2 then
                return nil, "REGEL " .. line_number .. ": Corrupte hoofding"
            end
            blockHash[hashEntry[1]] = hashEntry[2]
        end

        if line_read:match("^%-?%d") then
            local coordinates: {integer} = {}
            local block: string
            local blockCode: string

            for match in string.gmatch(line_read, "%-?%d+%s") do
                local c = tonumber(match)
                if c == nil then return nil, "LINE " .. line_number ..": beschadigde coördinaat" end
                table.insert(coordinates, c)
            end

            if #coordinates ~= 3 then
                return nil, "REGEL " .. line_number .. ": onvolledige coördinaat"
            end

            blockCode = string.match(line_read, "%w+%s*$")
            if blockCode == nil then
                return nil, "REGEL " .. line_number .. ": Ontbrekende of beschadigde bloksleutel"
            end

            block = blockHash[blockCode]
            if block == nil then
                return nil, "REGEL " .. line_number .. ": Ontbrekende of beschadigde bloksleutel"
            end

            local blockEntry = pt.NewBlockEntry(coordinates, block)
            local blockErr = pt.VerifyBlockEntry(blockEntry)
            if blockErr then return nil, blockErr end

            table.insert(blockEntries, blockEntry)
        end
    end

    local model = pt.NewModel(blockEntries)
    modelFile.close()
    return model, nil
end

local function VerifyIfEnoughItems(mdl: pt.Model): Error
    local inventoryBlockCount: {string:integer} = {}
    local modelBlockCount: {string:integer} = {}
    local differenceHash: {string:integer} = {}
    local errorMessage: Error
    local failed: boolean = false

    for i=1, 16 do
        local item = turtle.getItemDetail(i)
        if not (item is nil) then
            if inventoryBlockCount[item.name] == nil then
                inventoryBlockCount[item.name] = 0
            end
            inventoryBlockCount[item.name] = inventoryBlockCount[item.name] + item.count
        end
    end

    for _, b in ipairs(mdl.blocks) do 
        if modelBlockCount[b.block] == nil then
            modelBlockCount[b.block] = 0
        end
        modelBlockCount[b.block] = modelBlockCount[b.block] + 1
    end

    for k, v in pairs(modelBlockCount) do
        if inventoryBlockCount[k] == nil then inventoryBlockCount[k] = 0 end

        if inventoryBlockCount[k] < v then
            differenceHash[k] = v - inventoryBlockCount[k]
        end
    end

    errorMessage = "Er ontbreken een paar items:\n"
    for k, v in pairs(differenceHash) do
        failed = true
        errorMessage = errorMessage .. v .. " " .. k .. "\n"
    end

    if failed then return errorMessage end
end

local function BuildModel(mdl: pt.Model): Error
    local printMap: {{{string}}}
    local currentPosition: pt.Vector3
    local size_x: integer 
    local size_y: integer 
    local size_z: integer

    -- Helper functions
    local function GeneratePrintMap(model: pt.Model): {{{string}}}
        local buffer: {{{string}}} = {}
        for z=1, model.size[3] do 
            buffer[z] = {}
            for y=1, model.size[2] do 
                buffer[z][y] = {}
                for x=1, model.size[1] do 
                    buffer[z][y][x] = ""
                end
            end
        end

        for _, b in ipairs(model.blocks) do 
            local block_x = b.pos[1] + 1
            local block_y = b.pos[2] + 1
            local block_z = b.pos[3] + 1
            local block_name = b.block

            buffer[block_z][block_y][block_x] = block_name
        end

        return buffer
    end

    local function turn(i: integer) 
        local direction = (i % 2 == 0)
        if direction then turtle.turnRight() 
        else turtle.turnLeft() end
    end

    -- Advancement functions
    local function next_x()
        if turtle.forward() then 
            local increment = 1
            if (currentPosition[2] + currentPosition[3]) % 2 == 1 then
                increment = -1
            end
            currentPosition[1] = currentPosition[1] + increment
        end
    end

    local function next_y()
        local increment = 1
        if currentPosition[3] % 2 == 0 then 
            increment = -1
        end

        turn(currentPosition[2])
        turtle.forward()
        turn(currentPosition[2])
        
        currentPosition[2] = currentPosition[2] + increment
    end

    local function next_z() 
        turtle.up()
        turtle.turnRight()
        turtle.turnRight()
        currentPosition[3] = currentPosition[3] + 1
    end

    -- Main loop
    currentPosition = {1, 1, 1}
    size_x, size_y, size_z = mdl.size[1], mdl.size[2], mdl.size[3]
    printMap = GeneratePrintMap(mdl)
    turtle.up() 
    for z=1, size_z do
        for y=1, size_y do
            for x=1, size_x do
                local bx, by, bz = table.unpack(currentPosition)
                local item_to_place = printMap[bz][by][bx]
                utils.writeTable(currentPosition); print()
                if item_to_place ~= "" then
                    if not utils.SelectItemByName(item_to_place) then
                        return item_to_place .. " niet gevonden."
                    end
                    turtle.placeDown()
                end
                if x < size_x then 
                    next_x() 
                end
            end
            if y < size_y then
                next_y()
            end
        end
        if z < size_z then 
            next_z()
        end
    end
    turtle.forward()
    for _=1, size_z do turtle.down() end
end

return {
    ReadModelFromFile = ReadModelFromFile,
    BuildModel = BuildModel,
    VerifyIfEnoughItems = VerifyIfEnoughItems,
}