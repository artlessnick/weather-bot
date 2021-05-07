require 'telegram/bot'
require_relative 'one_day'
require_relative 'few_days'


token = "1646660468:AAHh-9G_HWpXW3qebOrogEFOmRn9ekoP_2A"

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    Thread.start(message) do |message|
        if message.text == "/start" 
          bot.api.send_message(chat_id: message.chat.id,text: "Привет, #{message.from.first_name}, введите город и количество дней о погоде, в формате <Москва, 1>") 
        else
          begin
            date = message.text.chomp.split(', ')
            city = URI.encode(date[0])
            if date[1] == "today" or date[1] == "1"
              url = "http://api.openweathermap.org/data/2.5/weather?q=#{city}&units=metric&lang=ru&appid=afbac24c5abcee38b0f68c243d05fc35"
              msg = one_day(url)
              bot.api.send_message(chat_id: message.chat.id,text: "#{msg}")
            else
              url = "http://api.openweathermap.org/data/2.5/forecast?q=#{city}&lang=ru&units=metric&appid=afbac24c5abcee38b0f68c243d05fc35"
              msg = few_days(date[1].to_i, url)
              for day in msg
                bot.api.send_message(chat_id: message.chat.id,text: "#{Time.parse(day['data']).strftime("%d-%m-%Y")}, 
                  температура днем: #{day['max_temp']}\u00B0С,
                  температура ночью: #{day['min_temp']}\u00B0С,
                  влажность: #{day['humidity']}%,
                  давление: #{day['pressure']},
                  #{day['clouds']},")
              end
            end

          rescue OpenURI::HTTPError => error
            if error.message == "404 Not Found"
              bot.api.send_message(chat_id: message.chat.id,text: "По такому городу информацию не предоставляем")
            else 
              bot.api.send_message(chat_id: message.chat.id,text: "ooops, у нас ошибочка")
            end
          rescue StandardError => error
            bot.api.send_message(chat_id: message.chat.id,text: "Неизвестная ошибка, #{error.message}")          
          end
        end
    end
  end
 
end


