-- =============================================================================
-- StartEvalServer.lua
--
-- A file-based RPC eval server for Synthesizer V Studio.
-- Polls a command file, evaluates arbitrary Lua code against the SV API,
-- and writes JSON results back to a response file.
--
-- Usage: Run this script inside Synthesizer V Studio. Then use the eval-client
-- CLI tool (or any process) to write JSON commands to the command file.
-- =============================================================================

POLL_INTERVAL = 500
COMMAND_FILE = "/tmp/svstudio-eval-command.json"
RESPONSE_FILE = "/tmp/svstudio-eval-response.json"
STATE_FILE = "/tmp/svstudio-eval-state.txt"

-- =============================================================================
-- JSON library (minimal implementation for Lua 5.4)
-- Source: https://gist.github.com/tylerneylon/59f4bcf316be525b30ab
-- =============================================================================

local json = {}

local function kind_of(obj)
    if type(obj) ~= 'table' then return type(obj) end
    local i = 1
    for _ in pairs(obj) do
        if obj[i] ~= nil then i = i + 1 else return 'table' end
    end
    if i == 1 then return 'table' else return 'array' end
end

local function escape_str(s)
    local in_char  = {'\\', '"', '/', '\b', '\f', '\n', '\r', '\t'}
    local out_char = {'\\', '"', '/',  'b',  'f',  'n',  'r',  't'}
    for i, c in ipairs(in_char) do
        s = s:gsub(c, '\\' .. out_char[i])
    end
    return s
end

local function skip_delim(str, pos, delim, err_if_missing)
    pos = pos + #str:match('^%s*', pos)
    if str:sub(pos, pos) ~= delim then
        if err_if_missing then
            error('Expected ' .. delim .. ' near position ' .. pos)
        end
        return pos, false
    end
    return pos + 1, true
end

local function parse_str_val(str, pos, val)
    val = val or ''
    local early_end_error = 'End of input found while parsing string.'
    if pos > #str then error(early_end_error) end
    local c = str:sub(pos, pos)
    if c == '"'  then return val, pos + 1 end
    if c ~= '\\' then return parse_str_val(str, pos + 1, val .. c) end
    local esc_map = {b = '\b', f = '\f', n = '\n', r = '\r', t = '\t'}
    local nextc = str:sub(pos + 1, pos + 1)
    if not nextc then error(early_end_error) end
    return parse_str_val(str, pos + 2, val .. (esc_map[nextc] or nextc))
end

local function parse_num_val(str, pos)
    local num_str = str:match('^-?%d+%.?%d*[eE]?[+-]?%d*', pos)
    local val = tonumber(num_str)
    if not val then error('Error parsing number at position ' .. pos .. '.') end
    return val, pos + #num_str
end

