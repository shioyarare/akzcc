import std;
import core.stdc.stdlib;
void error() {
	writeln("error");
	exit(1);
}
enum TokenKind{
	BOF,
	RESERVED,
	NUM,
	EOF,
}

struct Token {
	TokenKind kind;
	int val;
	string str;
}

int strtol(ref string str, ref int i) {
	int hd = i;
	while(i<str.length && str[i].isDigit()) i++;
	return str[hd..i].to!int();
}

class Parser {
	Token[] token;
	int curr;
	void tokenize(string str) {
		int i;
		while(str.length>i) {
			if( str[i].isSpace() ) {
				i++;
				continue;
			}

			if(str[i]=='+' || str[i]=='-') {
				token ~= Token(TokenKind.RESERVED, 0, str[i++].to!string);
				continue;
			}

			if(str[i].isDigit()) {
				token ~= Token(TokenKind.NUM, 0, str[i].to!string);
				token[$-1].val = strtol(str, i);
				continue;
			}

			error();
		}
		token ~= Token(TokenKind.EOF, 0, i.to!string);
	}

	bool at_eof() {
		return token[curr].kind == TokenKind.EOF;
	}

	bool consume(char op) {
		if( token[curr].kind != TokenKind.RESERVED || token[curr].str[0] != op ) return false;

		curr++;
		return true;
	}

	int expect_number() {
		if( token[curr].kind != TokenKind.NUM ) error();
		int val = token[curr].val;
		curr++;
		return val;
	}

	void expect(char op) {
		if( token[curr].kind != TokenKind.RESERVED || token[curr].str[0] != op ) error();
		curr++;
	}
}

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

	auto parser = new Parser;
	parser.tokenize( args[1] );


	writeln(".intel_syntax noprefix");
	writeln(".global main");
	writeln("main:");

	writeln("  mov rax, ", parser.expect_number());
		while( !parser.at_eof() ) {
		if( parser.consume('+') ) {
			writeln("  add rax, ", parser.expect_number());
			continue;
		}

		parser.expect('-');
		writeln("  sub rax, ", parser.expect_number());
	}
	writeln("ret");
	return 0;
}
