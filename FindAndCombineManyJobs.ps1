$jobsCombined = @();
$jobs = (Get-ChildItem -path "R:\AA240311\*" -include "*.json" -r);
for ($i = 0; $i -lt $jobs.length; $i++) {
  $ordersInJob = (Get-Content $jobs[$i].fullname | convertfrom-json);
  $ordersKeys = $ordersInJob | get-member | Select-Object -property 'name';
  # for loop starts at 4 to start at the first actual property name as powershell has extra properties
  for ($j = 4; $j -lt $ordersKeys.length; $j++) {
    # I should also add the filename (should be jobId UUID) to the jobId property
    $jobsCombined += $ordersInJob.($ordersKeys[$j].name);
  };
}
set-content ~\Desktop\missing-orders-2.json ($jobsCombined | convertto-json);
