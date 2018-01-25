.user_info {
    account 0 : string
    id 1 : integer
    sex 2 : integer
    create_time 3 : integer
    nick_name 4 : string
    head_img 5 : string
    ip 6 : string
    last_login_time 7 : integer
    login_time 8 : integer
    model 9 : model_info
    name 10 : string
}

.model_info {
    index 0 : integer
}

.change_user {
    model 0 : model_info
    name 1 : string
}

.room_user {
    account 0 : string
    id 1 : integer
    sex 2 : integer
    nick_name 3 : string
    head_img 4 : string
    ip 5 : string
    model 6 : model_info
    name 7 : string
    pos 8 : integer
    action 9 : string
    permit 10 : integer
    start_show_time 11 : integer
}

.room_info {
    name 0 : string
    id 1 : integer
    chief 2 : integer
    show_time 3 : integer
    room_type 4 : integer
    desc 5 : string
    show_list 6 : *integer
    chat 7 : boolean
}

.room_all {
    info 0 : room_info
    user 1 : *room_user
}

.change_room {
    name 0 : string
    desc 1 : string
    show_time 2 : integer
    chat 3 : boolean
}

.show {
    action 0 : string
}

.user_all {
    user 0 : user_info
    room 1 : room_all
}

.info_all {
    user 0 : user_all
    start_time 1 : integer
    room_list 2 : *room_list_info
}

.update_user {
    update 0 : user_all
    iap_index 1 : integer
}

.heart_beat {
    time 0 : integer
}

.heart_beat_response {
    time 0 : integer
    server_time 1 : integer
}

.error_code {
    code 0 : integer
}

.logout {
    id 0 : integer
}

.get_role {
    id 0 : integer
}

.role_info {
    info 0 : user_all
}

.new_room {
    name 0 : string
    desc 1 : string
    show_time 2 : integer
    room_type 3 : integer
    chat 4 : boolean
}

.join {
    id 0 : integer
}

.room_list_info {
    name 0 : string
    id 1 : integer
    room_type 2 : integer
    user_count 3 : integer
}

.room_list {
    list 0 : *room_list_info
}

.iap {
    index 0 : integer
    receipt 1 : string
    sandbox 2 : boolean
}

.charge {
    num 0 : integer
    url 1 : string
}

.charge_ret {
    url 0 : string
}
