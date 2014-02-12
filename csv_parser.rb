require 'csv'
require 'json'
require 'date'
require 'pry'

#Roman Numerals? --Find regex thing
#Abbreviations 'M.g.h'

#words: by

#use empty strings for nils?

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

#Each word capitalized
def clean_string(string)
  unless string == nil
    clean_string = string.downcase.split.map(&:capitalize).join(' ')
  end
  return clean_string == '' ? nil : clean_string
end

#Only first letter capitalized
def clean_text(text)
  unless text == nil?
    text.split.map(&:downcase).join(' ').capitalize
  end
end

def clean_business_name(name)
  return name if name.nil?
  clean_name = downcase_prepositions(name)
  index = clean_name.index("(") || clean_name.index("/") || clean_name.index("/-\S/")
  if index != nil && index != clean_name.length - 1
    clean_name[index + 1] = clean_name[index + 1].upcase
  end
  clean_name.sub!(/l\sl\sc|l\.*?l\.*?c/i, 'LLC')
  clean_name.sub!(/co\.?\s/i, 'Co. ')
  clean_name.sub!(/l\s?l\s?p/i, 'LLP')
  return clean_name
end

def downcase_prepositions(uppercase_prep_string)
  uppercase_prep_string.gsub(/\sOn\s|\sAnd\s|\sThe\s|\sOf\s/, ' On ' => ' on ', ' And ' => ' and ', ' The ' => ' the ', ' Of ' => ' of ')
end

def clean_coordinates(coordinates)
  coordinates_array = Array.new
  coordinates.delete!('()')
  latitude,longitutde = coordinates.split(', ')
  return coordinates_array << latitude.to_f << longitutde.to_f
end

def clean_address(address)
  unless address == nil
    clean_address = clean_string(address)
    if clean_address.include? ' Av'
      return clean_address.sub(' Av', ' Ave.')
    elsif clean_address.include? ' Bl'
      return address.sub(' Bl', ' Blvd.')
    elsif clean_address.include? ' St' or clean_address.include? ' Rd'
      return clean_address << '.'
    else
      return clean_address
    end
  end
end

def determine_owner(legalowner, first_name, last_name)
  legalowner = clean_string(legalowner)
  first_name = clean_string(first_name)
  last_name = clean_string(last_name)

  return clean_business_name(legalowner) if legalowner != nil
  return clean_business_name("#{first_name} #{last_name}") if first_name != nil && last_name != nil
  owner = first_name || last_name
  return clean_business_name(owner)
end

def iterate_output(input_array)
  parsed_array = Array.new
  input_array.each do |row|

    unless row[:violdttm].nil? || row[:location].nil? || row[:violdttm].include?('/12'||'/13') == false || row[:licstatus] == 'Inactive' || row[:violstatus] == 'Pass'

      if parsed_array.last != nil && row[:licenseno] == parsed_array.last[:licenseno] && row[:violstatus] == 'Fail'
        violation = Hash.new
        violation[:level] = convert_violation_level(row[:viollevel])
        violation[:description] = clean_text(row[:violdesc])
        violation[:comments] = clean_text(row[:comments])
        violation[:violation_code] = row[:violation]
        violation[:violation_dttm] = row[:violdttm]
        parsed_array.last[:violations].push(violation)
        parsed_array.last[:violations_count] += 1

      elsif row[:licstatus] == 'Active'
        restaurant = Hash.new
        restaurant[:label] = clean_business_name(clean_string(row[:businessname]))
        restaurant[:owner] = determine_owner(row[:legalowner], row[:namefirst], row[:namelast])
        restaurant[:address] = clean_address(row[:address])
        restaurant[:city] = clean_string(row[:city])
        restaurant[:licenseno] = row[:licenseno]
        restaurant[:lat], restaurant[:lng] = clean_coordinates(row[:location])
        restaurant[:violations_count] = 0
        restaurant[:violations] = Array.new

        if row[:violstatus] =='Fail'
          violation = Hash.new
          violation['level'] = convert_violation_level(row[:viollevel])
          violation[:description] = clean_text(row[:violdesc])
          violation[:comments] = clean_text(row[:comments])
          violation[:violation_code] = row[:violation]
          violation[:violation_dttm] = row[:violdttm]
          restaurant[:violations].push(violation)
          restaurant[:violations_count] += 1
        end
        parsed_array.push(restaurant)
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

#input csv
file = File.read('csv.csv', encoding: 'windows-1251:utf-8')
csv_file = CSV.new(file, {headers: true, header_converters: :symbol, converters: [:blank_to_nil]})

output_array = csv_file.to_a.map { |row| row.to_hash }

#output csv
parsed_array = iterate_output(output_array).to_json

open('output.json', 'a') do |f|
f << 'restaurant_data = '
f << parsed_array
end