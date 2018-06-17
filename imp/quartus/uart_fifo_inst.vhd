uart_fifo_inst : uart_fifo PORT MAP (
		clock	 => clock_sig,
		data	 => data_sig,
		rdreq	 => rdreq_sig,
		sclr	 => sclr_sig,
		wrreq	 => wrreq_sig,
		full	 => full_sig,
		q	 => q_sig,
		usedw	 => usedw_sig
	);
