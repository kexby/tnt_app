local vshard = require('vshard')
local cartridge = require('cartridge')
--local log = require('log')

local role_name = 'Api'

local function init(opts) -- luacheck: no unused args

    local httpd = assert(cartridge.service_get('httpd'), "Failed to get httpd service")

    httpd:route({method = 'GET', path = '/get_btc_rate_actual'}, function(req)
        local bucket_id = vshard.router.bucket_id_mpcrc32('BTC', 'USDT')

        local result, err = vshard.router.callro(bucket_id, 'GetCoinRatesActual', {'BTC', 'USDT'})

        if err then
            local resp = req:render({json = {
                info = "Internal error :(",
                error = err
            }})
            resp.status = 500
            return resp
        end

        if result == nil then
            local resp = req:render({json = { info = "BTC rate not found" }})
            resp.status = 404
            return resp
        end

        local resp = req:render({json = result})
        resp.status = 200
        return resp
    end)

    httpd:route({method = 'GET', path = '/get_btc_rate_history'}, function(req)
        local bucket_id = vshard.router.bucket_id_mpcrc32('BTC', 'USDT')
        local result, err = vshard.router.callro(bucket_id, 'GetCoinRatesHist', {'BTC', 'USDT'})

        if err then
            local resp = req:render({json = {
                info = "Internal error :(",
                error = err
            }})
            resp.status = 500
            return resp
        end

        local resp = req:render({json = result})
        resp.status = 200
        return resp
    end)

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
    dependencies = {'cartridge.roles.vshard-router'},
}