function json.stringify(obj, as_key)
    local s = {}
    local kind = kind_of(obj)
    if kind == 'array' then
        if as_key then error('Can\'t encode array as key.') end
        s[#s + 1] = '['
        for i, val in ipairs(obj) do
            if i > 1 then s[#s + 1] = ', ' end
            s[#s + 1] = json.stringify(val)
        end
        s[#s + 1] = ']'
    elseif kind == 'table' then
        if as_key then error('Can\'t encode table as key.') end
        s[#s + 1] = '{'
        for k, v in pairs(obj) do
            if #s > 1 then s[#s + 1] = ', ' end
            s[#s + 1] = json.stringify(k, true)
            s[#s + 1] = ':'
            s[#s + 1] = json.stringify(v)
        end
        s[#s + 1] = '}'
    elseif kind == 'string' then
        return '"' .. escape_str(obj) .. '"'
    elseif kind == 'number' then
        if as_key then return '"' .. tostring(obj) .. '"' end
        return tostring(obj)
    elseif kind == 'boolean' then
        return tostring(obj)
    elseif kind == 'nil' then
        return 'null'
    else
        -- For userdata/functions/etc., serialize a descriptive string
        return '"' .. tostring(obj) .. '"'
    end
    return table.concat(s)
end

json.null = {}

function json.parse(str, pos, end_delim)
    pos = pos or 1
    if pos > #str then error('Reached unexpected end of input.') end
    local pos = pos + #str:match('^%s*', pos)
    local first = str:sub(pos, pos)
    if first == '{' then
        local obj, key, delim_found = {}, true, true
        pos = pos + 1
        while true do
            key, pos = json.parse(str, pos, '}')
            if key == nil then return obj, pos end
            if not delim_found then error('Comma missing between object items.') end
            pos = skip_delim(str, pos, ':', true)
            obj[key], pos = json.parse(str, pos)
            pos, delim_found = skip_delim(str, pos, ',')
        end
    elseif first == '[' then
        local arr, val, delim_found = {}, true, true
        pos = pos + 1
        while true do
            val, pos = json.parse(str, pos, ']')
            if val == nil then return arr, pos end
            if not delim_found then error('Comma missing between array items.') end
            arr[#arr + 1] = val
            pos, delim_found = skip_delim(str, pos, ',')
        end
    elseif first == '"' then
        return parse_str_val(str, pos + 1)
    elseif first == '-' or first:match('%d') then
        return parse_num_val(str, pos)
    elseif first == end_delim then
        return nil, pos + 1
    else
        local literals = {['true'] = true, ['false'] = false, ['null'] = json.null}
        for lit_str, lit_val in pairs(literals) do
            local lit_end = pos + #lit_str - 1
            if str:sub(pos, lit_end) == lit_str then return lit_val, lit_end + 1 end
        end
        local pos_info_str = 'position ' .. pos .. ': ' .. str:sub(pos, pos + 10)
        error('Invalid json syntax starting at ' .. pos_info_str)
    end
end

-- =============================================================================
-- Eval server logic
-- =============================================================================

function fetchState()
    local file = io.open(STATE_FILE, "r")
    if file then
        local state = file:read("*all")
        file:close()
        return state
    else
        -- Create initial state
        local file = io.open(STATE_FILE, "w")
        file:write("running")
        file:close()
        return "running"
    end
end

-- Evaluate Lua code. Returns (result, error_msg).
function evalCode(code)
    local func, err = load(code, "eval", "t")
    if not func then
        return nil, err
    end

    local ok, result = pcall(func)
    if not ok then
        return nil, tostring(result)
    end

    return result, nil
end

-- Write a JSON response to the response file.
function writeResponse(requestId, success, result, errorMessage)
    local response = {
        requestId = requestId,
        success = success,
    }
    if success then
        response.result = result
    else
        response.error = errorMessage
    end

    local file = io.open(RESPONSE_FILE, "w")
    if file then
        file:write(json.stringify(response))
        file:close()
    end
end

-- Process a single command from the command file.
function processCommand()
    local file = io.open(COMMAND_FILE, "r")
    if not file then
        return  -- No command pending
    end

    local content = file:read("*all")
    file:close()

    if not content or content == "" then
        return
    end

    -- Clear the command file immediately to signal we're processing
    local clearFile = io.open(COMMAND_FILE, "w")
    if clearFile then
        clearFile:close()
    end

    local ok, command = pcall(json.parse, content)
    if not ok then
        writeResponse(nil, false, nil, "Invalid JSON in command: " .. tostring(command))
        return
    end

    local requestId = command.requestId or "unknown"

    if command.action == "eval" then
        local code = command.code
        if not code or code == "" then
            writeResponse(requestId, false, nil, "No code provided")
            return
        end

        local result, err = evalCode(code)
        if err then
            writeResponse(requestId, false, nil, err)
        else
            writeResponse(requestId, true, result, nil)
        end

    elseif command.action == "ping" then
        writeResponse(requestId, true, "pong", nil)

    elseif command.action == "get_status" then
        local status = {
            state = fetchState(),
            hostInfo = SV:getHostInfo(),
        }
        writeResponse(requestId, true, status, nil)

    else
        writeResponse(requestId, false, nil, "Unknown action: " .. tostring(command.action))
    end
end

-- Main polling loop.
function pollLoop()
    SV:setTimeout(POLL_INTERVAL, function()
        processCommand()

        if fetchState() == "terminated" then
            SV:finish()
        else
            pollLoop()
        end
    end)
end

-- =============================================================================
-- Script entry point
-- =============================================================================

function getClientInfo()
    return {
        name = "StartEvalServer",
        author = "Haruki Okada",
        category = "Eval",
        versionNumber = 1,
        minEditorVersion = 65540
    }
end

function main()
    -- Set initial state
    local file = io.open(STATE_FILE, "w")
    file:write("running")
    file:close()

    -- Clear stale files
    local f = io.open(COMMAND_FILE, "w")
    if f then f:close() end
    f = io.open(RESPONSE_FILE, "w")
    if f then f:close() end

    SV:print("EvalServer started. Polling " .. COMMAND_FILE)
    pollLoop()
end
