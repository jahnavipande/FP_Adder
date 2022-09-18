module fpadd (
    clk, reset, start,
    a, b,
    sum, 
    done
);
    input clk, reset, start;
    input [31:0] a, b;
    output [31:0] sum;
    output done;
	reg [7:0] 	expa, expb, expr;
	reg [23:0] 	 manta, mantb;
	reg [24:0]	mantr;
	reg [0:0] 	 signa, signb, signr;
	reg 			 done;
	reg [31:0]	sum;
	reg expdiff;

always @(posedge clk)

	if(reset)
	begin
	sum<=0;
	end

	else
	begin

	if(start)
	begin
	done <=0;
	signa <= a[31];
	signb <= b[31];
	signr<=1'b0;
	expa <= a[30:23];
	expb <= b[30:23];
	manta <= {1'b1, a[22:0]};
	mantb <= {1'b1, b[22:0]};

	if((expa == 0) && (manta == 0))
	begin
		mantr<=mantb;
		expr<=expb;
		signr<=signb;
	end

	if((expb == 0) && (mantb == 0))
	begin
		mantr<=manta;
		expr<=expa;
		signr<=signa;
	end

	if(expa==8'b11111111)
	begin
		mantr<=manta;
		expr<=expa;
		signr<=signa;
	end

	if(expb==8'b11111111)
	begin
		mantr<=mantb;
		expr<=expb;
		signr<=signb;
	end
	else
	begin
	if(expa>expb)
	begin
		expdiff = expa-expb;
		mantb = mantb>>expdiff;
		expr= expb;
	end	
	if(expb>expa)
	begin
		expdiff = expb-expa;
		manta = manta>>expdiff;
		expr= expb;
	end	
	mantr = manta+mantb;
	if(mantr[25])
		begin
			mantr <= mantr >> 1;
			expr  <= expr + 1;
		end
	end
	sum<={signr,expr,mantr};
	end
	
	else
	begin
		done<=1;
	end

	end
endmodule

