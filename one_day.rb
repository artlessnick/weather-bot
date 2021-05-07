require 'json'
require 'date'
require 'open-uri'

def one_day(url)
  html = open(url)
  date = JSON.parse(html.string)

  timezone = date['timezone']

  city = date['name']
  current_day = DateTime.strptime("#{date['sys']['sunrise']+timezone}", '%s').strftime('%Y-%m-%d')

  sunrise = DateTime.strptime("#{date['sys']['sunrise']+timezone}", '%s').strftime('%H:%M')
  sunset = DateTime.strptime("#{date['sys']['sunset']+timezone}", '%s').strftime('%H:%M')

  temperature = date['main']['temp'].to_i.round
  feels_like = date['main']['feels_like'].to_i.round
  min_temp = date['main']['temp_min']
  max_temp = date['main']['temp_max'].to_i.round

  pressure = (date['main']['pressure'].to_i / 1.333).round(1) #hPa => mmHg
  humidity = date['main']['humidity']

  description = date['weather'][0]['description']
  today = {}
  today.merge!("data"=>current_day, "sunrise" => sunrise, "sunset" => sunset, "current_temp" => temperature, "feels_like" => feels_like, "min_temp" => min_temp, "max_temp" => max_temp, "pressure" => pressure, "humidity" => humidity, 'clouds' => description)

  return "#{Time.parse(today['data']).strftime("%d-%m-%Y")} 
    температура: #{today['current_temp']}, ощущается как: #{today['feels_like']}
    max: #{today['max_temp']}\u00B0С, min: #{today['min_temp']}\u00B0С,
    влажность: #{today['humidity']}%,
    давление: #{today['pressure']} мм.рт.ст,
    #{today['clouds']}
    рассвет: #{today['sunrise']} закат: #{today['sunset']}"    

end

