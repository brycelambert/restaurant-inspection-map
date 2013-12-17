require 'csv'
require 'json'

CSV::Converters[:blank_to_nil] = lambda do |field|
  field && field.empty? ? nil : field
end

def convert_violation_level(level)
  case level
  when '*'
    return 1
  when '**'
    return 2
  when '***'
    return 3
  else
    return nil
  end
end

def clean_string(string)
  unless string == nil
    clean_string = string.downcase.split.map(&:capitalize).join(' ')
  end
  return clean_string == '' ? nil : clean_string
end

def clean_business_name(name)
  clean_name = clean_string(name)
  index = clean_name.index("(") || clean_name.index("/")
  unless index == nil?
    clean_name[index + 1] = clean_name[index + 1].upcase
  end
  return clean_name
end

def clean_text(text)
  unless text == nil?
    text.split.map(&:capitalize).join(' ').capitalize
  end
end

def clean_coordinates(coordinates)
  coordinates_array = Array.new
  coordinates.delete!('()')
  longitutde, latitude = coordinates.split(', ')
  coordinates_array << longitutde.to_f << latitude.to_f
end

def clean_address(address)
  clean_address = clean_string(address)

  if clean_address.include? 'Av'
    return clean_address.gsub(' Av', ' Ave.')
  elsif clean_address.include? ' Bl'
    return address.gsub(' Bl', ' Blvd.')
  elsif clean_address.include? 'St' or clean_address.include? 'Rd'
    return clean_address << '.'
  elsif clean_address.include? 'Plaza' or clean_address.include? 'Airport'
    return clean_address
  else
    return clean_address
  end
end

def iterate_output(input_array)
  parsed_array = Array.new

  input_array.each do |row|
    unless row[:location] == nil
      if parsed_array.last != nil && clean_string(row[:businessname]) == parsed_array.last[:businessname] && row[:violstatus] = 'Fail'
        # violation = Hash.new
        # violation[:level] = convert_violation_level(row[:viollevel])
        # violation[:description] = clean_text(row[:violdesc])
        # violation[:comments] = clean_text(row[:comments])
        # violation[:violation_code] = row[:violation]
        # violation[:violation_dttm] = row[:violdttm]

        # parsed_array.last[:violations].push(violation)
        parsed_array.last[:violations_count] += 1

        # #output
        # puts "parsed row #{row}"

      elsif row[:licstatus] == 'Active'
        restaurant = Hash.new
        restaurant[:businessname] = clean_string(row[:businessname])
        restaurant[:owner] = clean_string(row[:legalowner])
        restaurant[:first_name] = clean_string(row[:namefirst].capitalize)
        restaurant[:last_name] = clean_string(row[:namelast].capitalize)
        restaurant[:address] = clean_address(row[:address])
        restaurant[:city] = clean_string(row[:city])
        restaurant[:licenseno] = row[:licenseno]
        restaurant[:long], restaurant[:lat] = clean_coordinates(row[:location])
        # restaurant[:violations] = Array.new

        if row[:violstatus] = 'Fail'
        #   violation = Hash.new
        #   violation['level'] = convert_violation_level(row[:viollevel])
        #   violation[:description] = clean_text(row[:violdesc])
        #   violation[:comments] = clean_text(row[:comments])
        #   violation[:violation_code] = row[:violation]
        #   violation[:violation_dttm] = row[:violdttm]
        #   restaurant[:violations].push(violation)
          restaurant[:violations_count] = 1
        end

        parsed_array.push(restaurant)

        #output
        puts "parsed row #{row}"
      end
    end
  end

  return parsed_array
end

#Optional covert Hashes to arrays
#Will not handle violations array!
# def convert_hashes(input_array)
#   output_array = Array.new
#   input_array.each do |restaurant|
#     restaurant[:violations].each { |violation| }
#    output_array << restaurant.values
#  end
#   return output_array
# end

#Input csv
file = File.read('csv2.csv', encoding: 'windows-1251:utf-8')
csv_file = CSV.new(file, {headers: true, header_converters: :symbol, converters: [:all, :blank_to_nil]})

output_array = csv_file.to_a.map { |row| row.to_hash }

#output csv
parsed_array = iterate_output(output_array)

open('output_no_violations.json', 'a') do |f|
f << 'restaurant_data = '
f << parsed_array.to_json
end