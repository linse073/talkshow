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
    model 9 : integer
    name 10 : string
}

.change_user {
    model 0 : integer
    name 1 : string
}

.room_user {
    account 0 : string
    id 1 : integer
    sex 2 : integer
    nick_name 3 : string
    head_img 4 : string
    ip 5 : string
    model 6 : integer
    name 7 : string
    pos 8 : integer
    action 9 : integer
    permit 10 : string
    show_time 11 : integer
    speak 12 : boolean
}

.room_info {
    name 0 : string
    number 1 : integer
    chief 2 : integer
    show_time 3 : integer
    room_type 4 : integer
    desc 5 : string
    permit 6 : string
}

.room_all {
    info 0 : room_info
    user 1 : *room_user
    show_list 2 : *integer
    start_session 3 : integer
    session 4 : integer
}

.change_room {
    name 0 : string
    desc 1 : string
    show_time 2 : integer
    permit 3 : string
}

.show {
    action 0 : integer
}

.speak {
    be 0 : boolean
}

.user_all {
    user 0 : user_info
    room 1 : room_all
}

.info_all {
    user 0 : user_all
    start_time 1 : integer
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
    permit 4 : string
}

.join {
    number 0 : integer
}

.room_list_info {
    name 0 : string
    number 1 : integer
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
