require 'csv'
require 'time'
require 'date'

def clean_phone_number(phone_number, cleaned_numbers)
  number = phone_number.gsub(/[^\d]/, '')
  if number.length < 10 || number.length > 11
    number = ''
  elsif number.length == 10
    number = number.insert(3, '-').insert(7, '-')
  elsif number.length == 11
      if number[0] == '1'
        number = number[1..-1].insert(4, '-').insert(-5, '-')
      else
        number = ''
      end
  end
  cleaned_numbers.push(number)
end

def add_hour(time, reg_hours)
  current_time = Time.parse(time)
  if reg_hours[current_time.hour] >= 1
    reg_hours[current_time.hour] += 1
  else
    reg_hours[current_time.hour] = 1
  end
end

def peak_hours(reg_hours)
  peak_reg = []
  max_reg = reg_hours.values.max

  reg_hours.each do |key, value|
    peak_reg.push(key) if reg_hours[key] == max_reg 
  end

  peak_reg = peak_reg.sort
  peak_reg.map { |value| value.to_s << ':00'}
end

def add_weekday(date, reg_weekdays)
  current_date = Date.strptime(date, '%m/%d/%Y')
  if reg_weekdays[current_date.wday] >= 1
    reg_weekdays[current_date.wday] += 1
  else
    reg_weekdays[current_date.wday] = 1
  end
end

def peak_weedays(reg_weekdays, wday_hash)
  peak_reg = []
  reg_max = reg_weekdays.values.max
  reg_weekdays.each do |key, value| 
    if reg_weekdays[key] == reg_max
      peak_reg.push(wday_hash[key])
    end
  end
  peak_reg
end

content = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
  )

cleaned_numbers = []
reg_hours = Hash.new(0)
WEEKDAYS = {
  0 => 'Sunday',
  1 => 'Monday',
  2 => 'Tuesday',
  3 => 'Wednesday',
  4 => 'Thursday',
  5 => 'Friday',
  6 => 'Saturday'
}
reg_weekdays = Hash.new(0)

content.each do |line|
  clean_phone_number(line[:homephone], cleaned_numbers)
  date_time = line[:regdate].split(' ')
  add_hour(date_time[1], reg_hours)
  add_weekday(date_time[0], reg_weekdays)
end

puts 'Cleaned phone numbers:'
puts cleaned_numbers
puts "\nPeak registration hours:"
puts peak_hours(reg_hours)
puts "\nPeak weekday registrations:"
puts peak_weedays(reg_weekdays, WEEKDAYS)
