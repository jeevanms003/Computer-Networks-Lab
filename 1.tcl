# Create simulator
set ns [new Simulator]

# Create NAM trace file
set nam [open out.nam w]
$ns namtrace-all $nam

# Create trace file
set tr [open out.tr w]
$ns trace-all $tr 

# Create 3 nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

# Create duplex links between nodes
$ns duplex-link $n0 $n1 20Mb 10ms DropTail
$ns duplex-link $n1 $n2 5Mb 10ms DropTail

# Set queue size on links
$ns queue-limit $n0 $n1 3
$ns queue-limit $n1 $n2 3

# Create TCP agent and TCP sink
set tcp  [new Agent/TCP]
set sink [new Agent/TCPSink]

# Attach agents to nodes
$ns attach-agent $n0 $tcp
$ns attach-agent $n2 $sink

# Connect TCP to sink
$ns connect $tcp $sink

# Create CBR application over TCP
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $tcp

# (Optional) CBR settings to create more traffic
$cbr set packetSize_ 1000
$cbr set interval_ 0.005

# Finish procedure
proc finish {} {
    global ns nam tr 

    $ns flush-trace
    close $tr
    close $nam

    # Open NAM and print number of dropped packets
    exec nam out.nam &
    exec echo "The number of packets dropped are:" &
    exec grep -c "^d" out.tr &
    exit 0
}

# Schedule CBR start and stop
$ns at 0.1 "$cbr start"
$ns at 1.0 "$cbr stop"

# Schedule finish
$ns at 1.5 "finish"

# Run simulation
$ns run


