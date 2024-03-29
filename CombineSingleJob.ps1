$jobsCombined = @();
# Change the filename here to the desired file:
$job = (Get-Content "R:\AA240219\r022001\81e1f84c-f099-412e-9a5b-cad9729e81b2.json" | convertfrom-json);
$jobKeys = ($job | get-member | Select-Object -property 'name');
for ($i = 0; $i -lt $jobKeys.length; $i++) {
  $ordersInJob = $job.($jobKeys[$i].name)
  $jobsCombined += $ordersInJob;
  }
set-content ~\Desktop\single-job.json ($jobsCombined | convertto-json);
