// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_chip.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/05 17:16:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/18 12:37:39 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

library platform_chip;

import 'dart:js' as Js;
import 'dart:async' as Async;
import 'dart:html' as Html;
import 'dart:indexed_db' as Idb;
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

import 'package:ft/ft.dart' as Ft;
import 'package:emulator/enums.dart';
import 'package:emulator/emulator.dart' as Emulator;

import 'package:component_system/src/include_cs.dart';
import 'package:component_system/src/include_ccs.dart';
import 'package:component_system/src/include_dc.dart';
import 'package:component_system/src/include_cdc.dart';

part 'platform_chip_parts.dart';

class PlatformChip extends Object with _Actions implements _Super
{

  // ATTRIBUTES ************************************************************* **
  final PlatformComponentStorage _pcs;
  final PlatformDomEvents _pde;
  final PlatformComponentEvents _pce;
  final PlatformDomComponentStorage _pdcs;
  final Emulator.Emulator _emu;

  // CONSTRUCTION *********************************************************** **
  PlatformChip(this._pcs, this._pde, this._pce, this._pdcs, this._emu) {
    Ft.log('PlatformChip', 'contructor');

    _pde.onDropReceived
      .where((v) => v is ChipBank)
      .map((v) => v as ChipBank)
      .forEach(_onDropReceived);
    _pdcs.btnExtractRam.onClick
      .forEach(_onExtractRamClick);
  }

  // PUBLIC ***************************************************************** **
  void newChip(DomChip that) {
    final LsChip data = that.data as LsChip;

    if (!data.isBound)
      _actionNewDetached(that);
    else
      _actionNewAttached(that);
  }

  void deleteChip(DomChip that) {
    final LsChip data = that.data as LsChip;

    if (!data.isBound)
      _actionDeleteDetached(that);
    else
      _actionDeleteAttached(that);
  }

  void updateChip(DomChip that, Update<LsEntry> u) {
    final LsChip oldDat = u.oldValue;
    final LsChip newDat = u.newValue;

    that.setData(newDat);
    if (oldDat.isBound && newDat.isBound)
      _actionMoveAttach(
          that, _pdcs.componentOfUid(oldDat.romUid.v),
          _pdcs.componentOfUid(newDat.romUid.v));
    else if (oldDat.isBound && !newDat.isBound)
      _actionDetach(that, _pdcs.componentOfUid(oldDat.romUid.v));
    else if (!oldDat.isBound && newDat.isBound)
      _actionAttach(that, _pdcs.componentOfUid(newDat.romUid.v));
    else
      assert(false, 'updateChip#unreachable');
  }

  // CALLBACKS ************************************************************** **
  // The almighty function that has the view on:
  //   The chip-socket, the cart, and the dragged chip.
  void _onDropReceived(ChipBank that) {
    DomCart cart;
    DomChip chip;
    LsChip chdata;

    assert(_pdcs.dragged.isSome, '_onDropReceived() with none dragged');
    chip = _pdcs.dragged.v;
    chdata = chip.data as LsChip;
    if (that is DomDetachedChipBank)
      _pcs.unbind(chdata);
    else {
      cart = _pdcs.cartOfSocket(that as DomChipSocket);
      if (chdata.type is Ram)
        _pcs.bindRam(chdata, cart.data);
      else
        _pcs.bindSs(chdata, cart.data, cart.ssSocketIndex(that));
    }
  }

  void _onExtractRamClick(_) async {
    assert(_pdcs.gbCart.isSome, '_onExtractRamClick() with none in gb');

    final LsRom romData = _pdcs.gbCart.v.data;
    final Emulator.Ram ram =
      new Emulator.Ram.emptyDetail(romData.fileName, romData.ramSize);
    final LsRam unsafeRamData = await _pcs.newRamBound(ram, romData);

    _emu.send('ExtractRam', new Emulator.EventExtractRam(
            'GBmu_db', Ram.v.toString(), unsafeRamData.idbid));

  }

  // PRIVATE **************************************************************** **

}