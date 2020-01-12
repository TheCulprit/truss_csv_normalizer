
require 'active_support/all'
require 'CSV'
require 'byebug'

def main
  original_string = $stdin.read
  scrubbed_string = original_string.encode('UTF-8', invalid: :replace, undef: :replace, replace: '�')
  f = File.new("sample_tmp.csv",  "w+")
  f.write(scrubbed_string)
  f.close
  f = CSV.open("sample_tmp.csv", headers: true, encoding: 'UTF-8')

  # byebug

  rows = []
  f.read
  rows << "#{f.headers.join(',')}\n"
  f.rewind
  f.each do |row|
    begin
      row["Timestamp"] = parse_timestamp(row["Timestamp"])
      row["ZIP"] = pad_zip_code(row["ZIP"])
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

  f.close
  `rm sample_tmp.csv`
  $stdout << rows.join
end

def parse_timestamp(timestamp)
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

def resolve_offset(datetime)
  offset = datetime.split(//).last(6)
  offset[2] = (offset[2].to_i - 3).to_s
  offset.join
end

def hh_mm_ss_to_seconds(duration)
  duration.split(':').map { |a| a.to_f }.inject(0) { |a, b| a * 60 + b}
end

def pad_zip_code(zip_code)
  zip_code.rjust(5, "0")
end

main


###############################################################################
def resolve_encoding(scrubbed_string)
  original_string = $stdin.read
  original_string.encode('UTF-8', invalid: :replace, undef: :replace, replace: '�')
  f = File.new("sample_tmp.csv",  "w+")
  f.write(scrubbed_string)
  f.close
end
###############################################################################
  csv.each do |row|
    begin
      row["Timestamp"] = parse_timestamp(row["Timestamp"])
      row["ZIP"] = pad_zip_code(row["ZIP"])
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
  $stdout << rows.join
###############################################################################

_This is one of the steps in the Truss interview process. If you've
stumbled upon this repository and are interested in a career with
Truss, [check out our jobs page](https://truss.works/jobs)._

# Truss Software Engineering Interview

## Introduction and expectations

Hi there! Please complete the problem described below to the best of
your ability, using the tools you're most comfortable with. Assume
you're sending your submission in for code review from peers;
we'll be talking about your submission in your intervie win that
context.

We expect this to take less than 4 hours of actual coding time. Please
submit a working but incomplete solution instead of spending more time
on it. We're also aware that getting after-hours coding time can be
challenging; we'd like a submission within a week and if you need more
time please let us know.

If you have any questions, please contact hiring@truss.works; we're
happy to help if you're not sure what we're asking for or if you have
questions.

## How to submit your response

Please send hiring@truss.works a link to a public git repository
(Github is fine) that contains your code and a README.md that tells us
how to build and run it. Your code will be run on either macOS 10.13
or Ubuntu 16.04 LTS, your choice.

## The problem: CSV normalization

Please write a tool that reads a CSV formatted file on `stdin` and
emits a normalized CSV formatted file on `stdout`. For example, if
your program was named `normalizer` we would test your code on the
command line like this:

```sh
./normalizer < sample.csv > output.csv
```

Normalized, in this case, means:

* The entire CSV is in the UTF-8 character set.
* The `Timestamp` column should be formatted in ISO-8601 format.
* The `Timestamp` column should be assumed to be in US/Pacific time;
  please convert it to US/Eastern.
* All `ZIP` codes should be formatted as 5 digits. If there are less
  than 5 digits, assume 0 as the prefix.
* The `FullName` column should be converted to uppercase. There will be
  non-English names.
* The `Address` column should be passed through as is, except for
  Unicode validation. Please note there are commas in the Address
  field; your CSV parsing will need to take that into account. Commas
  will only be present inside a quoted string.
* The `FooDuration` and `BarDuration` columns are in HH:MM:SS.MS
  format (where MS is milliseconds); please convert them to the
  total number of seconds expressed in floating point format.
  You should not round the result.
* The `TotalDuration` column is filled with garbage data. For each
  row, please replace the value of `TotalDuration` with the sum of
  `FooDuration` and `BarDuration`.
* The `Notes` column is free form text input by end-users; please do
  not perform any transformations on this column. If there are invalid
  UTF-8 characters, please replace them with the Unicode Replacement
  Character.

You can assume that the input document is in UTF-8 and that any times
that are missing timezone information are in US/Pacific. If a
character is invalid, please replace it with the Unicode Replacement
Character. If that replacement makes data invalid (for example,
because it turns a date field into something unparseable), print a
warning to `stderr` and drop the row from your output.

You can assume that the sample data we provide will contain all date
and time format variants you will need to handle.
4/1/11 11:00:00 AM,"123 4th St, Anywhere, AA",94121,Monkey Alberto,1:23:32.123,1:32:33.123,zzsasdfa,I am the very model of a modern major general
3/12/14 12:00:00 AM,"Somewhere Else, In Another Time, BB",1,Superman übertan,111:23:32.123,1:32:33.123,zzsasdfa,This is some Unicode right here. ü ¡! 😀
2/29/16 12:11:11 PM,111 Ste. #123123123,1101,Résumé Ron,31:23:32.123,1:32:33.123,zzsasdfa,🏳️🏴🏳️🏴
1/1/11 12:00:01 AM,"This Is Not An Address, BusyTown, BT",94121,Mary 1,1:23:32.123,0:00:00.000,zzsasdfa,I like Emoji! 🍏🍎😍
11/11/11 11:11:11 AM,überTown,10001,Prompt Negotiator,1:23:32.123,1:32:33.123,zzsasdfa,"I’m just gonna say, this is AMAZING. WHAT NEGOTIATIONS."
5/12/10 4:48:12 PM,Høøük¡,1231,Sleeper Service,1:23:32.123,1:32:33.123,zzsasdfa,2/1/22
10/5/12 10:31:11 PM,"Test Pattern Town, Test Pattern, TP",121,株式会社スタジオジブリ,1:23:32.123,1:32:33.123,zzsasdfa,1:11:11.123
10/2/04 8:44:11 AM,The Moon,11,HERE WE GO,1:23:32.123,1:32:33.123,zzsasdfa,
12/31/16 11:59:59 PM,"123 Gangnam Style Lives Here, Gangnam Town",31403,Anticipation of Unicode Failure,1:23:32.123,1:32:33.123,zzsasdfa,I like Math Symbols! ≱≰⨌⊚