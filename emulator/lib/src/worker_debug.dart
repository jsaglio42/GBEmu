// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker_debug.dart                                  :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/26 11:51:18 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/26 12:02:46 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:typed_data';
import 'package:ft/ft.dart' as Ft;
import 'package:ft/wired_isolate.dart' as Wiso;

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';
import 'package:emulator/src/memory/rom.dart' as Rom;
import 'package:emulator/src/memory/ram.dart' as Ram;
import 'package:emulator/src/memory/mem_registers.dart' as Memregisters;
import 'package:emulator/src/memory/cartmbc0.dart' as Cartmbc0;
import 'package:emulator/src/gameboy.dart' as Gameboy;
import 'package:emulator/src/worker.dart' as Worker;

DateTime now() => new DateTime.now();

abstract class Debug implements Worker.AWorker {

  DebStatus _debuggerStatus = DebStatus.ON;
  // DateTime _emulationStartTime = now();
  Async.Timer _debuggerTimer;
  final int _debuggerMemoryLen = 144; // <- bad, should be initialised by dom
  int _debuggerMemoryAddr = 0;

  void _disableDebugger()
  {
    _debuggerStatus = DebStatus.OFF;
    this.ports.send('DebStatusUpdate', _debuggerStatus);
  }

  void _enableDebugger()
  {
    _debuggerStatus = DebStatus.ON;
    this.ports.send('DebStatusUpdate', _debuggerStatus);
  }

  void _onDebuggerStateChange(DebStatusRequest p)
  {
    print('worker:\tonDebuggerStateChange($p ${p.index})');

    // Enum equality fails after passing through a SendPort
    if (p.index == DebStatusRequest.TOGGLE.index) {
      if (_debuggerStatus == DebStatus.ON)
        _disableDebugger();
      else
        _enableDebugger();
    }
    else if (p.index == DebStatusRequest.DISABLE.index) {
      if (_debuggerStatus == DebStatus.ON)
        _disableDebugger();
    }
    else if (p.index == DebStatusRequest.ENABLE.index) {
      if (_debuggerStatus == DebStatus.OFF)
        _enableDebugger();
    }
    return ;
  }

  void _onDebug(_)
  {
    if (this.gb.isSome && _debuggerStatus == DebStatus.ON) {
      final l = new Uint8List(MemReg.values.length);
      final it = new Ft.DoubleIterable(MemReg.values, Memregisters.memRegInfos);

      this.ports.send('RegInfo', this.gb.data.cpuRegs);
      it.forEach((r, i) {
        l[r.index] = this.gb.data.mmu.pullMemReg(r);
      });
      this.ports.send('MemRegInfo', l);
      this.ports.send('ClockInfo', this.gb.data.clockCount);
    }
    return ;
  }

  void _onMemoryAddrChange(int addr)
  {
    print('worker:\tonMemoryAddrChange($addr)');
    assert((addr >= 0) && (addr <= 0x10000 - _debuggerMemoryLen)
        , '_onMemoryAddrChange: addr not valid');
    _debuggerMemoryAddr = addr;
    return ;
  }

  void init_debug()
  {
    this.ports.listener('DebStatusRequest').listen(_onDebuggerStateChange);
    this.ports.listener('DebMemAddrChange').listen(_onMemoryAddrChange);
    _debuggerTimer = new Async.Timer.periodic(DEBUG_PERIOD_DURATION, _onDebug);
  }

}