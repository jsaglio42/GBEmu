// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   handler_dropzone_catalyst.dart                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/01 16:41:22 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/01 17:29:09 by ngoguey          ###   ########.fr       //
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

import 'package:component_system/src/include_cs.dart';
// import 'package:component_system/src/include_ccs.dart';
import 'package:component_system/src/include_dc.dart';
import 'package:component_system/src/include_cdc.dart';

class HandlerDropZoneCatalyst {

  // ATTRIBUTES ************************************************************* **
  final PlatformDomComponentStorage _pdcs;
  final PlatformTopLevelBanks _ptlb;
  final PlatformComponentEvents _pce;
  // final PlatformDomEvents _pde;

  List<HtmlDropZone> _enabledOpt;

  // CONSTRUCTION *********************************************************** **
  static HandlerDropZoneCatalyst _instance;

  factory HandlerDropZoneCatalyst(pdcs, ptlb, pce) {
    if (_instance == null)
      _instance = new HandlerDropZoneCatalyst._(pdcs, ptlb, pce);
    return _instance;
  }

  HandlerDropZoneCatalyst._(this._pdcs, this._ptlb, this._pce) {
    Ft.log('HandlerDropZoneCatalyst', 'contructor');

    _pce.onDraggedChange.forEach(_onDragChange);
  }

  // CALLBACKS ************************************************************** **
  void _onDragChange(SlotEvent<DomComponent> ev) {
    if (ev.type is Arrival) {
      assert(_enabledOpt == null, '_onDragChange() Arrival with some enabled');
      if (ev.value is DomCart)
        _startCart(ev.value);
      // TODO: Implement chip drop zone catalyst
    }
    else {
      assert(_enabledOpt != null, '_onDragChange() Dismissal with none enabled');
      _enabledOpt.forEach((dz) => dz.hdz_disable());
      _enabledOpt = null;
    }
  }

  // PRIVATE **************************************************************** **
  void _startCart(DomCart c) {
    _enabledOpt = <HtmlDropZone>[];
    if (_pdcs.gbCart.v == c) {
      _enabledOpt.add(_ptlb.cartBank);
    }
    else if (_pdcs.openedCart.v == c) {
      if (_pdcs.gbCart.isNone)
        _enabledOpt.add(_ptlb.gbSocket);
    }
    else
      assert(false, 'from: _startCart()');
    _enabledOpt.forEach((dz) => dz.hdz_enable());
  }

}
