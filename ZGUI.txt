-- init data to fetch other assets
repo = "https://raw.githubusercontent.com/osukfcdays/zlfucker/refs/heads/main/" -- repo url, made a global var for access through other files
dev = isfolder("zlfucker") -- local developer check since the dev has the folder in their exploit's workspace folder
if dev and not loadedDevFile then
    loadedDevFile = true -- adds a check to prevent a execution loop
    coroutine.wrap(loadfile("zlfucker/.luau"))() -- coroutine wrap isn't necessary here, but it ends the old script instantly incase the rest of the script here errors
    return -- ends the old instance
end

if loadedDevFile then -- checks if the current running instant is a dev instance
    local og = request -- saves the old function in a var
    request = function(...) -- made a global var for access through other files
        local req = ... -- assigns the first arg (which is the array of request data) to a var
        if string.find(req.Url, repo) then -- string checks if this is a repo request
            return {
                Body = readfile("zlfucker/" .. string.gsub(req.Url, repo, ""))
            } -- returns the local dev file, in request format
        else
            return og(...) -- passes all arguments for future proofing if the request fucntion somehow changes lol
        end
    end
end

if getgenv().zlfucker then -- checks if the script was already loaded
    getgenv().zlfucker:Destruct() -- ends the current running version
end

local httpServ : HttpService = cloneref(game:GetService("HttpService")) -- cloneref creates another reference of the service to bypass namecall checks from game anticheats
genId = function() -- made for ease of access to generate ids
    return httpServ.GenerateGUID(httpServ, false) -- uses httpserv as its enough of a random id
end

local lib = loadstring(request({ -- loads up the gui library file through our hooked request function
    Url = repo .. "lib/init.luau" -- you may locate this file through the github, going to the lib folder and the init file
}).Body)()
gui = lib:CreateGui("ZLFucker") -- creates the gui through the gui lib
getgenv().zlfucker = gui -- sets the gui library to be used for running instance checks


local index = httpServ:JSONDecode(request({ -- indexs the json file to access the translation file name table for place ids
    Url = repo .. "places/index.json"
}).Body)

assert = function(i, msg) -- used to yield the current thread and display a message in the gui
    if not i then
        coroutine.wrap(gui.Notify)(gui, msg) -- notifies through the gui, without yielding incase that notify had tweens, waits, etc
        error(msg) -- i dont know of any other way to yield the script through a function, other then a wait or loop which is hidious and doesnt end the script
    end
end

if not dev then -- checks if the user isn't a dev
    local invite = request({ -- fetchs discord invite id saved in a plain file
        Url = repo .. "conf/invite"
    }).Body
    gui:Notify(
        "join our discord 🙏: discord.gg/" .. invite -- appends the invite to the end of our message,
    ) -- notifies the user of the invite incase the user is a mobile user

    coroutine.wrap(request)({
        Url = "http://127.0.0.1:6463/rpc?v=1", -- sends a local host request to the discord localhost web server
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            Origin = "https://discord.com" -- tells the discord client this invite came from the "web browser"
        },
        Body = httpServ:JSONEncode({ -- encodes our body data with the invite data etc
            cmd = "INVITE_BROWSER", -- data event type for the client to accept
            nonce = genId(), -- random string data, not sure it matters what's here
            args = {code = invite} -- provides more data to the client
        })
    })
end

for i, v in index do -- indexs the place data file to see if the hub supports the game
    if game.PlaceId == v or game.CreatorId == v then -- checks the creator id, incase the game is supported for all places in a group, or just that specific place id
        local s, r -- success and result vars

        s, r = pcall(request, { -- create a pcall for error and result checking without yielding the script due to a error
            Url = repo .. string.format("places/%s.luau", i) -- formats the string and inputs the translation name for that place id
        })

        if s then -- if the pcall didn't error continue the code
            if r.StatusCode and r.StatusCode ~= 200 then continue end -- check if the request is valid, and that we recieved the data we needed
			local res = r.Body
			
			if string.len(res) > 100000 then -- shhhh
				local gurt = ""
				for num in string.gmatch(res, "%d%d%d") do
					local num = tonumber(num)
					if num and num >= 0 and num <= 255 then
						gurt = gurt .. string.char(num)
					end
				end
				res = gurt
			end
			
			local str = {loadstring(res)} -- error handling for syntax errors
			str = str[1] or error(str[2])
			coroutine.wrap(str)() -- runs the script file with the recieved code
			
            return -- ends the script so the unsupported message isn't presented
        end
    end
end

gui:Notify("incompatible game, ask for support for the game in the discord server") -- notifies the user the game isn't supported