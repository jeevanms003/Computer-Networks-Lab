# Create a new simulator object
set ns [new Simulator]

# Create trace files for NAM and packet-level tracing
set nam [open out.nam w]
$ns namtrace-all $nam

set tr [open out.tr w]
$ns trace-all $tr

# Create two nodes: sender (n0) and receiver (n1)
set n0 [$ns node]
set n1 [$ns node]

# Create duplex link between nodes with bandwidth 1Mb and delay 10ms
$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns queue-limit $n0 $n1 50

# Create TCP agents for sender and receiver
set tcp0 [new Agent/TCP]
set sink [new Agent/TCPSink]

# Attach the agents to the nodes
$ns attach-agent $n0 $tcp0
$ns attach-agent $n1 $sink

# Connect the TCP sender to the TCP sink (receiver)
$ns connect $tcp0 $sink

# Create a sliding window CBR application
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $tcp0

# Set packet size and interval for the CBR (data packets)
$cbr set packetSize_ 512      ;# Each packet will be 512 bytes
$cbr set interval_ 0.5        ;# Interval of 500ms between packets

# Define the Sliding Window protocol behavior
set window_size 4  ;# Set the window size (e.g., 4 packets in the window)

# Define a procedure to handle the sliding window behavior
proc sliding_window {} {
    global ns cbr window_size tcp0

    # Get the current simulation time
    set curr_time [$ns now]
    
    # Send packets within the window size
    for {set i 0} {$i < $window_size} {incr i} {
        # Start sending the next packet within the window
        $cbr start
        # Set the time for stopping the current packet (e.g., 1 second per packet)
        $ns at [expr $curr_time + 1.0] "$cbr stop"
    }

    # Slide the window after sending the packets
    $ns at [expr $curr_time + 1.5] "sliding_window"
}

# Start the sliding window process after 0.1 seconds
$ns at 0.1 "sliding_window"

# Finish procedure to close trace files and run simulation
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
