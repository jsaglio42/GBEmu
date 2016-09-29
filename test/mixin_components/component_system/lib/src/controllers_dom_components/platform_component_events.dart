// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_component_events.dart                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/29 15:55:47 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/29 15:57:54 by ngoguey          ###   ########.fr       //
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
import 'package:component_system/src/include_dc.dart';

class PlatformComponentEvents {

  // CONTRUCTION ************************************************************ **
  static PlatformComponentEvents _instance;

  factory PlatformComponentEvents() {
    if (_instance == null)
      _instance = new PlatformComponentEvents._();
    return _instance;
  }

  PlatformComponentEvents._() {
    Ft.log('PlatformCE', 'contructor', []);
  }

  // PUBLIC ***************************************************************** **
  // Notified by ControllerHtmlCartClosable
  final Async.StreamController<DomCart> _cartOpenedOpt =
    new Async.StreamController<DomCart>.broadcast();
  void cartOpenedOpt(DomCart that) => _cartOpenedOpt.add(that);
  Async.Stream<DomCart> get onCartOpenedOpt => _cartOpenedOpt.stream;

  // Notified by PlatformDomComponentStorage
  final Async.StreamController<DomCart> _cartNew =
    new Async.StreamController<DomCart>.broadcast();
  void cartNew(DomCart that) => _cartNew.add(that);
  Async.Stream<DomCart> get onCartNew => _cartNew.stream;

  final Async.StreamController<DomCart> _cartDelete =
    new Async.StreamController<DomCart>.broadcast();
  void cartDelete(DomCart that) => _cartDelete.add(that);
  Async.Stream<DomCart> get onCartDelete => _cartDelete.stream;

  final Async.StreamController<SlotEvent<DomCart>> _openedCartChange =
    new Async.StreamController<SlotEvent<DomCart>>.broadcast();
  void openedCartChange(SlotEvent<DomCart> that) => _openedCartChange.add(that);
  Async.Stream<SlotEvent<DomCart>> get onOpenedCartChange => _openedCartChange.stream;

  final Async.StreamController<SlotEvent<DomCart>> _gbCartChange =
    new Async.StreamController<SlotEvent<DomCart>>.broadcast();
  void gbCartChange(SlotEvent<DomCart> that) => _gbCartChange.add(that);
  Async.Stream<SlotEvent<DomCart>> get onGbCartChange => _gbCartChange.stream;

  final Async.StreamController<SlotEvent<DomComponent>> _draggedChange =
    new Async.StreamController<SlotEvent<DomComponent>>.broadcast();
  void draggedChange(SlotEvent<DomComponent> that) => _draggedChange.add(that);
  Async.Stream<SlotEvent<DomComponent>> get onDraggedChange => _draggedChange.stream;

}
