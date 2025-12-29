# ---------- BUS TOPOLOGY (NS2) ----------

# Create Simulator
set ns [new Simulator]

# Trace files
set tr [open out.tr w]
$ns trace-all $tr

set nam [open out.nam w]
$ns namtrace-all $nam

# Create nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

# Create a shared bus (LAN)
# All nodes connect to the SAME medium
set lan_nodes "$n0 $n1 $n2 $n3 $n4"

$ns newLan $lan_nodes 10Mb 10ms LL Queue/DropTail Mac/802_3 Channel

# TCP Sender & Sink
set tcp  [new Agent/TCP]
set sink [new Agent/TCPSink]

$tcp set fid_ 1

$ns attach-agent $n0 $tcp
$ns attach-agent $n4 $sink
$ns connect $tcp $sink

# CBR Application over TCP
set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 512
$cbr set rate_ 1Mb
$cbr attach-agent $tcp

# Finish procedure
proc finish {} {
    global ns tr nam
    $ns flush-trace
    close $tr
    close $nam
    exec nam out.nam &
    exit 0
}

# Start / Stop traffic
$ns at 0.1 "$cbr start"
$ns at 3.0 "$cbr stop"
$ns at 3.5 "finish"

# Run simulation
$ns run