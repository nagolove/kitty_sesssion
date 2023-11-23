#!/usr/bin/env lua

local json = require "json"
local inspect = require "inspect"
local tabular = require "tabular".show
local serpent = require "serpent"
local parser = require "argparse"()

parser:flag("-s --store", "store session")
parser:flag("-l --load", "load session")
local arguments = parser:parse()

if arguments.store then
    local kitty_ls_json = io.popen("kitty @ ls"):read("*a")
    local kitty_ls = json.decode(kitty_ls_json)
    --print(inspect(kitty_ls))
    local ser = serpent.dump(kitty_ls)
    local file = io.open("session.lua", "w")
    file:write(ser)
    file:close()
elseif arguments.load then
    local sock = require "socket"
    os.execute("nohup kitty -o allow_remote_control=yes --listen-on " ..
               "unix:/tmp/xxx -o enabled_layouts=tall &"
    )
    sock.sleep(2)
    local deser = loadfile("session.lua")()
    for _, kitty in ipairs(deser) do
        --print('kitty', inspect(kitty))
        for _, tab in ipairs(kitty.tabs) do
            --print('tab', inspect(tab))
            --os.execute("kitten @ --to unix:/tmp/xxx launch new-window")

            for _, wnd in ipairs(tab.windows) do
                print('wnd', inspect(wnd))
                os.execute(
                    "kitten @ --to unix:/tmp/xxx launch " .. 
                    wnd.cmdline[1] .. 
                    " --cwd " .. wnd.cwd
                )
            end
        end
    end
    --print('deser', inspect(deser))

end
