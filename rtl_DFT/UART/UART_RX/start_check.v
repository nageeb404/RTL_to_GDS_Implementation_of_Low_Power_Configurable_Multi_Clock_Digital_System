module start_check (
input				STRT_CHK_EN,
input				SAMPLED_BIT,
output				STRT_GLITCH
);


assign STRT_GLITCH = (STRT_CHK_EN && (SAMPLED_BIT == 1'b1));

endmodule