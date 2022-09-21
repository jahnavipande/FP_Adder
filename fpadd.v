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
	reg [2:0]	current_state;

/*always @(*)
	begin
			current_state<=next_state;
	end*/
		
always @(posedge clk)
	begin
		if(reset)
				begin
					current_state<=3'b000;
				end

		else if(start)
		    begin
                current_state<=3'b000;
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

                /*expdiffb <= expb-expa;
                expdiffa <= expa-expb;*/

			    if(current_state==3'b000)
				    begin
					    if(expa==8'b11111111)
						begin
							mantr<=manta;
							expr<=expa;
							signr<=signa;
							current_state<=3'b111;
						end
                        else if(expb==8'b11111111)
						begin
							mantr<=mantb;
							expr<=expb;
							signr<=signb;
							current_state<=3'b111;
						end
                        else if((expb == 0) && (mantb == 0))
						begin
							mantr<=manta;
							expr<=expa;
							signr<=signa;
							current_state<=3'b111;
                             $display("Damnn Correct");
						end
                        else if((expa == 0) && (manta == 0))				
						begin
							mantr <=mantb;
							expr<=expb;
							signr<=signb;
							current_state<=3'b111;

						end
                        else
                            begin
                                current_state<=3'b001;
                            end
                    end    
			    
			    else if(current_state==3'b001)
				    begin
                        if(signa)
                            begin
                                manta<= ~manta +1;
                            end
                        if(signb)
                            begin
                                mantb<= ~mantb +1;
                            end
                                current_state<=3'b010;
                    end    

                else if(current_state==3'b010)
                    begin
					   	if(expa==expb)
						begin
							expr<= expb;
                            current_state<=3'b011;	
						end	

                        else if(expa>expb)
                        begin
                            mantb <= {signb, mantb[25:1]};
                            expb<=expb+1;
                            current_state<=3'b010;
                        end	

                        else if(expb>expa)
                        begin
                            manta <= {signa, manta[25:1]};
                            expa<=expa+1;
                            current_state<=3'b010;
                        end
                    end

                                //$display("current_state=%b,signr=%b,expr=%b,mantr=%b",current_state,signr,expr,mantr); 

                else if(current_state==3'b011)
                    begin               
                        mantr<= manta+mantb;
                        current_state<=3'b100;
                    end 
             
                else if(current_state==3'b100)   
                        begin
                            if(mantr[25])
                                begin
                                    signr<=1;
                                    mantr<= -mantr;
                                    current_state<=3'b101;
                                end
                            else
                                begin
                                    signr<=0;
                                    current_state<=3'b101;
                                end
                        end

                else if(current_state==3'b101)
                        begin
                            if(mantr==0)
                                begin
                                    expr<=0;
                                    current_state<=3'b111;
                                end

                            else if(mantr[24])
                                begin
                                    mantr <= mantr >> 1;
                                    expr <= expr + 1;
                                    current_state<=3'b111;
                                end

                            else if(mantr[23])
                                begin
                                    current_state<=3'b111;
                                end
                            else
                                begin
                                    current_state<=3'b110;
                                end
                        end

                                    //$display("current_state=%b,signr=%b,expr=%b,mantr=%b",current_state,signr,expr,mantr);

                else if(current_state==3'b110)
                        begin
                            if(mantr[23]==0)
                                begin
                                    mantr<=mantr<<1;
                                    expr<=expr-1;
                                    current_state<=3'b110;
                                end
                            else
                                begin
                                    current_state<=3'b111;                                    
                                end	
                        end

                                        //$display("current_state=%b,signr=%b,expr=%b,mantr=%b",current_state,signr,expr,mantr);
                    
                else if(current_state==3'b111)
                    begin
                        sum<={signr,expr,mantr[22:0]};
                        done<=1;
                                //$display("current_state=%b,signr=%b,expr=%b,mantr=%b",current_state,signr,expr,mantr);
                    end
			
			end

			
	end
endmodule
