ENTRY(_start)
SECTIONS
{
	. = 0x01000;
	.text : 
	{
		*(.text)
	}
	.rodata : 
	{
		*(.rodata)
	}
	.data : 
	{
		*(.data)
	}
	.bss : 
	{
		*(COMMON)
		*(.bss)
	}
}
