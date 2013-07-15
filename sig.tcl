#!/usr/bin/tclsh
#  sig.tcl 
#
# - Produce a random signature from the file sigs.
# - Signatures in the sigs file is delimited by two consecutive newlines
# - v 0.2

set sigdir . ;#b:/Personal 
set sigfile sigs
set sigspace [list]

if [ catch { open $sigdir/$sigfile r+ } sighandle ] {
    puts "$argv0 - Error: Couldn't open $sigdir/$sigfile - exiting\n"
    exit 1
}

fconfigure $sighandle -translation lf

# Check existence of signature index 

if {![file exists ${sigfile}.idx] || [file mtime ${sigfile}.idx] < [file mtime ${sigfile}]} { 
    puts "Refreshing ${sigfile}.idx"
    while { ! [eof $sighandle] } {
	set line [ gets $sighandle ]
	if { $line == "%" } { 
	    lappend sigspace [ tell $sighandle ] 
	    puts -nonewline "[lindex $sigspace end] "
	}
    }

    set idx [open ${sigfile}.idx w]
    puts $idx $sigspace
    close $idx
    seek $sighandle 0
} 

# Read the signature index (if it wasn't created above)

if {![llength $sigspace]} {
    set idx [open ${sigfile}.idx]
    set sigspace [read $idx]
    close $idx
}

#puts $sigspace

set signum [llength $sigspace]
set sigpoint [expr [clock seconds] % $signum]

set sigstart [lindex $sigspace $sigpoint]
set siglen [expr [lindex $sigspace [expr $sigpoint + 1]] - $sigstart - 2]

seek $sighandle $sigstart
set sig [ read $sighandle $siglen ]
set numlines [ llength [ split \n $sig ]]

puts "$sig"
# \n($numlines lines)"

close $sighandle

