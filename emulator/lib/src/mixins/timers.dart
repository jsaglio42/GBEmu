// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   timers.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/15 19:53:45 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/enums.dart";
import "package:emulator/src/globals.dart";

import "package:emulator/src/hardware/hardware.dart" as Hardware;
import "package:emulator/src/mixins/interruptmanager.dart" as Interrupt;
import "package:emulator/src/mixins/tail_ram.dart" as Tailram;

abstract class TrapAccessors {

  void resetDIVRegister();

}

abstract class Timers
  implements Hardware.Hardware
  , Tailram.TailRam
  , Interrupt.InterruptManager
  , TrapAccessors
{

  int _thresholdTIMA = 1024;
  int _counterTIMA = 0;
  int _counterDIV = 0;

  /* API **********************************************************************/
  void updateTimers(int nbClock) {
    this.clockTotal += nbClock;
    _updateDIV(nbClock);
    _updateTIMA(nbClock);
    return ;
  }

  void resetDIVRegister() {
    this.memr.DIV = 0;
    return ;
  }

  /* Private ******************************************************************/

  void _updateDIV(int nbClock) {
    _counterDIV += nbClock;
    if (_counterDIV >= 256)
    {
      _counterDIV -= 256;
      final DIV_old = this.memr.DIV;
      final DIV_new = (DIV_old + 1) & 0xFF;
      this.memr.DIV = DIV_new;
    }
    return ;
  }

  void _updateTIMA(int nbClock) {
    final int TAC = this.memr.TAC;
    if (TAC & (0x1 << 2) == 0)
      return ;
    _counterTIMA += nbClock;
    if (_counterTIMA >= _thresholdTIMA)
    {
      _counterTIMA -= _thresholdTIMA;
      _thresholdTIMA = _getTimerFrequency(TAC);
      final int TIMA_old = this.memr.TIMA;
      if (TIMA_old < 0xFF)
        this.memr.TIMA = TIMA_old + 1;
      else
      {
        final int TMA = this.memr.TMA;
        this.memr.TIMA = TMA;
        this.requestInterrupt(InterruptType.Timer);
      }
    }
    return ;
  }

  int _getTimerFrequency(int TAC)
  {
    switch(TAC & 0x3)
    {
      case (0): return 1024;
      case (1): return 16;
      case (2): return 64;
      case (3): return 256;
      default : assert(false, '_getTimerFrequency: switch failure');
    }
  }

}
