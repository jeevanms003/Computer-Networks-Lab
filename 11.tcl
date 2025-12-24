# ================================
# GSM Parameters
# ================================
set bwUL(gsm) 9600
set bwDL(gsm) 9600
set propUL(gsm) 0.500
set propDL(gsm) 0.500
set buf(gsm) 10

# ================================
# Simulator Setup
# ================================
set ns [new Simulator]

set nt [open Lab5.tr w]
$ns trace-all $nt

# ================================
# Create Nodes
# ================================
set nodes(c1) [$ns node]
set nodes(ms) [$ns node]
set nodes(bs1) [$ns node]
set nodes(bs2) [$ns node]
set nodes(c2) [$ns node]

# ================================
# Topology Procedure
# ================================
proc cell_topo {} {
    global ns nodes bwUL bwDL propUL propDL buf

    # Wired links
    $ns duplex-link $nodes(c1) $nodes(bs1) 3Mb 10ms DropTail
    $ns duplex-link $nodes(bs2) $nodes(c2) 3Mb 50ms DropTail

    # Wireless core links
    $ns duplex-link $nodes(bs1) $nodes(ms) 1Mb 1ms RED
    $ns duplex-link $nodes(ms)  $nodes(bs2) 1Mb 1ms RED

    # Bandwidth (Simplex)
    $ns bandwidth $nodes(bs1) $nodes(ms) $bwDL(gsm) simplex
    $ns bandwidth $nodes(ms)  $nodes(bs1) $bwUL(gsm) simplex
    $ns bandwidth $nodes(bs2) $nodes(ms) $bwDL(gsm) simplex
    $ns bandwidth $nodes(ms)  $nodes(bs2) $bwUL(gsm) simplex

    # Delay (Simplex)
    $ns delay $nodes(bs1) $nodes(ms) $propDL(gsm) simplex
    $ns delay $nodes(ms)  $nodes(bs1) $propUL(gsm) simplex
    $ns delay $nodes(bs2) $nodes(ms) $propDL(gsm) simplex
    $ns delay $nodes(ms)  $nodes(bs2) $propUL(gsm) simplex

    # Queue Limits
    $ns queue-limit $nodes(bs1) $nodes(ms) $buf(gsm)
    $ns queue-limit $nodes(ms)  $nodes(bs1) $buf(gsm)
    $ns queue-limit $nodes(bs2) $nodes(ms) $buf(gsm)
    $ns queue-limit $nodes(ms)  $nodes(bs2) $buf(gsm)

    # Delayers
    $ns insert-delayer $nodes(ms)  $nodes(bs1) [new Delayer]
    $ns insert-delayer $nodes(bs1) $nodes(ms)  [new Delayer]
    $ns insert-delayer $nodes(ms)  $nodes(bs2) [new Delayer]
    $ns insert-delayer $nodes(bs2) $nodes(ms)  [new Delayer]
}

# ================================
# Build GSM Topology
# ================================
cell_topo

# ================================
# TCP & FTP Setup
# ================================
set tcp [new Agent/TCP]
$ns attach-agent $nodes(c1) $tcp

set sink [new Agent/TCPSink]
$ns attach-agent $nodes(c2) $sink

$ns connect $tcp $sink

set ftp [new Application/FTP]
$ftp attach-agent $tcp

# ================================
# Finish Procedure
# ================================
proc finish {} {
    global ns nt
    $ns flush-trace
    close $nt
    exec awk -f Lab5.awk Lab5.tr &
    exec xgraph -P -x TIME -y DATA -tkFont fixed gsm.xg &
    exit 0
}

# ================================
# Simulation Events
# ================================
$ns at 0.0 "$ftp start"
$ns at 10.0 "finish"

$ns run