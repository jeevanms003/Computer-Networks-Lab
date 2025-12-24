# ================================
# CDMA / UMTS Cellular Network
# ================================

# Bandwidth, Delay, Buffer
set bwDL(cdma) 384000     ;# Downlink bandwidth (bps)
set bwUL(cdma) 64000      ;# Uplink bandwidth (bps)
set propDL(cdma) 0.150
set propUL(cdma) 0.150
set buf(cdma) 20

# Simulator
set ns [new Simulator]

# Trace file
set nt [open Lab6.tr w]
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
    global ns nodes bwDL bwUL propDL propUL buf

    # Wired links
    $ns duplex-link $nodes(c1)  $nodes(bs1) 3Mb 10ms DropTail
    $ns duplex-link $nodes(bs1) $nodes(ms)  1Mb 1ms RED
    $ns duplex-link $nodes(ms)  $nodes(bs2) 1Mb 1ms RED
    $ns duplex-link $nodes(bs2) $nodes(c2)  3Mb 50ms DropTail

    # CDMA Bandwidth
    $ns bandwidth $nodes(bs1) $nodes(ms) $bwDL(cdma) simplex
    $ns bandwidth $nodes(ms)  $nodes(bs1) $bwUL(cdma) simplex
    $ns bandwidth $nodes(bs2) $nodes(ms) $bwDL(cdma) simplex
    $ns bandwidth $nodes(ms)  $nodes(bs2) $bwUL(cdma) simplex

    # CDMA Propagation Delay
    $ns delay $nodes(bs1) $nodes(ms) $propDL(cdma) simplex
    $ns delay $nodes(ms)  $nodes(bs1) $propUL(cdma) simplex
    $ns delay $nodes(bs2) $nodes(ms) $propDL(cdma) simplex
    $ns delay $nodes(ms)  $nodes(bs2) $propUL(cdma) simplex

    # Queue Limits
    $ns queue-limit $nodes(bs1) $nodes(ms) $buf(cdma)
    $ns queue-limit $nodes(ms)  $nodes(bs1) $buf(cdma)
    $ns queue-limit $nodes(bs2) $nodes(ms) $buf(cdma)
    $ns queue-limit $nodes(ms)  $nodes(bs2) $buf(cdma)

    # Delayers
    $ns insert-delayer $nodes(ms)  $nodes(bs1) [new Delayer]
    $ns insert-delayer $nodes(bs1) $nodes(ms)  [new Delayer]
    $ns insert-delayer $nodes(ms)  $nodes(bs2) [new Delayer]
    $ns insert-delayer $nodes(bs2) $nodes(ms)  [new Delayer]
}

# Call topology
cell_topo

# ================================
# Transport Layer
# ================================
set tcp [new Agent/TCP]
$ns attach-agent $nodes(c1) $tcp

set sink [new Agent/TCPSink]
$ns attach-agent $nodes(c2) $sink

$ns connect $tcp $sink

# FTP Application
set ftp [new Application/FTP]
$ftp attach-agent $tcp

# ================================
# Finish Procedure
# ================================
proc End {} {
    global ns nt
    $ns flush-trace
    close $nt
    exec awk -f Lab6.awk Lab6.tr &
    exec xgraph -P -bar -x TIME -y DATA cdma.xg &
    exit 0
}

# ================================
# Simulation Events
# ================================
$ns at 0.0  "$ftp start"
$ns at 10.0 "End"
$ns run