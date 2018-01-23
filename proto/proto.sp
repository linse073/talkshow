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
}

.other_all {
    other 0 : *user_info
}

.user_all {
    user 0 : user_info
}

.info_all {
    user 0 : user_all
    start_time 1 : integer
    code 2 : integer
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
    rule 1 : string
    location 2 : binary
}

.join {
    number 0 : integer
    location 1 : binary
}

.room_name {
	name 0 : string
}

.enter_game {
    number 0 : integer
}

.chat_info {
    text 0 : string
    audio 1 : binary
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

.location_info {
    location 0 : binary
}
