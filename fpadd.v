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
	reg [25:0] 	manta, mantb;
	reg [25:0]	mantr;
	reg [0:0] 	signa, signb, signr;
	reg 		done;
	reg [31:0]	sum;
	reg [4:0]	ctr;
	reg [3:0]	current_state;

always @(posedge clk)
	begin
		if(reset)
			begin
				current_state<=4'b1000;
				done <=0;
				ctr<=0;
				expr<=0;
				sum<=0;
				signa <= 0;
				signb <= 0;
				signr<=0;
				mantr<=26'b0;
				expa <= 0;
				expb <= 0;
				manta <= 0;
				mantb <= 0;
			end

		else if(start)
		    begin
		        current_state<=4'b0000;
		        done <=0;
		        ctr<=24;
		        expr<=0;
		        sum<=0;
		        signa <= a[31];
		        signb <= b[31];
		        signr<=0;
		        mantr<=26'b0;
		        expa <= a[30:23];
		        expb <= b[30:23];
		        manta <= {3'b001, a[22:0]};
		        mantb <= {3'b001, b[22:0]};

		    end
        	else
		    begin

/*State 0: Checks Special cases*/
			    if(current_state==4'b0000)
				    begin
					    if(expa==8'b11111111)
						begin
							mantr<=manta;
							expr<=expa;
							signr<=signa;
							current_state<=4'b0111;
							//$display("signr=%1b, expr=%8b, mantr=%26b\n", signr, expr, mantr);
						end
                        else if(expb==8'b11111111)
						begin
							mantr<=mantb;
							expr<=expb;
							signr<=signb;
							current_state<=4'b0111;
					
						end
                        else if((expb == 0) && (mantb[22:0] == 0))
						begin
							mantr<=manta;
							expr<=expa;
							signr<=signa;
							current_state<=4'b0111;
                 
						end
                        else if((expa == 0) && (manta[22:0] == 0))				
						begin
							mantr <=mantb;
							expr<=expb;
							signr<=signb;
							current_state<=4'b0111;
					

						end
                        else
                            begin
                                current_state<=4'b0001;
                            end
                    end    

/*State 1: Checks sign of a,b and convert mantissa into 2's complement*/	

			    else if(current_state==4'b0001)
				    begin
                        if(signa)
                            begin
                                manta<= ~manta +1;
                            end
                        if(signb)
                            begin
                                mantb<= ~mantb +1;
                            end
                                current_state<=4'b0010;
                    end    

/*State 2: Checks exponent of a,b and shifts*/
                else if(current_state==4'b0010)
                    begin
					   	if(expa==expb)
						begin
							expr<= expb;
                            current_state<=4'b0011;	
						end	

                        else if(expa>expb)
                        begin
                            mantb <= {signb, mantb[25:1]};
                            expb<=expb+1;
                            current_state<=4'b0010;
                        end	

                        else if(expb>expa)
                        begin
                            manta <= {signa, manta[25:1]};
                            expa<=expa+1;
                            current_state<=4'b0010;
                        end
                    end

/*State 3: Adds mantissas*/
                                
                else if(current_state==4'b0011)
                    begin               
                        mantr<= manta+mantb;
                        current_state<=4'b0100;
                    end 

 /*State 4: Checks sign of mantissa of sum and converts mantissa from 2's complement to magnitude.*/    

                else if(current_state==4'b0100)   
                        begin
                            if(mantr[25])
                                begin
                                    signr<=1;
                                    mantr<= -mantr;
                                    current_state<=4'b0101;
                                end
                            else
                                begin
                                    signr<=0;
                                    current_state<=4'b0101;
                                end
                        end

/*State 5: Checks and normalises overflow or the case of mantissa 0*/
                else if(current_state==4'b0101)
                        begin
                            if(mantr==0)
                                begin
                                    expr<=0;
                                    current_state<=4'b0111;
                                end

                            else if(mantr[24])
                                begin
                                    mantr <= mantr >> 1;
                                    expr <= expr + 1;
                                    current_state<=4'b0111;
                                end

                            else if(mantr[23])
                                begin
                                    current_state<=4'b0111;
                                end
                            else
                                begin
                                    current_state<=4'b0110;
                                end
                        end

                                    
/*State 6: Searches for leading one and normalizes*/

                else if(current_state==4'b0110)
                        begin
                            if(mantr[23]==0)
                                begin
                                    mantr<=mantr<<1;
                                    expr<=expr-1;
                                    current_state<=4'b0110;
                                end
                            else
                                begin
                                   current_state<=4'b0111;                                    
                                end	
                        end

/*State 7: Done*/                                     
                    
                else if(current_state==4'b0111)
                    begin
                        sum<={signr,expr,mantr[22:0]};
                        done<=1;
                               
                    end
			
			end

			
	end
endmodule
