set ns [new Simulator]

set nt [open out.tr w]
$ns trace-all $nt

set na [open out.nam w]
$ns namtrace-all-wireless $na 500 500

set topo [new Topography]
$topo load_flatgrid 500 500

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

create-god 4

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

$n0 set X_ 250.0 ; $n0 set Y_ 250.0 ; $n0 set Z_ 0.0
$n1 set X_ 200.0 ; $n1 set Y_ 250.0 ; $n1 set Z_ 0.0
$n2 set X_ 300.0 ; $n2 set Y_ 250.0 ; $n2 set Z_ 0.0
$n3 set X_ 250.0 ; $n3 set Y_ 300.0 ; $n3 set Z_ 0.0

$ns at 0.0 "$n0 setdest 400.0 300.0 20.0"
$ns at 0.0 "$n1 setdest 50.0 100.0 10.0"
$ns at 0.0 "$n2 setdest 75.0 180.0 15.0"
$ns at 0.0 "$n3 setdest 100.0 100.0 25.0"

set tcp1 [new Agent/TCP]
set sink1 [new Agent/TCPSink]
$ns attach-agent $n0 $tcp1
$ns attach-agent $n1 $sink1
$ns connect $tcp1 $sink1

set tcp2 [new Agent/TCP]
set sink2 [new Agent/TCPSink]
$ns attach-agent $n2 $tcp2
$ns attach-agent $n3 $sink2
$ns connect $tcp2 $sink2

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2

proc finish {} {
    global ns nt na
    $ns flush-trace
    close $nt
    close $na
    exec awk -f 10.awk out.tr &
    exec nam out.nam &
    exit 0
}

$ns at 1.0 "$ftp1 start"
$ns at 1.0 "$ftp2 start"
$ns at 10.0 "finish"

$ns run