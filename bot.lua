local bot_api_key = "TOKEN" 315802477:AAFl1VrjL9mpoKoy2ojY_OEpBq7Aj99pvf4--Your telegram bot api key
local BASE_URL = "https://api.telegram.org/bot"..bot_api_key
local BASE_FOLDER = ""
local start = [[ ]] 

function is_admin(msg)
  local var = false
  local admins = {66321932}-- آیدیتون
  for k,v in pairs(admins) do
    if msg.from.id == v then
      var = true
    end
  end
  return var
end

package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
  ..';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'
URL = require('socket.url')
JSON = require('dkjson')
HTTPS = require('ssl.https')
redis_server = require('redis')
redis = redis_server.connect('127.0.0.1', 6379)

function sendRequest(url)
  local dat, res = HTTPS.request(url)
  local tab = JSON.decode(dat)

  if res ~= 200 then
    return false, res
  end

  if not tab.ok then
    return false, tab.description
  end

  return tab

end
function adduser(msg)
	redis:sadd('pmrsn:users1',msg.from.id)
end
function userlist(msg)
	local users = '*>* _'..redis:scard('pmrsn:users1')..'_ *User*'
return users
end
function getMe()
    local url = BASE_URL .. '/getMe'
  return sendRequest(url)
end

function getUpdates(offset)

  local url = BASE_URL .. '/getUpdates?timeout=20'

  if offset then

    url = url .. '&offset=' .. offset

  end

  return sendRequest(url)

end
sendSticker = function(chat_id, sticker, reply_to_message_id)

	local url = BASE_URL .. '/sendSticker'

	local curl_command = 'curl -s "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "sticker=@' .. sticker .. '"'

	if reply_to_message_id then
		curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
	end

	io.popen(curl_command):read("*all")
	return end

sendPhoto = function(chat_id, photo, caption, reply_to_message_id)

	local url = BASE_URL .. '/sendPhoto'

	local curl_command = 'curl -s "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "photo=@' .. photo .. '"'

	if reply_to_message_id then
		curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
	end

	if caption then
		curl_command = curl_command .. ' -F "caption=' .. caption .. '"'
	end

	io.popen(curl_command):read("*all")
	return end
	
forwardMessage = function(chat_id, from_chat_id, message_id)

	local url = BASE_URL .. '/forwardMessage?chat_id=' .. chat_id .. '&from_chat_id=' .. from_chat_id .. '&message_id=' .. message_id

	return sendRequest(url)

end

function sendMessage(chat_id, text, disable_web_page_preview, reply_to_message_id, use_markdown)

	local url = BASE_URL .. '/sendMessage?chat_id=' .. chat_id .. '&text=' .. URL.escape(text)

	if disable_web_page_preview == true then
		url = url .. '&disable_web_page_preview=true'
	end

	if reply_to_message_id then
		url = url .. '&reply_to_message_id=' .. reply_to_message_id
	end

	if use_markdown then
		url = url .. '&parse_mode=Markdown'
	end

	return sendRequest(url)

end
function sendDocument(chat_id, document, reply_to_message_id)

	local url = BASE_URL .. '/sendDocument'

	local curl_command = 'cd \''..BASE_FOLDER..currect_folder..'\' && curl -s "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "document=@' .. document .. '"'

	if reply_to_message_id then
		curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
	end
	io.popen(curl_command):read("*all")
	return

end

function download_to_file(url, file_name, file_path)
  print("url to download: "..url)

  local respbody = {}
  local options = {
    url = url,
    sink = ltn12.sink.table(respbody),
    redirect = true
  }
  local response = nil
    options.redirect = false
    response = {HTTPS.request(options)}
  local code = response[2]
  local headers = response[3]
  local status = response[4]
  if code ~= 200 then return nil end
  local file_path = BASE_FOLDER..currect_folder..file_name

  print("Saved to: "..file_path)

  file = io.open(file_path, "w+")
  file:write(table.concat(respbody))
  file:close()
  return file_path
end

function bot_run()
	bot = nil

	while not bot do
		bot = getMe()
	end

	bot = bot.result

	local bot_info = "Username = @"..bot.username.."\nName = "..bot.first_name.."\nId = "..bot.id.."\nDeveloper > @MehdiHS\nChannel > @Black_CH"
	print(bot_info)

	last_update = last_update or 0

	is_running = true

	currect_folder = ""
