local t = require('luatest')
local g = t.group('integration_api')

local helper = require('test.helper')

g.before_all(function(cg)
    cg.cluster = helper.cluster
    cg.cluster:start()
end)

g.after_all(function(cg)
    helper.stop_cluster(cg.cluster)
end)

g.before_each(function(cg) -- luacheck: no unused args
    -- helper.truncate_space_on_cluster(g.cluster, 'Set your space name here')
end)

g.test_get_rate_actual = function(cg)
    local server = cg.cluster.main_server

    -- наполним БД данными
    --server.net_box:eval('rpc_download_btc_rates()')
    server.net_box:call('rpc_download_btc_rates')

    -- Делаем GET запросы
    local response = server:http_request('get', '/get_btc_rate_actual')
    t.assert_equals(response.status, 200)

    response = server:http_request('get', '/get_btc_rate_history')
    t.assert_equals(response.status, 200)
end

g.test_sample = function(cg)
    local server = cg.cluster.main_server
    local response = server:http_request('post', '/admin/api', {json = {query = '{ cluster { self { alias } } }'}})
    t.assert_equals(response.json, {data = { cluster = { self = { alias = 'api' } } }})
    t.assert_equals(server.net_box:eval('return box.cfg.memtx_dir'), server.workdir)
end

g.test_metrics = function(cg)
    local server = cg.cluster.main_server
    local response = server:http_request('get', '/metrics')
    t.assert_equals(response.status, 200)
    t.assert_equals(response.reason, "Ok")
end
