# ================================
# Lab 4 – Wireless Adhoc Network
# DSDV Routing + TCP + FTP
# Throughput Analysis using AWK
# ================================

# Create Simulator
set ns [new Simulator]

# Trace files
set nt [open Lab4.tr w]
$ns trace-all $nt

set na [open Lab4.nam w]
$ns namtrace-all-wireless $na 500 500

# Topography
set topo [new Topography]
$topo load_flatgrid 500 500

# Node configuration
$ns node-config \
    -adhocRouting DSDV \
    -llType LL \
    -macType Mac/802_11 \
    -ifqType Queue/DropTail \
    -ifqLen 50 \
    -phyType Phy/WirelessPhy \
    -channelType Channel/WirelessChannel \
    -propType Propagation/TwoRayGround \
    -antType Antenna/OmniAntenna \
    -topoInstance $topo \
    -agentTrace ON \
    -routerTrace ON \
    -macTrace ON

# Create GOD
create-god 4

# Create Nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

# Initial Positions
$n0 set X_ 250.0 ; $n0 set Y_ 250.0 ; $n0 set Z_ 0.0
$n1 set X_ 200.0 ; $n1 set Y_ 250.0 ; $n1 set Z_ 0.0
$n2 set X_ 300.0 ; $n2 set Y_ 250.0 ; $n2 set Z_ 0.0
$n3 set X_ 250.0 ; $n3 set Y_ 300.0 ; $n3 set Z_ 0.0

# Mobility
$ns at 0.0 "$n0 setdest 400.0 300.0 20.0"
$ns at 0.0 "$n1 setdest 50.0 100.0 10.0"
$ns at 0.0 "$n2 setdest 75.0 180.0 15.0"
$ns at 0.0 "$n3 setdest 100.0 100.0 25.0"

# TCP Connections
set tcp1 [new Agent/TCP]
$ns attach-agent $n0 $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $n1 $sink1
$ns connect $tcp1 $sink1

set tcp2 [new Agent/TCP]
$ns attach-agent $n2 $tcp2
set sink2 [new Agent/TCPSink]
$ns attach-agent $n3 $sink2
$ns connect $tcp2 $sink2

# FTP Applications (CORRECT for TCP)
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2

# Finish Procedure
proc finish {} {
    global ns nt na
    $ns flush-trace
    close $nt
    close $na

    puts "\nRunning AWK throughput analysis..."
    exec awk -f Lab4.awk Lab4.tr

    exec nam Lab4.nam &
    exit 0
}

# Start & Stop
$ns at 1.0 "$ftp1 start"
$ns at 1.0 "$ftp2 start"
$ns at 10.0 "finish"

# Run Simulation
$ns run
