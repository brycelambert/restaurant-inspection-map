require 'csv'
require 'json'
require 'pry'

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

#FIX SPACE SUBTITUTION
def clean_string(string)
  string.downcase
  string.split.map(&:capitalize).join(' ')
end

def clean_text(text)
end

def clean_coordinates(coordinates)
  coordinates_array = Array.new
  coordinates.delete!('()')
  longitutde, latitude = coordinates.split(', ')
  coordinates_array << longitutde.to_f << latitude.to_f
end

def clean_address(address)
  if address.include? 'Av'
    return address.gsub(' Av ', ' Ave. ')
  elsif address.include? 'Bl'
    return address.gsub('Bl', 'Blvd.')
  elsif address.include? 'Plaza' || address.include? 'Logan Airport'
    return address
  else
    returnaddress << '.'
  end
end

def iterate_output(input_array)
  parsed_array = Array.new

  input_array.each do |row|
    unless row[:location] == nil
      if parsed_array.last != nil && clean_string(row[:businessname]) == parsed_array.last[:businessname] && row[:result] = 'HE_Fail'
        violation = Hash.new
        violation[:level] = convert_violation_level(row[:viollevel])
        violation[:description] = row[:violdesc]
        violation[:comments] = row[:comments]
        violation[:violation_code] = row[:violation]
        violation[:violation_dttm] = row[:violdttm]

        parsed_array.last[:violations].push(violation)
        parsed_array.last[:violations_count] += 1

      elsif row[:licstatus] == 'Active'
        restaurant = Hash.new
        restaurant[:businessname] = clean_string(row[:businessname])
        restaurant[:owner] = clean_string(row[:legalowner])
        restaurant[:first_name] = clean_string(row[:namefirst].capitalize)
        restaurant[:last_name] = clean_string(row[:namelast].capitalize)
        restaurant[:address] = clean_string(row[:address])
        restaurant[:city] = clean_string(row[:city])
        restaurant[:licenseno] = row[:licenseno]
        restaurant[:longitutde], restaurant[:latitude] = clean_coordinates(row[:location])
        restaurant[:violations] = Array.new

        if row[:violstatus] = 'HE_Fail'
          violation = Hash.new
          violation[:level] = convert_violation_level(row[:viollevel])
          violation[:description] = row[:violdesc]
          violation[:comments] = row[:comments]
          violation[:violation_code] = row[:violation]
          violation[:violation_dttm] = row[:violdttm]
          restaurant[:violations].push(violation)
          restaurant[:violations_count] = 1
        end

        parsed_array.push(restaurant)
      end
    end
  end

  return parsed_array
end


file = File.read('csv.csv')
csv_file = CSV.new(file, {headers: true, header_converters: :symbol, converters: [:all, :blank_to_nil]})

output_array = csv_file.to_a.map { |row| row.to_hash }
binding.pry

parsed_array = iterate_output(output_array)

File.open('output.json', 'w') { |file| file.write(parsed_array) }
