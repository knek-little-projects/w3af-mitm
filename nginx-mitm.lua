-- DANGEROUS TCP USE! 
-- TODO: rewrite to UDP

-- nginx.conf:
-- access_by_lua_file "/etc/nginx/nginx-mitm.lua";


local target_host = "127.0.0.1"
local target_port = 8080
local socket_timeout = 2000


-- get request BODY
local function get_body()
    ngx.req.read_body()  -- explicitly read the req body
    local data = ngx.req.get_body_data()
    if data then
         return data
     end

     -- body may get buffered in a temp file:
     local file_name = ngx.req.get_body_file()
     if file_name then
        local file = io.open(file_name, "rb") -- r read mode and b binary mode
        if not file then 
            return nil 
        end
        
        local content = file:read("*a") -- *a or *all reads the whole file
        file:close()
        
        return content
     else
         return nil
     end
end


-- get request HTTP HEADERS and BODY as text
local function get_request_text()
    local headers = ngx.req.raw_header()
    local body = get_body()

    local text = headers
    if body then
        text = text .. body
    end

    return text
end


-- send data to remote socket
local function send_data(host, port, sock_timeout)
    local sock = ngx.socket.tcp()
    sock:settimeout(sock_timeout)
    local ok, err = sock:connect(target_host, target_port)
    if not ok then
        return -- SOCK FAIL
    end
    sock:send(text)
    sock:close()
end


send_data(target_host, target_port, socket_timeout)
