local skynet = require "skynet"
local share = require "share"
local util = require "util"
local delist = require "tool.delist"
local timer = require "timer"

local string = string
local ipairs = ipairs
local pairs = pairs
local table = table
local floor = math.floor
local assert = assert

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

local function session_msg(user, room)
    room.session = user.session
    local msg = {update={room=room}}
    user.session = user.session + 1
    return "update_user", msg
end

local function send(user, room)
    local m, i = session_msg(user, room)
    skynet.call(user.agent, "lua", "notify", m, i)
end

local function broadcast(room, role, ...)
    if ... then
        local exclude = {}
        for k, v in ipairs({...}) do
            exclude[v] = v
        end
        for k, v in pairs(role) do
            if not exclude[v.id] then
                send(v, room)
            end
        end
    else
        for k, v in pairs(role) do
            send(v, room)
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
    self._show_list = delist()
    timer.add_second_routine("show_timer", function()
        self:update()
    end)
end

function talkshow:pop_show(show_role, now)
    local show_list = self._show_list
    assert(show_list.pop().value==show_role.id, "list head isn't show role")
    show_role.show_time = 0
    self._show_role = nil
    local cu = {
        {id=show_role.id, show_time=0, action=base.ACTION_UNSTAGE},
    }
    local ns = show_list.head()
    if ns then
        local nr = self._id[ns.value]
        nr.show_time = now
        self._show_role = nr
        cu[#cu+1] = {id=nr.id, show_time=now}
    end
    return cu
end

function talkshow:update()
    local show_role = self._show_role
    if show_role then
        local show_time = self._room.show_time
        if show_time > 0 then
            local now = floor(skynet.time())
            if now - show_role.show_time >= show_time then
                local cu = self:pop_show(show_role, now)
                broadcast({user=cu}, self._id)
            end
        end
    end
end

function talkshow:destroy()
    timer.del_second_routine("show_timer")
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
    info.show_time = 0
    info.speak = false
    info.session = 1
    local id = info.id
    info.queue = {value=id}
    local room = self._room
    if not room.chief then
        room.chief = id
    end
    self._role[pos] = info
    local ids = self._id
    ids[id] = info
    self._count = self._count + 1
    skynet.call(table_mgr, "lua", "update", room.number, room.name, self._count)
    skynet.call(chess_mgr, "lua", "add", id, skynet.self())
    local user = {}
    for k, v in pairs(ids) do
        user[#user+1] = v
    end
    return "update_user", {update={room={
        info = room,
        user = user,
        show_list = self._show_list.get_all(),
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
    broadcast({user={info}}, ids, info.id)
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

function talkshow:leave_impl(info)
    local id = info.id
    local ids = self._id
    ids[id] = nil
    self._role[info.pos] = nil
    self._count = self._count - 1
    local room = self._room
    skynet.call(table_mgr, "lua", "update", room.number, room.name, self._count)
    skynet.call(chess_mgr, "lua", "del", id)
    skynet.call(info.agent, "lua", "action", "role", "leave")
    self._show_list.remove(info.queue)
    local cu
    local show_role = self._show_role
    if show_role and show_role.id == id then
        cu = self:pop_show(show_role, floor(skynet.time()))
        cu[1].action = base.ACTION_LEAVE
    else
        cu = {
            {id=id, action=base.ACTION_LEAVE},
        }
    end
    local ru
    if self._count == 0 then
        room.chief = 0
        ru = {chief = 0}
        self:finish()
    elseif id == room.chief then
        room.chief = self:random_chief()
        ru = {chief = room.chief}
    end
    local tu = {user=cu, info=ru}
    broadcast(tu, ids)
    return tu
end

function talkshow:leave(id)
    local info = self._id[id]
    if info then
        self:leave_impl(info)
    end
end

function talkshow:quit(id, msg)
    local ids = self._id
    local info = ids[id]
    if not info then
        error{code = error_code.NOT_IN_CHESS}
    end
    local tu = self:leave_impl(info)
    return session_msg(info, tu)
end

function talkshow:show(id, msg)
    local ids = self._id
    local info = ids[id]
    if not info then
        error{code = error_code.NOT_IN_CHESS}
    end
    local cu = {
        {id=id, action=msg.action},
    }
    local tu = {user=cu}
    broadcast(tu, ids, id)
    return session_msg(info, tu)
end

function talkshow:change_room(id, msg)
    local ids = self._id
    local info = ids[id]
    if not info then
        error{code = error_code.NOT_IN_CHESS}
    end
    local room = self._room
    if room.chief ~= id then
        error{code = error_code.PERMISSION_LIMIT}
    end
    local ru = {}
    for k, v in pairs(msg) do
        room[k] = v
        ru[k] = v
    end
    local tu = {info=ru}
    broadcast(tu, ids, id)
    return session_msg(info, tu);
end

function talkshow:speak(id, msg)
    local ids = self._id
    local info = ids[id]
    if not info then
        error{code = error_code.NOT_IN_CHESS}
    end
    info.speak = msg.be
    local cu = {
        {id=id, speak=msg.be},
    }
    local tu = {user=cu}
    broadcast(tu, ids, id)
    return session_msg(info, tu)
end

function talkshow:stage(id, msg)
    local ids = self._id
    local info = ids[id]
    if not info then
        error{code = error_code.NOT_IN_CHESS}
    end
    local show_list = self._show_list
    if not show_list.push(info.queue) then
        error{code = error_code.ALREAD_ON_SHOW_LIST}
    end
    local cu = {id=id, action=base.ACTION_STAGE}
    if show_list.count() == 1 then
        local now = floor(skynet.time())
        info.show_time = now
        self._show_role = info
        cu.show_time = now
        if info.speak then
            cu.speak = false
        end
    end
    local tu = {user={cu}}
    broadcast(tu, ids, id)
    return session_msg(info, tu)
end

function talkshow:unstage(id, msg)
    local ids = self._id
    local info = ids[id]
    if not info then
        error{code = error_code.NOT_IN_CHESS}
    end
    local show_role = self._show_role
    if show_role and show_role.id == id then
        local cu = self:pop_show(show_role, floor(skynet.time()))
        local tu = {user=cu}
        broadcast(tu, ids, id)
        return session_msg(info, tu)
    else
        local show_list = self._show_list
        if not show_list.remove(info.queue) then
            error{code = error_code.NOT_ON_SHOW_LIST}
        end
        local cu = {
            {id=id, action=base.ACTION_UNSTAGE},
        }
        local tu = {user=cu}
        broadcast(tu, ids, id)
        return session_msg(info, tu)
    end
end

return {__index=talkshow}
