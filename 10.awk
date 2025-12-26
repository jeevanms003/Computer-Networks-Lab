BEGIN {
    received_bytes = 0
    start_time = 1.0
    end_time   = 10.0
}

{
    if ($1 == "r" && $4 == "AGT") {
        received_bytes += $6
    }
}

END {
    duration = end_time - start_time

    if (received_bytes == 0) {
        print "\nNo packets received. Check simulation.\n"
        exit
    }

    throughput = (received_bytes * 8) / (duration * 1000000)

    printf("\n---------------------------------\n")
    printf("Total Received Bytes = %d\n", received_bytes)
    printf("Throughput = %.4f Mbps\n", throughput)
    printf("---------------------------------\n\n")
}




awk -f Lab4.awk Lab4.tr
