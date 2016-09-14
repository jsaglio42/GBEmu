
import 'package:emulator/src/enums.dart';
import 'package:ft/ft.dart' as Ft;

/* Classes */

class Instruction
{
  final int addr;
  final InstructionInfo info;
  final int data;

  Instruction(
    this.addr,
    this.info,
    this.data
  );

}

class InstructionInfo
{
  final int opCode;
  final int opCodeSize;
  final int dataSize;
  final int durationSuccess;
  final int durationFail;
  final String desc;
  final String flagInfo;

  int get instSize => this.dataSize + this.opCodeSize;

  InstructionInfo(
    this.opCode,
    this.opCodeSize,
    this.dataSize,
    this.durationSuccess,
    this.durationFail,
    this.desc,
    this.flagInfo
  );

  String toString(){
  return 
'''opCode: ${Ft.toAddressString(this.opCode, 2)} {
  desc: ${this.desc}
  flagInfo: ${this.flagInfo}
  opCodeSize: ${this.opCodeSize}
  dataSize: ${this.dataSize}
  durationSuccess: ${this.durationSuccess}
  durationFail: ${this.durationFail}
}''';
  }
}

/* Global */

final instInfos = new List<InstructionInfo>.unmodifiable([
  new InstructionInfo(0x00, 1, 0, 4, 4, 'NOP', '- - - -'),
  new InstructionInfo(0x01, 1, 2, 12, 12, 'LD BC,d16', '- - - -'),
  new InstructionInfo(0x02, 1, 0, 8, 8, 'LD (BC),A', '- - - -'),
  new InstructionInfo(0x03, 1, 0, 8, 8, 'INC BC', '- - - -'),
  new InstructionInfo(0x04, 1, 0, 4, 4, 'INC B', 'Z 0 H -'),
  new InstructionInfo(0x05, 1, 0, 4, 4, 'DEC B', 'Z 1 H -'),
  new InstructionInfo(0x06, 1, 1, 8, 8, 'LD B,d8', '- - - -'),
  new InstructionInfo(0x07, 1, 0, 4, 4, 'RLCA', '0 0 0 C'),
  new InstructionInfo(0x08, 1, 2, 20, 20, 'LD (a16),SP', '- - - -'),
  new InstructionInfo(0x09, 1, 0, 8, 8, 'ADD HL,BC', '- 0 H C'),
  new InstructionInfo(0x0A, 1, 0, 8, 8, 'LD A,(BC)', '- - - -'),
  new InstructionInfo(0x0B, 1, 0, 8, 8, 'DEC BC', '- - - -'),
  new InstructionInfo(0x0C, 1, 0, 4, 4, 'INC C', 'Z 0 H -'),
  new InstructionInfo(0x0D, 1, 0, 4, 4, 'DEC C', 'Z 1 H -'),
  new InstructionInfo(0x0E, 1, 1, 8, 8, 'LD C,d8', '- - - -'),
  new InstructionInfo(0x0F, 1, 0, 4, 4, 'RRCA', '0 0 0 C'),
  new InstructionInfo(0x10, 1, 1, 4, 4, 'STOP 0', '- - - -'),
  new InstructionInfo(0x11, 1, 2, 12, 12, 'LD DE,d16', '- - - -'),
  new InstructionInfo(0x12, 1, 0, 8, 8, 'LD (DE),A', '- - - -'),
  new InstructionInfo(0x13, 1, 0, 8, 8, 'INC DE', '- - - -'),
  new InstructionInfo(0x14, 1, 0, 4, 4, 'INC D', 'Z 0 H -'),
  new InstructionInfo(0x15, 1, 0, 4, 4, 'DEC D', 'Z 1 H -'),
  new InstructionInfo(0x16, 1, 1, 8, 8, 'LD D,d8', '- - - -'),
  new InstructionInfo(0x17, 1, 0, 4, 4, 'RLA', '0 0 0 C'),
  new InstructionInfo(0x18, 1, 1, 12, 12, 'JR r8', '- - - -'),
  new InstructionInfo(0x19, 1, 0, 8, 8, 'ADD HL,DE', '- 0 H C'),
  new InstructionInfo(0x1A, 1, 0, 8, 8, 'LD A,(DE)', '- - - -'),
  new InstructionInfo(0x1B, 1, 0, 8, 8, 'DEC DE', '- - - -'),
  new InstructionInfo(0x1C, 1, 0, 4, 4, 'INC E', 'Z 0 H -'),
  new InstructionInfo(0x1D, 1, 0, 4, 4, 'DEC E', 'Z 1 H -'),
  new InstructionInfo(0x1E, 1, 1, 8, 8, 'LD E,d8', '- - - -'),
  new InstructionInfo(0x1F, 1, 0, 4, 4, 'RRA', '0 0 0 C'),
  new InstructionInfo(0x20, 1, 1, 12, 8, 'JR NZ,r8', '- - - -'),
  new InstructionInfo(0x21, 1, 2, 12, 12, 'LD HL,d16', '- - - -'),
  new InstructionInfo(0x22, 1, 0, 8, 8, 'LD (HL+),A', '- - - -'),
  new InstructionInfo(0x23, 1, 0, 8, 8, 'INC HL', '- - - -'),
  new InstructionInfo(0x24, 1, 0, 4, 4, 'INC H', 'Z 0 H -'),
  new InstructionInfo(0x25, 1, 0, 4, 4, 'DEC H', 'Z 1 H -'),
  new InstructionInfo(0x26, 1, 1, 8, 8, 'LD H,d8', '- - - -'),
  new InstructionInfo(0x27, 1, 0, 4, 4, 'DAA', 'Z - 0 C'),
  new InstructionInfo(0x28, 1, 1, 12, 8, 'JR Z,r8', '- - - -'),
  new InstructionInfo(0x29, 1, 0, 8, 8, 'ADD HL,HL', '- 0 H C'),
  new InstructionInfo(0x2A, 1, 0, 8, 8, 'LD A,(HL+)', '- - - -'),
  new InstructionInfo(0x2B, 1, 0, 8, 8, 'DEC HL', '- - - -'),
  new InstructionInfo(0x2C, 1, 0, 4, 4, 'INC L', 'Z 0 H -'),
  new InstructionInfo(0x2D, 1, 0, 4, 4, 'DEC L', 'Z 1 H -'),
  new InstructionInfo(0x2E, 1, 1, 8, 8, 'LD L,d8', '- - - -'),
  new InstructionInfo(0x2F, 1, 0, 4, 4, 'CPL', '- 1 1 -'),
  new InstructionInfo(0x30, 1, 1, 12, 8, 'JR NC,r8', '- - - -'),
  new InstructionInfo(0x31, 1, 2, 12, 12, 'LD SP,d16', '- - - -'),
  new InstructionInfo(0x32, 1, 0, 8, 8, 'LD (HL-),A', '- - - -'),
  new InstructionInfo(0x33, 1, 0, 8, 8, 'INC SP', '- - - -'),
  new InstructionInfo(0x34, 1, 0, 12, 12, 'INC (HL)', 'Z 0 H -'),
  new InstructionInfo(0x35, 1, 0, 12, 12, 'DEC (HL)', 'Z 1 H -'),
  new InstructionInfo(0x36, 1, 1, 12, 12, 'LD (HL),d8', '- - - -'),
  new InstructionInfo(0x37, 1, 0, 4, 4, 'SCF', '- 0 0 1'),
  new InstructionInfo(0x38, 1, 1, 12, 8, 'JR C,r8', '- - - -'),
  new InstructionInfo(0x39, 1, 0, 8, 8, 'ADD HL,SP', '- 0 H C'),
  new InstructionInfo(0x3A, 1, 0, 8, 8, 'LD A,(HL-)', '- - - -'),
  new InstructionInfo(0x3B, 1, 0, 8, 8, 'DEC SP', '- - - -'),
  new InstructionInfo(0x3C, 1, 0, 4, 4, 'INC A', 'Z 0 H -'),
  new InstructionInfo(0x3D, 1, 0, 4, 4, 'DEC A', 'Z 1 H -'),
  new InstructionInfo(0x3E, 1, 1, 8, 8, 'LD A,d8', '- - - -'),
  new InstructionInfo(0x3F, 1, 0, 4, 4, 'CCF', '- 0 0 C'),
  new InstructionInfo(0x40, 1, 0, 4, 4, 'LD B,B', '- - - -'),
  new InstructionInfo(0x41, 1, 0, 4, 4, 'LD B,C', '- - - -'),
  new InstructionInfo(0x42, 1, 0, 4, 4, 'LD B,D', '- - - -'),
  new InstructionInfo(0x43, 1, 0, 4, 4, 'LD B,E', '- - - -'),
  new InstructionInfo(0x44, 1, 0, 4, 4, 'LD B,H', '- - - -'),
  new InstructionInfo(0x45, 1, 0, 4, 4, 'LD B,L', '- - - -'),
  new InstructionInfo(0x46, 1, 0, 8, 8, 'LD B,(HL)', '- - - -'),
  new InstructionInfo(0x47, 1, 0, 4, 4, 'LD B,A', '- - - -'),
  new InstructionInfo(0x48, 1, 0, 4, 4, 'LD C,B', '- - - -'),
  new InstructionInfo(0x49, 1, 0, 4, 4, 'LD C,C', '- - - -'),
  new InstructionInfo(0x4A, 1, 0, 4, 4, 'LD C,D', '- - - -'),
  new InstructionInfo(0x4B, 1, 0, 4, 4, 'LD C,E', '- - - -'),
  new InstructionInfo(0x4C, 1, 0, 4, 4, 'LD C,H', '- - - -'),
  new InstructionInfo(0x4D, 1, 0, 4, 4, 'LD C,L', '- - - -'),
  new InstructionInfo(0x4E, 1, 0, 8, 8, 'LD C,(HL)', '- - - -'),
  new InstructionInfo(0x4F, 1, 0, 4, 4, 'LD C,A', '- - - -'),
  new InstructionInfo(0x50, 1, 0, 4, 4, 'LD D,B', '- - - -'),
  new InstructionInfo(0x51, 1, 0, 4, 4, 'LD D,C', '- - - -'),
  new InstructionInfo(0x52, 1, 0, 4, 4, 'LD D,D', '- - - -'),
  new InstructionInfo(0x53, 1, 0, 4, 4, 'LD D,E', '- - - -'),
  new InstructionInfo(0x54, 1, 0, 4, 4, 'LD D,H', '- - - -'),
  new InstructionInfo(0x55, 1, 0, 4, 4, 'LD D,L', '- - - -'),
  new InstructionInfo(0x56, 1, 0, 8, 8, 'LD D,(HL)', '- - - -'),
  new InstructionInfo(0x57, 1, 0, 4, 4, 'LD D,A', '- - - -'),
  new InstructionInfo(0x58, 1, 0, 4, 4, 'LD E,B', '- - - -'),
  new InstructionInfo(0x59, 1, 0, 4, 4, 'LD E,C', '- - - -'),
  new InstructionInfo(0x5A, 1, 0, 4, 4, 'LD E,D', '- - - -'),
  new InstructionInfo(0x5B, 1, 0, 4, 4, 'LD E,E', '- - - -'),
  new InstructionInfo(0x5C, 1, 0, 4, 4, 'LD E,H', '- - - -'),
  new InstructionInfo(0x5D, 1, 0, 4, 4, 'LD E,L', '- - - -'),
  new InstructionInfo(0x5E, 1, 0, 8, 8, 'LD E,(HL)', '- - - -'),
  new InstructionInfo(0x5F, 1, 0, 4, 4, 'LD E,A', '- - - -'),
  new InstructionInfo(0x60, 1, 0, 4, 4, 'LD H,B', '- - - -'),
  new InstructionInfo(0x61, 1, 0, 4, 4, 'LD H,C', '- - - -'),
  new InstructionInfo(0x62, 1, 0, 4, 4, 'LD H,D', '- - - -'),
  new InstructionInfo(0x63, 1, 0, 4, 4, 'LD H,E', '- - - -'),
  new InstructionInfo(0x64, 1, 0, 4, 4, 'LD H,H', '- - - -'),
  new InstructionInfo(0x65, 1, 0, 4, 4, 'LD H,L', '- - - -'),
  new InstructionInfo(0x66, 1, 0, 8, 8, 'LD H,(HL)', '- - - -'),
  new InstructionInfo(0x67, 1, 0, 4, 4, 'LD H,A', '- - - -'),
  new InstructionInfo(0x68, 1, 0, 4, 4, 'LD L,B', '- - - -'),
  new InstructionInfo(0x69, 1, 0, 4, 4, 'LD L,C', '- - - -'),
  new InstructionInfo(0x6A, 1, 0, 4, 4, 'LD L,D', '- - - -'),
  new InstructionInfo(0x6B, 1, 0, 4, 4, 'LD L,E', '- - - -'),
  new InstructionInfo(0x6C, 1, 0, 4, 4, 'LD L,H', '- - - -'),
  new InstructionInfo(0x6D, 1, 0, 4, 4, 'LD L,L', '- - - -'),
  new InstructionInfo(0x6E, 1, 0, 8, 8, 'LD L,(HL)', '- - - -'),
  new InstructionInfo(0x6F, 1, 0, 4, 4, 'LD L,A', '- - - -'),
  new InstructionInfo(0x70, 1, 0, 8, 8, 'LD (HL),B', '- - - -'),
  new InstructionInfo(0x71, 1, 0, 8, 8, 'LD (HL),C', '- - - -'),
  new InstructionInfo(0x72, 1, 0, 8, 8, 'LD (HL),D', '- - - -'),
  new InstructionInfo(0x73, 1, 0, 8, 8, 'LD (HL),E', '- - - -'),
  new InstructionInfo(0x74, 1, 0, 8, 8, 'LD (HL),H', '- - - -'),
  new InstructionInfo(0x75, 1, 0, 8, 8, 'LD (HL),L', '- - - -'),
  new InstructionInfo(0x76, 1, 0, 4, 4, 'HALT', '- - - -'),
  new InstructionInfo(0x77, 1, 0, 8, 8, 'LD (HL),A', '- - - -'),
  new InstructionInfo(0x78, 1, 0, 4, 4, 'LD A,B', '- - - -'),
  new InstructionInfo(0x79, 1, 0, 4, 4, 'LD A,C', '- - - -'),
  new InstructionInfo(0x7A, 1, 0, 4, 4, 'LD A,D', '- - - -'),
  new InstructionInfo(0x7B, 1, 0, 4, 4, 'LD A,E', '- - - -'),
  new InstructionInfo(0x7C, 1, 0, 4, 4, 'LD A,H', '- - - -'),
  new InstructionInfo(0x7D, 1, 0, 4, 4, 'LD A,L', '- - - -'),
  new InstructionInfo(0x7E, 1, 0, 8, 8, 'LD A,(HL)', '- - - -'),
  new InstructionInfo(0x7F, 1, 0, 4, 4, 'LD A,A', '- - - -'),
  new InstructionInfo(0x80, 1, 0, 4, 4, 'ADD A,B', 'Z 0 H C'),
  new InstructionInfo(0x81, 1, 0, 4, 4, 'ADD A,C', 'Z 0 H C'),
  new InstructionInfo(0x82, 1, 0, 4, 4, 'ADD A,D', 'Z 0 H C'),
  new InstructionInfo(0x83, 1, 0, 4, 4, 'ADD A,E', 'Z 0 H C'),
  new InstructionInfo(0x84, 1, 0, 4, 4, 'ADD A,H', 'Z 0 H C'),
  new InstructionInfo(0x85, 1, 0, 4, 4, 'ADD A,L', 'Z 0 H C'),
  new InstructionInfo(0x86, 1, 0, 8, 8, 'ADD A,(HL)', 'Z 0 H C'),
  new InstructionInfo(0x87, 1, 0, 4, 4, 'ADD A,A', 'Z 0 H C'),
  new InstructionInfo(0x88, 1, 0, 4, 4, 'ADC A,B', 'Z 0 H C'),
  new InstructionInfo(0x89, 1, 0, 4, 4, 'ADC A,C', 'Z 0 H C'),
  new InstructionInfo(0x8A, 1, 0, 4, 4, 'ADC A,D', 'Z 0 H C'),
  new InstructionInfo(0x8B, 1, 0, 4, 4, 'ADC A,E', 'Z 0 H C'),
  new InstructionInfo(0x8C, 1, 0, 4, 4, 'ADC A,H', 'Z 0 H C'),
  new InstructionInfo(0x8D, 1, 0, 4, 4, 'ADC A,L', 'Z 0 H C'),
  new InstructionInfo(0x8E, 1, 0, 8, 8, 'ADC A,(HL)', 'Z 0 H C'),
  new InstructionInfo(0x8F, 1, 0, 4, 4, 'ADC A,A', 'Z 0 H C'),
  new InstructionInfo(0x90, 1, 0, 4, 4, 'SUB B', 'Z 1 H C'),
  new InstructionInfo(0x91, 1, 0, 4, 4, 'SUB C', 'Z 1 H C'),
  new InstructionInfo(0x92, 1, 0, 4, 4, 'SUB D', 'Z 1 H C'),
  new InstructionInfo(0x93, 1, 0, 4, 4, 'SUB E', 'Z 1 H C'),
  new InstructionInfo(0x94, 1, 0, 4, 4, 'SUB H', 'Z 1 H C'),
  new InstructionInfo(0x95, 1, 0, 4, 4, 'SUB L', 'Z 1 H C'),
  new InstructionInfo(0x96, 1, 0, 8, 8, 'SUB (HL)', 'Z 1 H C'),
  new InstructionInfo(0x97, 1, 0, 4, 4, 'SUB A', 'Z 1 H C'),
  new InstructionInfo(0x98, 1, 0, 4, 4, 'SBC A,B', 'Z 1 H C'),
  new InstructionInfo(0x99, 1, 0, 4, 4, 'SBC A,C', 'Z 1 H C'),
  new InstructionInfo(0x9A, 1, 0, 4, 4, 'SBC A,D', 'Z 1 H C'),
  new InstructionInfo(0x9B, 1, 0, 4, 4, 'SBC A,E', 'Z 1 H C'),
  new InstructionInfo(0x9C, 1, 0, 4, 4, 'SBC A,H', 'Z 1 H C'),
  new InstructionInfo(0x9D, 1, 0, 4, 4, 'SBC A,L', 'Z 1 H C'),
  new InstructionInfo(0x9E, 1, 0, 8, 8, 'SBC A,(HL)', 'Z 1 H C'),
  new InstructionInfo(0x9F, 1, 0, 4, 4, 'SBC A,A', 'Z 1 H C'),
  new InstructionInfo(0xA0, 1, 0, 4, 4, 'AND B', 'Z 0 1 0'),
  new InstructionInfo(0xA1, 1, 0, 4, 4, 'AND C', 'Z 0 1 0'),
  new InstructionInfo(0xA2, 1, 0, 4, 4, 'AND D', 'Z 0 1 0'),
  new InstructionInfo(0xA3, 1, 0, 4, 4, 'AND E', 'Z 0 1 0'),
  new InstructionInfo(0xA4, 1, 0, 4, 4, 'AND H', 'Z 0 1 0'),
  new InstructionInfo(0xA5, 1, 0, 4, 4, 'AND L', 'Z 0 1 0'),
  new InstructionInfo(0xA6, 1, 0, 8, 8, 'AND (HL)', 'Z 0 1 0'),
  new InstructionInfo(0xA7, 1, 0, 4, 4, 'AND A', 'Z 0 1 0'),
  new InstructionInfo(0xA8, 1, 0, 4, 4, 'XOR B', 'Z 0 0 0'),
  new InstructionInfo(0xA9, 1, 0, 4, 4, 'XOR C', 'Z 0 0 0'),
  new InstructionInfo(0xAA, 1, 0, 4, 4, 'XOR D', 'Z 0 0 0'),
  new InstructionInfo(0xAB, 1, 0, 4, 4, 'XOR E', 'Z 0 0 0'),
  new InstructionInfo(0xAC, 1, 0, 4, 4, 'XOR H', 'Z 0 0 0'),
  new InstructionInfo(0xAD, 1, 0, 4, 4, 'XOR L', 'Z 0 0 0'),
  new InstructionInfo(0xAE, 1, 0, 8, 8, 'XOR (HL)', 'Z 0 0 0'),
  new InstructionInfo(0xAF, 1, 0, 4, 4, 'XOR A', 'Z 0 0 0'),
  new InstructionInfo(0xB0, 1, 0, 4, 4, 'OR B', 'Z 0 0 0'),
  new InstructionInfo(0xB1, 1, 0, 4, 4, 'OR C', 'Z 0 0 0'),
  new InstructionInfo(0xB2, 1, 0, 4, 4, 'OR D', 'Z 0 0 0'),
  new InstructionInfo(0xB3, 1, 0, 4, 4, 'OR E', 'Z 0 0 0'),
  new InstructionInfo(0xB4, 1, 0, 4, 4, 'OR H', 'Z 0 0 0'),
  new InstructionInfo(0xB5, 1, 0, 4, 4, 'OR L', 'Z 0 0 0'),
  new InstructionInfo(0xB6, 1, 0, 8, 8, 'OR (HL)', 'Z 0 0 0'),
  new InstructionInfo(0xB7, 1, 0, 4, 4, 'OR A', 'Z 0 0 0'),
  new InstructionInfo(0xB8, 1, 0, 4, 4, 'CP B', 'Z 1 H C'),
  new InstructionInfo(0xB9, 1, 0, 4, 4, 'CP C', 'Z 1 H C'),
  new InstructionInfo(0xBA, 1, 0, 4, 4, 'CP D', 'Z 1 H C'),
  new InstructionInfo(0xBB, 1, 0, 4, 4, 'CP E', 'Z 1 H C'),
  new InstructionInfo(0xBC, 1, 0, 4, 4, 'CP H', 'Z 1 H C'),
  new InstructionInfo(0xBD, 1, 0, 4, 4, 'CP L', 'Z 1 H C'),
  new InstructionInfo(0xBE, 1, 0, 8, 8, 'CP (HL)', 'Z 1 H C'),
  new InstructionInfo(0xBF, 1, 0, 4, 4, 'CP A', 'Z 1 H C'),
  new InstructionInfo(0xC0, 1, 0, 20, 8, 'RET NZ', '- - - -'),
  new InstructionInfo(0xC1, 1, 0, 12, 12, 'POP BC', '- - - -'),
  new InstructionInfo(0xC2, 1, 2, 16, 12, 'JP NZ,a16', '- - - -'),
  new InstructionInfo(0xC3, 1, 2, 16, 16, 'JP a16', '- - - -'),
  new InstructionInfo(0xC4, 1, 2, 24, 12, 'CALL NZ,a16', '- - - -'),
  new InstructionInfo(0xC5, 1, 0, 16, 16, 'PUSH BC', '- - - -'),
  new InstructionInfo(0xC6, 1, 1, 8, 8, 'ADD A,d8', 'Z 0 H C'),
  new InstructionInfo(0xC7, 1, 0, 16, 16, 'RST 00H', '- - - -'),
  new InstructionInfo(0xC8, 1, 0, 20, 8, 'RET Z', '- - - -'),
  new InstructionInfo(0xC9, 1, 0, 16, 16, 'RET', '- - - -'),
  new InstructionInfo(0xCA, 1, 2, 16, 12, 'JP Z,a16', '- - - -'),
  new InstructionInfo(0xCB, 1, 0, 0, 0, '0xCB: PREFIX', '- - - -'),
  new InstructionInfo(0xCC, 1, 2, 24, 12, 'CALL Z,a16', '- - - -'),
  new InstructionInfo(0xCD, 1, 2, 24, 24, 'CALL a16', '- - - -'),
  new InstructionInfo(0xCE, 1, 1, 8, 8, 'ADC A,d8', 'Z 0 H C'),
  new InstructionInfo(0xCF, 1, 0, 16, 16, 'RST 08H', '- - - -'),
  new InstructionInfo(0xD0, 1, 0, 20, 8, 'RET NC', '- - - -'),
  new InstructionInfo(0xD1, 1, 0, 12, 12, 'POP DE', '- - - -'),
  new InstructionInfo(0xD2, 1, 2, 16, 12, 'JP NC,a16', '- - - -'),
  new InstructionInfo(0xD3, 1, 0, 4, 4, '0xD3: N/A', '- - - -'),
  new InstructionInfo(0xD4, 1, 2, 24, 12, 'CALL NC,a16', '- - - -'),
  new InstructionInfo(0xD5, 1, 0, 16, 16, 'PUSH DE', '- - - -'),
  new InstructionInfo(0xD6, 1, 1, 8, 8, 'SUB d8', 'Z 1 H C'),
  new InstructionInfo(0xD7, 1, 0, 16, 16, 'RST 10H', '- - - -'),
  new InstructionInfo(0xD8, 1, 0, 20, 8, 'RET C', '- - - -'),
  new InstructionInfo(0xD9, 1, 0, 16, 16, 'RETI', '- - - -'),
  new InstructionInfo(0xDA, 1, 2, 16, 12, 'JP C,a16', '- - - -'),
  new InstructionInfo(0xDB, 1, 0, 4, 4, '0xDB: N/A', '- - - -'),
  new InstructionInfo(0xDC, 1, 2, 24, 12, 'CALL C,a16', '- - - -'),
  new InstructionInfo(0xDD, 1, 0, 4, 4, '0xDD: N/A', '- - - -'),
  new InstructionInfo(0xDE, 1, 1, 8, 8, 'SBC A,d8', 'Z 1 H C'),
  new InstructionInfo(0xDF, 1, 0, 16, 16, 'RST 18H', '- - - -'),
  new InstructionInfo(0xE0, 1, 1, 12, 12, 'LDH (a8),A', '- - - -'),
  new InstructionInfo(0xE1, 1, 0, 12, 12, 'POP HL', '- - - -'),
  new InstructionInfo(0xE2, 1, 1, 8, 8, 'LD (C),A', '- - - -'),
  new InstructionInfo(0xE3, 1, 0, 4, 4, '0xE3: N/A', '- - - -'),
  new InstructionInfo(0xE4, 1, 0, 4, 4, '0xE4: N/A', '- - - -'),
  new InstructionInfo(0xE5, 1, 0, 16, 16, 'PUSH HL', '- - - -'),
  new InstructionInfo(0xE6, 1, 1, 8, 8, 'AND d8', 'Z 0 1 0'),
  new InstructionInfo(0xE7, 1, 0, 16, 16, 'RST 20H', '- - - -'),
  new InstructionInfo(0xE8, 1, 1, 16, 16, 'ADD SP,r8', '0 0 H C'),
  new InstructionInfo(0xE9, 1, 0, 4, 4, 'JP (HL)', '- - - -'),
  new InstructionInfo(0xEA, 1, 2, 16, 16, 'LD (a16),A', '- - - -'),
  new InstructionInfo(0xEB, 1, 0, 4, 4, '0xEB: N/A', '- - - -'),
  new InstructionInfo(0xEC, 1, 0, 4, 4, '0xEC: N/A', '- - - -'),
  new InstructionInfo(0xED, 1, 0, 4, 4, '0xED: N/A', '- - - -'),
  new InstructionInfo(0xEE, 1, 1, 8, 8, 'XOR d8', 'Z 0 0 0'),
  new InstructionInfo(0xEF, 1, 0, 16, 16, 'RST 28H', '- - - -'),
  new InstructionInfo(0xF0, 1, 1, 12, 12, 'LDH A,(a8)', '- - - -'),
  new InstructionInfo(0xF1, 1, 0, 12, 12, 'POP AF', 'Z N H C'),
  new InstructionInfo(0xF2, 1, 1, 8, 8, 'LD A,(C)', '- - - -'),
  new InstructionInfo(0xF3, 1, 0, 4, 4, 'DI', '- - - -'),
  new InstructionInfo(0xF4, 1, 0, 4, 4, '0xF4: N/A', '- - - -'),
  new InstructionInfo(0xF5, 1, 0, 16, 16, 'PUSH AF', '- - - -'),
  new InstructionInfo(0xF6, 1, 1, 8, 8, 'OR d8', 'Z 0 0 0'),
  new InstructionInfo(0xF7, 1, 0, 16, 16, 'RST 30H', '- - - -'),
  new InstructionInfo(0xF8, 1, 1, 12, 12, 'LD HL,SP+r8', '0 0 H C'),
  new InstructionInfo(0xF9, 1, 0, 8, 8, 'LD SP,HL', '- - - -'),
  new InstructionInfo(0xFA, 1, 2, 16, 16, 'LD A,(a16)', '- - - -'),
  new InstructionInfo(0xFB, 1, 0, 4, 4, 'EI', '- - - -'),
  new InstructionInfo(0xFC, 1, 0, 4, 4, '0xFC: N/A', '- - - -'),
  new InstructionInfo(0xFD, 1, 0, 4, 4, '0xFD: N/A', '- - - -'),
  new InstructionInfo(0xFE, 1, 1, 8, 8, 'CP d8', 'Z 1 H C'),
  new InstructionInfo(0xFF, 1, 0, 16, 16, 'RST 38H', '- - - -')
]);

