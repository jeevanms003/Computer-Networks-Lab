# Create simulator object
set ns [new Simulator]

# Create a trace file for NAM visualization
set nam [open out.nam w]
$ns namtrace-all $nam

# Create a trace file for packet-level tracing
set tr [open out.tr w]
$ns trace-all $tr

# Create two nodes: one sender (n0) and one receiver (n1)
set n0 [$ns node]
set n1 [$ns node]

# Create duplex link between nodes
$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns queue-limit $n0 $n1 50

# Create TCP agent for sender (n0) and receiver (n1)
set tcp0 [new Agent/TCP]
set sink [new Agent/TCPSink]

# Attach the agents to the nodes
$ns attach-agent $n0 $tcp0
$ns attach-agent $n1 $sink

# Connect TCP sender to the sink (receiver)
$ns connect $tcp0 $sink

# Create a CBR (Constant Bit Rate) application for sending data
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $tcp0

# Set packet size and interval for the CBR application
$cbr set packetSize_ 512        ;# Each packet will be 512 bytes
$cbr set interval_ 0.05         ;# Interval of 50ms between packets

# Set window size for Go-Back-N Protocol (the maximum number of unacknowledged packets)
set window_size 4               ;# Define Go-Back-N window size

# Initialize sender's packet number (used to simulate Go-Back-N)
set packet_number 0

# A procedure to simulate Go-Back-N protocol behavior
proc go_back_n {} {
    global ns cbr window_size tcp0 packet_number

    # Get the current simulation time
    set curr_time [$ns now]

    # Send packets up to the window size
    for {set i $packet_number} {$i < [expr $packet_number + $window_size]} {incr i} {
        $cbr start
        $ns at [expr $curr_time + 0.1 * $i] "$cbr stop"    ;# Send each packet with a slight delay
    }

    # Increase the packet number to slide the window
    set packet_number [expr $packet_number + $window_size]

    # Simulate the acknowledgment process by rescheduling Go-Back-N
    # The Go-Back-N protocol retransmits after a timeout
    $ns at [expr $curr_time + 1.0] "go_back_n"  ;# Re-schedule the next window after 1 second
}

# Start the Go-Back-N process at 0.1 seconds
$ns at 0.1 "go_back_n"

# Finish procedure to close files and run the simulation
proc finish {} {
    global ns nam tr
    $ns flush-trace
    close $tr
    close $nam
    exec nam out.nam &
    exec echo "Simulation finished" &
    exit 0
}

# Run the simulation for 10 seconds
$ns at 10.0 "finish"
$ns run
