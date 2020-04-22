require 'net/http'
require 'rexml/document'

# Подключаем класс MeteoserviceForecast
require_relative 'lib/meteoservice_forecast'

CITIES = {
  37 => 'Москва',
  69 => 'Санкт-Петербург',
  99 => 'Новосибирск',
  59 => 'Пермь',
  115 => 'Орел',
  121 => 'Чита',
  141 => 'Братск',
  199 => 'Краснодар'
}.invert.freeze

# Сделаем массив из названий городов, взяв ключи массива CITIES
city_names = CITIES.keys

# Спрашиваем у пользователя, какой город по порядку ему нужен
puts 'Погоду для какого города Вы хотите узнать?'
city_names.each_with_index { |name, index| puts "#{index + 1}: #{name}" }
city_index = gets.to_i
unless city_index.between?(1, city_names.size)
  city_index = gets.to_i
  puts "Введите число от 1 до #{city_names.size}"
end

# Когда, наконец, получим нужный индекс, достаем city_id
city_id = CITIES[city_names[city_index - 1]]

# Сформировали адрес запроса
url = "https://xml.meteoservice.ru/export/gismeteo/point/#{city_id}.xml"

# Дальше все по старому
response = Net::HTTP.get_response(URI.parse(url))
doc = REXML::Document.new(response.body)

city_name = URI.unescape(doc.root.elements['REPORT/TOWN'].attributes['sname'])

forecast_nodes = doc.root.elements['REPORT/TOWN'].elements.to_a

puts city_name
puts

forecast_nodes.each do |node|
  puts MeteoserviceForecast.from_xml(node)
  puts
end
