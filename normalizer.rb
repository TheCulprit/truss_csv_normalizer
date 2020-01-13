
require 'active_support/all'
require 'CSV'

def main
  scrubbed_string = resolve_encoding
  csv = CSV.open("sample_tmp.csv", headers: true, encoding: 'UTF-8')
  rows = create_rows_with_headers(csv)
  $stdout << poulate_rows(csv, rows)
end

def resolve_encoding
  original_string = $stdin.read
  scrubbed_string = original_string.encode('UTF-8', invalid: :replace, undef: :replace, replace: '�')
  f = File.new("sample_tmp.csv",  "w+")
  f.write(scrubbed_string)
  f.close
end

def create_rows_with_headers(csv)
  csv.read
  rows = ["#{csv.headers.join(',')}\n"]
  csv.rewind
  rows
end

def poulate_rows(csv, rows)
  csv.each do |row|
    begin
      row["Timestamp"] = parsed_timestamp(row["Timestamp"])
      row["ZIP"] = padded_zip_code(row["ZIP"])
      row["FullName"] = row["FullName"].upcase unless row["Notes"].nil?
      row["Address"].gsub!(/[^[:print:]]/i, '�')
      row["FooDuration"] = hh_mm_ss_to_seconds(row["FooDuration"]) 
      row["BarDuration"] = hh_mm_ss_to_seconds(row["BarDuration"])
      row["TotalDuration"] = row["FooDuration"] + row["BarDuration"]
      rows << row.to_s
    rescue StandardError => e  
        $stderr << e.message
    end
  end

  csv.close
  `rm sample_tmp.csv`
  rows.join
end

def parsed_timestamp(timestamp)
  timestamp = timestamp.split(' ')
  date = timestamp[0].split('/')
  year = date[2].to_i + 2000
  month = date[0].to_i
  day = date[1].to_i

  time = timestamp[1].split(':')
  hour = time[0].to_i
  minute = time[1].to_i
  second = time[2].to_i

  parsed_time = Time.strptime("#{year}-#{month}-#{day}T#{hour}:#{minute}:#{second}PM", "%Y-%m-%dT%H:%M:%S")
  datetime = to_24(parsed_time, timestamp[2] == 'PM').to_datetime
  datetime = datetime.new_offset(resolve_offset(datetime.to_s))
end

def to_24(time, is_pm)
  time = is_pm ? time + 12.hours : time
end

def padded_zip_code(zip_code)
  zip_code.rjust(5, "0")
end

def hh_mm_ss_to_seconds(duration)
  duration.split(':').map { |a| a.to_f }.inject(0) { |a, b| a * 60 + b}
end


def resolve_offset(datetime)
  offset = datetime.split(//).last(6)
  offset[2] = (offset[2].to_i - 3).to_s
  offset.join
end

main
