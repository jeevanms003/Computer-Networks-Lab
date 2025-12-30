# =====================================
# TOKEN RING SIMULATION – RING TOPOLOGY
# =====================================

# Create Simulator
set ns [new Simulator]

# Set colors
$ns color 1 blue
$ns color 2 red
$ns color 3 green

# Trace files
set tr [open tokenring.tr w]
$ns trace-all $tr

set nam [open tokenring.nam w]
$ns namtrace-all $nam

# =====================================
# Create Nodes
# =====================================
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

# =====================================
# Ring Topology
# =====================================
$ns duplex-link $n0 $n1 10Mb 10ms DropTail
$ns duplex-link $n1 $n2 10Mb 10ms DropTail
$ns duplex-link $n2 $n3 10Mb 10ms DropTail
$ns duplex-link $n3 $n4 10Mb 10ms DropTail
$ns duplex-link $n4 $n0 10Mb 10ms DropTail

# =====================================
# TCP + CBR for each node
# =====================================

# Node 0
set tcp0 [new Agent/TCP]
set sink0 [new Agent/TCPSink]
$tcp0 set fid_ 1
$ns attach-agent $n0 $tcp0
$ns attach-agent $n2 $sink0
$ns connect $tcp0 $sink0

set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 512
$cbr0 set rate_ 1Mb
$cbr0 attach-agent $tcp0

# Node 1
set tcp1 [new Agent/TCP]
set sink1 [new Agent/TCPSink]
$tcp1 set fid_ 2
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
$tcp2 set fid_ 3
$ns attach-agent $n2 $tcp2
$ns attach-agent $n4 $sink2
$ns connect $tcp2 $sink2

set cbr2 [new Application/Traffic/CBR]
$cbr2 set packetSize_ 512
$cbr2 set rate_ 1Mb
$cbr2 attach-agent $tcp2

# =====================================
# TOKEN PASSING (Controlled Access)
# =====================================
# Each node gets token for fixed time

$ns at 0.1  "$cbr0 start"
$ns at 0.6  "$cbr0 stop"

$ns at 0.7  "$cbr1 start"
$ns at 1.2  "$cbr1 stop"

$ns at 1.3  "$cbr2 start"
$ns at 1.8  "$cbr2 stop"

# =====================================
# Finish Procedure
# =====================================
proc finish {} {
    global ns tr nam
    $ns flush-trace
    close $tr
    close $nam
    exec nam tokenring.nam &
    exit 0
}

$ns at 2.0 "finish"

# Run Simulation
$ns run