final instInfos_CB = new List<InstructionInfo>.unmodifiable([
  new InstructionInfo(0x00CB, 2, 0, 8, 8, 'RLC B', 'Z 0 0 C'),
  new InstructionInfo(0x01CB, 2, 0, 8, 8, 'RLC C', 'Z 0 0 C'),
  new InstructionInfo(0x02CB, 2, 0, 8, 8, 'RLC D', 'Z 0 0 C'),
  new InstructionInfo(0x03CB, 2, 0, 8, 8, 'RLC E', 'Z 0 0 C'),
  new InstructionInfo(0x04CB, 2, 0, 8, 8, 'RLC H', 'Z 0 0 C'),
  new InstructionInfo(0x05CB, 2, 0, 8, 8, 'RLC L', 'Z 0 0 C'),
  new InstructionInfo(0x06CB, 2, 0, 16, 16, 'RLC (HL)', 'Z 0 0 C'),
  new InstructionInfo(0x07CB, 2, 0, 8, 8, 'RLC A', 'Z 0 0 C'),
  new InstructionInfo(0x08CB, 2, 0, 8, 8, 'RRC B', 'Z 0 0 C'),
  new InstructionInfo(0x09CB, 2, 0, 8, 8, 'RRC C', 'Z 0 0 C'),
  new InstructionInfo(0x0ACB, 2, 0, 8, 8, 'RRC D', 'Z 0 0 C'),
  new InstructionInfo(0x0BCB, 2, 0, 8, 8, 'RRC E', 'Z 0 0 C'),
  new InstructionInfo(0x0CCB, 2, 0, 8, 8, 'RRC H', 'Z 0 0 C'),
  new InstructionInfo(0x0DCB, 2, 0, 8, 8, 'RRC L', 'Z 0 0 C'),
  new InstructionInfo(0x0ECB, 2, 0, 16, 16, 'RRC (HL)', 'Z 0 0 C'),
  new InstructionInfo(0x0FCB, 2, 0, 8, 8, 'RRC A', 'Z 0 0 C'),
  new InstructionInfo(0x10CB, 2, 0, 8, 8, 'RL B', 'Z 0 0 C'),
  new InstructionInfo(0x11CB, 2, 0, 8, 8, 'RL C', 'Z 0 0 C'),
  new InstructionInfo(0x12CB, 2, 0, 8, 8, 'RL D', 'Z 0 0 C'),
  new InstructionInfo(0x13CB, 2, 0, 8, 8, 'RL E', 'Z 0 0 C'),
  new InstructionInfo(0x14CB, 2, 0, 8, 8, 'RL H', 'Z 0 0 C'),
  new InstructionInfo(0x15CB, 2, 0, 8, 8, 'RL L', 'Z 0 0 C'),
  new InstructionInfo(0x16CB, 2, 0, 16, 16, 'RL (HL)', 'Z 0 0 C'),
  new InstructionInfo(0x17CB, 2, 0, 8, 8, 'RL A', 'Z 0 0 C'),
  new InstructionInfo(0x18CB, 2, 0, 8, 8, 'RR B', 'Z 0 0 C'),
  new InstructionInfo(0x19CB, 2, 0, 8, 8, 'RR C', 'Z 0 0 C'),
  new InstructionInfo(0x1ACB, 2, 0, 8, 8, 'RR D', 'Z 0 0 C'),
  new InstructionInfo(0x1BCB, 2, 0, 8, 8, 'RR E', 'Z 0 0 C'),
  new InstructionInfo(0x1CCB, 2, 0, 8, 8, 'RR H', 'Z 0 0 C'),
  new InstructionInfo(0x1DCB, 2, 0, 8, 8, 'RR L', 'Z 0 0 C'),
  new InstructionInfo(0x1ECB, 2, 0, 16, 16, 'RR (HL)', 'Z 0 0 C'),
  new InstructionInfo(0x1FCB, 2, 0, 8, 8, 'RR A', 'Z 0 0 C'),
  new InstructionInfo(0x20CB, 2, 0, 8, 8, 'SLA B', 'Z 0 0 C'),
  new InstructionInfo(0x21CB, 2, 0, 8, 8, 'SLA C', 'Z 0 0 C'),
  new InstructionInfo(0x22CB, 2, 0, 8, 8, 'SLA D', 'Z 0 0 C'),
  new InstructionInfo(0x23CB, 2, 0, 8, 8, 'SLA E', 'Z 0 0 C'),
  new InstructionInfo(0x24CB, 2, 0, 8, 8, 'SLA H', 'Z 0 0 C'),
  new InstructionInfo(0x25CB, 2, 0, 8, 8, 'SLA L', 'Z 0 0 C'),
  new InstructionInfo(0x26CB, 2, 0, 16, 16, 'SLA (HL)', 'Z 0 0 C'),
  new InstructionInfo(0x27CB, 2, 0, 8, 8, 'SLA A', 'Z 0 0 C'),
  new InstructionInfo(0x28CB, 2, 0, 8, 8, 'SRA B', 'Z 0 0 0'),
  new InstructionInfo(0x29CB, 2, 0, 8, 8, 'SRA C', 'Z 0 0 0'),
  new InstructionInfo(0x2ACB, 2, 0, 8, 8, 'SRA D', 'Z 0 0 0'),
  new InstructionInfo(0x2BCB, 2, 0, 8, 8, 'SRA E', 'Z 0 0 0'),
  new InstructionInfo(0x2CCB, 2, 0, 8, 8, 'SRA H', 'Z 0 0 0'),
  new InstructionInfo(0x2DCB, 2, 0, 8, 8, 'SRA L', 'Z 0 0 0'),
  new InstructionInfo(0x2ECB, 2, 0, 16, 16, 'SRA (HL)', 'Z 0 0 0'),
  new InstructionInfo(0x2FCB, 2, 0, 8, 8, 'SRA A', 'Z 0 0 0'),
  new InstructionInfo(0x30CB, 2, 0, 8, 8, 'SWAP B', 'Z 0 0 0'),
  new InstructionInfo(0x31CB, 2, 0, 8, 8, 'SWAP C', 'Z 0 0 0'),
  new InstructionInfo(0x32CB, 2, 0, 8, 8, 'SWAP D', 'Z 0 0 0'),
  new InstructionInfo(0x33CB, 2, 0, 8, 8, 'SWAP E', 'Z 0 0 0'),
  new InstructionInfo(0x34CB, 2, 0, 8, 8, 'SWAP H', 'Z 0 0 0'),
  new InstructionInfo(0x35CB, 2, 0, 8, 8, 'SWAP L', 'Z 0 0 0'),
  new InstructionInfo(0x36CB, 2, 0, 16, 16, 'SWAP (HL)', 'Z 0 0 0'),
  new InstructionInfo(0x37CB, 2, 0, 8, 8, 'SWAP A', 'Z 0 0 0'),
  new InstructionInfo(0x38CB, 2, 0, 8, 8, 'SRL B', 'Z 0 0 C'),
  new InstructionInfo(0x39CB, 2, 0, 8, 8, 'SRL C', 'Z 0 0 C'),
  new InstructionInfo(0x3ACB, 2, 0, 8, 8, 'SRL D', 'Z 0 0 C'),
  new InstructionInfo(0x3BCB, 2, 0, 8, 8, 'SRL E', 'Z 0 0 C'),
  new InstructionInfo(0x3CCB, 2, 0, 8, 8, 'SRL H', 'Z 0 0 C'),
  new InstructionInfo(0x3DCB, 2, 0, 8, 8, 'SRL L', 'Z 0 0 C'),
  new InstructionInfo(0x3ECB, 2, 0, 16, 16, 'SRL (HL)', 'Z 0 0 C'),
  new InstructionInfo(0x3FCB, 2, 0, 8, 8, 'SRL A', 'Z 0 0 C'),
  new InstructionInfo(0x40CB, 2, 0, 8, 8, 'BIT 0,B', 'Z 0 1 -'),
  new InstructionInfo(0x41CB, 2, 0, 8, 8, 'BIT 0,C', 'Z 0 1 -'),
  new InstructionInfo(0x42CB, 2, 0, 8, 8, 'BIT 0,D', 'Z 0 1 -'),
  new InstructionInfo(0x43CB, 2, 0, 8, 8, 'BIT 0,E', 'Z 0 1 -'),
  new InstructionInfo(0x44CB, 2, 0, 8, 8, 'BIT 0,H', 'Z 0 1 -'),
  new InstructionInfo(0x45CB, 2, 0, 8, 8, 'BIT 0,L', 'Z 0 1 -'),
  new InstructionInfo(0x46CB, 2, 0, 16, 16, 'BIT 0,(HL)', 'Z 0 1 -'),
  new InstructionInfo(0x47CB, 2, 0, 8, 8, 'BIT 0,A', 'Z 0 1 -'),
  new InstructionInfo(0x48CB, 2, 0, 8, 8, 'BIT 1,B', 'Z 0 1 -'),
  new InstructionInfo(0x49CB, 2, 0, 8, 8, 'BIT 1,C', 'Z 0 1 -'),
  new InstructionInfo(0x4ACB, 2, 0, 8, 8, 'BIT 1,D', 'Z 0 1 -'),
  new InstructionInfo(0x4BCB, 2, 0, 8, 8, 'BIT 1,E', 'Z 0 1 -'),
  new InstructionInfo(0x4CCB, 2, 0, 8, 8, 'BIT 1,H', 'Z 0 1 -'),
  new InstructionInfo(0x4DCB, 2, 0, 8, 8, 'BIT 1,L', 'Z 0 1 -'),
  new InstructionInfo(0x4ECB, 2, 0, 16, 16, 'BIT 1,(HL)', 'Z 0 1 -'),
  new InstructionInfo(0x4FCB, 2, 0, 8, 8, 'BIT 1,A', 'Z 0 1 -'),
  new InstructionInfo(0x50CB, 2, 0, 8, 8, 'BIT 2,B', 'Z 0 1 -'),
  new InstructionInfo(0x51CB, 2, 0, 8, 8, 'BIT 2,C', 'Z 0 1 -'),
  new InstructionInfo(0x52CB, 2, 0, 8, 8, 'BIT 2,D', 'Z 0 1 -'),
  new InstructionInfo(0x53CB, 2, 0, 8, 8, 'BIT 2,E', 'Z 0 1 -'),
  new InstructionInfo(0x54CB, 2, 0, 8, 8, 'BIT 2,H', 'Z 0 1 -'),
  new InstructionInfo(0x55CB, 2, 0, 8, 8, 'BIT 2,L', 'Z 0 1 -'),
  new InstructionInfo(0x56CB, 2, 0, 16, 16, 'BIT 2,(HL)', 'Z 0 1 -'),
  new InstructionInfo(0x57CB, 2, 0, 8, 8, 'BIT 2,A', 'Z 0 1 -'),
  new InstructionInfo(0x58CB, 2, 0, 8, 8, 'BIT 3,B', 'Z 0 1 -'),
  new InstructionInfo(0x59CB, 2, 0, 8, 8, 'BIT 3,C', 'Z 0 1 -'),
  new InstructionInfo(0x5ACB, 2, 0, 8, 8, 'BIT 3,D', 'Z 0 1 -'),
  new InstructionInfo(0x5BCB, 2, 0, 8, 8, 'BIT 3,E', 'Z 0 1 -'),
  new InstructionInfo(0x5CCB, 2, 0, 8, 8, 'BIT 3,H', 'Z 0 1 -'),
  new InstructionInfo(0x5DCB, 2, 0, 8, 8, 'BIT 3,L', 'Z 0 1 -'),
  new InstructionInfo(0x5ECB, 2, 0, 16, 16, 'BIT 3,(HL)', 'Z 0 1 -'),
  new InstructionInfo(0x5FCB, 2, 0, 8, 8, 'BIT 3,A', 'Z 0 1 -'),
  new InstructionInfo(0x60CB, 2, 0, 8, 8, 'BIT 4,B', 'Z 0 1 -'),
  new InstructionInfo(0x61CB, 2, 0, 8, 8, 'BIT 4,C', 'Z 0 1 -'),
  new InstructionInfo(0x62CB, 2, 0, 8, 8, 'BIT 4,D', 'Z 0 1 -'),
  new InstructionInfo(0x63CB, 2, 0, 8, 8, 'BIT 4,E', 'Z 0 1 -'),
  new InstructionInfo(0x64CB, 2, 0, 8, 8, 'BIT 4,H', 'Z 0 1 -'),
  new InstructionInfo(0x65CB, 2, 0, 8, 8, 'BIT 4,L', 'Z 0 1 -'),
  new InstructionInfo(0x66CB, 2, 0, 16, 16, 'BIT 4,(HL)', 'Z 0 1 -'),
  new InstructionInfo(0x67CB, 2, 0, 8, 8, 'BIT 4,A', 'Z 0 1 -'),
  new InstructionInfo(0x68CB, 2, 0, 8, 8, 'BIT 5,B', 'Z 0 1 -'),
  new InstructionInfo(0x69CB, 2, 0, 8, 8, 'BIT 5,C', 'Z 0 1 -'),
  new InstructionInfo(0x6ACB, 2, 0, 8, 8, 'BIT 5,D', 'Z 0 1 -'),
  new InstructionInfo(0x6BCB, 2, 0, 8, 8, 'BIT 5,E', 'Z 0 1 -'),
  new InstructionInfo(0x6CCB, 2, 0, 8, 8, 'BIT 5,H', 'Z 0 1 -'),
  new InstructionInfo(0x6DCB, 2, 0, 8, 8, 'BIT 5,L', 'Z 0 1 -'),
  new InstructionInfo(0x6ECB, 2, 0, 16, 16, 'BIT 5,(HL)', 'Z 0 1 -'),
  new InstructionInfo(0x6FCB, 2, 0, 8, 8, 'BIT 5,A', 'Z 0 1 -'),
  new InstructionInfo(0x70CB, 2, 0, 8, 8, 'BIT 6,B', 'Z 0 1 -'),
  new InstructionInfo(0x71CB, 2, 0, 8, 8, 'BIT 6,C', 'Z 0 1 -'),
  new InstructionInfo(0x72CB, 2, 0, 8, 8, 'BIT 6,D', 'Z 0 1 -'),
  new InstructionInfo(0x73CB, 2, 0, 8, 8, 'BIT 6,E', 'Z 0 1 -'),
  new InstructionInfo(0x74CB, 2, 0, 8, 8, 'BIT 6,H', 'Z 0 1 -'),
  new InstructionInfo(0x75CB, 2, 0, 8, 8, 'BIT 6,L', 'Z 0 1 -'),
  new InstructionInfo(0x76CB, 2, 0, 16, 16, 'BIT 6,(HL)', 'Z 0 1 -'),
  new InstructionInfo(0x77CB, 2, 0, 8, 8, 'BIT 6,A', 'Z 0 1 -'),
  new InstructionInfo(0x78CB, 2, 0, 8, 8, 'BIT 7,B', 'Z 0 1 -'),
  new InstructionInfo(0x79CB, 2, 0, 8, 8, 'BIT 7,C', 'Z 0 1 -'),
  new InstructionInfo(0x7ACB, 2, 0, 8, 8, 'BIT 7,D', 'Z 0 1 -'),
  new InstructionInfo(0x7BCB, 2, 0, 8, 8, 'BIT 7,E', 'Z 0 1 -'),
  new InstructionInfo(0x7CCB, 2, 0, 8, 8, 'BIT 7,H', 'Z 0 1 -'),
  new InstructionInfo(0x7DCB, 2, 0, 8, 8, 'BIT 7,L', 'Z 0 1 -'),
  new InstructionInfo(0x7ECB, 2, 0, 16, 16, 'BIT 7,(HL)', 'Z 0 1 -'),
  new InstructionInfo(0x7FCB, 2, 0, 8, 8, 'BIT 7,A', 'Z 0 1 -'),
  new InstructionInfo(0x80CB, 2, 0, 8, 8, 'RES 0,B', '- - - -'),
  new InstructionInfo(0x81CB, 2, 0, 8, 8, 'RES 0,C', '- - - -'),
  new InstructionInfo(0x82CB, 2, 0, 8, 8, 'RES 0,D', '- - - -'),
  new InstructionInfo(0x83CB, 2, 0, 8, 8, 'RES 0,E', '- - - -'),
  new InstructionInfo(0x84CB, 2, 0, 8, 8, 'RES 0,H', '- - - -'),
  new InstructionInfo(0x85CB, 2, 0, 8, 8, 'RES 0,L', '- - - -'),
  new InstructionInfo(0x86CB, 2, 0, 16, 16, 'RES 0,(HL)', '- - - -'),
  new InstructionInfo(0x87CB, 2, 0, 8, 8, 'RES 0,A', '- - - -'),
  new InstructionInfo(0x88CB, 2, 0, 8, 8, 'RES 1,B', '- - - -'),
  new InstructionInfo(0x89CB, 2, 0, 8, 8, 'RES 1,C', '- - - -'),
  new InstructionInfo(0x8ACB, 2, 0, 8, 8, 'RES 1,D', '- - - -'),
  new InstructionInfo(0x8BCB, 2, 0, 8, 8, 'RES 1,E', '- - - -'),
  new InstructionInfo(0x8CCB, 2, 0, 8, 8, 'RES 1,H', '- - - -'),
  new InstructionInfo(0x8DCB, 2, 0, 8, 8, 'RES 1,L', '- - - -'),
  new InstructionInfo(0x8ECB, 2, 0, 16, 16, 'RES 1,(HL)', '- - - -'),
  new InstructionInfo(0x8FCB, 2, 0, 8, 8, 'RES 1,A', '- - - -'),
  new InstructionInfo(0x90CB, 2, 0, 8, 8, 'RES 2,B', '- - - -'),
  new InstructionInfo(0x91CB, 2, 0, 8, 8, 'RES 2,C', '- - - -'),
  new InstructionInfo(0x92CB, 2, 0, 8, 8, 'RES 2,D', '- - - -'),
  new InstructionInfo(0x93CB, 2, 0, 8, 8, 'RES 2,E', '- - - -'),
  new InstructionInfo(0x94CB, 2, 0, 8, 8, 'RES 2,H', '- - - -'),
  new InstructionInfo(0x95CB, 2, 0, 8, 8, 'RES 2,L', '- - - -'),
  new InstructionInfo(0x96CB, 2, 0, 16, 16, 'RES 2,(HL)', '- - - -'),
  new InstructionInfo(0x97CB, 2, 0, 8, 8, 'RES 2,A', '- - - -'),
  new InstructionInfo(0x98CB, 2, 0, 8, 8, 'RES 3,B', '- - - -'),
  new InstructionInfo(0x99CB, 2, 0, 8, 8, 'RES 3,C', '- - - -'),
  new InstructionInfo(0x9ACB, 2, 0, 8, 8, 'RES 3,D', '- - - -'),
  new InstructionInfo(0x9BCB, 2, 0, 8, 8, 'RES 3,E', '- - - -'),
  new InstructionInfo(0x9CCB, 2, 0, 8, 8, 'RES 3,H', '- - - -'),
  new InstructionInfo(0x9DCB, 2, 0, 8, 8, 'RES 3,L', '- - - -'),
  new InstructionInfo(0x9ECB, 2, 0, 16, 16, 'RES 3,(HL)', '- - - -'),
  new InstructionInfo(0x9FCB, 2, 0, 8, 8, 'RES 3,A', '- - - -'),
  new InstructionInfo(0xA0CB, 2, 0, 8, 8, 'RES 4,B', '- - - -'),
  new InstructionInfo(0xA1CB, 2, 0, 8, 8, 'RES 4,C', '- - - -'),
  new InstructionInfo(0xA2CB, 2, 0, 8, 8, 'RES 4,D', '- - - -'),
  new InstructionInfo(0xA3CB, 2, 0, 8, 8, 'RES 4,E', '- - - -'),
  new InstructionInfo(0xA4CB, 2, 0, 8, 8, 'RES 4,H', '- - - -'),
  new InstructionInfo(0xA5CB, 2, 0, 8, 8, 'RES 4,L', '- - - -'),
  new InstructionInfo(0xA6CB, 2, 0, 16, 16, 'RES 4,(HL)', '- - - -'),
  new InstructionInfo(0xA7CB, 2, 0, 8, 8, 'RES 4,A', '- - - -'),
  new InstructionInfo(0xA8CB, 2, 0, 8, 8, 'RES 5,B', '- - - -'),
  new InstructionInfo(0xA9CB, 2, 0, 8, 8, 'RES 5,C', '- - - -'),
  new InstructionInfo(0xAACB, 2, 0, 8, 8, 'RES 5,D', '- - - -'),
  new InstructionInfo(0xABCB, 2, 0, 8, 8, 'RES 5,E', '- - - -'),
  new InstructionInfo(0xACCB, 2, 0, 8, 8, 'RES 5,H', '- - - -'),
  new InstructionInfo(0xADCB, 2, 0, 8, 8, 'RES 5,L', '- - - -'),
  new InstructionInfo(0xAECB, 2, 0, 16, 16, 'RES 5,(HL)', '- - - -'),
  new InstructionInfo(0xAFCB, 2, 0, 8, 8, 'RES 5,A', '- - - -'),
  new InstructionInfo(0xB0CB, 2, 0, 8, 8, 'RES 6,B', '- - - -'),
  new InstructionInfo(0xB1CB, 2, 0, 8, 8, 'RES 6,C', '- - - -'),
  new InstructionInfo(0xB2CB, 2, 0, 8, 8, 'RES 6,D', '- - - -'),
  new InstructionInfo(0xB3CB, 2, 0, 8, 8, 'RES 6,E', '- - - -'),
  new InstructionInfo(0xB4CB, 2, 0, 8, 8, 'RES 6,H', '- - - -'),
  new InstructionInfo(0xB5CB, 2, 0, 8, 8, 'RES 6,L', '- - - -'),
  new InstructionInfo(0xB6CB, 2, 0, 16, 16, 'RES 6,(HL)', '- - - -'),
  new InstructionInfo(0xB7CB, 2, 0, 8, 8, 'RES 6,A', '- - - -'),
  new InstructionInfo(0xB8CB, 2, 0, 8, 8, 'RES 7,B', '- - - -'),
  new InstructionInfo(0xB9CB, 2, 0, 8, 8, 'RES 7,C', '- - - -'),
  new InstructionInfo(0xBACB, 2, 0, 8, 8, 'RES 7,D', '- - - -'),
  new InstructionInfo(0xBBCB, 2, 0, 8, 8, 'RES 7,E', '- - - -'),
  new InstructionInfo(0xBCCB, 2, 0, 8, 8, 'RES 7,H', '- - - -'),
  new InstructionInfo(0xBDCB, 2, 0, 8, 8, 'RES 7,L', '- - - -'),
  new InstructionInfo(0xBECB, 2, 0, 16, 16, 'RES 7,(HL)', '- - - -'),
  new InstructionInfo(0xBFCB, 2, 0, 8, 8, 'RES 7,A', '- - - -'),
  new InstructionInfo(0xC0CB, 2, 0, 8, 8, 'SET 0,B', '- - - -'),
  new InstructionInfo(0xC1CB, 2, 0, 8, 8, 'SET 0,C', '- - - -'),
  new InstructionInfo(0xC2CB, 2, 0, 8, 8, 'SET 0,D', '- - - -'),
  new InstructionInfo(0xC3CB, 2, 0, 8, 8, 'SET 0,E', '- - - -'),
  new InstructionInfo(0xC4CB, 2, 0, 8, 8, 'SET 0,H', '- - - -'),
  new InstructionInfo(0xC5CB, 2, 0, 8, 8, 'SET 0,L', '- - - -'),
  new InstructionInfo(0xC6CB, 2, 0, 16, 16, 'SET 0,(HL)', '- - - -'),
  new InstructionInfo(0xC7CB, 2, 0, 8, 8, 'SET 0,A', '- - - -'),
  new InstructionInfo(0xC8CB, 2, 0, 8, 8, 'SET 1,B', '- - - -'),
  new InstructionInfo(0xC9CB, 2, 0, 8, 8, 'SET 1,C', '- - - -'),
  new InstructionInfo(0xCACB, 2, 0, 8, 8, 'SET 1,D', '- - - -'),
  new InstructionInfo(0xCBCB, 2, 0, 8, 8, 'SET 1,E', '- - - -'),
  new InstructionInfo(0xCCCB, 2, 0, 8, 8, 'SET 1,H', '- - - -'),
  new InstructionInfo(0xCDCB, 2, 0, 8, 8, 'SET 1,L', '- - - -'),
  new InstructionInfo(0xCECB, 2, 0, 16, 16, 'SET 1,(HL)', '- - - -'),
  new InstructionInfo(0xCFCB, 2, 0, 8, 8, 'SET 1,A', '- - - -'),
  new InstructionInfo(0xD0CB, 2, 0, 8, 8, 'SET 2,B', '- - - -'),
  new InstructionInfo(0xD1CB, 2, 0, 8, 8, 'SET 2,C', '- - - -'),
  new InstructionInfo(0xD2CB, 2, 0, 8, 8, 'SET 2,D', '- - - -'),
  new InstructionInfo(0xD3CB, 2, 0, 8, 8, 'SET 2,E', '- - - -'),
  new InstructionInfo(0xD4CB, 2, 0, 8, 8, 'SET 2,H', '- - - -'),
  new InstructionInfo(0xD5CB, 2, 0, 8, 8, 'SET 2,L', '- - - -'),
  new InstructionInfo(0xD6CB, 2, 0, 16, 16, 'SET 2,(HL)', '- - - -'),
  new InstructionInfo(0xD7CB, 2, 0, 8, 8, 'SET 2,A', '- - - -'),
  new InstructionInfo(0xD8CB, 2, 0, 8, 8, 'SET 3,B', '- - - -'),
  new InstructionInfo(0xD9CB, 2, 0, 8, 8, 'SET 3,C', '- - - -'),
  new InstructionInfo(0xDACB, 2, 0, 8, 8, 'SET 3,D', '- - - -'),
  new InstructionInfo(0xDBCB, 2, 0, 8, 8, 'SET 3,E', '- - - -'),
  new InstructionInfo(0xDCCB, 2, 0, 8, 8, 'SET 3,H', '- - - -'),
  new InstructionInfo(0xDDCB, 2, 0, 8, 8, 'SET 3,L', '- - - -'),
  new InstructionInfo(0xDECB, 2, 0, 16, 16, 'SET 3,(HL)', '- - - -'),
  new InstructionInfo(0xDFCB, 2, 0, 8, 8, 'SET 3,A', '- - - -'),
  new InstructionInfo(0xE0CB, 2, 0, 8, 8, 'SET 4,B', '- - - -'),
  new InstructionInfo(0xE1CB, 2, 0, 8, 8, 'SET 4,C', '- - - -'),
  new InstructionInfo(0xE2CB, 2, 0, 8, 8, 'SET 4,D', '- - - -'),
  new InstructionInfo(0xE3CB, 2, 0, 8, 8, 'SET 4,E', '- - - -'),
  new InstructionInfo(0xE4CB, 2, 0, 8, 8, 'SET 4,H', '- - - -'),
  new InstructionInfo(0xE5CB, 2, 0, 8, 8, 'SET 4,L', '- - - -'),
  new InstructionInfo(0xE6CB, 2, 0, 16, 16, 'SET 4,(HL)', '- - - -'),
  new InstructionInfo(0xE7CB, 2, 0, 8, 8, 'SET 4,A', '- - - -'),
  new InstructionInfo(0xE8CB, 2, 0, 8, 8, 'SET 5,B', '- - - -'),
  new InstructionInfo(0xE9CB, 2, 0, 8, 8, 'SET 5,C', '- - - -'),
  new InstructionInfo(0xEACB, 2, 0, 8, 8, 'SET 5,D', '- - - -'),
  new InstructionInfo(0xEBCB, 2, 0, 8, 8, 'SET 5,E', '- - - -'),
  new InstructionInfo(0xECCB, 2, 0, 8, 8, 'SET 5,H', '- - - -'),
  new InstructionInfo(0xEDCB, 2, 0, 8, 8, 'SET 5,L', '- - - -'),
  new InstructionInfo(0xEECB, 2, 0, 16, 16, 'SET 5,(HL)', '- - - -'),
  new InstructionInfo(0xEFCB, 2, 0, 8, 8, 'SET 5,A', '- - - -'),
  new InstructionInfo(0xF0CB, 2, 0, 8, 8, 'SET 6,B', '- - - -'),
  new InstructionInfo(0xF1CB, 2, 0, 8, 8, 'SET 6,C', '- - - -'),
  new InstructionInfo(0xF2CB, 2, 0, 8, 8, 'SET 6,D', '- - - -'),
  new InstructionInfo(0xF3CB, 2, 0, 8, 8, 'SET 6,E', '- - - -'),
  new InstructionInfo(0xF4CB, 2, 0, 8, 8, 'SET 6,H', '- - - -'),
  new InstructionInfo(0xF5CB, 2, 0, 8, 8, 'SET 6,L', '- - - -'),
  new InstructionInfo(0xF6CB, 2, 0, 16, 16, 'SET 6,(HL)', '- - - -'),
  new InstructionInfo(0xF7CB, 2, 0, 8, 8, 'SET 6,A', '- - - -'),
  new InstructionInfo(0xF8CB, 2, 0, 8, 8, 'SET 7,B', '- - - -'),
  new InstructionInfo(0xF9CB, 2, 0, 8, 8, 'SET 7,C', '- - - -'),
  new InstructionInfo(0xFACB, 2, 0, 8, 8, 'SET 7,D', '- - - -'),
  new InstructionInfo(0xFBCB, 2, 0, 8, 8, 'SET 7,E', '- - - -'),
  new InstructionInfo(0xFCCB, 2, 0, 8, 8, 'SET 7,H', '- - - -'),
  new InstructionInfo(0xFDCB, 2, 0, 8, 8, 'SET 7,L', '- - - -'),
  new InstructionInfo(0xFECB, 2, 0, 16, 16, 'SET 7,(HL)', '- - - -'),
  new InstructionInfo(0xFFCB, 2, 0, 8, 8, 'SET 7,A', '- - - -')
]);

/* Debug */

// void debug()
// {
//   for (var i = 0; i < instInfos.length; ++i)
//   {
//     assert (i == (instInfos[i].opCode & 0x00FF));
//     print(info);
//   }
// }

// void debugEX()
// {
//   for (var i = 0; i < instInfos.length; ++i)
//   {
//     assert (i == (instInfos_CB[i].opCode >> 8));
//     print(info);
//   }
// }

// void main ()
// {
//   debug();
//   debugEX();
// }