# ================================
# Wireless Adhoc Network (DSDV)
# TCP + FTP + Throughput (AWK)
# Output: out.tr , out.nam
# ================================

set ns [new Simulator]

# Trace files
set tr [open out.tr w]
$ns trace-all $tr

set nam [open out.nam w]
$ns namtrace-all-wireless $nam 500 500

# Topography
set topo [new Topography]
$topo load_flatgrid 500 500

# Create GOD
create-god 4

# ---- Nodes ----
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

# Initial positions
$n0 set X_ 250.0 ; $n0 set Y_ 250.0 ; $n0 set Z_ 0.0
$n1 set X_ 200.0 ; $n1 set Y_ 250.0 ; $n1 set Z_ 0.0
$n2 set X_ 300.0 ; $n2 set Y_ 250.0 ; $n2 set Z_ 0.0
$n3 set X_ 250.0 ; $n3 set Y_ 300.0 ; $n3 set Z_ 0.0

# Mobility
$ns at 0.0 "$n0 setdest 400.0 300.0 20.0"
$ns at 0.0 "$n1 setdest 50.0 100.0 10.0"
$ns at 0.0 "$n2 setdest 75.0 180.0 15.0"
$ns at 0.0 "$n3 setdest 100.0 100.0 25.0"

# TCP connection 1
set tcp1 [new Agent/TCP]
$ns attach-agent $n0 $tcp1

set sink1 [new Agent/TCPSink]
$ns attach-agent $n1 $sink1

$ns connect $tcp1 $sink1

# TCP connection 2
set tcp2 [new Agent/TCP]
$ns attach-agent $n2 $tcp2

set sink2 [new Agent/TCPSink]
$ns attach-agent $n3 $sink2

$ns connect $tcp2 $sink2

# FTP applications
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2

# ---- Finish Procedure ----
proc finish {} {
    global ns tr nam
    $ns flush-trace
    close $tr
    close $nam

    puts "\nRunning AWK throughput analysis..."
    exec awk -f throughput.awk out.tr

    exec nam out.nam &
    exit 0
}

# Start FTP traffic
$ns at 1.0 "$ftp1 start"
$ns at 1.0 "$ftp2 start"

# Stop simulation
$ns at 10.0 "finish"

$ns run