end

function msg_processor(msg)
if msg then
	if msg.new_chat_participant or msg.new_chat_title or msg.new_chat_photo or msg.left_chat_participant then return end
	if msg.date < os.time() - 5 then
		return
    end
    local dn = redis:get('pmrsn:setdn')
	local blocked = redis:sismember('pmrsn:blocksa',msg.from.id)
	if msg.sticker then
		if msg.chat.type == 'private' then
		local output = redis:get('pmrsn:setid')
		if output and dn then
			   if blocked then
		local blocked1 = "`Sorry`\n_You,re_ *Block*\n--------------------\n*متاسفانه شما *بلاک* هستید و امکان ارسال پیام را *ندارید"
					sendMessage(msg.chat.id,blocked1,false,nil,true)
					else
			forwardMessage(output,msg.chat.id,msg.message_id)
			local text = sendMessage(msg.chat.id,dn,true,nil,true)
			if msg.from.username then
				username = '@'..msg.from.username
			else
				username = msg.from.first_name
			end
			local text = sendMessage(output,'*Sticker from:*\n\n| '..username..' |',true,nil,true)
		end
	end
	elseif msg.sticker and msg.reply_to_message and msg.reply_to_message.forward_from then
	local user = msg.reply_to_message.forward_from.id
				forwardMessage(user,msg.chat.id,msg.message_id)
	end
	elseif msg.voice then
		if msg.chat.type == 'private' then
		local output = redis:get('pmrsn:setid')
		if output and dn then
			   if blocked then
				local blocked1 = "`Sorry`\n_You,re_ *Block*\n--------------------\n*متاسفانه شما *بلاک* هستید و امکان ارسال پیام را *ندارید"
					sendMessage(msg.chat.id,blocked1,false,nil,true)
					else
			forwardMessage(output,msg.chat.id,msg.message_id)
			local text = sendMessage(msg.chat.id,dn,true,nil,true)
			if msg.from.username then
				username = '@'..msg.from.username
			else
				username = '----'
			end
		end
	end
	elseif msg.voice and msg.reply_to_message and msg.reply_to_message.forward_from then
	local user = msg.reply_to_message.forward_from.id
			  forwardMessage(user,msg.chat.id,msg.message_id)
	end
	elseif msg.video then
		if msg.chat.type == 'private' then
		local output = redis:get('pmrsn:setid')
		if output and dn then
			   if blocked then
				local blocked1 = "`Sorry`\n_You,re_ *Block*\n--------------------\n*متاسفانه شما *بلاک* هستید و امکان ارسال پیام را *ندارید"
					sendMessage(msg.chat.id,blocked1,false,nil,true)
					else
			forwardMessage(output,msg.chat.id,msg.message_id)
			local text = sendMessage(msg.chat.id,dn,true,nil,true)
			if msg.from.username then
				username = '@'..msg.from.username
			else
				username = '----'
			end
		end
	end
	elseif msg.video and msg.reply_to_message and msg.reply_to_message.forward_from then
	local user = msg.reply_to_message.forward_from.id
				forwardMessage(user,msg.chat.id,msg.message_id)
	end
	elseif msg.photo then
		if msg.chat.type == 'private' then
		local output = redis:get('pmrsn:setid')
		if output and dn then
			   if blocked then
				local blocked1 = "`Sorry`\n_You,re_ *Block*\n--------------------\n*متاسفانه شما *بلاک* هستید و امکان ارسال پیام را *ندارید"
					sendMessage(msg.chat.id,blocked1,false,nil,true)
					else
			forwardMessage(output,msg.chat.id,msg.message_id)
			local text = sendMessage(msg.chat.id,dn,true,nil,true)
			if msg.from.username then
				username = '@'..msg.from.username
			else
				username = '----'
			end
		end
	end
	elseif msg.photo and msg.reply_to_message and msg.reply_to_message.forward_from then
	local user = msg.reply_to_message.forward_from.id
		forwardMessage(user,msg.chat.id,msg.message_id)
	end
	elseif msg.text:match("^/donemsg (.*)") and is_admin(msg) then
		local matches = { string.match(msg.text, "^/donemsg (.*)") }
		redis:set('pmrsn:setdn',matches[1])
		sendMessage(msg.chat.id,'_New Msg_ *Saved.*',true,nil,true)
 
	
	elseif msg.text:match("^/setrealm") and is_admin(msg) then
	    redis:set('pmrsn:setid',msg.chat.id)
        sendMessage(msg.chat.id, '*Done*\n_Realm Has Been Updated._', true, false, true)
	
	elseif msg.reply_to_message and msg.reply_to_message.forward_from then
		if msg.text:match("^/[Bb]lock") and msg.chat.type ~= 'private' and is_admin(msg) then
		local user = msg.reply_to_message.forward_from.id
		redis:sadd('pmrsn:blocksa',user)
		local torealm = sendMessage(msg.chat.id,'*Done*\n`User has been added to` *Block list*!',true, false, true)
		local touser = sendMessage(user, ' _Sorry_\n `You are` *blocked* `from bot.`', true, false, true)
	elseif msg.text:match("^/[Bb]lock") and msg.chat.type ~= 'private' and not is_admin(msg) then
		local user = msg.reply_to_message.forward_from.id
		local torealm = sendMessage(msg.chat.id,'`You` *Can,t* _Block_ `or` _Unblock_ `Users.`\n-----------------------------------\n`شما` *نمیتوانید* `کاربران را` _بلاک_ `یا` _آنبلاک_`کنید`',true, false, true)
		local touser = sendMessage(user, '', true, false, true)
	elseif msg.text:match("^/[Uu]nblock") and msg.chat.type ~= 'private' and is_admin(msg) then
		local user = msg.reply_to_message.forward_from.id
		redis:srem('pmrsn:blocksa',user)
		local torealm = sendMessage(msg.chat.id,'*Done*\n`User has been Removed From` *Block list*',true, false, true)
		local touser = sendMessage(user, 'You has been *Unblocked*', true, false, true)
	elseif msg.text:match("^/[Uu]nblock") and msg.chat.type ~= 'private' and not is_admin(msg) then
		local user = msg.reply_to_message.forward_from.id
		local torealm = sendMessage(msg.chat.id,'`You` *Can,t* _Block_ `or` _Unblock_ `Users.`\n-----------------------------------\n`شما` *نمیتوانید* `کاربران را` _بلاک_ `یا` _آنبلاک_`کنید`',true, false, true)
		local touser = sendMessage(user, '', true, false, true)
	else
		local user = msg.reply_to_message.forward_from.id
		sendMessage(user,msg.text)
		end
		
	elseif msg.text:match("^/users") and is_admin(msg) then
		local list = userlist(msg)
	sendMessage(msg.chat.id,list,true,nil,true)
	
	elseif msg.text:match("^/version") then
	sendMessage(msg.chat.id,'*Black Support Bot*\n\n_Developer_ > [MehdiHS](https://telegram.me/MehdiHS)\n[My Channel](https://telegram.me/black_ch)\n\n _Bot Version_ : *4*',true,nil,true)
	
    elseif msg.text:match("^/help") and not is_admin(msg) then
	sendMessage(msg.chat.id,'*Black Support Bot Help:*\n\n\n `-` /version\n`نمایش ورژن ربات`\n\n `-` /plist\n`دریافت لیست قیمت ها برای‌خرید گروه`\n\n `-` /start\n`دریافت اطلاعاتی درباره خرید گروه`',true,nil,true)

	elseif msg.text:match("^/help") and is_admin(msg) then
	sendMessage(msg.chat.id,'_Black Support Help_ *(For Admin)*\n\n\n `-` /version\n`نمایش ورژن ربات`\n\n `-` /plist\n`دریافت لیست قیمت ها برای‌خرید گروه`\n\n `-` /start\n`دریافت اطلاعاتی درباره خرید گروه`\n\n `-` /users\n`نمایش تعداد افرادی که در ربات پیام دادند`\n\n `-` /block [reply]\n`بلاک کردن یک شخص با ریپلی`\n\n `-` /unblock [reply]\n`آنبلاک کردن یک شخص با ریپلی`\n\n `-` /setrealm\n`تنظیم گروه اصلی ربات`\n*نکته : اگر این دستور رو در داخل پیوی ربات بفرستید پیام ها به پیوی شما ارسال میشود*\n\n `-` /startmsg [متن]\nYou Can user {USERNAME} and {FirstName}\n`تنظیم یک متن به عنوان متن استارت`\n*نکته: این زمانی که کاربر دستور /start رو ارسال کنه نمایش داده میشه*\n\n `-` /donemsg [متن]\n`تنظیم یک متن برای تایید ارسال شدن پیام`\n\n `-` /help\n`نمایش تنظیمات ربات`\n\n `-` /clean blocklist\n`حذف کردن کل افراد بلاک شده از لیست بلاک شده ها`\n\n `-` /clean users\n`خالی کردن لیست افرادی که از ربات استفاده کرده اند`',true,nil,true)
    elseif msg.text:match("^/broadcast (.*)") and is_admin(msg) then 
          local gps = redis:smembers("pmrsn:users1") 
          local matches = { string.match(msg.text, "^/broadcast (.*)") } 
          local text = matches[1] 
      for i=1, #gps do 
       sendMessage(gps[i],matches[1],true,nil,true) 
      end 
       sendMessage(msg.chat.id,'Done.',true,nil,true)
    elseif msg.text:match("^/nerkh") or msg.text:match("^/plist") or msg.text:match("^/planlist") then
	sendMessage(msg.chat.id,'*لیست قیمت های خرید گروه با* [BlackPlus](https://telegram.me/bIackplus)\n\n `-` *1 ماهه* > `5000` _تومان_\n `-` *3 ماهه* > `10000` _تومان_\n `-` *نامحدود* > `20000` _تومان_ ',true,nil,true)
	elseif msg.text:match("^/clean blocklist") and is_admin(msg) then
	sendMessage(msg.chat.id,'لیستتتت افراد بلاک شده با موفقیت خالی شد.',true,nil,true)
	redis:del('pmrsn:blocksa')
	
    elseif msg.text:match("^/clean users") and is_admin(msg) then
	sendMessage(msg.chat.id,'لیست اعضای ربات با موفقیت خالی شد.',true,nil,true)
	redis:del('pmrsn:users1')
	
	elseif msg.text:match("^/startmsg (.*)") and is_admin(msg) then
		local matches = { string.match(msg.text, "^/startmsg (.*)") }
		local text = matches[1]
		redis:set('pmrsn:setst',matches[1])
		sendMessage(msg.chat.id,'*Done*\n _Start Msg Has Been_ *Updated*',true,nil,true)
	
    elseif msg.chat.type == 'private' then
		if msg.text:match("^/[sS]tart") then
			local mtn = redis:get('pmrsn:setst')
			local text = 'Hello\nWelcome To My bot'
			if mtn then
			text = mtn
			end
 			if string.match(text,"{FIRSTNAME}") then
		        text = string.gsub(text,"{FIRSTNAME}",msg.from.first_name)
			end
			if string.match(text,"{USERNAME}") then
			local text = string.gsub(text,"{USERNAME}",msg.from.username)
			end
			sendMessage(msg.chat.id,text,false,nil,true)
			local ttaua = adduser(msg)
		else
			local output = redis:get('pmrsn:setid')
			local dn = redis:get('pmrsn:setdn')
			local blocked = redis:sismember('pmrsn:blocksa',msg.from.id)
			
			if output and dn then
				if blocked then
				local blocked1 = "`Sorry`\n_You,re_ *Block*\n--------------------\n*متاسفانه شما *بلاک* هستید و امکان ارسال پیام را *ندارید"
					sendMessage(msg.chat.id,blocked1,false,nil,true)
					else
					
					forwardMessage(output,msg.chat.id,msg.message_id)
					local text = sendMessage(msg.chat.id,dn,true,nil,true)
					end
			else
				return 
			end
				
			end

        return 
    end
  end
end
bot_run()
while is_running do 
	local response = getUpdates(last_update+1) 
	if response then
		for i,v in ipairs(response.result) do
			last_update = v.update_id
			msg_processor(v.message)
		end
	else
		print("BlackSupport Bot Crashed!!")
	end
end
print("BlackSupport Bot Crashed!!")sudo apt-get updatesudo apt-get install libreadline-dev libconfig-dev libssl-dev lua5.2 liblua5.2-dev lua-socket lua-sec lua-expat libevent-dev make unzip git redis-server autoconf g++ libjansson-dev libpython-dev expat libexpat1-devgit clone https://github.com/Mehdi-HS/Black-Support-Bot.gitcd Black-Support-Botchmod +x launch.sh./launch.sh install./launch.sh
