# Create simulator
set ns [ new Simulator ]

# Create trace files
set nam [ open out.nam w]
$ns namtrace-all $nam

set tr [ open out.tr w ]
$ns trace-all $tr 

# Create nodes
set n0 [ $ns node ]
set n1 [ $ns node ]
set n2 [ $ns node ]

# Create duplex links between nodes
$ns duplex-link $n0 $n1 20Mb 10ms DropTail
$ns duplex-link $n1 $n2 5Mb 10ms DropTail

# Set queue limits
$ns queue-limit $n0 $n1 3
$ns queue-limit $n1 $n2 3

# Create TCP agent and sink
set tcp [ new Agent/TCP ]
set sink [ new Agent/TCPSink ]

# Attach agents to nodes
$ns attach-agent $n0 $tcp
$ns attach-agent $n2 $sink
$ns connect $tcp $sink

# Create CBR traffic over TCP
set cbr [ new Application/Traffic/CBR ]
$cbr attach-agent $tcp

# Define finish procedure
proc finish {} {
	global ns nam tr 
	$ns flush-trace
	close $tr
	close $nam
	
	exec nam out.nam &
	exec echo "The number of packets dropped are: " &
	exec grep -c "^d" out.tr &
	exit 0
}

# Schedule events
$ns at 0.1 "$cbr start"
$ns at 1.0 "$cbr stop"
$ns at 1.5 "finish"

# Run simulation
$ns run
