set ns [new Simulator]

set nam [open out.nam w]
$ns namtrace-all $nam

set tr [open out.tr w]
$ns trace-all $tr

set n0 [$ns node]
set n1 [$ns node]

$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns queue-limit $n0 $n1 50

set tcp0 [new Agent/TCP]
set sink [new Agent/TCPSink]

$ns attach-agent $n0 $tcp0
$ns attach-agent $n1 $sink
$ns connect $tcp0 $sink

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $tcp0

proc stop_and_wait {} {
    global ns cbr
    set t [$ns now]
    $cbr start
    $ns at [expr $t + 1.0] "$cbr stop"
    $ns at [expr $t + 1.5] "stop_and_wait"
}

$ns at 0.1 "stop_and_wait"

proc finish {} {
    global ns nam tr
    $ns flush-trace
    close $tr
    close $nam
    exec nam out.nam &
    exit 0
}

$ns at 5.0 "finish"
$ns run