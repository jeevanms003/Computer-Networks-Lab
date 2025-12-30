set ns [new Simulator]

set tr [open out.tr w]
$ns trace-all $tr

set nam [open out.nam w]
$ns namtrace-all $nam

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

set lan_nodes "$n0 $n1 $n2 $n3 $n4"
$ns newLan $lan_nodes 10Mb 10ms LL Queue/DropTail Mac/802_3 Channel

set tcp0 [new Agent/TCP]
set sink0 [new Agent/TCPSink]
$ns attach-agent $n0 $tcp0
$ns attach-agent $n3 $sink0
$ns connect $tcp0 $sink0
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $tcp0

set tcp1 [new Agent/TCP]
set sink1 [new Agent/TCPSink]
$ns attach-agent $n1 $tcp1
$ns attach-agent $n4 $sink1
$ns connect $tcp1 $sink1
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $tcp1

set tcp2 [new Agent/TCP]
set sink2 [new Agent/TCPSink]
$ns attach-agent $n2 $tcp2
$ns attach-agent $n0 $sink2
$ns connect $tcp2 $sink2
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $tcp2

$ns at 0.1 "$cbr0 start"
$ns at 0.8 "$cbr0 stop"

$ns at 0.9 "$cbr1 start"
$ns at 1.6 "$cbr1 stop"

$ns at 1.7 "$cbr2 start"
$ns at 2.4 "$cbr2 stop"

proc finish {} {
    global ns tr nam
    $ns flush-trace
    close $tr
    close $nam
    exec nam out.nam &
    exit 0
}

$ns at 2.8 "finish"
$ns run