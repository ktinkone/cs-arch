function Bit#(1) and1(Bit#(1) a, Bit#(1) b);
    return a & b;
endfunction

function Bit#(1) or1(Bit#(1) a, Bit#(1) b);
    return a | b;
endfunction

function Bit#(1) not1(Bit#(1) a);
    return ~a;
endfunction

// Exercise 1
// Using the and, or, and not gates, re-implement the function multiplexer1 in Multiplexer.bsv.
// How many gates are needed? (The required functions, called and1, or1 and not1, respectively,
// are provided in Multiplexers.bsv.)

function Bit#(1) multiplexer1(Bit#(1) sel, Bit#(1) a, Bit#(1) b);
	return or1(and1(a, not1(sel)), and1(b, sel));
endfunction

// Exercise 2
// Complete the implementation of the function multiplexer5 in Multiplexer.bsv
// using for loops and multiplexer1.

//function Bit#(5) multiplexer5(Bit#(1) sel, Bit#(5) a, Bit#(5) b);
//	Bit#(5) out;
//	for (Integer i = 0; i < 5; i = i + 1) begin
//		out[i] = multiplexer1(sel, a[i], b[i]);
//	end
//	return out;
//endfunction


// Exercise 3
// Complete the definition of the function multiplexer_n.
// Verify that this function is correct by replacing the original definition of multiplexer5 to only have:
// return multiplexer_n(sel, a, b);. This redefinition allows the test benches to test your new
// implementation without modification.

function Bit#(n) multiplexer_n(Bit#(1) sel, Bit#(n) a, Bit#(n) b);
	Bit#(n) out;
	for (Integer i = 0; i < valueOf(n); i = i + 1) begin
		out[i] = multiplexer1(sel, a[i], b[i]);
	end
    return out;
endfunction

function Bit#(5) multiplexer5(Bit#(1) sel, Bit#(5) a, Bit#(5) b);
    return multiplexer_n(sel, a, b);
endfunction
