$jobsCombined = @();
# Change the filename here to the desired file:
$job = (cat "R:\AA240219\r022001\2a22566d-5acf-4ef6-863e-7e178a6d894c ab1a7cc2-06ca-4d76-becf-fddd17e9ac4c.json" | convertfrom-json);
$jobKeys = ($job | get-member | select -property 'name');
for ($i = 0; $i -lt $jobKeys.length; $i++) {
  $ordersInJob = $job.($jobKeys[$i].name)
  $jobsCombined += $ordersInJob;
  }
set-content ~\Desktop\single-job.json ($jobsCombined | convertto-json);
