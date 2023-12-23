import Multiplexer::*;

function Bit#(1) fa_sum(Bit#(1) a, Bit#(1) b, Bit#(1) c);
    return a ^ b ^ c;
endfunction

function Bit#(1) fa_carry(Bit#(1) a, Bit#(1) b, Bit#(1) c);
    return (a&b) | (a&c) | (b&c);
endfunction

// Exercise 4
// Complete the code for add4 by using a for loop to properly connect all the uses of fa_sum and fa_carry.

function Bit#(5) add4(Bit#(4) a, Bit#(4) b, Bit#(1) c0);
	Bit#(1) c_out;
	Bit#(4) s_out;
	c_out = c0;
	for(Integer i = 0; i < 4; i = i + 1) begin
		s_out[i] = fa_sum(a[i], b[i], c_out);
		c_out = fa_carry(a[i], b[i], c_out);
	end
	return {c_out, s_out};
endfunction

function Bit#(TAdd#(n,1)) addN(Bit#(n) a, Bit#(n) b, Bit#(1) c0);
    Bit#(n) s;
    Bit#(1) c = c0;
    for(Integer i = 0; i < valueOf(n); i = i + 1)
    begin
        s[i] = fa_sum(a[i], b[i], c);
        c = fa_carry(a[i], b[i], c);
    end
    return {c,s};
endfunction

//function Bit#(5) add4(Bit#(4) a, Bit#(4) b, Bit#(1) c0);
//    return addN(a,b,c0);
//endfunction

interface Adder8;
    method ActionValue#(Bit#(9)) sum(Bit#(8) a,Bit#(8) b, Bit#(1) c_in);
endinterface

module mkRCAdder(Adder8);
    method ActionValue#(Bit#(9)) sum(Bit#(8) a,Bit#(8) b,Bit#(1) c_in);
        let low = add4(a[3:0], b[3:0], c_in);
        let high = add4(a[7:4], b[7:4], low[4]);
        return { high, low[3:0] };
    endmethod
endmodule

// Exercise 5
// Complete the code for the carry-select adder in the module mkCSAdder.
// Use Figure 3 as a guide for the required hardware and connections.
// This module can be tested by running the following:

module mkCSAdder(Adder8);
    method ActionValue#(Bit#(9)) sum(Bit#(8) a,Bit#(8) b,Bit#(1) c_in);
		let low_c_s = add4(a[3:0], b[3:0], c_in);
		let high_c_s_pos = add4(a[7:4], b[7:4], 1);
		let high_c_s_neg = add4(a[7:4], b[7:4], 0);
		let high_c_s = low_c_s[4] == 1 ? high_c_s_pos : high_c_s_neg;
		return {high_c_s, low_c_s[3:0]};
	endmethod
endmodule
