/*
 Copyright 2013 Ray Salemi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
module top;
mult_bfm bfm();
tpgen tpgen_i (bfm);
//coverage coverage_i (bfm);
scoreboard scoreboard_i(bfm);


vdic_dut_2023 DUT (.arg_a(bfm.arg_a), .arg_b(bfm.arg_b), .arg_a_parity(bfm.arg_a_parity), .result_rdy(bfm.result_rdy),
    .clk(bfm.clk), .rst_n(bfm.rst_n), .ack(bfm.ack), .result_parity(bfm.result_parity), .arg_parity_error(bfm.arg_parity_error),
    .arg_b_parity(bfm.arg_b_parity), .req(bfm.req), .result(bfm.result));

endmodule : top


