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

set window_size 4

proc sliding_window {} {
    global ns cbr window_size
    set t [$ns now]
    for {set i 0} {$i < $window_size} {incr i} {
        $cbr start
        $ns at [expr $t + 1.0] "$cbr stop"
    }
    $ns at [expr $t + 1.5] "sliding_window"
}

$ns at 0.1 "sliding_window"

proc finish {} {
    global ns nam tr
    $ns flush-trace
    close $tr
    close $nam
    exec nam out.nam &
    exit 0
}

$ns at 10.0 "finish"
$ns run