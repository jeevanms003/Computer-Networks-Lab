# ---------- BUS TOPOLOGY (NS2) ----------

set ns [new Simulator]

set tr  [open out.tr w]
$ns trace-all $tr

set nam [open out.nam w]
$ns namtrace-all $nam

# Create nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

# Bus topology links (linear chain)
$ns duplex-link $n0 $n1 10Mb 10ms DropTail
$ns duplex-link $n1 $n2 10Mb 10ms DropTail
$ns duplex-link $n2 $n3 10Mb 10ms DropTail
$ns duplex-link $n3 $n4 10Mb 10ms DropTail

# TCP Sender & Sink
set tcp  [new Agent/TCP]
set sink [new Agent/TCPSink]

$tcp set fid_ 1

$ns attach-agent $n0 $tcp
$ns attach-agent $n4 $sink
$ns connect $tcp $sink

# CBR Application over TCP
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $tcp

# Finish Procedure
proc finish {} {
    global ns tr nam
    $ns flush-trace
    close $tr
    close $nam
    exec nam out.nam &
    exit 0
}

# Start / Stop Traffic
$ns at 0.1 "$cbr start"
$ns at 3.0 "$cbr stop"
$ns at 3.5 "finish"

$ns run
