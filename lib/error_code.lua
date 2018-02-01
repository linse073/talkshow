
local pairs = pairs
local ipairs = ipairs
local table = table

local type_code = {
    [0] = {
        OK="成功",
    },

    [1000] = {
        INTERNAL_ERROR="数据错误",
    },

    [1100] = {
        ALREADY_NOTIFY="重复提示",
        ERROR_ARGS="参数错误",
        ERROR_SIGN="签名错误",
    },

    [1200] = {
        ROLE_ALREADY_ENTER="已经登陆",
        IAP_FAIL="苹果内支付失败",
        ALREADY_SHARE="已经分享",
        HAS_INVITE_CODE="已经绑定邀请码",
        INVITE_CODE_ERROR="邀请码错误",
        NO_SHOP_ITEM="商品不存在",
    },

    [3000] = {
        NOT_JOIN_CHESS="尚未加入房间",
        CHESS_ROLE_FULL="对不起，房间人数已满",
        ALREAD_IN_CHESS="已经在房间中",
        NO_CHESS="游戏不存在",
        NOT_IN_CHESS="不在房间中",
        ALREADY_READY="已经准备好了",
        ERROR_CHESS_NUMBER="房间不存在",
        ERROR_CHESS_NAME="游戏不匹配",
        ERROR_OPERATION="操作失败",
        ROOM_CARD_LIMIT="钻石数量不足",
        PERMISSION_LIMIT="没有权限",
    },
}

local code = {}
local code_string = {}

for k, v in pairs(type_code) do
    local t = {}
    for k1, v1 in pairs(v) do
        t[#t+1] = k1
    end
    table.sort(t)
    for k1, v1 in ipairs(t) do
        local i = k + k1
        code[v1] = i
        code_string[i] = v[v1]
    end
end

return {code=code, code_string=code_string}
