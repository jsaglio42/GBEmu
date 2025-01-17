// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_component_storage.dart                    :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/27 14:18:20 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/26 19:54:11 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

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

// Did my best to limit data races, couldn't find a bullet proof solution
// This storage keeps track of all LsEntries, even the deleted one, to dampen
//  data-races effects.
class PlatformComponentStorage {

  // ATTRIBUTES ************************************************************* **
  final Map<int, LsEntry> _entries = <int, LsEntry>{};
  final PlatformIndexedDb _pidb;
  final PlatformLocalStorage _pls;

  final _rng = new Random.secure();
  static final int _maxint = pow(2, 32);

  Async.Stream<LsEntry> _entryDelete;
  Async.Stream<LsEntry> _entryNew;
  Async.Stream<Update<LsEntry>> _entryUpdate;

  // CONTRUCTION ************************************************************ **
  static PlatformComponentStorage _instance;

  factory PlatformComponentStorage(
      PlatformLocalStorage pls, PlatformIndexedDb pidb) {
    if (_instance == null)
      _instance = new PlatformComponentStorage._(pls, pidb);
    return _instance;
  }

  PlatformComponentStorage._(this._pls, this._pidb) {
    Ft.log('PlatformCS', 'contructor', []);
  }

  void start(TransformerLseIdbCheck tic) {
    Ft.log('PlatformCS', 'start', [tic]);

    _entryDelete = tic.lsEntryDelete.map(_handleDelete);
    _entryNew = tic.lsEntryNew.map(_handleNew);
    _entryUpdate = tic.lsEntryUpdate.map(_handleUpdate);
  }

  // PUBLIC ***************************************************************** **
  Async.Stream<LsEntry> get entryDelete {
    assert(_entryDelete != null, 'from: PlatformCS.entryDelete');
    return _entryDelete;
  }

  Async.Stream<LsEntry> get entryNew {
    assert(_entryNew != null, 'from: PlatformCS.entryNew');
    return _entryNew;
  }

  Async.Stream<Update<LsEntry>> get entryUpdate {
    assert(_entryUpdate != null, 'from: PlatformCS.entryUpdate');
    return _entryUpdate;
  }

  LsEntry entryOptOfUid(int uid) =>
    _entries[uid];

  bool romHasRam(LsRom dst) =>
    _entries.values
    .where((LsEntry e) => e.life is Alive && e.type is Ram)
    .where((LsRam r) => r.isBound && r.romUid.v == dst.uid)
    .isNotEmpty;

  bool romSlotBusy(LsRom dst, int slot) =>
    _entries.values
    .where((LsEntry e) => e.life is Alive && e.type is Ss)
    .where((LsSs ss) =>
        ss.isBound && ss.romUid.v == dst.uid && ss.slot.v == slot)
    .isNotEmpty;

  bool romHasAnyChip(LsRom dst) =>
    _entries.values
    .where((LsEntry e) => e.life is Alive && e.type is Chip)
    .where((LsChip c) => c.isBound && c.romUid.v == dst.uid)
    .isNotEmpty;

  Async.Future<dynamic> getRawData(LsEntry e) async =>
    (await _pidb.getRaw(e.type, e.idbid))['data'];

  // CREATION UNBOUND *********************************** **
  Async.Future<LsRom> newRom(Emulator.Rom r) async {
    Ft.log('PlatformCS', 'newRom', [r]);

    final int uid = _makeUid();
    final int idbid = await _pidb.add(Rom.v, r);
    final LsRom e = new LsRom.ofRom(uid, idbid, r);

    _pls.add(e);
    return e;
  }

  Async.Future<LsRam> newRam(Emulator.Ram r) async {
    Ft.log('PlatformCS', 'newRam', [r]);

    final int uid = _makeUid();
    final int idbid = await _pidb.add(Ram.v, r);
    final LsRam e = new LsRam.ofRam(uid, idbid, r);

    _pls.add(e);
    return e;
  }

  Async.Future<LsSs> newSs(Emulator.Ss ss) async {
    Ft.log('PlatformCS', 'newSs', [ss]);

    final int uid = _makeUid();
    final int idbid = await _pidb.add(Ss.v, ss);
    final int rgcs = ss.romGlobalChecksum;
    final LsSs e = new LsSs.ofSs(uid, idbid, ss);

    _pls.add(e);
    return e;
  }

  Async.Future<LsEntry> duplicate(LsEntry ref) async {
    Ft.log('PlatformCS', 'duplicate', [ref]);

    final int uid = _makeUid();
    final int idbid = await _pidb.duplicate(ref.type, ref.idbid);
    final LsEntry e = new LsEntry.duplicateUnbound(ref, uid, idbid);

    _pls.add(e);
    return e;
  }

