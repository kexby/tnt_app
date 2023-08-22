local http_client = require('http.client').new()
local json = require('json')
local log = require('log')

local coinapi_client = {}

local apiCfg = {
    EndPoint = 'http://rest.coinapi.io/',
    ApiSecretKey = '707E2659-E986-4804-BD14-5206C881F0A0'
}


function coinapi_client.get_data(path)

    local ok, result = xpcall(function()
        local url = apiCfg.EndPoint .. path

        local response = http_client:get(url, {
            headers = {
                ['X-CoinAPI-Key'] = apiCfg.ApiSecretKey,
            }})

        log.info('Api method "' .. path ..'" status = ' .. response.status)

        if response.status >=200 and response.status<300 then
            return json.decode(response.body)
        else
            log.warn(response)
            return nil
        end

    end,
    function(err)
        log.error(err)
        return err
    end
    )

    if not ok then
        return nil
    end

    return result
end

return coinapi_client