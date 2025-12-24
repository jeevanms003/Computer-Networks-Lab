BEGIN {
    total_pkts = 0
}

{
    if ($1 == "r") {
        total_pkts++
        printf("%f %d\n", $2, total_pkts) >> "gsm.xg"
    }
}

END {
    print "Total Packets Received =", total_pkts
}