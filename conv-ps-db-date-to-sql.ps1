$db = (Get-Content .\db-trimmed.json | convertfrom-json);
	
$db = ($db | Where-Object -property 'jobId' -eq $null)
# $db = ($db | Select-Object -property 'printDate' -f 1)
$date_last_order = [dateTime](get-date);
$jobsArray = @();
$db | ForEach-Object {
    # Write-Output "order: $($_)"
    $dateToFix = ($_.printDate).split(' ');
    $fixedDate = @();
	 for ( $i = 0; $i -lt $dateToFix.length - 4; $i++ ) {
        $fixedDate += $dateToFix[$i]
    };
    $fixedDate = ($fixedDate -join " ");
    $fixedDate = [dateTime](get-date $fixedDate -format 'yyyy-MM-dd HH:mm:ss');
    $time_diff = $fixedDate - $date_last_order;
    Write-Output "time last: $($fixedDate)`n time curr: $($date_last_order)`n diff_sec: $($time_diff.Minutes)"
    if ($time_diff.Minutes -gt 1) {
        $guid = get-guid.guid
        Write-Output "new job starts here: $($guid)"
        $jobsArray += ($_ | convertto-json)
    }
    $date_last_order = $fixedDate;
    $_.printDate = $fixedDate;
    Write-Output "$($_.orderId) : printDate: $($_.printDate)"
};