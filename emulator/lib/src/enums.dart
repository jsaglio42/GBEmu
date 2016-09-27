// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   enums.dart                                         :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:14 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/26 19:01:56 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

/*
 * This file should be fully imported for convenience
 */

export 'package:emulator/src/worker.dart'
  show DebuggerExternalMode
  , GameBoyExternalMode
  , PauseExternalMode
  , AutoBreakExternalMode
  , EmulatorEvent;
export 'package:emulator/src/hardware/cpu_registers.dart'
  show Reg16
  , Reg8
  , Reg1;
export 'package:emulator/src/hardware/headerdecoder.dart'
  show RomHeaderField
  , CartridgeType;
export 'package:emulator/src/hardware/registermapping.dart'
  show MemReg;
export 'package:emulator/src/mixins/interruptmanager.dart'
  show InterruptType ;
export 'package:emulator/src/mixins/joypad.dart'
  show KeyCode ;

enum DebuggerModeRequest {
  Toggle,
  Disable,
  Enable
}
