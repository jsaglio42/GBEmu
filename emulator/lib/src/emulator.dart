// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   emulator.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:19 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/30 14:21:07 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:async' as Async;
import 'dart:typed_data';
import 'package:ft/ft.dart' as Ft;
import 'package:ft/wired_isolate.dart' as Wiso;

import 'package:emulator/enums.dart';
import 'package:emulator/src/worker.dart' as Worker;
import "package:emulator/src/cpu_registers.dart" as Cpuregs;

/*
 * ************************************************************************** **
 * Ports configuration ****************************************************** **
 * ************************************************************************** **
 * Defines two Map<String, Type>.
 * `Type` must match EXACTLY the sent type.
 * Don't send any `double` here, a double rounded is always a type int.
 * Receiver may use `a subtype` or `dynamic` parameter in
 *   it's callback function.
 */

final _mainReceivers = <String, Type>{
  'RegInfo' : Cpuregs.CpuRegs,
  'MemRegInfo' : Uint8List,
  'ClockInfo' : int,
  'EmulationSpeed' : <String, dynamic>{}.runtimeType,
  'EmulationStatus' : GameBoyExternalMode,
  'EmulationPause' : int,
  'EmulationResume' : int,
  'DebStatusUpdate' : bool,
  'MemInfo' : <String, dynamic>{}.runtimeType,
  'Events': <String, dynamic>{}.runtimeType,
};

final _workerReceivers = <String, Type>{
  'DebStatusRequest' : DebuggerModeRequest,
  'EmulationStart' : Uint8List,
  'EmulationSpeed' : <String, dynamic>{}.runtimeType,
  'EmulationAutoBreak' : AutoBreakExternalMode,
  'EmulationPause' : int,
  'EmulationResume' : int,
  'DebMemAddrChange' : int,
  'Debug' : <String, dynamic>{}.runtimeType,
};

/*
 * ************************************************************************** **
 * Emulator class ...
 * ************************************************************************** **
 */

class Emulator {

  final Wiso.WiredIsolate _wiso;
  final Async.StreamController<Map<String, dynamic>> _eventsBroadcast =
    new Async.StreamController<Map<String, dynamic>>.broadcast();

  Emulator(wiso)
    : _wiso = wiso
  {
    wiso.p.listener('Events')
    .forEach((Map e){
          _eventsBroadcast.add(e);
        });
    _wiso.isoErrors
    .forEach((e) {
          _eventsBroadcast.add(<String, dynamic>{
            'type': EmulatorEvent.EmulatorCrash,
            'msg': e,
          });
        });
  }

  void send(String msgType, var data) => _wiso.p.send(msgType, data);
  Async.Stream listener(String msgType)
  {
    if (msgType == 'Events')
      return _eventsBroadcast.stream;
    return _wiso.p.listener(msgType);
  }

}

Async.Future<Emulator> spawn()
async {
  Ft.log('emulator', 'spawn');

  final wiso = await Wiso.spawn(
      Worker.entryPoint, _mainReceivers, _workerReceivers);

  wiso.i.resume(wiso.resumeCapability);
  return new Emulator(wiso);
}
