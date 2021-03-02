import std;
import core.stdc.stdlib;
void error_at(string user_input, int loc, string message) {
	stderr.writeln(user_input);
	stderr.writeln(" ".repeat(loc).join(""), "^", message);
	exit(1);
}

enum TokenKind{
	BOF,
	RESERVED,
	NUM,
	EOF,
}

enum NodeKind{
	ADD, // +
	SUB, // - 
	MUL, // /
	DIV, // ==
	EQ, // !=
	NE, // !=
	LT, // <
	LE, // <=
	NUM, // Integer
}

struct Node {
	NodeKind kind;
	Node *lhs;
	Node *rhs;
	int val;
}
struct Token {
	TokenKind kind;
	int val;
	string str;
	int len;
}

int strtol(ref string str, ref int i) {
	int hd = i;
	while(i<str.length && str[i].isDigit()) i++;
	return str[hd..i].to!int();
}

