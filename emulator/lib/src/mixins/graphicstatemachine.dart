// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   graphicstatemachine.dart                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/19 18:41:31 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/enums.dart";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";

import "package:emulator/src/hardware/hardware.dart" as Hardware;
import "package:emulator/src/mixins/interrupts.dart" as Interrupts;

enum GraphicMode {
  HBLANK,
  VBLANK,
  OAM_ACCESS,
  VRAM_ACCESS
}

enum GraphicInterrupt {
  HBLANK,
  VBLANK,
  OAM_ACCESS,
  COINCIDENCE
}

abstract class GraphicStateMachine
  implements Hardware.Hardware
  , Interrupts.Interrupts {

  /* API **********************************************************************/
  void updateGraphicMode(int nbClock) {
    this.memr.rSTAT.counter += nbClock;
    switch (this.memr.rSTAT.mode)
    {
      case (GraphicMode.OAM_ACCESS) : _OAM_routine(); break;
      case (GraphicMode.VRAM_ACCESS) : _VRAM_routine(); break;
      case (GraphicMode.HBLANK) : ; _HBLANK_routine(); break;
      case (GraphicMode.VBLANK) : ; _VBLANK_routine(); break;
      default: assert (false, 'GraphicMode: switch failure');
    }
  }

  /* Private ******************************************************************/
  /* Switch to VRAM_ACCESS or remain as is */
  void _OAM_routine() {
    if (this.memr.rSTAT.counter >= CLOCK_PER_OAM_ACCESS)
    {
      this.memr.rSTAT.counter -= CLOCK_PER_OAM_ACCESS;
      this.memr.rSTAT.mode = GraphicMode.VRAM_ACCESS;
    }
  }

  /* Switch to HBLANK or remain as is */
  void _VRAM_routine() {
    if (this.memr.rSTAT.counter >= CLOCK_PER_VRAM_ACCESS)
    {
      this.memr.rSTAT.counter -= CLOCK_PER_VRAM_ACCESS;
      this.memr.rSTAT.mode = GraphicMode.HBLANK;
      if (this.memr.rSTAT.isInterruptMonitored(GraphicInterrupt.HBLANK))
        this.requestInterrupt(InterruptType.LCDStat);
    }
  }

  /* Switch to OAM_ACCESS/VBLANK or remain as is */
  void _HBLANK_routine() {
    if (this.memr.rSTAT.counter >= CLOCK_PER_HBLANK)
    {
      this.memr.rSTAT.counter -= CLOCK_PER_HBLANK;
      this.lcd.requestDrawLine(this.memr.LY);
      this.memr.LY = this.memr.LY + 1;
      _updateCoincidence(this.memr.LYC == this.memr.LY);
      if (this.memr.LY < VBLANK_THRESHOLD)
      {
        this.memr.rSTAT.mode = GraphicMode.OAM_ACCESS;
        if (this.memr.rSTAT.isInterruptMonitored(GraphicInterrupt.OAM_ACCESS))
          this.requestInterrupt(InterruptType.LCDStat);
      }
      else
      {
        this.memr.rSTAT.mode = GraphicMode.VBLANK;
        if (this.memr.rSTAT.isInterruptMonitored(GraphicInterrupt.VBLANK))
          this.requestInterrupt(InterruptType.LCDStat);
        this.requestInterrupt(InterruptType.VBlank);
      }
    }
  }

  /* Switch to OAM_ACCESS or remain as is */
  void _VBLANK_routine() {
    if (this.memr.rSTAT.counter >= CLOCK_PER_LINE)
    {
      this.memr.rSTAT.counter -= CLOCK_PER_LINE;
      final int incLY = this.memr.LY + 1;
      if (incLY >= FRAME_THRESHOLD)
      {
        this.lcd.shouldRefreshScreen = true;
        this.memr.LY = 0;
        _updateCoincidence(this.memr.LYC == this.memr.LY);
        this.memr.rSTAT.mode = GraphicMode.OAM_ACCESS;
        if (this.memr.rSTAT.isInterruptMonitored(GraphicInterrupt.OAM_ACCESS))
          this.requestInterrupt(InterruptType.LCDStat);
      }
      else
      {
        this.memr.LY = incLY;
        _updateCoincidence(this.memr.LYC == this.memr.LY);
      }
    }
  }

  /* Should probably be global, and checked when setting LY, LYC, STAT */
  void _updateCoincidence(bool coincidence) {
    this.memr.rSTAT.coincidence = coincidence;
    if (coincidence
      && this.memr.rSTAT.isInterruptMonitored(GraphicInterrupt.COINCIDENCE))
      this.requestInterrupt(InterruptType.LCDStat);
    return ;
  }

}
