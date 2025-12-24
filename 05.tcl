# ================================
# Create simulator
# ================================
set ns [new Simulator]

# ================================
# Create trace files
# ================================
set tr [open token_star.tr w]
$ns trace-all $tr

set nam [open token_star.nam w]
$ns namtrace-all $nam

# ================================
# Finish procedure
# ================================
proc finish {} {
    global ns tr nam
    $ns flush-trace
    close $tr
    close $nam
    exec nam token_star.nam &
    exit 0
}

# ================================
# Create nodes (1 hub + 5 stations)
# ================================
set hub [$ns node]

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

# ================================
# Create STAR topology (hub based)
# ================================
$ns duplex-link $hub $n0 1Mb 10ms DropTail
$ns duplex-link $hub $n1 1Mb 10ms DropTail
$ns duplex-link $hub $n2 1Mb 10ms DropTail
$ns duplex-link $hub $n3 1Mb 10ms DropTail
$ns duplex-link $hub $n4 1Mb 10ms DropTail

# ================================
# Set queue limits
# ================================
$ns queue-limit $hub $n0 10
$ns queue-limit $hub $n1 10
$ns queue-limit $hub $n2 10
$ns queue-limit $hub $n3 10
$ns queue-limit $hub $n4 10

# ================================
# Node orientation for NAM
# ================================
$ns duplex-link-op $hub $n0 orient right
$ns duplex-link-op $hub $n1 orient up
$ns duplex-link-op $hub $n2 orient left
$ns duplex-link-op $hub $n3 orient down
$ns duplex-link-op $hub $n4 orient right-down

# ================================
# Create UDP agents (Token controlled)
# ================================
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0

set udp1 [new Agent/UDP]
$ns attach-agent $n1 $udp1

set udp2 [new Agent/UDP]
$ns attach-agent $n2 $udp2

set udp3 [new Agent/UDP]
$ns attach-agent $n3 $udp3

set udp4 [new Agent/UDP]
$ns attach-agent $n4 $udp4

# ================================
# Create Null sink
# ================================
set null0 [new Agent/Null]
$ns attach-agent $hub $null0

# ================================
# Connect agents to hub
# ================================
$ns connect $udp0 $null0
$ns connect $udp1 $null0
$ns connect $udp2 $null0
$ns connect $udp3 $null0
$ns connect $udp4 $null0

# ================================
# Create CBR applications (Token passing simulation)
# ================================
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 512
$cbr0 set interval_ 0.05
$cbr0 attach-agent $udp0

set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 512
$cbr1 set interval_ 0.05
$cbr1 attach-agent $udp1

set cbr2 [new Application/Traffic/CBR]
$cbr2 set packetSize_ 512
$cbr2 set interval_ 0.05
$cbr2 attach-agent $udp2

set cbr3 [new Application/Traffic/CBR]
$cbr3 set packetSize_ 512
$cbr3 set interval_ 0.05
$cbr3 attach-agent $udp3

set cbr4 [new Application/Traffic/CBR]
$cbr4 set packetSize_ 512
$cbr4 set interval_ 0.05
$cbr4 attach-agent $udp4

# ================================
# Schedule logical TOKEN passing
# ================================
$ns at 0.5 "$cbr0 start"
$ns at 1.0 "$cbr0 stop"

$ns at 1.1 "$cbr1 start"
$ns at 1.6 "$cbr1 stop"

$ns at 1.7 "$cbr2 start"
$ns at 2.2 "$cbr2 stop"

$ns at 2.3 "$cbr3 start"
$ns at 2.8 "$cbr3 stop"

$ns at 2.9 "$cbr4 start"
$ns at 3.4 "$cbr4 stop"

# ================================
# End simulation
# ================================
$ns at 3.8 "finish"

# ================================
# Run simulation
# ================================
$ns run