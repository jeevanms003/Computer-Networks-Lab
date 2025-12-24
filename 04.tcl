# ================================
# Create simulator
# ================================
set ns [new Simulator]

# ================================
# Create trace files
# ================================
set tr [open tokenring.tr w]
$ns trace-all $tr

set nam [open tokenring.nam w]
$ns namtrace-all $nam

# ================================
# Finish procedure
# ================================
proc finish {} {
    global ns tr nam
    $ns flush-trace
    close $tr
    close $nam
    exec nam tokenring.nam &
    exit 0
}

# ================================
# Create 5 nodes
# ================================
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

# ================================
# Create Ring Topology (Simplex links)
# ================================
$ns simplex-link $n0 $n1 1Mb 10ms DropTail
$ns simplex-link $n1 $n2 1Mb 10ms DropTail
$ns simplex-link $n2 $n3 1Mb 10ms DropTail
$ns simplex-link $n3 $n4 1Mb 10ms DropTail
$ns simplex-link $n4 $n0 1Mb 10ms DropTail

# ================================
# Orientation for NAM
# ================================
$ns simplex-link-op $n0 $n1 orient right
$ns simplex-link-op $n1 $n2 orient down
$ns simplex-link-op $n2 $n3 orient left
$ns simplex-link-op $n3 $n4 orient up
$ns simplex-link-op $n4 $n0 orient right

# ================================
# Create UDP agents
# ================================
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0

set udp1 [new Agent/UDP]
$ns attach-agent $n3 $udp1

# ================================
# Create Null sink
# ================================
set null0 [new Agent/Null]
$ns attach-agent $n2 $null0

# ================================
# Connect agents
# ================================
$ns connect $udp0 $null0
$ns connect $udp1 $null0

# ================================
# Create CBR applications
# ================================
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 512
$cbr0 set interval_ 0.05
$cbr0 attach-agent $udp0

set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 512
$cbr1 set interval_ 0.05
$cbr1 attach-agent $udp1

# ================================
# Schedule traffic
# ================================
$ns at 0.5 "$cbr0 start"
$ns at 0.7 "$cbr1 start"

$ns at 3.5 "$cbr0 stop"
$ns at 3.7 "$cbr1 stop"

# ================================
# End simulation
# ================================
$ns at 4.0 "finish"

# ================================
# Run
# ================================
$ns run