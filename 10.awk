BEGIN {
    received_bytes = 0
    start_time = 1.0
    end_time = 10.0
}

{
    if ($1 == "r" && $4 == "AGT" && $7 == "tcp") {
        received_bytes += $8
    }
}

END {
    duration = end_time - start_time
    throughput = (received_bytes * 8) / (duration * 1000000)
    printf("\nThroughput = %.3f Mbps\n\n", throughput)
}


ns 10.tcl
awk -f 10.awk 10.tr