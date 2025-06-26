ENTRY(boot)
OUTPUT_FORMAT("binary")
SECTIONS {
	 . = 0x7c00;
	 .text :
	 {
		*(.boot)
		*(.text)
	 }
	 .bss :
	 {
		*(.bss)
	 }
}
