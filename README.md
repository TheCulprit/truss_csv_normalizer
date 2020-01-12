
This projectruns on ruby and requires the `CSV` and `active_support/all` gems to be installed. 
I believe that CSV is included with ruby but active_support will need to be installed
(if you have rails installed, you're done here).

To run the normalizer:
- navigate to the directory that contains `normalizer.rb`
- `ruby ./normalizer.rb < [path_to]/sample.csv > [path_to]/output.csv`