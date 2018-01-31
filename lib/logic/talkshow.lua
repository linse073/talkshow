local skynet = require "skynet"
local share = require "share"
local util = require "util"

local string = string
local ipairs = ipairs
local pairs = pairs
local table = table
local floor = math.floor

local base
local error_code
local table_mgr
local chess_mgr
local offline_mgr

skynet.init(function()
    base = share.base
    error_code = share.error_code
    table_mgr = skynet.queryservice("table_mgr")
    chess_mgr = skynet.queryservice("chess_mgr")
    offline_mgr = skynet.queryservice("offline_mgr")
end)

local function session_msg(user, chess_user, chess_info)
    local msg = {update={chess={
        info = chess_info,
        user = chess_user,
        session = user.session,
    }}}
    user.session = user.session + 1
    return "update_user", msg
end

local function send(user, chess_user, chess_info)
    if user.agent then
        local m, i = session_msg(user, chess_user, chess_info)
        skynet.call(user.agent, "lua", "notify", m, i)
    end
end

local function broadcast(chess_user, chess_info, role, ...)
    if ... then
        local exclude = {}
        for k, v in ipairs({...}) do
            exclude[v] = v
        end
        for k, v in pairs(role) do
            if not exclude[v.id] then
                send(v, chess_user, chess_info)
            end
        end
    else
        for k, v in pairs(role) do
            send(v, chess_user, chess_info)
        end
    end
end

local talkshow = {}

function talkshow:init(room, rand, server)
    self._room = room
    self._rand = rand
    self._server = server
    self._role = {}
    self._id = {}
    self._count = 0
    self._chat = (string.unpack("B", room.permit)==1)
    self._show_list = {}
end

function talkshow:destroy()
end

local function finish()
    skynet.call(skynet.self(), "lua", "destroy")
    skynet.call(table_mgr, "lua", "free", skynet.self())
end
function talkshow:finish()
    skynet.fork(finish)
end

function talkshow:random_pos()
    local pos = self._rand.randi(1, base.MAX_ROLE)
    local role = self._role
    if role[pos] then
        local i = 1
        repeat
            local go_on = false
            local up = pos - i
            if up >= 1 then
                if not role[up] then
                    return up
                end
                go_on = true
            end
            local down = pos + i
            if down <= base.MAX_ROLE then
                if not role[down] then
                    return down
                end
                go_on = true
            end
            i = i + 1
        until not go_on
    else
        return pos
    end
    assert(false, "role full")
end

function talkshow:enter(info, agent)
    local pos = self:random_pos()
    info.agent = agent
    info.pos = pos
    info.session = 1
    local room = self._room
    if not room.chief then
        room.chief = info.id
    end
    self._role[pos] = info
    local ids = self._id
    ids[info.id] = info
    self._count = self._count + 1
    skynet.call(chess_mgr, "lua", "add", info.id, skynet.self())
    local user = {}
    for k, v in pairs(ids) do
        user[#user+1] = v
    end
    return "update_user", {update={room={
        info = room,
        user = user,
        start_session = info.session,
    }}}
end

function talkshow:join(info, agent)
    if self._count >= base.MAX_ROLE then
        error{code = error_code.CHESS_ROLE_FULL}
    end
    local ids = self._id
    local i = ids[info.id]
    if i then
        error{code = error_code.ALREAD_IN_CHESS}
    end
    local rmsg, rinfo = self:enter(info, agent)
    broadcast({info}, nil, ids, info.id)
    return rmsg, rinfo
end

function talkshow:random_chief()
    local pos = self._rand.randi(1, base.MAX_ROLE)
    local role = self._role
    local info = role[pos]
    if info then
        return info.id
    else
        local i = 1
        repeat
            local go_on = false
            local up = pos - i
            if up >= 1 then
                info = role[up]
                if info then
                    return info.id
                end
                go_on = true
            end
            local down = pos + i
            if down <= base.MAX_ROLE then
                info = role[down]
                if info then
                    return info.id
                end
                go_on = true
            end
            i = i + 1
        until not go_on
    end
    assert(false, "not role")
end

function talkshow:leave(id, msg)
    local ids = self._id
    local info = ids[id]
    if not info then
        error{code = error_code.NOT_IN_CHESS}
    end
    ids[id] = nil
    self._role[info.pos] = nil
    self._count = self._count - 1
    skynet.call(chess_mgr, "lua", "del", id)
    skynet.call(info.agent, "lua", "action", "role", "leave")
    local cu = {
        {id=id, action=base.ACTION_LEAVE},
    }
    local room = self._room
    local ru
    if self._count == 0 then
        room.chief = 0
        ru = {chief = 0}
        self:finish()
    elseif id == room.chief then
        room.chief = self:random_chief()
        ru = {chief = room.chief}
    end
    broadcast(cu, ru, role)
    return session_msg(info, cu, ru)
end

return {__index=talkshow}
