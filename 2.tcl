# Create simulator
set ns [new Simulator]

# Set colors for flows
$ns color 1 blue
$ns color 2 red

# NAM trace file
set nam [open out.nam w]
$ns namtrace-all $nam

# Text trace file
set tr [open out.tr w]
$ns trace-all $tr

# Create 6 nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

# Create duplex links between nodes with different bandwidths
$ns duplex-link $n0 $n1 0.1Mb 10ms DropTail
$ns duplex-link $n1 $n2 0.2Mb 10ms DropTail
$ns duplex-link $n2 $n3 0.3Mb 10ms DropTail
$ns duplex-link $n3 $n4 0.4Mb 10ms DropTail
$ns duplex-link $n4 $n5 0.5Mb 10ms DropTail

# Print ping reply message
Agent/Ping instproc recv {from rtt} {
    $self instvar node_
    puts "node [$node_ id] received ping reply from $from RTT = $rtt ms"
}

# Set queue limits on each link
$ns queue-limit $n0 $n1 10
$ns queue-limit $n1 $n2 10
$ns queue-limit $n2 $n3 10
$ns queue-limit $n3 $n4 10
$ns queue-limit $n4 $n5 10

# Create ping agents
set p0 [new Agent/Ping]
$p0 set class_ 1
$ns attach-agent $n0 $p0

set p1 [new Agent/Ping]
$p1 set class_ 1
$ns attach-agent $n5 $p1

# Connect ping agents
$ns connect $p0 $p1

# Create TCP and sink
set tcp  [new Agent/TCP]
$tcp set class_ 2
$tcp set fid_ 1

set sink [new Agent/TCPSink]

# Attach TCP and sink
$ns attach-agent $n0 $tcp
$ns attach-agent $n5 $sink

# Connect TCP to sink
$ns connect $tcp $sink

# Create CBR traffic over TCP
set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 500
$cbr set rate_ 1Mb
$cbr attach-agent $tcp

# Finish procedure
proc finish {} {
    global ns tr nam
    $ns flush-trace
    close $tr
    close $nam

    exec nam out.nam &
    exec echo "The number of ping messages lost is:" &
    exec grep "^d" out.tr | cut -d " " -f 5 | grep -c "ping" &
    exit 0
}

# Schedule ping messages and CBR traffic
$ns at 0.2 "$p0 send"
$ns at 0.4 "$p1 send"
$ns at 0.6 "$cbr start"
$ns at 0.8 "$p0 send"
$ns at 1.0 "$p1 send"
$ns at 1.2 "$cbr stop"
$ns at 1.4 "$p0 send"
$ns at 1.6 "$p1 send"

# End simulation
$ns at 1.8 "finish"

# Run the simulation
$ns run
