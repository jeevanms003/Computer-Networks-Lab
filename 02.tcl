# ================================
# Create simulator
# ================================
set ns [new Simulator]

# ================================
# Create NAM trace file
# ================================
set nam [open out.nam w]
$ns namtrace-all $nam

# ================================
# Create trace file
# ================================
set tr [open out.tr w]
$ns trace-all $tr 

# ================================
# Create 6 nodes
# ================================
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

# ================================
# Create duplex links between nodes
# ================================
$ns duplex-link $n0 $n1 10Mb 10ms DropTail
$ns duplex-link $n1 $n2 10Mb 10ms DropTail

# Congested link (low bandwidth)
$ns duplex-link $n2 $n3 1Mb 20ms DropTail

$ns duplex-link $n3 $n4 10Mb 10ms DropTail
$ns duplex-link $n4 $n5 10Mb 10ms DropTail

# ================================
# Set queue size on links
# ================================
$ns queue-limit $n2 $n3 3

# ================================
# Node orientation for NAM
# ================================
$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n3 $n4 orient right
$ns duplex-link-op $n4 $n5 orient right

# ================================
# Create Ping agents
# ================================
set ping0 [new Agent/Ping]
set ping1 [new Agent/Ping]

# Attach Ping agents to nodes
$ns attach-agent $n0 $ping0
$ns attach-agent $n5 $ping1

# Connect Ping agents
$ns connect $ping0 $ping1

# ================================
# Schedule Ping packets
# ================================
for {set i 0} {$i < 25} {incr i} {
    $ns at [expr 0.2 + $i*0.05] "$ping0 send"
}

# ================================
# Finish procedure
# ================================
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

# ================================
# Schedule finish
# ================================
$ns at 3.0 "finish"

# ================================
# Run simulation
# ================================
$ns run