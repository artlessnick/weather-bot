require 'json'
require 'date'
require 'time'
require 'open-uri'

def middle(array) #подсчета средней температуры/давления/влажности за день
  sum = 0
  array.each{ |a| sum += a}
  return sum/array.size
end

def weather(array) #для определения облачности/ясности и возможности осадков
  hash = {}
  for i in array
    if hash.has_key?(i)
      hash[i] += 1
    else
      hash[i] = 1
    end
  end

  value = []
  keys =[]

  hash.each do |key, val| 
    value << val
    keys << key
  end 

  out = hash.key(value.max)
  precipitation = []
    for key in keys 
      if key.include?("снег") || key.include?("дождь") || key.include?("град")
        precipitation << key
      end
    end
  if out.include?("снег") || out.include?("дождь") || out.include?("град") or precipitation.length == 0
    return out
  else  
    if precipitation.length > 1
      return "#{hash.key(value.max)}, возможны осадки"
    else  
      return "#{hash.key(value.max)}, возможен #{precipitation[0]}"
    end
  end
end

def collection(n, date_list) #сбор данных на каждый день
  for_temp = []
  for_pressure = []
  for_humidity = []
  for_clouds = []
  hash = {}
    for i in date_list
        if i['dt_txt'].slice(0..9) == n
          for_temp << (i["main"]['temp'])
          for_pressure << (i['main']['pressure'])
          for_humidity << (i['main']['humidity'])
          for_clouds << i['weather'][0]['description']
        end
    end
  pressure = (middle(for_pressure).to_i/1.333).round(1)
  humidity = middle(for_humidity)
  clouds = weather(for_clouds)
  return hash.merge("data" => n,'min_temp' => for_temp.min.round, "max_temp" => for_temp.max.round, "pressure" => pressure, "humidity" => humidity, "clouds" => clouds)
end 

def few_days(number, url)
  file = open(url)
  date = JSON.parse(file.read)

  list = date['list']

  days = []
  few_days = number
  need_date = []

  for i in list 
      if days.include?(i['dt_txt'].slice(0..9)) == false && days.length < few_days
        days << i['dt_txt'].slice(0..9)
      end 
  end

  for day in days
    a = collection(day, list)
    need_date << a
  end

  return need_date

end

