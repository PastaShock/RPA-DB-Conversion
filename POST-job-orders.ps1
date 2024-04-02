# Import existing jobs into jobs database
# George Pastushok March 2024
# 
# Purpose:
#   Find and iterate through all JSON files named with a GUID.
#   In each job file, pull the job information and pass the job id, dates, user and printer.
#   POST the job to the /jobs/ endpoint
#   In each job file, pull the job ID and order ID and post it to the /job_orders/ endpoint.
#

# following function copied from POST-orders-db-to-server:
function trimDate($date) {
    if ($date.Contains("GMT")) {
        return $($a = ($date).split(' ')
        $date_join = @()
        for ( $i = 0; $i -lt $a.length - 4; $i++ ) {
            $date_join += $a[$i]
        }
        $date_join = $date_join -join ' '
        get-date $date_join -format 'yyyy-MM-dd hh:mm:ss')
    } else {
        return $date
    }
}
# POSTjobId is for a single job file
$POSTjobId = '623d64d6-369d-4392-ba82-8c7206dc388a'
# this is the definition for a GUID in regex
$guidREGEX = '[A-z0-9]{8}-[A-z0-9]{4}-[A-z0-9]{4}-[A-z0-9]{4}-[A-z0-9]{12}'
# Using the regex def find all matching files
# $JobOrdersJson = Get-ChildItem -path "R:\AA2403*" -include "*.json" -r
$JobOrdersJson = Get-ChildItem -Path "R:\AA240325\George Pastushok_DL\test.json"
# Loop through all files:
$JobOrdersJson | ForEach-Object {
    # Set the POSTjobId to the name of the current job file
    $POSTjobId = $_.Name.split('.')[0]
    if ($POSTjobId -notmatch $guidREGEX) {
        Write-Output "job $($_.FullName) has no GUID; generating new one."
        $POSTjobid = (New-Guid).Guid
        Write-Output "new uuid = $POSTjobid"
    }
    # Get content of file and convert into PSO
    $orderJob = $(Get-Content $_ -raw | ConvertFrom-JSON)
    Write-host "checking... length: $($orderJob.length)`n$orderJob"
    if ($orderJob.length -eq 1) {
        $orderJob = @($orderJob)
    }
    forEach($order in $orderJob) {
        # Create API call to post job to Jobs:
        # I need:
        # job_id: (file name)
        # date_downloaded
        # date_printed
        # print_user
        # print_device
        # print_queue
        # Each of the above datapoints should be on an order
        # I'll need to take the first order on the job to get that information
        # Each order ID is object's member 'name'
        # 
        # --------------------------------------------------------------------
        # Test behavior for one order in JSON file:
        # When there is only one order, the properties keys are returned -- not desired behavior
        $orderIds = ($orderJob | get-member).name
        Write-Output "orderIds: $orderids"
        $firstOrder = $orderIds[4]
        Write-Output "firstOrder: $firstOrder"
        $PJP = $orders.$firstOrder
        Write-Output "PJP: $PJP"
            # The job ID needs to be saved as the file name into a jobID var as it is lost in this
            #   scope due to the pipes.
            # Print queue needs to be defined based on the folder of the file
            # if the folder name follows this pattern: 'r[01]{1}[0-9]{1}[0-9]{2}0[1-4]{1}'
            #                                               i.e. r060601
            Write-Output "checking $order"
            $queue = "a"
            $match = $_.directory.name -match "r[01]{1}[0-9]{1}[0-9]{2}0[1-4]{1}"
            if ($match) {
                $queue = "c"
            }
            $printerDestination = $PJP.printer
            if ($printerDestination -eq $NULL) {
                $printerDestination = 'Default'
                Write-Output "Old order without 'printer' record: set to Default"
            }
            if ($PJP.printDate -eq $NULL) {
                $printDate = (trimDate $order.downloadDate)
                Write-Output "print date defaulted to downloadDate : $printDate"
            } else {
                $printDate = (trimDate $PJP.printDate)
            }
            $res = Invoke-WebRequest -Method GET -Uri "$db_uri/printersByName/$($printerDestination)"
            $printer = ($res.Content | convertfrom-json).equip_id
            if ($PJP.printUser -eq $NULL) {
                $user = "600574fb-7a69-4384-9216-2d59a62c3a59"
            } else {
                $res = Invoke-WebRequest -Method GET -Uri "$db_uri/usersByName/$($PJP.printUser)"
                $user = ($res.Content | convertfrom-json).user_id
            }
            $body = @{
                job_id = $POSTjobId
                date_downloaded = (trimDate $orderJob.downloadDate)
                date_printed = $printDate
                print_user = $user
                print_device = $printer
                print_queue = $queue
            }
            Write-Output "POST:jobs:"$($body | Format-Table)
            # Invoke-RestMethod -Method POST -Uri "$db_uri`jobs/" -body $body
        # Loop through all names and start at index 4 to skip default PSO 'name's
        for ($i = 4; $i -lt $orderIds.length; $i++) {
            # Call the API to post a job_order with job id (file name) and order id
            # Note: each job_order requires a job to exist, make sure job is posted before hand!
            $body = @{
                job_id = $POSTjobId
                order_id = $orderIds[$i]
            }
            Write-Output "POST:job_orders:"$($body | Format-Table)
            # invoke-restMethod -Method POST -Uri "$db_uri`job_orders" -body $body
        }
    } 
}