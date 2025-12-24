BEGIN {
    total_pkts = 0
}

{
    if ($1 == "r") {
        total_pkts += $6
        printf("%f %d\n", $2, total_pkts) >> "cdma.xg"
    }
}

END {
    # End of processing
}