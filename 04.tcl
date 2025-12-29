# ================================
# TOKEN RING SIMULATION (RING TOPOLOGY)
# ================================

# Create simulator
set ns [new Simulator]

# Set colors
$ns color 1 blue

# Trace files
set tr [open out.tr w]
$ns trace-all $tr

set nam [open out.nam w]
$ns namtrace-all $nam

# ================================
# Create Nodes
# ================================
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

# ================================
# Ring Topology Links
# ================================
$ns duplex-link $n0 $n1 10Mb 10ms DropTail
$ns duplex-link $n1 $n2 10Mb 10ms DropTail
$ns duplex-link $n2 $n3 10Mb 10ms DropTail
$ns duplex-link $n3 $n4 10Mb 10ms DropTail
$ns duplex-link $n4 $n0 10Mb 10ms DropTail

# ================================
# TCP + CBR (Token Holder)
# ================================
set tcp [new Agent/TCP]
set sink [new Agent/TCPSink]

$tcp set fid_ 1

$ns attach-agent $n0 $tcp
$ns attach-agent $n3 $sink
$ns connect $tcp $sink

# CBR Application
set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 512
$cbr set rate_ 1Mb
$cbr attach-agent $tcp

# ================================
# TOKEN CONTROL PROCEDURE
# ================================
proc token_start {app} {
    $app start
}

proc token_stop {app} {
    $app stop
}

# ================================
# Finish Procedure
# ================================
proc finish {} {
    global ns nam tr
    $ns flush-trace
    close $tr
    close $nam
    exec nam out.nam &
    exit 0
}

# ================================
# Token Passing Schedule
# ================================
# Token with n0 from 0.1 to 1.0 sec
$ns at 0.1 "token_start $cbr"
$ns at 1.0 "token_stop $cbr"

# End simulation
$ns at 1.5 "finish"

# Run
$ns run