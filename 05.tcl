# =====================================
# TOKEN RING SIMULATION – STAR TOPOLOGY
# =====================================

# Create Simulator
set ns [new Simulator]

# Set color
$ns color 1 blue
$ns color 2 red
$ns color 3 green

# Trace files
set nam [open star_tokenring.nam w]
$ns namtrace-all $nam

set tr [open star_tokenring.tr w]
$ns trace-all $tr

# =====================================
# Create Nodes
# =====================================
set n0 [$ns node]   ;# Central MAU
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

$n0 shape square

# =====================================
# Star Topology Links
# =====================================
$ns duplex-link $n0 $n1 10Mb 10ms DropTail
$ns duplex-link $n0 $n2 10Mb 10ms DropTail
$ns duplex-link $n0 $n3 10Mb 10ms DropTail
$ns duplex-link $n0 $n4 10Mb 10ms DropTail
$ns duplex-link $n0 $n5 10Mb 10ms DropTail

# =====================================
# TCP + CBR for Each Node
# =====================================

# Node 1
set tcp1 [new Agent/TCP]
set sink1 [new Agent/TCPSink]
$tcp1 set fid_ 1
$ns attach-agent $n1 $tcp1
$ns attach-agent $n3 $sink1
$ns connect $tcp1 $sink1

set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 512
$cbr1 set rate_ 1Mb
$cbr1 attach-agent $tcp1

# Node 2
set tcp2 [new Agent/TCP]
set sink2 [new Agent/TCPSink]
$tcp2 set fid_ 2
$ns attach-agent $n2 $tcp2
$ns attach-agent $n4 $sink2
$ns connect $tcp2 $sink2

set cbr2 [new Application/Traffic/CBR]
$cbr2 set packetSize_ 512
$cbr2 set rate_ 1Mb
$cbr2 attach-agent $tcp2

# Node 5
set tcp3 [new Agent/TCP]
set sink3 [new Agent/TCPSink]
$tcp3 set fid_ 3
$ns attach-agent $n5 $tcp3
$ns attach-agent $n1 $sink3
$ns connect $tcp3 $sink3

set cbr3 [new Application/Traffic/CBR]
$cbr3 set packetSize_ 512
$cbr3 set rate_ 1Mb
$cbr3 attach-agent $tcp3

# =====================================
# TOKEN PASSING (LOGICAL RING)
# =====================================

$ns at 0.1  "$cbr1 start"
$ns at 0.6  "$cbr1 stop"

$ns at 0.7  "$cbr2 start"
$ns at 1.2  "$cbr2 stop"

$ns at 1.3  "$cbr3 start"
$ns at 1.8  "$cbr3 stop"

# =====================================
# Finish Procedure
# =====================================
proc finish {} {
    global ns nam tr
    $ns flush-trace
    close $tr
    close $nam
    exec nam star_tokenring.nam &
    exit 0
}

$ns at 2.0 "finish"

# Run Simulation
$ns run