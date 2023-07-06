local printer = require "printer"

local args = {...}
if #args < 1 then
    print("Gebruik: ".. arg[0] .. " bestandsnaam")
    return
end

local filepath = shell.resolve(args[1])
if not fs.exists(filepath) then
    print("Het bestand \"" .. filepath .. "\" bestaat niet" )
    return
end

local model, readModelErr = printer.ReadModelFromFile(filepath)
if readModelErr then
    print(readModelErr)
    return
end

local verifyItemsErr = printer.VerifyIfEnoughItems(model)
if verifyItemsErr then
    print(verifyItemsErr)
    return
end

local buildErr = printer.BuildModel(model)
if readModelErr then
    print(buildErr)
    return
end