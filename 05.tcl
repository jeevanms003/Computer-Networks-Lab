set ns [new Simulator]

set nam [open out.nam w]
$ns namtrace-all $nam

set tr [open out.tr w]
$ns trace-all $tr

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

$n0 shape square

$ns duplex-link $n0 $n1 10Mb 10ms DropTail
$ns duplex-link $n0 $n2 10Mb 10ms DropTail
$ns duplex-link $n0 $n3 10Mb 10ms DropTail
$ns duplex-link $n0 $n4 10Mb 10ms DropTail
$ns duplex-link $n0 $n5 10Mb 10ms DropTail

set tcp1 [new Agent/TCP]
set sink1 [new Agent/TCPSink]
$ns attach-agent $n1 $tcp1
$ns attach-agent $n3 $sink1
$ns connect $tcp1 $sink1
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $tcp1

set tcp2 [new Agent/TCP]
set sink2 [new Agent/TCPSink]
$ns attach-agent $n2 $tcp2
$ns attach-agent $n4 $sink2
$ns connect $tcp2 $sink2
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $tcp2

set tcp3 [new Agent/TCP]
set sink3 [new Agent/TCPSink]
$ns attach-agent $n5 $tcp3
$ns attach-agent $n1 $sink3
$ns connect $tcp3 $sink3
set cbr3 [new Application/Traffic/CBR]
$cbr3 attach-agent $tcp3

$ns at 0.1 "$cbr1 start"
$ns at 0.6 "$cbr1 stop"

$ns at 0.7 "$cbr2 start"
$ns at 1.2 "$cbr2 stop"

$ns at 1.3 "$cbr3 start"
$ns at 1.8 "$cbr3 stop"

proc finish {} {
    global ns tr nam
    $ns flush-trace
    close $tr
    close $nam
    exec nam out.nam &
    exit 0
}

$ns at 2.0 "finish"
$ns run