require 'csv'
require 'json'
require 'pry'

#START REPO!!

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

def iterate_output(input_array)
  parsed_array = Array.new

  input_array.each do |row|
    unless row[:location] == nil
      if parsed_array.last != nil && row[:businessname] == parsed_array.last[:businessname] && row[:result] = 'HE_Fail'
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
        restaurant[:businessname] = row[:businessname]
        restaurant[:owner] = row[:legalowner]
        restaurant[:first_name] = row[:namefirst].capitalize
        restaurant[:last_name] = row[:namelast].capitalize
        restaurant[:address] = row[:address]
        restaurant[:city] = row[:city]
        restaurant[:licenseno] = row[:licenseno]
        restaurant[:coordinates] = row[:location]
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

parsed_array = iterate_output(output_array)

File.open('output.json', 'w') { |file| file.write(parsed_array) }
