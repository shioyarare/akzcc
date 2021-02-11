import std;

int strtol(ref string s){
	foreach(i, elm; s){
		if( !elm.to!string.isNumeric() ) {
			int ans = s[0..i].to!int;
			s = s[i..$];
			return ans;
		}
	}
	int ans = s.to!int;
	s = "";
	return ans;
}

int main(string[] args){
	if(args.length != 2){
		stderr.writeln("Incorrect number of arguments.");
		return 1;
	}

	writeln(".intel_syntax noprefix");
	writeln(".global main");
	writeln("main:");
	writeln("  mov rax, ", args[1].strtol);
	
	while(args[1].length){
		if(args[1][0]=='+'){
			args[1] = args[1][1..$];
			writeln("  add rax, ", args[1].strtol);
			continue;
		}
		if(args[1][0]=='-'){
			args[1] = args[1][1..$];
			writeln("  sub rax, ", args[1].strtol);
			continue;
		}
		stderr.writeln("unexpected value,");
	}
	writeln("  ret");
	return 0;
}
