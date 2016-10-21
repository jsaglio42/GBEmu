// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   tailrammanager.dart                                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/21 13:53:16 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

import "package:emulator/src/hardware/mem_registers_info.dart";

import "package:emulator/src/hardware/hardware.dart" as Hardware;
import "package:emulator/src/mixins/mmu.dart" as Mmu;
import "package:emulator/src/mixins/interrupts.dart" as Interrupt;

abstract class TrapAccessor {
  int tr_pull8(int memAddr);
  void tr_push8(int memAddr, int v);
}

abstract class TailRamManager
  implements Hardware.Hardware
  , Mmu.Mmu
  , Interrupt.Interrupts {

  /* Getters ******************************************************************/
  int tr_pull8(int memAddr) {
    switch (memAddr) {
      case (addr_P1): return this.memr.P1;
      case (addr_SB): return this.memr.SB;
      case (addr_SC): return this.memr.SC;
      case (addr_DIV): return this.memr.DIV;
      case (addr_TIMA): return this.memr.TIMA;
      case (addr_TMA): return this.memr.TMA;
      case (addr_TAC): return this.memr.TAC;
      case (addr_IF): return this.memr.IF;
      case (addr_LCDC): return this.memr.LCDC;
      case (addr_STAT): return this.memr.STAT;
      case (addr_SCY): return this.memr.SCY;
      case (addr_SCX): return this.memr.SCX;
      case (addr_LY): return this.memr.LY;
      case (addr_LYC): return this.memr.LYC;
      case (addr_DMA): return this.memr.DMA;
      case (addr_BGP): return this.memr.BGP;
      case (addr_OBP0): return this.memr.OBP0;
      case (addr_OBP1): return this.memr.OBP1;
      case (addr_WY): return this.memr.WY;
      case (addr_WX): return this.memr.WX;
      case (addr_KEY1): return this.memr.KEY1;
      case (addr_VBK): return this.memr.VBK;
      case (addr_HDMA1): return this.memr.HDMA1;
      case (addr_HDMA2): return this.memr.HDMA2;
      case (addr_HDMA3): return this.memr.HDMA3;
      case (addr_HDMA4): return this.memr.HDMA4;
      case (addr_HDMA5): return this.memr.HDMA5;
      case (addr_RP): return this.memr.RP;
      case (addr_BGPI): return this.memr.BGPI;
      case (addr_BGPD): return this.memr.BGPD;
      case (addr_OBPI): return this.memr.OBPI;
      case (addr_OBPD): return this.memr.OBPD;
      case (addr_SVBK): return this.memr.SVBK;
      case (addr_IE): return this.memr.IE;
      default: return this.tailram.pull8(memAddr);
    }
  }

  void tr_push8(int memAddr, int v) {
    switch (memAddr) {
      /* Timers */
      case (addr_DIV):
        this.memr.DIV = 0;
        this.memr.rDIV.counter = 0;
        break ;
      case (addr_TIMA):
        this.memr.TIMA = v;
        this.memr.rTIMA.counter = 0; // Needed ???
        break ;
      case (addr_TMA): this.memr.TMA = v; break ;
      case (addr_TAC): this.memr.TAC = v; break ;
      /* Graphics */
      case (addr_LY):
        this.memr.LY = 0;
        _updateCoincidence(this.memr.LYC == this.memr.LY);
        break ;
      case (addr_LYC):
        this.memr.LYC = v;
        _updateCoincidence(this.memr.LYC == this.memr.LY);
        break ;
      case (addr_STAT):
        this.memr.STAT = v;
        _updateCoincidence(this.memr.LYC == this.memr.LY);
        break;
      case (addr_DMA): _execDMA(v); break ;
      case (addr_LCDC): _setLCDCRegister(v); break ;
      /* Regular */
      case (addr_P1): this.memr.P1 = v; break ;
      case (addr_SB): this.memr.SB = v; break ;
      case (addr_SC): this.memr.SC = v; break ;
      case (addr_IF): this.memr.IF = v; break ;
      case (addr_SCY): this.memr.SCY = v; break ;
      case (addr_SCX): this.memr.SCX = v; break ;
      case (addr_BGP): this.memr.BGP = v; break ;
      case (addr_OBP0): this.memr.OBP0 = v; break ;
      case (addr_OBP1): this.memr.OBP1 = v; break ;
      case (addr_WY): this.memr.WY = v; break ;
      case (addr_WX): this.memr.WX = v; break ;
      case (addr_KEY1): this.memr.KEY1 = v; break ;
      case (addr_VBK): this.memr.VBK = v; break ;
      case (addr_HDMA1): this.memr.HDMA1 = v; break ;
      case (addr_HDMA2): this.memr.HDMA2 = v; break ;
      case (addr_HDMA3): this.memr.HDMA3 = v; break ;
      case (addr_HDMA4): this.memr.HDMA4 = v; break ;
      case (addr_HDMA5): this.memr.HDMA5 = v; break ;
      case (addr_RP): this.memr.RP = v; break ;
      case (addr_BGPI): this.memr.BGPI = v; break ;
      case (addr_BGPD): this.memr.BGPD = v; break ;
      case (addr_OBPI): this.memr.OBPI = v; break ;
      case (addr_OBPD): this.memr.OBPD = v; break ;
      case (addr_SVBK): this.memr.SVBK = v; break ;
      case (addr_IE): this.memr.IE = v; break ;
      default: this.tailram.push8(memAddr, v); break ;
    }
  }

  /* Specific routines ********************************************************/
  void _setLCDCRegister(int v) {
    final bool enabling = ((v >> 7) & 0x1 == 1);
    if (!this.memr.rLCDC.isLCDEnabled && enabling)
    {
      this.memr.rSTAT.counter = 0;
      this.memr.rSTAT.mode = GraphicMode.OAM_ACCESS;
      this.memr.LY = 0;
      _updateCoincidence(this.memr.LY == this.memr.LYC);
    }
    this.memr.LCDC = v;
    return ;
  }

  void _execDMA(int v) {
    int addr = v * 0x100;

    for (int i = 0 ; i < 40; ++i) {
      this.oam[i].posY = this.pull8(addr + 0);
      this.oam[i].posX = this.pull8(addr + 1);
      this.oam[i].tileID = this.pull8(addr + 2);
      this.oam[i].info.value = this.pull8(addr + 3);
      addr += 4;
    }
    this.memr.DMA = v;
    return ;
  }

  /* BE CAREFUL THE SAME FUNCTION IS IS GRAPHIC -> TO UPDATE */
  /* Generaly, LY, LYC and STAT are linked and should be updated together
  * ASK FOR EXPLANATION */
  void _updateCoincidence(bool coincidence) {
    this.memr.rSTAT.coincidence = coincidence;
    if (coincidence
      && this.memr.rSTAT.isInterruptMonitored(GraphicInterrupt.COINCIDENCE))
      this.requestInterrupt(InterruptType.LCDStat);
    return ;
  }

}
