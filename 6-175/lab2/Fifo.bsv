import Ehr::*;
import Vector::*;
import FIFO::*;

interface Fifo#(numeric type n, type t);
    method Action enq(t x);
    method Action deq;
    method t first;
    method Bool notEmpty;
    method Bool notFull;
endinterface

// Exercise 1
// Completes the code in Fifo.bsv to implements a 3-elements fifo with properly
// guarded methods. Feel free to take inspiration from the class slides.
// The interface defined in Fifo.bsv tells you the type of the methods
// (enq, deq, first) that your module should define.
module mkFifo(Fifo#(3,t)) provisos (Bits#(t,tSz));
	//define you own 3-elements fifo here
    //Reg#(t) ring[3];
    
	Vector#(3, Reg#(t)) ring;
    ring[0] <- mkRegU();
    ring[1] <- mkRegU();
    ring[2] <- mkRegU();
    
	Reg#(Bit#(2)) head <- mkReg(3);
	Reg#(Bit#(2)) tail <- mkReg(3); 

	method Action enq(t x) if ((tail + 1) % 3 != head);
        $display("head %d tail %d", head, tail);
		if (tail == 3) begin
			ring[0] <= x;
			head <= 0;
			tail <= 0;
			end
		else begin
            /*
			    tail <= (tail + 1) % 3;
			    ring[tail] <= x;
            */
            let next = (tail + 1) % 3;
            ring[next] <= x;
            tail <= next;
			end
        $display("ring[head] %d", ring[head]);
	endmethod

	method Action deq if (head != 3);
        $display("head %d tail %d", head, tail);
		if (head == tail) begin
			head <= 3;
			tail <= 3;
			end
		else begin
			head <= (head + 1) % 3;
			end
        $display("ring[head] %d", ring[head]);
	endmethod

	method t first if (head != 3);
		return ring[head];
	endmethod

	method Bool notEmpty;
		return head != 3;
	endmethod

	method Bool notFull;
		return !((tail + 1) % 3 == head);
	endmethod

endmodule


/*
module mkFifo(Fifo#(3,t)) provisos (Bits#(t,tSz));
	//define you own 3-elements fifo here
    //Reg#(t) data[3];
	Vector#(3, Reg#(t)) data;
    data[0] <- mkRegU();
    data[1] <- mkRegU();
    data[2] <- mkRegU();
    Reg#(Bool) flag0 <- mkReg(False);
    Reg#(Bool) flag1 <- mkReg(False);
    Reg#(Bool) flag2 <- mkReg(False);

    method Action enq(t x) if(!flag0);
        $display("enq=%d", x);
        if (!flag2) begin
            $display("routine 1");
            data[2] <= x;
            flag2 <= True;
            $display("data 2 %d\n", data[2]);
            end
        else if (!flag1) begin
            $display("routine 2");
            data[1] <= x;
            flag1 <= True;
            end
        else begin
            $display("routine 3");
            data[0] <= x;
            flag0 <= True;
            end
    endmethod

    method Action deq if(flag2);
        $display("deq=%d", data[2]);
        if (flag0) begin
            data[2] <= data[1];
            data[1] <= data[0];
            flag0 <= False;
            end
        else if (flag1) begin
            data[2] <= data[1];
            flag1 <= False;
            end
        else
            flag2 <= False;
        
    endmethod

    method t first if (flag2);
        return data[2];
    endmethod

    method Bool notEmpty();
        return flag2;
    endmethod

    method Bool notFull();
        return !flag0;
    endmethod

endmodule
*/

 

// Two elements conflict-free fifo given as black box
module mkCFFifo( Fifo#(2, t) ) provisos (Bits#(t, tSz));
    Ehr#(2, t) da <- mkEhr(?);
    Ehr#(2, Bool) va <- mkEhr(False);
    Ehr#(2, t) db <- mkEhr(?);
    Ehr#(2, Bool) vb <- mkEhr(False);

    rule canonicalize;
        if( vb[1] && !va[1] ) begin
            da[1] <= db[1];
            va[1] <= True;
            vb[1] <= False;
        end
    endrule

    method Action enq(t x) if(!vb[0]);
        db[0] <= x;
        vb[0] <= True;
    endmethod

    method Action deq() if(va[0]);
        va[0] <= False;
    endmethod

    method t first if (va[0]);
        return da[0];
    endmethod

    method Bool notEmpty();
        return va[0];
    endmethod

    method Bool notFull();
        return !vb[0];
    endmethod

endmodule

module mkCF3Fifo(Fifo#(3,t)) provisos (Bits#(t, tSz));
    FIFO#(t) bsfif <-  mkSizedFIFO(3);
    method Action enq( t x);
        bsfif.enq(x);
    endmethod

    method Action deq();
        bsfif.deq();
    endmethod

    method t first();
        return bsfif.first();
    endmethod

    method Bool notEmpty();
        return True;
    endmethod

    method Bool notFull();
        return True;
    endmethod

endmodule
