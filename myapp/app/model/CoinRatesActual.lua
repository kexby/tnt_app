local box = require('box')
local checks = require('checks')
--local log = require('log')

local CoinRatesActual = {}

function CoinRatesActual.Init()

    local space = box.schema.space.create('CoinRatesActual',
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
        parts = {'asset_id_base', 'asset_id_quote'},
        if_not_exists = true,
    })

    space:create_index('bucket_id', {
        parts = {'bucket_id'},
        unique = false,
        if_not_exists = true,
    })

end


function CoinRatesActual.Space()
    return box.space.CoinRatesActual
end


function CoinRatesActual.Get(asset_id_base, asset_id_quote)
    checks('string', 'string')

    local space = CoinRatesActual.Space()

    local result = space:get({asset_id_base, asset_id_quote})
    if result == nil then
        return nil
    end
    return result:tomap({ names_only = true })
end


function CoinRatesActual.Add(CoinRate)
    local space = CoinRatesActual.Space()

    local tuple = assert(space:frommap(CoinRate))

    return space:replace(tuple):tomap{names_only = true}
end


return CoinRatesActual