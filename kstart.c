int kstart() {
	*((unsigned int*)(0x9000000)) = 'X';
	while(1);
	return 0;
}
