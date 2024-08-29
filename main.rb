require 'json'
require 'date'
require 'active_support/all'

Time.zone = 'America/Sao_Paulo'

def add_record(file_path, json_data, input_data)
  if json_data['tasks'].empty?
    new_id = 1
  else
    new_id = json_file['tasks'].last['id'] + 1
  end

  json_input = {
    id: new_id,
    description: input_data.split('"')[1],
    status: 'todo',
    created_at: Time.zone.now,
    updated_at: Time.zone.now
  }

  json_data['tasks'] << json_input

  File.open(file_path, 'w') do |f|
    f.write(JSON.pretty_generate(json_data))
  end
end


def update_record(file_path, json_data, id, input_data)
  index = json_data['tasks'].index { |entry| entry['id'].to_s == id.to_s }

  if index
    task = json_data['tasks'].find {|t| t['id'].to_s == id.to_s}

    task['description'] = input_data.split('"')[1]
    task['updated_at'] = Time.zone.now
  
    json_data['tasks'][index] = task
  
    File.open(file_path, 'w') do |f|
      f.write(JSON.pretty_generate(json_data))
    end
    
    puts "Record with ID #{task['id']} updated successfully."
  else
    puts "No record found with id #{id}"
  end
end 

def delete_record(file_path, json_data,id)
  index = json_data['tasks'].index { |entry| entry['id'].to_s == id.to_s }
  if index 
    json_data['tasks'].delete_at(index)

    File.open(file_path, 'w') do |f|
      f.write(JSON.pretty_generate(json_data))
    end
    
    puts "Record with ID #{id} deleted successfully."
  else
    puts "No record found with id #{id}"
  end
end

def update_status(file_path, json_data, id, status)
  index = json_data['tasks'].index { |entry| entry['id'].to_s == id.to_s }

  if index
    task = json_data['tasks'].find {|t| t['id'].to_s == id.to_s}

    task['status'] = status
    task['updated_at'] = Time.zone.now
  
    json_data['tasks'][index] = task
  
    File.open(file_path, 'w') do |f|
      f.write(JSON.pretty_generate(json_data))
    end
    
    puts "Record with ID #{task['id']} updated successfully."
  else
    puts "No record found with id #{id}"
  end
end

def select_records(json_data, filter)
  if filter.nil?
    puts JSON.pretty_generate(json_data)
  else
    filtered_data = json_data['tasks'].select { |record| record['status'] == filter }
    puts JSON.pretty_generate(filtered_data)
  end
end

while(true)
  file_path = 'tasks.json'
  if File.exist?(file_path)
    file = File.read(file_path)
    json_file = JSON.parse(file)
    json_file['tasks'] ||= [] 
  else
    json_file = { 'tasks' => [] }
  end

  p 'enter a command'
  input = gets.chomp
  array_input = input.split

  case array_input[0]
  when 'close'
    break

  when 'add'
    add_record(file_path, json_file, input)

  when 'update'
    id = array_input[1]
    update_record(file_path, json_file, id, input)

  when 'delete'
    id = array_input[1]
    delete_record(file_path, json_file, id)

  when 'mark-in-progress'
    id = array_input[1]
    update_status(file_path, json_file, id, 'in-progress')

  when 'mark-done'
    id = array_input[1]
    update_status(file_path, json_file, id, 'done')

  when 'list'
    case array_input[1]
    when 'done'
      select_records(json_file, 'done')
    when 'todo'
      select_records(json_file, 'todo')
    when 'in-progress'
      select_records(json_file, 'in-progress')
    else
      select_records(json_file, nil)
    end

  else
    puts "Unknown command: #{array_input[0]}"
  end
end
