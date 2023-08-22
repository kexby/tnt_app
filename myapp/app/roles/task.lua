local log = require('log')
local vshard = require('vshard')
local fiber = require('fiber')
local decimal = require('decimal')
local datetime = require('datetime')


local coinApiClient = require('app.coinapi_client')

local role_name = 'Task-Get_BTC_Rates'
local active_task_fiber = true

local function download_btc_rates()
    local exchangerate = coinApiClient.get_data('v1/exchangerate/BTC/USDT')
    if exchangerate then
        exchangerate.bucket_id = vshard.router.bucket_id_mpcrc32('BTC','USDT')
        exchangerate.rate = decimal.new(exchangerate.rate)
        exchangerate.time = datetime.parse(exchangerate.time)

        local result, err = vshard.router.callrw(exchangerate.bucket_id, 'AddCoinRates', {exchangerate})

        if not result then
            log.error(err)
        end
    end
end

local function init(opts) -- luacheck: no unused args

    rawset(_G, 'rpc_download_btc_rates', download_btc_rates)

    active_task_fiber = true

    fiber.create(function ()
        while active_task_fiber do
            download_btc_rates()
            fiber.sleep(15)
        end
    end)

    return true
end

local function stop()
    -- деактивация фонового файбера
    active_task_fiber = false
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
    --rpc_download_btc_rates = download_btc_rates,
    validate_config = validate_config,
    apply_config = apply_config,
    dependencies = {'cartridge.roles.vshard-router'},
}