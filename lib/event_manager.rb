require "csv"
require 'sunlight/congress'
require 'erb'
require 'date'
require 'pry'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
	zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zipcode)
	legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id, form_letter)
	Dir.mkdir("output") unless Dir.exists? "output"

	filename = "output/thanks_#{id}.html"

	File.open(filename,'w') do |file|
		file.puts form_letter
	end
end

def clean_phone_numbers(phonenumber)
	badnumber = '0000000000'
	phonenumber = phonenumber.to_s.gsub!(/[-().' ']/, '')
	if phonenumber.length < 10 || phonenummber.length > 11
		badnumber
	elsif phonenumber.length == 11
		if phonenumber.start_with?('1')
			phonenumber[1..10]
		else
			badnumber
		end
	else
		phonenumber
	end
end

def time_target(csv_contents)
	hours = []
	csv_contents.each do |row|
		hours << DateTime.strptime(row[:regdate], '%m/%d/%Y %H:%M').strftime("%H") end
	count = hours.map {|hour| hours.count(hour)}
	count.zip(hours).uniq!.sort_by{|nest| nest[0]}.reverse!.each {|nest| nest[1] = nest[1] + ':00'}
	end

def day_target(csv_contents)
	days = []
	csv_contents.each do |row|
		days << DateTime.strptime(row[:regdate], '%m/%d/%Y %H:%M').strftime("%A") end
	count = days.map {|day| days.count(day)}
	count.zip(days).uniq!.sort_by{|nest| nest[0]}.reverse!
end


puts "Event Manager Initialized!"

contents = CSV.read "event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

puts "Time Target!!"
print time_target(contents)


puts "\nDay Target!!"
print day_target(contents)

contents.each do |row|
	id = row[0]
	name = row[:first_name]
	
	zipcode = clean_zipcode(row[:zipcode])

	legislators = legislators_by_zipcode(zipcode)

	form_letter = erb_template.result(binding)

	save_thank_you_letters(id,form_letter)

end
