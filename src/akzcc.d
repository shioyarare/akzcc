import std;

int main(string[] args){
	if(args.length != 2){
		stderr.writeln("Incorrect number of arguments.");
		return 1;
	}

	writeln(".intel_syntax noprefix");
	writeln(".global main");
	writeln("main:");
	writeln("  mov rax, ", args[1]);
	writeln("  ret");
	return 0;
}
