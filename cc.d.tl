local type byte = integer
global type Error = string

local enum Unlimited "unlimited" end
global type FuelLevel = integer|Unlimited

global enum FileMode
    "r"
    "w"
    "a"
end

global record fs
    open: function(path: string, mode: FileMode): File, Error
    exists: function(path: string): boolean
end

global record File
    close: function()
    readLine: function(): string
    readAll: function(): string
    write: function(data: string)
    writeLine: function(data: string)
    flush: function()
    read: function(): byte
    write: function(): byte
end

global enum Side
    "up"
    "down"
    "left"
    "right"
    "front"
    "back"
end

global record BlockInfo 
    name: string
    state: string
    tags: {string:boolean}
    count: integer
end

global record turtle
    craft: function(limit: integer|nil): (boolean, Error)
    forward: function(): (boolean, Error)
    back: function(): (boolean, Error)
    up: function(): (boolean, Error)
    down: function(): (boolean, Error)
    turnLeft: function(): (boolean, Error)
    turnRight: function(): (boolean, Error)
    dig: function(side: Side|nil): (boolean, Error)   
    digDown: function(side: Side|nil): (boolean, Error)   
    digUp: function(side: Side|nil): (boolean, Error)   
    place: function(signText: string|nil): (boolean, Error)   
    placeUp: function(signText: string|nil): (boolean, Error)   
    placeDown: function(signText: string|nil): (boolean, Error)   
    drop: function(count: integer|nil): (boolean, Error)   
    dropUp: function(count: integer|nil): (boolean, Error)   
    dropDown: function(count: integer|nil): (boolean, Error)   
    select: function(slot: integer): boolean
    getItemCount: function(slot: integer|nil): integer
    getItemSpace: function(slot: integer|nil): integer
    detect: function(): boolean
    detectUp: function(): boolean
    detectDown: function(): boolean
    compare: function(): boolean
    compareUp: function(): boolean
    compareDown: function(): boolean
    attack: function(weaponSide: Side|nil): (boolean, Error) 
    attackUp: function(weaponSide: Side|nil): (boolean, Error)
    attackDown: function(weaponSide: Side|nil): (boolean, Error)
    suck: function(count: integer|nil): (boolean, Error) 
    suckUp: function(count: integer|nil): (boolean, Error)
    suckDown: function(count: integer|nil): (boolean, Error)
    getFuelLevel: function(): FuelLevel
    refuel: function(count: integer|nil): (boolean, Error)
    compareTo: function(slot: integer): boolean
    transferTo: function(slot: integer, count: integer|nil): boolean
    getSelectedSlot: function(): integer
    getFuelLimit: function(): FuelLevel
    equipLeft: function(): (boolean, Error)
    equipRight: function(): (boolean, Error)
    inspect: function(): (boolean, BlockInfo|Error)
    inspectUp: function(): (boolean, BlockInfo|Error)
    inspectDown: function(): (boolean, BlockInfo|Error)
    getItemDetail: function(slot: integer|nil, boolean|nil): BlockInfo|nil
end

global record shell
    getRunningProgram: function(): string
    resolve: function(path: string): string
    exit: function()
end