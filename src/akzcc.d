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
	ADD,
	SUB,
	MUL,
	DIV,
	NUM,
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
}

int strtol(ref string str, ref int i) {
	int hd = i;
	while(i<str.length && str[i].isDigit()) i++;
	return str[hd..i].to!int();
}

class Parser {
	Token[] token;
	auto node = new Node;
	string anl_str;
	int curr;
	void parse() {
		node = expr();
	}
	void tokenize(string str) {
		anl_str = str;
		int i;
		while(str.length>i) {
			if( str[i].isSpace() ) {
				i++;
				continue;
			}

			if( "+-*/()".count(str[i])>0 ) {
				token ~= Token(TokenKind.RESERVED, 0, str[i++].to!string);
				continue;
			}

			if(str[i].isDigit()) {
				token ~= Token(TokenKind.NUM, 0, str[i].to!string);
				token[$-1].val = strtol(str, i);
				continue;
			}
			error_at(anl_str, i, format("Cannnot Tokenize."));
		}
		token ~= Token(TokenKind.EOF, 0, i.to!string);
	}

	bool at_eof() {
		return token[curr].kind == TokenKind.EOF;
	}

	bool consume(char op) {
		if( token[curr].kind != TokenKind.RESERVED || token[curr].str[0] != op ) 
			return false;

		curr++;
		return true;
	}

	int expect_number() {
		if( token[curr].kind != TokenKind.NUM ) error_at(anl_str, curr, format("Is not a number"));
		int val = token[curr].val;
		curr++;
		return val;
	}

	void expect(char op) {
		if( token[curr].kind != TokenKind.RESERVED || token[curr].str[0] != op ) 
			error_at(anl_str, curr, format("Is not the '%c'", op));
		curr++;
	}

	Node* new_node(NodeKind kind, Node *lhs, Node *rhs) {
		auto node = new Node;
		node.kind = kind;
		node.lhs = lhs;
		node.rhs = rhs;
		return node;
	} 

	Node* new_node_num(int val) {
		auto node = new Node;
		node.kind = NodeKind.NUM;
		node.val = val;
		return node;
	}
	Node* expr() {
		Node *node = mul();

		while(1) {
			if(consume('+'))
				node = new_node(NodeKind.ADD, node, mul());
			else if (consume('-'))
				node = new_node(NodeKind.SUB, node, mul());
			else
				return node;
		}
	}
	void gen(Node* t_node){
		if(t_node.kind==NodeKind.NUM) {
			writeln("  push ", t_node.val);
			return;
		}

		gen(t_node.lhs);
		gen(t_node.rhs);

		writeln("  pop rdi");
		writeln("  pop rax");

		switch(t_node.kind) {
			case NodeKind.ADD:
				writeln("  add rax, rdi");
				break;
			case NodeKind.SUB:
				writeln("  sub rax, rdi");
				break;
			case NodeKind.MUL:
				writeln("  imul rax, rdi");
				break;
			case NodeKind.DIV:
				writeln("  cqo");
				writeln("  idiv rdi");
				break;
			default:
				break;
		}
		writeln("  push rax");
	}
	
	Node* unary() {
		if(consume('+'))
			return primary();
		if(consume('-'))
			return new_node(NodeKind.SUB, new_node_num(0), primary());
		return primary();
	}
	Node* mul() {
		auto node = unary();
		while(1) {
			if(consume('*'))
				node = new_node(NodeKind.MUL, node, unary());
			else if(consume('/'))
				node = new_node(NodeKind.DIV, node, unary());
			else
				return node;
		}
	}
	Node* primary() {
		if(consume('(')) {
			Node* node = expr();
			expect(')');
			return node;
		}

		return new_node_num(expect_number());
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
	parser.parse();

	writeln(".intel_syntax noprefix");
	writeln(".global main");
	writeln("main:");
	
	parser.gen(parser.node);
	writeln("  pop rax");
	writeln("ret");
	return 0;
}
