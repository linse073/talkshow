
local config = {}

config.server = {
    {
        serverid = 1,
        servername = "server01",
    },
}

config.gate = {
    ip = "192.168.2.19",
    port = 20888,
    maxclient = 65535,
    servername = "gate01",
}

config.redis = {
    host = "127.0.0.1",
    port = 6379,
    base = 0,
    name = {
    },
}

config.mongo = {
    host = "127.0.0.1",
    name = {
	    "account",
        "user",
        "info",
        "offline",
        "status",
        "register",
        "iap_log",
        "charge_log",
    },
    index = {
        {"account", {"key", unique=true}},
        {"user", {"id", unique=true}},
        {"info", {"id", unique=true}},
        {"offline", {"id", unique=true}},
        {"status", {"key", unique=true}},
        {"iap_log", {"transaction_id", unique=true}},
        {"charge_log", {"id", unique=true}},
    },
}

return config
