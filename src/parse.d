import std;
import utils;

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

			// Punctuator
			if( "+-*/()".count(str[i])>0 ) {
				token ~= Token(TokenKind.RESERVED, 0, str[i++].to!string, 1);
				continue;
			}
			// Multi-letter punctuator
			if( str[i..$].length >= 2 && (
					str[i..i+2] == "==" || str[i..i+2] == "!=" ||
					str[i..i+2] == "<=" || str[i..i+2] == ">=") ) {
				token ~= Token(TokenKind.RESERVED, 0, str[i..i+2], 2);
				i+= 2;
				continue;
			}
			// Single-letter punctuator
			if( "+-*/()<>".count(str[i]) > 0 ) {
				token ~= Token(TokenKind.RESERVED, 0, str[i++].to!string, 1);
			}
			if(str[i].isDigit()) {
				token ~= Token(TokenKind.NUM, 0, str[i].to!string, 0);
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

	bool consume(string op) {
		if( token[curr].kind != TokenKind.RESERVED || op != token[curr].str ) 
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

	void expect(string op) {
		if( token[curr].kind != TokenKind.RESERVED || token[curr].str != op ) 
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

	Node *expr() {
		return equality();
	}

	Node *equality() {
		Node *node = relational();

		while(1) {
			if(consume("=="))
				node = new_binary(NodeKind.EQ, node, relational());
			else if(consume("!="))
				node = new_binary(NodeKind.NE, node, relational());
			else
				return node;
		}
	}

	Node *relational() {
		Node *node = add();

		while(1) {
			if(consume("<"))
				node = new_binary(NodeKind.LT, node, add());
			else if(consume("<="))
				node = new_binary(NodeKind.LE, node, add());
			else if(consume(">"))
				node = new_binary(NodeKind.LT, add(), node);
			else if(consume(">="))
				node = new_binary(NodeKind.LE, add(), node);
			else
				return node;
		}
	}

	Node *add() {
		Node *node = mul();

		while(1) {
			if(consume("+"))
				node = new_binary(NodeKind.ADD, node, mul());
			else if(consume("-"))
				node = new_binary(NodeKind.SUB, node, mul());
			else
				return node;
		}
	}

	Node* new_binary(NodeKind kind, Node *lhs, Node *rhs) {
		Node *node = new Node(kind, null, null, 0);
		node.lhs = lhs;
		node.rhs = rhs;
		return node;
	}
		
	Node* unary() {
		if(consume("+"))
			return primary();
		if(consume("-"))
			return new_node(NodeKind.SUB, new_node_num(0), primary());
		return primary();
	}
	Node* mul() {
		auto node = unary();
		while(1) {
			if(consume("*"))
				node = new_node(NodeKind.MUL, node, unary());
			else if(consume("/"))
				node = new_node(NodeKind.DIV, node, unary());
			else
				return node;
		}
	}
	Node* primary() {
		if(consume("(")) {
			Node* node = expr();
			expect(")");
			return node;
		}

		return new_node_num(expect_number());
	}
}

