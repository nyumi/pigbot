module.exports = (robot) ->

  robot.hear /HELLO$/i, (msg) ->
    msg.send "hello!"

  robot.hear /ぶた/, (msg) ->
    msg.send ":pig:" 

  robot.hear /ばな/, (msg) ->
    msg.send ":dog:" 
   
  robot.hear /#___/, (msg) ->  
    msg.send msg.message.text 

  robot.respond /集計して/i, (msg) ->
    today = new Date()
    oldestMilliSec = new Date(today.getFullYear(), today.getMonth(), today.getDate()).getTime() / 1000

    request = msg.http('https://slack.com/api/channels.history')
                  .query(token: process.env.HUBOT_SLACK_TOKEN, channel:process.env.CHANNEL_ID, oldest:oldestMilliSec)
                  .post()    
                  
    request (err, res, body) ->
      json = JSON.parse body
      contents = json.messages
                .filter((v) -> v.user == process.env.USER_ID)
                .filter((z) -> z.text.startsWith("#___"))
                .reverse()

      # console.log contents          
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

      resultList = contents.map((val,i)->
        if i == contents.length-1
          obj = {}
          task = val.text.slice(4)
          cost = (Date.now()/ 1000 - val.ts)
          obj[task] = cost
          return obj

        if (i + 1 < contents.length)
          obj = {}          
          task = val.text.slice(4)
          cost = (contents[i+1].ts - val.ts)
          obj[task] = cost 
          return obj         
      )

      # resultList2 = resultList.map((result, i, arry) ->
      #   key = Object.keys(result)[0]
      #   if arry[key]
      #     arry[key]+= result[key]
      #     return 
      #   else
      #     return result
      # )

      resultList2 = []

      hasSameTask = (list,taskName,result) ->
        if list.length == 0
          return false
        for obj in list
          console.log obj
          taskInList = Object.keys(obj)[0]
          if taskName == taskInList
            obj[taskInList] += result[taskName]
            return true
        return false
          
      for result in resultList
        task = Object.keys(result)[0]

        if not hasSameTask(resultList2,task, result)
          resultList2.push(result)
    

      console.log resultList2
      resultList3 = resultList2.map((result)->
        key = Object.keys(result)[0]
        # console.log result.key
        "#{key}:#{formatTime(result[key])}"
      )

      # for val, i in contents
      #   if i == contents.length-1
      #     obj = {}
      #     task = val.text.slice(4)
      #     cost = (Date.now()/ 1000 - val.ts)
      #     obj[task] = cost
      #     resultList.push(obj)
      #   if (i + 1 < contents.length)
      #     obj = {}          
      #     task = val.text.slice(4)
      #     cost = (contents[i+1].ts - val.ts)
      #     obj[task] = cost          
      #     resultList.push(obj)
      # console.log resultList


      # msg.send "はいやで\r\n #{resultList2.join('')}"
      msg.send "はいやで\r\n #{resultList3}"