  // CREATION BOUND ************************************* **
  Async.Future<LsRam> newRamBound(Emulator.Ram r, LsRom rom) async {
    Ft.log('PlatformCS', 'newRamBound', [r]);

    final int uid = _makeUid();
    final int idbid = await _pidb.add(Ram.v, r);
    final LsRam eUnbound = new LsRam.ofRam(uid, idbid, r);
    final LsRam e = new LsChip.bind(eUnbound, rom.uid);

    _pls.add(e);
    return e;
  }

  Async.Future<LsSs> newSsBound(Emulator.Ss ss, int slot, LsRom rom) async {
    Ft.log('PlatformCS', 'newSsBound', [ss]);

    final int uid = _makeUid();
    final int idbid = await _pidb.add(Ss.v, ss);
    final LsSs eUnbound = new LsSs.ofSs(uid, idbid, ss);
    final LsSs e = new LsChip.bind(eUnbound, rom.uid, slot);

    _pls.add(e);
    return e;
  }

  // UPDATES ******************************************** **
  void bindRam(LsRam c, LsRom dst) {
    Ft.log('PlatformCS', 'bindRam', [c, dst]);
    if (_entries[c.uid] == null) {
      Ft.logerr('PlatformCS', 'bindRam#missing-element', [c]);
      return ;
    }
    if (c.isBound && c.romUid.v == dst.uid) {
      Ft.logerr('PlatformCS', 'bindRam#already-here', [c, dst]);
      return ;
    }
    if (c.life is Dead) {
      Ft.logerr('PlatformCS', 'bindRam#dead-chip', [c]);
      return ;
    }
    if (dst.life is Dead) {
      Ft.logerr('PlatformCS', 'bindRam#dead-rom', [c, dst]);
      return ;
    }
    if (this.romHasRam(dst)) {
      Ft.logerr('PlatformCS', 'bindRam#full-rom', [c, dst]);
      return ;
    }
    _pls.update(new LsChip.bind(c, dst.uid));
  }

  void bindSs(LsSs c, LsRom dst, int slot) {
    Ft.log('PlatformCS', 'bindSs', [c, dst, slot]);
    if (_entries[c.uid] == null) {
      Ft.logerr('PlatformCS', 'bindSs#missing-element', [c]);
      return ;
    }
    if (c.isBound && c.romUid.v == dst.uid && c.slot.v == slot) {
      Ft.logerr('PlatformCS', 'bindSs#already-here', [c]);
      return ;
    }
    if (c.life is Dead) {
      Ft.logerr('PlatformCS', 'bindSs#dead-chip', [c]);
      return ;
    }
    if (dst.life is Dead) {
      Ft.logerr('PlatformCS', 'bindSs#dead-rom', [c, dst]);
      return ;
    }
    if (this.romSlotBusy(dst, slot)) {
      Ft.logerr('PlatformCS', 'bindSs#full-rom', [c, dst]);
      return ;
    }
    _pls.update(new LsChip.bind(c, dst.uid, slot));
  }

  void unbind(LsChip c) {
    Ft.log('PlatformCS', 'unbind', [c]);
    if (_entries[c.uid] == null) {
      Ft.logerr('PlatformCS', 'unbind#missing-element', [c]);
      return ;
    }
    if (!c.isBound) {
      Ft.logerr('PlatformCS', 'unbind#not-bound', [c]);
      return ;
    }
    if (c.life is Dead) {
      Ft.logerr('PlatformCS', 'unbind#dead', [c]);
      return ;
    }
    _pls.update(new LsChip.unbind(c));
  }

  // DELETIONS ****************************************** **
  Async.Future delete(LsEntry e) async {
    Ft.log('PlatformCS', 'delete', [e]);
    if (_entries[e.uid] == null) {
      Ft.logerr('PlatformCS', 'delete#missing-element', [e]);
      return ;
    }
    if (e.type is Rom && romHasAnyChip(e)) {
      Ft.logerr('PlatformCS', 'delete#busy-rom', [e]);
      return ;
    }
    await _pidb.delete(e.type, e.idbid);
    _pls.delete(e);
  }

  // CALLBACKS ************************************************************** **
  LsEntry _handleDelete(LsEntry e) {
    LsEntry old;

    // Ft.log('PlatformCS', '_handleDelete', [e]);
    old = _entries[e.uid];
    old.kill();
    return old;
  }

  LsEntry _handleNew(LsEntry e) {
    // Ft.log('PlatformCS', '_handleNew', [e]);
    _entries[e.uid] = e;
    return e;
  }

  Update<LsEntry> _handleUpdate(Update<LsEntry> u) {
    LsEntry old;

    // Ft.log('PlatformCS', '_handleUpdate', [u]);
    old = _entries[u.newValue.uid];
    _entries[u.newValue.uid] = u.newValue;
    return new Update<LsEntry>(oldValue: old, newValue: u.newValue);
  }

  // PRIVATE **************************************************************** **
  int _makeUid() {
    int uid;

    do {
      uid = _rng.nextInt(_maxint);
    } while (_entries[uid] != null);
    return uid;
  }

}
