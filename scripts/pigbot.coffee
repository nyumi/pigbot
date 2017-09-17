module.exports = (robot) ->

  robot.hear /HELLO$/i, (msg) ->
    msg.send "hello!"

  robot.hear /ぶた/, (msg) ->
    msg.send ":pig:" 

  robot.hear /ばな/, (msg) ->
    msg.send ":dog:" 
   
  robot.hear /じょぶ/, (msg) ->  
    chompedmsg =   msg.message.text.slice(3)
    msg.send "[Job] #{chompedmsg}" 

  robot.respond /集計して/i, (msg) ->
    today = new Date()
    oldestMilliSec = new Date(today.getFullYear(), today.getMonth(), today.getDate()).getTime() / 1000

    request = msg.http('https://slack.com/api/channels.history')
                  .query(token: "xoxb-223873516423-FduoDrpoHunPIyzG98iVCzYx",channel:"C096P24G4",oldest:oldestMilliSec)
                  .post()    
                  
    request (err, res, body) ->
      json = JSON.parse body
      contents = json.messages
                .filter((v) -> v.user == "U6KRPF6CF")
                .filter((z) -> z.text.startsWith("[Job]"))
                .reverse()
      if contents.length == 0
         msg.send "ないやで"
         return

      formatTime = (seconds) ->
        result = ''
        #時間計算
        hour = Math.floor(seconds / 60 / 60)
        min = Math.floor(seconds / 60 % 60)
        sec = Math.floor(seconds % 60)
        #フォーマット
        if hour > 0
          result += hour + '時'
        if min > 0
          result += min + '分'
        if sec > 0
          result += sec + '秒'
        result  

      resultList = []

      for val, i in contents
        if i == contents.length-1
          cost = formatTime(Date.now()/ 1000 - val.ts)
          resultList.push("#{val.text.slice(5)}:#{cost}\r\n")
          # console.log "#{i}:#{JSON.stringify(contents[i])}"
        if (i + 1 < contents.length)  
          cost = formatTime(contents[i+1].ts - val.ts)
          resultList.push("#{val.text.slice(5)}:#{cost}\r\n")
      msg.send "はいやで\r\n #{resultList.join('')}"
      