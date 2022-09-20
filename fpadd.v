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
	reg [7:0] 	expa, expb, expr, expdiffa, expdiffb;
	reg [23:0] 	manta, mantb;
	reg [25:0]	mantr;
	reg [0:0] 	signa, signb, signr;
	reg 		done;
	reg [31:0]	sum;
	reg [4:0]	ctr;
	reg [2:0]	current_state, next_state;

always @(posedge clk)
	begin

		if(reset)
		begin
			current_state<=3'b000;
		end

		else
		begin
			current_state<=next_state;
		end
	end
		
always @(posedge clk)
	begin
		if(start)
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
                manta <= {1'b1, a[22:0]};
                mantb <= {1'b1, b[22:0]};

		    end
        else
		    begin

                expdiffb <= expb-expa;
                expdiffa <= expa-expb;

			    if(current_state==3'b000)

                    expdiffb <= expb-expa;
                    expdiffa <= expa-expb;
				    begin
					   if((expa == 0) && (manta == 0))					//00
						begin
							mantr <=mantb;
							expr<=expb;
							signr<=signb;
							next_state<=3'b111;

						end
					   else
						   begin
							   next_state<=3'b001;
						   end
                                $display("current_state=%b,signr=%b,expr=%b,mantr=%b",current_state,signr,expr,mantr);

				    end
			    if(current_state==3'b001)
				    begin
					    if((expb == 0) && (mantb == 0))
						begin
							mantr<=manta;
							expr<=expa;
							signr<=signa;
							next_state<=3'b111;
						end
					    else
						   begin
							   next_state<=3'b010;
						   end

                                $display("current_state=%b,signr=%b,expr=%b,mantr=%b",current_state,signr,expr,mantr);
				    end
			    if(current_state==3'b010)
				    begin
					    if(expa==8'b11111111)
						begin
							mantr<=manta;
							expr<=expa;
							signr<=signa;
							next_state<=3'b111;
						end
					    else
						   begin
							   next_state<=3'b011;
						   end

                                $display("current_state=%b,signr=%b,expr=%b,mantr=%b",current_state,signr,expr,mantr);

				    end
			    
			    if(current_state==3'b011)
				    begin
					     if(expb==8'b11111111)
						begin
							mantr<=mantb;
							expr<=expb;
							signr<=signb;
							next_state<=3'b111;
						end
					    else
						   begin
							   next_state<=3'b100;
						   end

                            $display("current_state=%b,signr=%b,expr=%b,mantr=%b",current_state,signr,expr,mantr);

				    end
			    
			    if(current_state==3'b100)
				    begin
					   	if(expa==expb)
						begin
							expr<= expb;
							if(manta>mantb)
								begin
									if(signb)
										begin
											mantr<= manta-mantb;
											signr<=0;
                                            next_state<=3'b111;
										end
									if(signa)
										begin
											mantr<= manta-mantb;
											signr<=1;
                                            next_state<=3'b111;
										end
									else
										begin
											mantr<= manta+mantb;
											signr<=0;
                                            next_state<=3'b111;
										end
								end
							if(mantb>manta)
								begin
									if(signb)
										begin
											mantr<= mantb-manta;
											signr<=1;
                                            next_state<=3'b111;
										end
									if(signa)
										begin
											mantr<= mantb-manta;
											signr<=0;
                                            next_state<=3'b111;
										end
									else
										begin
											mantr<= manta+mantb;
											signr<=0;
                                            next_state<=3'b111;
										end
                                end
											
							else
								begin
									if(signb)
										begin
											mantr<= 0;
											signr<=0;
                                            next_state<=3'b111;
										end
									if(signa)
										begin
											mantr<= 0;
											signr<=0;
                                            next_state<=3'b111;
										end
									else
										begin
											mantr<= manta+mantb;
											signr<=0;
                                            next_state<=3'b111;
										end
								end

						end	

                        if(expa>expb)
                        begin
                            mantb <= mantb>>expdiffa;
                            expr<= expa;
                            if(manta>mantb)
								begin
									if(signb)
										begin
											mantr<= manta-mantb;
											signr<=0;
                                            next_state<=3'b111;
										end
									if(signa)
										begin
											mantr<= manta-mantb;
											signr<=1;
                                            next_state<=3'b111;
										end
									else
										begin
											mantr<= manta+mantb;
											signr<=0;
                                            next_state<=3'b111;
										end
								end
							if(mantb>manta)
								begin
									if(signb)
										begin
											mantr<= mantb-manta;
											signr<=1;
                                            next_state<=3'b111;
										end
									if(signa)
										begin
											mantr<= mantb-manta;
											signr<=0;
                                            next_state<=3'b111;
										end
									else
										begin
											mantr<= manta+mantb;
											signr<=0;
                                            next_state<=3'b111;
										end
                                end
											
							else
								begin
									if(signb)
										begin
											mantr<= 0;
											signr<=0;
                                            next_state<=3'b111;
										end
									if(signa)
										begin
											mantr<= 0;
											signr<=0;
                                            next_state<=3'b111;
										end
									else
										begin
											mantr<= manta+mantb;
											signr<=0;
                                            next_state<=3'b111;
										end
								end
                        end	

                        if(expb>expa)
                        begin
                            manta <= manta>>expdiffb;
                            expr<= expb;
                            if(manta>mantb)
								begin
									if(signb)
										begin
											mantr<= manta-mantb;
											signr<=0;
                                            next_state<=3'b111;
										end
									if(signa)
										begin
											mantr<= manta-mantb;
											signr<=1;
                                            next_state<=3'b111;
										end
									else
										begin
											mantr<= manta+mantb;
											signr<=0;
                                            next_state<=3'b111;
										end
								end
							if(mantb>manta)
								begin
									if(signb)
										begin
											mantr<= mantb-manta;
											signr<=1;
                                            next_state<=3'b111;
										end
									if(signa)
										begin
											mantr<= mantb-manta;
											signr<=0;
                                            next_state<=3'b111;
										end
									else
										begin
											mantr<= manta+mantb;
											signr<=0;
                                            next_state<=3'b111;
										end
                                end
											
							else
								begin
									if(signb)
										begin
											mantr<= 0;
											signr<=0;
                                            next_state<=3'b111;
										end
									if(signa)
										begin
											mantr<= 0;
											signr<=0;
                                            next_state<=3'b111;
										end
									else
										begin
											mantr<= manta+mantb;
											signr<=0;
                                            next_state<=3'b111;
										end
								end
                        end

                                $display("current_state=%b,signr=%b,expr=%b,mantr=%b",current_state,signr,expr,mantr); 

                    end 
             
                    if(current_state==3'b111)   
                        begin
                            if(mantr[25])
                                begin
                                    mantr <= mantr >> 2;
                                    expr  <= expr + 2;
                                    next_state<=3'b110;
                                end

                            if(mantr[24])
                                begin
                                    mantr <= mantr >> 1;
                                    expr  <= expr + 1;
                                    next_state<=3'b110;
                                end

                            else
                                begin
                                    next_state<=3'b110;
                                end

                                    $display("current_state=%b,signr=%b,expr=%b,mantr=%b",current_state,signr,expr,mantr);

                        end


                    if(current_state==3'b110)
                        begin
                            if (ctr > 0)
                                begin
                                    if(mantr[ctr-1]!=1)
                                        begin
                                            mantr<=mantr<<1;
                                            expr<=expr-1;
                                            ctr<=ctr-1;
                                        end
                                    else
                                        begin
                                            ctr<=0;
                                            next_state<=3'b101;                                    
                                        end	
                                end

                                        $display("current_state=%b,signr=%b,expr=%b,mantr=%b",current_state,signr,expr,mantr);

                        end
                        
                    if(current_state==3'b101)
                        begin
                            sum<={signr,expr,mantr[22:0]};
			                done<=1;

                                    $display("current_state=%b,signr=%b,expr=%b,mantr=%b",current_state,signr,expr,mantr);
                        end
			
			end

			
	end
endmodule
