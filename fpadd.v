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
	reg [23:0] 	manta, mantb;
	reg [24:0]	mantr;
	reg [0:0] 	signa, signb, signr;
	reg 		done;
	reg [31:0]	sum;
	reg [7:0]	expdiff;
	reg [4:0]	ctr;

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
	ctr<=23;
	expr<=0;
	sum<=0;
	signa <= a[31];
	signb <= b[31];
	signr<=0;
	expa <= a[30:23];
	expb <= b[30:23];
	manta <= {1'b1, a[22:0]};
	mantb <= {1'b1, b[22:0]};
    	end
    else
    begin
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
	if(expa==expb)
	begin
		expr<= expb;
	end	
	if(expa>expb)
	begin
		expdiff <= expa-expb;
		mantb <= mantb>>expdiff;
		expr<= expa;
	end	
	if(expb>expa)
	begin
		expdiff <= expb-expa;
		manta <= manta>>expdiff;
		expr<= expb;
	end
		
	if(signa)
	begin
	manta<=-manta;	
	end

	if(signb)
	begin
	mantb<=-mantb;	
	end
	
	mantr <= manta+mantb;

	if(mantr<0)
	begin
		signr<=1;
		mantr<=-mantr;
	end

	if(mantr[24])
		begin
			mantr <= mantr >> 1;
			expr  <= expr + 1;
		end
	

	if (ctr >= 0)
	    begin
	   if(mantr[ctr]!=1)
	  	begin
	  	    mantr<=mantr<<1;
	     	    expr<=expr-1;
		    ctr<=ctr-1;
		end
		else
			begin
				ctr<=-1;
			end	
	      end
	

	sum<={signr,expr,mantr[22:0]};
	done<=1;
	end

	end
	end
endmodule
