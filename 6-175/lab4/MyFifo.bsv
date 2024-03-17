import Ehr::*;
import Vector::*;

interface Fifo#(numeric type n, type t);
    method Bool notFull;
    method Action enq(t x);
    method Bool notEmpty;
    method Action deq;
    method t first;
    method Action clear;
endinterface

module mkMyConflictFifo( Fifo#(n, t) ) provisos (Bits#(t,tSz));
    // n is size of fifo
    // t is data type of fifo
    Vector#(n, Reg#(t))     data     <- replicateM(mkRegU());
    Reg#(Bit#(TLog#(n)))    enq_p     <- mkReg(0);
    Reg#(Bit#(TLog#(n)))    deq_p     <- mkReg(0);
    Reg#(Bool)              not_empty <- mkReg(False);
    Reg#(Bool)              not_full  <- mkReg(True);
    Bit#(TLog#(n))          size     = fromInteger(valueOf(n)-1);

    method Bool notFull();
        return not_full;
    endmethod

    method Bool notEmpty();
		return not_empty;
    endmethod

    method Action enq (t x) if (not_full);
        let enq_p_next = enq_p + 1 > size  ? 0 : enq_p + 1;
		data[enq_p] <= x;
		if (enq_p_next == deq_p) begin
			not_full <= False;
		end
        enq_p <= enq_p_next;
        not_empty <= True;
    endmethod

    method Action deq() if (not_empty);
        let deq_p_next = deq_p + 1 > size ? 0 : deq_p + 1;
        deq_p <= deq_p_next;
		if (deq_p_next == enq_p) begin
			not_empty <= False;
		end
        not_full <= True;
    endmethod

    method t first() if (not_empty);
    	return data[deq_p];
	endmethod

    method Action clear();
		enq_p <= 0;
		deq_p <= 0;
		not_empty <= False;
		not_full <= True;
    endmethod

endmodule

// {not_empty, first, deq} < {not_full, enq} < clear
module mkMyPipelineFifo( Fifo#(n, t) ) provisos (Bits#(t,tSz));
    // n is size of fifo
    // t is data type of fifo
    Vector#(n, Reg#(t))     data     <- replicateM(mkRegU());
    Ehr#(3, Bit#(TLog#(n))) enq_p     <- mkEhr(0);
    Ehr#(3, Bit#(TLog#(n))) deq_p     <- mkEhr(0);
    Ehr#(3, Bool)           not_empty <- mkEhr(False);
    Ehr#(3, Bool)           not_full  <- mkEhr(True);
    Bit#(TLog#(n))          size     = fromInteger(valueOf(n)-1);

    method Bool notEmpty();
        return not_empty[0];
    endmethod

    method t first() if (not_empty[0]);
        return data[deq_p[0]];
    endmethod

    method Action deq() if (not_empty[0]);
        let deq_p_next = deq_p[0] + 1 > size ? 0 : deq_p[0] + 1;
        deq_p[0] <= deq_p_next;
        if (deq_p_next == enq_p[0]) begin
            not_empty[0] <= False;
        end
        not_full[0] <= True;
    endmethod

    method Bool notFull();
        return not_full[1];
    endmethod

    method Action enq (t x) if (not_full[1]);
    let enq_p_next = enq_p[1] + 1 > size ? 0 : enq_p[1] + 1;
    data[enq_p[1]] <= x;
    enq_p[1] <= enq_p_next;
    if (enq_p_next == deq_p[1]) begin
        not_full[1] <= False;
    end
    not_empty[1] <= True;
    endmethod

    method Action clear();
        not_empty[2] <= False;
        not_full[2] <= True;
        enq_p[2] <= 0;
        deq_p[2] <= 0;
    endmethod

endmodule

// {not_full, enq} < {not_empty, first, deq} < clear
module mkMyBypassFifo( Fifo#(n, t) ) provisos (Bits#(t,tSz));
    // n is size of fifo
    // t is data type of fifo
    Vector#(n, Reg#(t))     data     <- replicateM(mkRegU());
    Ehr#(3, Bit#(TLog#(n))) enq_p     <- mkEhr(0);
    Ehr#(3, Bit#(TLog#(n))) deq_p     <- mkEhr(0);
    Ehr#(3, Bool)           not_empty <- mkEhr(False);
    Ehr#(3, Bool)           not_full  <- mkEhr(True);
    Bit#(TLog#(n))          size     = fromInteger(valueOf(n)-1);

    method Bool notFull();
        return not_full[0];
    endmethod

    method Action enq (t x) if (not_full[0]);
        let enq_p_next = enq_p[0] + 1 > size ? 0 : enq_p[0] + 1;
        data[enq_p[0]] <= x;
        enq_p[0] <= enq_p_next;
        if (enq_p_next == deq_p[0]) begin
            not_full[0] <= False;
        end
        not_empty[0] <= True;
        $display("deq_p: %d", deq_p[0]);
    endmethod

    method Bool notEmpty();
        return not_empty[1];
    endmethod

    method Action deq() if (not_empty[1]);
        let deq_p_next = deq_p[1] + 1 > size ? 0 : deq_p[1] + 1;
        $display("deq_p_next: %d", deq_p_next);
        deq_p[1] <= deq_p_next;
        if (deq_p_next == enq_p[1]) begin
            not_empty[1] <= False;
        end
        not_full[1] <= True;
        $display("deq_p: %d", deq_p[1]);
    endmethod

    method t first() if (not_empty[1]);
        return data[deq_p[1]];
    endmethod

    method Action clear();
        enq_p[2] <= 0;
        deq_p[2] <= 0;
        not_empty[2] <= False;
        not_full[2] <= True;
    endmethod
endmodule

// {not_full, enq, not_empty, first, deq} < clear
module mkMyCFFifo( Fifo#(n, t) ) provisos (Bits#(t,tSz));
    // n is size of fifo
    // t is data type of fifo
    Vector#(n, Reg#(t))     data         <- replicateM(mkRegU());
    Ehr#(2, Bit#(TLog#(n))) enqP         <- mkEhr(0);
    Ehr#(2, Bit#(TLog#(n))) deqP         <- mkEhr(0);
    Ehr#(2, Bool)           not_empty     <- mkEhr(False);
    Ehr#(2, Bool)           not_full      <- mkEhr(True);
    Ehr#(2, Bool)           req_deq      <- mkEhr(False);
    Ehr#(2, Maybe#(t))      req_enq      <- mkEhr(tagged Invalid);
    Bit#(TLog#(n))          size         = fromInteger(valueOf(n)-1);

    (*no_implicit_conditions, fire_when_enabled*)
    rule canonicalize;
    endrule

    method Bool notFull();
    endmethod

    method Action enq (t x) if (not_full[0]);
    endmethod

    method Bool notEmpty();
    endmethod

    method Action deq() if (not_empty[0]);
    endmethod

    method t first() if (not_empty[0]);
    endmethod

    method Action clear();
    endmethod

endmodule
