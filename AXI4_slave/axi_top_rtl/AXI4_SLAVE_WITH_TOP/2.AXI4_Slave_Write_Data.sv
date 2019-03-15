module axi4_slave_data_channel 
#(
    parameter DATA_WIDTH   = 32,
    parameter ID_WIDTH     = 4,
    parameter BURST_LENGTH = 8
)(
    //========================INPUT SIGNALS===========================
    input  logic                         clk,
    input  logic                         rst,  
    input  logic                         awvalid,
    input  logic                         awready,
    input  logic [BURST_LENGTH - 1 : 0]  burst_length,
    input  logic                         wvalid,
    input  logic [DATA_WIDTH - 1 : 0]    wdata,
    input  logic                         wlast,
    input  logic [DATA_WIDTH/8 - 1 : 0]  wstrb,  
    input  logic [ID_WIDTH - 1 : 0]      wid,

    //=====================OUTPUT SIGNALS================================
    output logic                         count_done,
    output logic                         wready
);

//======================FSM STATES===================================
typedef enum logic [1:0] {
    W_IDLE = 2'b00,
    W_DATA = 2'b01,
    W_WAIT = 2'b10
} FMS_STATE;
FMS_STATE present_state, next_state;

//=====================INTERNAL REGISTERS=============================
logic [BURST_LENGTH - 1 : 0] burst_count;
logic                         count_en;

//======================RESET LOGIC===================================
always_ff @(posedge clk or negedge rst) begin
    if (!rst)
        present_state <= W_IDLE;
    else 
        present_state <= next_state;
end

//===========================STATE LOGIC=============================
always_comb begin
    next_state = present_state;
    case (present_state)
        W_IDLE: begin
            if (awvalid && awready)
                next_state = W_DATA;
        end
        W_DATA: begin
            if (count_done && wlast)
                next_state = W_IDLE;
            else if (!wvalid)
                next_state = W_WAIT;
        end
        W_WAIT: begin
            if (wvalid)
                next_state = W_DATA;
        end
    endcase
end

//=========================BURST COUNT LOGIC=========================
always_ff @(posedge clk or negedge rst) begin
    if (!rst)
        burst_count <= 0;
    else if (present_state == W_IDLE && awvalid && awready)
        burst_count <= burst_length;
    else if (present_state == W_DATA && count_en && burst_count > 0)
        burst_count <= burst_count - 1;
end

//=========================COUNT DONE LOGIC=========================
always_ff @(posedge clk or negedge rst) begin
    if (!rst)
        count_done <= 0;
    else if (burst_count == 1 && present_state == W_DATA && wvalid)
        count_done <= 1;
    else if (present_state == W_IDLE)
        count_done <= 0;
end

//====================LOGIC FOR COUNT ENABLE=========================
always_ff @(posedge clk or negedge rst) begin
    if (!rst)
        count_en <= 0;
    else if (present_state == W_DATA && wvalid)
        count_en <= 1;
    else 
        count_en <= 0;
end

//==========================OUTPUT LOGIC================================
always_ff @(posedge clk or negedge rst) begin
    if (!rst)
        wready <= 0;
    else begin
        case (present_state)
            W_IDLE:  wready <= 0;
            W_DATA:  wready <= 1;
            W_WAIT:  wready <= 0;
            default: wready <= 0;
        endcase
    end
end

endmodule
