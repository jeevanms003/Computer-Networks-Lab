# Create simulator object
set ns [new Simulator]

# Create a trace file for NAM
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

# Create TCP agent for sender and receiver
set tcp0 [new Agent/TCP]
set sink [new Agent/TCPSink]

# Attach the agents to the nodes
$ns attach-agent $n0 $tcp0
$ns attach-agent $n1 $sink

# Connect TCP sender to the sink (receiver)
$ns connect $tcp0 $sink

# Create a simple application to generate data (CBR) for Stop-and-Wait
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $tcp0

# Set packet size and interval for the CBR (data packets)
$cbr set packetSize_ 512       ;# Each packet will be 512 bytes
$cbr set interval_ 0.5         ;# Interval of 500ms between packets

# Define stop-and-wait behavior
proc stop_and_wait {} {
    global ns cbr

    # Get the current simulation time
    set curr_time [$ns now]

    # Start the CBR traffic (this sends the first packet)
    $cbr start

    # Schedule the stop for the current packet
    $ns at [expr $curr_time + 1.0] "$cbr stop"   ;# Stop after 1 second

    # Schedule the next packet to be sent after 1.5 seconds
    $ns at [expr $curr_time + 1.5] "stop_and_wait"
}

# Schedule the first packet to be sent at 0.1s and start Stop-and-Wait
$ns at 0.1 "stop_and_wait"

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

# Run the simulation for 5 seconds
$ns at 5.0 "finish"
$ns run
