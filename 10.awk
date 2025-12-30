BEGIN {
    bytes = 0
    start = 1.0
    end   = 10.0
}

{
    if ($1 == "r" && $4 == "AGT")
        bytes += $6
}

END {
    time = end - start
    thr = (bytes * 8) / (time * 1000000)

    printf("Total Received Bytes = %d\n", bytes)
    printf("Throughput = %.4f Mbps\n", thr)
}