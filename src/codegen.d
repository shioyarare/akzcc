import utils;
import std;
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
			case NodeKind.EQ:
				writeln("  cmp rax, rdi");
				writeln("  sete al");
				writeln("  movzb rax, al");
				break;
			case NodeKind.NE:
				writeln("  cmp rax, rdi");
				writeln("  setne al");
				writeln("  movzb rax, al");
				break;
			case NodeKind.LT:
				writeln("  cmp rax, rdi");
				writeln("  setl al");
				writeln("  movzb rax, al");
				break;
			case NodeKind.LE:
				writeln("  cmp rax, rdi");
				writeln("  setle al");
				writeln("  movzb rax, al");
				break;
			default:
				break;
		}
		writeln("  push rax");
	}

