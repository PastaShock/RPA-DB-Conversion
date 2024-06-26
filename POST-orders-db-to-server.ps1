$dbfilename = "r:\temp\orders_database.json"
# $dbfilename = "C:\users\rolanda\desktop\single-job.json"
# $dbfilename = "C:\users\rolanda\desktop\missing-orders-2.json"
# $dbFileName = "R:\AA240219\r022001\81e1f84c-f099-412e-9a5b-cad9729e81b2.json"
# $dbFileName = "C:\users\rolanda\Desktop\db-trimmed.json"
function dbFile($dbFileName) {
    $db_parse = (get-content $dbFileName | convertfrom-json);
    if ($db_parse[0].orderId) {
        return $db_parse
    } else {
        $db_flatten = @()
        foreach ($orderSet in $db_parse) {
            $orderList = ($orderSet | get-member | Select-Object -property 'name')
            for ( $i = 4; $i -lt $orderList.length; $i++ ) {
                $db_flatten += $orderSet.$($orderList[$i].name)
            }
        }
        $db_flatten_JSON = ($db_flatten | convertto-JSON)
        set-content C:\Users\rolanda\Desktop\db-current-trimmed.json $db_flatten_JSON
        return $db_flatten
    }
}

$db_trimmed = dbFile $dbFileName

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

foreach ($o in $db_trimmed) {
    # Write-Output $o
    $order = [pscustomobject]@{
        orderId      = $o.orderId
        salesOrder   = $o.salesOrder
        magentoId    = $o.magentoId
        fundId       = $o.fundId
        fundName     = $o.fundname
        placedDate   = get-date ($o.placedDate) -format 'yyyy-MM-dd HH:mm'
        downloaddate = (trimDate $o.downloadDate)
        printDate    = (trimDate $o.printDate)
        orderType    = $o.orderType
        logoScript   = $o.logoScript
        logoId       = $o.logoId
        priColor     = $o.priColor
        secColor     = $o.secColor
        digital      = $o.digital
        digiSmall    = $o.digiSmall
        sticker      = $o.sticker
        embroidery   = $o.embroidery
        printUser    = $o.printUser
        jobId        = $o.jobId
        printer      = $o.Printer
    }
    $body = "$($order | convertto-json)";
    invoke-restmethod -method 'post' -uri "$db_uri/orders/" -body $body -contentType "application/JSON"
}
