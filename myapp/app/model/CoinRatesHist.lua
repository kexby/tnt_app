local box = require('box')
local checks = require('checks')
--local log = require('log')
--local fun = require('fun')

local CoinRatesHist = { }

function CoinRatesHist.Init()

    local space = box.schema.space.create('CoinRatesHist',
        { if_not_exists = true }
    )

    space:format({
        {'bucket_id', 'unsigned'},
        {'time', 'datetime'},
        {'asset_id_base', 'string'},
        {'asset_id_quote', 'string'},
        {'rate', 'decimal'},
    })

    space:create_index('primary', {
        parts = {'asset_id_base', 'asset_id_quote', 'time'},
        if_not_exists = true,
    })

    space:create_index('bucket_id', {
        parts = {'bucket_id'},
        unique = false,
        if_not_exists = true,
    })

end

function CoinRatesHist.Space()
    return box.space.CoinRatesHist
end


function CoinRatesHist.Get(asset_id_base, asset_id_quote)
    checks('string', 'string')

    local space = CoinRatesHist.Space()
    local result = space.index.primary:select({asset_id_base, asset_id_quote}, {iterator = 'REQ', limit = 100})

    if result == nil then
        return nil
    end

    --return fun.iter(result):map(function (tuple) return tuple:tomap({names_only = true}) end):totable()

    local result_tbl = {}
    for _, x in pairs(result) do
        table.insert(result_tbl, x:tomap {names_only = true})
    end

    return result_tbl
end


function CoinRatesHist.Add(CoinRate)
    local space = CoinRatesHist.Space()

    local tuple = assert(space:frommap(CoinRate))

    return space:replace(tuple):tomap{names_only = true}
end


return CoinRatesHist