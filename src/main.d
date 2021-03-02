import parse, codegen;
import std;



int main(string[] args){
	if(args.length != 2){
		stderr.writeln("Incorrect number of arguments.");
		return 1;
	}

	auto parser = new Parser;
	parser.tokenize( args[1] );
	parser.parse();

	writeln(".intel_syntax noprefix");
	writeln(".global main");
	writeln("main:");
	
	gen(parser.node);
	writeln("  pop rax");
	writeln("ret");
	return 0;
}
