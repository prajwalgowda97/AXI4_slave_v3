module axi_top;

  import uvm_pkg::*;
  import test_pkg::*;
  

  `include "uvm_macros.svh"
  bit CLK;
     
  axi_interface intf(CLK);
  
    //DUT instantiation
    axi4_slave_top dut(
			            			
            //axi connections
			
		.CLK       	        (intf.CLK       	 ),
        .RST       	        (intf.RST       	 ),
		.AWVALID   	        (intf.AWVALID   	 ),
		.AWADDR    	        (intf.AWADDR    	 ),
		.AWID      	        (intf.AWID      	 ),
		.AWLEN     			(intf.AWLEN     	 ),
		.AWSIZE    	        (intf.AWSIZE    	 ),
		.AWBURST   	        (intf.AWBURST   	 ),
		.AWREADY   	        (intf.AWREADY   	 ),
		.WREADY    	        (intf.WREADY    	 ),
        .WVALID    	        (intf.WVALID    	 ),
        .WDATA     	        (intf.WDATA     	 ),
        .WLAST     	        (intf.WLAST     	 ),
        .WSTRB     	        (intf.WSTRB     	 ),
      //.WID       	        (intf.WID       	 ),
        .BVALID    	        (intf.BVALID    	 ),
        .BID       	        (intf.BID       	 ),
        .BRESP     	        (intf.BRESP     	 ),
        .BREADY    	        (intf.BREADY    	 ),
        .ARREADY   	        (intf.ARREADY   	 ),
        .ARVALID   	        (intf.ARVALID   	 ),
        .ARADDR    	        (intf.ARADDR    	 ),
        .ARID      	        (intf.ARID      	 ),
        .ARLEN     	        (intf.ARLEN     	 ),
        .ARSIZE    	        (intf.ARSIZE    	 ),
        .ARBURST   	        (intf.ARBURST   	 ),
        .RVALID    	        (intf.RVALID    	 ),
        .RDATA     	        (intf.RDATA     	 ),
        .RID       	        (intf.RID       	 ),
        .RLAST       	    (intf.RLAST          ),     
        .RRESP              (intf.RRESP          ), 
        .RREADY             (intf.RREADY         ));    


 /************************************************************************************/
                            //clock generation

initial
  begin
CLK =1'b0;
  forever begin #5 CLK = ~CLK;

   // #5 CLK =1'b0; 
    //#1000 $finish;

    end 
    end



 /************************************************************************************/
                            //creating interface handle
 
 
  initial
  begin

  //setting config db in top
  uvm_config_db#(virtual axi_interface)::set(null,"*","axi_interface", intf);
  end 


initial 
    begin
        uvm_top.set_report_verbosity_level(UVM_HIGH);
        run_test("axi_base_test");
    end


/***********************************************************************************/
                                //wave generation
  
  initial
  begin
  $shm_open("wave.shm");
  $shm_probe("ACTMF");
  end

endmodule
