require 'csv'
require 'sunlight/congress'
require 'erb'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"
def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone_number(phone)
  phone.delete! ". \(\)-"
  phone = '0000000000' if phone.length > 11 || phone.length < 10
  if phone.length == 11 && phone[0] == '1'
    phone.slice!(0)
  elsif phone.length == 11 && phone[0] != '1'
    phone = '0000000000'
  end
  phone
end

def clean_registration_time(regtime)
  regtime = DateTime.strptime(regtime, '%m/%d/%y %H:%M')
  hour = regtime.strftime('%H')
  make_hour_hash(hour)
end

def make_hour_hash
  hour_hash[hour]
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end

puts "EventManager initialized."

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phone_number = clean_phone_number(row[:homephone])
  legislators = legislators_by_zipcode(zipcode)
  registration_time = clean_registration_time(row[:regdate])
  form_letter = erb_template.result(binding)

  save_thank_you_letters(id,form_letter)
end

puts hour_hash
