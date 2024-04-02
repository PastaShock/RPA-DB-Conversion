$path = "R:\AA240311\"
$files = Get-ChildItem -path $path -include "*.json" -r
$jobs = @();
$files | ForEach-Object {
    $jobName = $_.name.split('.')[0].split(' ')[0];
    Write-Output $jobName;
    # jobject is an object for a job
    $jobject = [PSCustomObject]@{
            job_id = $jobName
            date_downloaded = $null
            date_printed = $null
            print_user_id = $null
            print_device_id = $null
            print_queue = $null
    };
    # set vars to add to jobject later:
    $downloadDate = ''
    $datePrinted = ''
    $printUser = ''
    $printDev = ''
    $printQ = ''
    $job = Get-Content $_ | convertfrom-json;
    $jobOrders = $job | get-member | select-object -property 'name';
    $ordersInJob = @();
    # Get order_ids for each order in job
    # Add order_ids to table job_orders
    # Get job information for table jobs
    for ($i = 4; $i -lt $jobOrders.length; $i++) {
        Write-Output $jobOrders[$i].name;
        # jobOrder is an object for table job_orders, a list of order_ids with corresponding job_ids
        $jobOrder = [PSCustomObject]@{
            job_id = $jobName
            order_id = $jobOrders[$i].name
        };
        # POST API call here for job_orders:
        #
        # get job info for jobject
        $body = $([PSCustomObject]@{
            user_name = $user
        } | convertto-json)
        $res = Invoke-RestMethod -Method GET -Uri "$db_uri/usersByName/" -Body $body
        $userID = $res.user_id
    }
}