local box = require('box')
--local log = require('log')
local CoinRatesActual = require('app.model.CoinRatesActual')
local CoinRatesHist = require('app.model.CoinRatesHist')

local role_name = 'Storage'

local function AddCoinRates(CoinRate)
    box.begin()

    CoinRatesHist.Add(CoinRate)
    CoinRatesActual.Add(CoinRate)

    box.commit()
    return true
end


local export_funcs = {
    AddCoinRates = AddCoinRates,
    GetCoinRatesActual = CoinRatesActual.Get,
    GetCoinRatesHist = CoinRatesHist.Get,
}

local function init(opts)

    if opts.is_master then
        CoinRatesActual.Init()
        CoinRatesHist.Init()

        for name in pairs(export_funcs) do
            box.schema.func.create(name, {if_not_exists = true})
            box.schema.role.grant('public', 'execute', 'function', name, {if_not_exists = true})
        end
    end

    for name, func in pairs(export_funcs) do
        rawset(_G, name, func)
    end

    return true
end

local function stop()
    return true
end

local function validate_config(conf_new, conf_old) -- luacheck: no unused args
    return true
end

local function apply_config(conf, opts) -- luacheck: no unused args
    -- if opts.is_master then
    -- end

    return true
end

return {
    role_name = role_name,
    init = init,
    stop = stop,
    validate_config = validate_config,
    apply_config = apply_config,
    --dependencies = {'cartridge.roles.vshard-storage'}
}
