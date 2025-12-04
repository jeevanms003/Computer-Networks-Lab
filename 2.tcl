# Create simulator
set ns [new Simulator]

# Trace files
set nam [open out.nam w]
$ns namtrace-all $nam

set tr [open out.tr w]
$ns trace-all $tr

# Create 6 nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

# Create links
$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 0.5Mb 10ms DropTail    ;# slow link
$ns duplex-link $n2 $n3 1Mb 10ms DropTail
$ns duplex-link $n3 $n4 1Mb 10ms DropTail
$ns duplex-link $n4 $n5 1Mb 10ms DropTail

# Set small queue for drops
$ns queue-limit $n1 $n2 3

# Create ping agents
set p0 [new Agent/Ping]
set p1 [new Agent/Ping]

# Attach agents
$ns attach-agent $n0 $p0
$ns attach-agent $n5 $p1

# Connect ping
$ns connect $p0 $p1

# Print ping reply
Agent/Ping instproc recv {from rtt} {
    $self instvar node_
    puts "Node [$node_ id] got reply from $from  RTT = $rtt ms"
}

# Finish procedure
proc finish {} {
    global ns nam tr
    $ns flush-trace
    close $nam
    close $tr
    exec nam out.nam &
    exec echo "Dropped packets:" &
    exec grep -c \"^d\" out.tr &
    exit 0
}

# Send ping packets
$ns at 0.3 "$p0 send"
$ns at 0.6 "$p0 send"
$ns at 0.9 "$p0 send"
$ns at 1.2 "$p0 send"

# End simulation
$ns at 2.0 "finish"

# Run
$ns run
