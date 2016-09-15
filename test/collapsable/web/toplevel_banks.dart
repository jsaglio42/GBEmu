// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   toplevel_banks.dart                                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/08 14:29:28 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/15 18:39:30 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;

import 'package:ft/ft.dart' as Ft;
import 'package:emulator/filedb.dart' as Emufiledb;

import './component_system.dart';
import './component_system_dom.dart';
import './cart.dart';
import './chip.dart';

class GameBoySocket extends ACartBank {

  final Html.Element _elt = Html.querySelector('#gb-slot');
  Ft.Option<Cart> _cart = new Ft.Option<Cart>.none();

  // Construction *********************************************************** **

  static bool _instanciated = false;
  GameBoySocket()
  {
    Ft.log('${this.runtimeType}', 'constructor');
    assert(_instanciated == false);
    _instanciated = true;

    var jqElt = Js.context.callMethod(r'$', [
      new Js.JsObject.fromBrowserObject(_elt)]);

    jqElt.callMethod('droppable', [new Js.JsObject.jsify({
      'accept': this.isAcceptable,
      'greedy': true,
      'classes': {
        'ui-droppable-active': 'gameboysocket-active',
        'ui-droppable-hover': 'gameboysocket-hover',
      },
    })]);
    jqElt.callMethod('on', ['drop', this.onDrop]);
  }

  // From ACartBank ********************************************************* **

  bool get full => _cart.isSome;
  bool get empty => _cart.isNone;
  Html.Element get elt => _elt;

  void pop(ICart c)
  {
    Ft.log('GameBoySocket', 'pop', [c]);
    assert(_cart.isSome && _cart.v == c
        , "GameBoySocket.pop($c) with `_cart.v = ${_cart.v}`"
           );
    _cart = new Ft.Option<Cart>.none();
    _elt.nodes = [];
  }

  void push(ICart c)
  {
    Ft.log('GameBoySocket', 'push', [c]);
    assert(_cart.isNone
        , "GameBoySocket.push($c) with `_cart.v = ${_cart.v}`"
           );
    _cart = new Ft.Option<Cart>.some(c);
    _elt.nodes = [_cart.v.elt];
    c.elt.style.left = '0px';
    c.elt.style.top = '0px';
    c.parent = this;
    c.setLocation(CartLocation.GameBoy);
  }

}

class CartBank extends ACartBank
{

  List<ICart> _carts = [];
  List<ICart> get carts => _carts;

  final Html.DivElement _elt = Html.querySelector('#accordion');

  final String _cartHtml;
  final Html.NodeValidator _validator;

  // Construction *********************************************************** **

  static bool _instanciated = false;
  CartBank(this._cartHtml, this._validator)
  {
    Ft.log('${this.runtimeType}', 'constructor');
    assert(_instanciated == false, "CartBank()");
    _instanciated = true;

    var jqElt = Js.context.callMethod(r'$', [
      new Js.JsObject.fromBrowserObject(_elt)]);

    jqElt.callMethod('droppable', [new Js.JsObject.jsify({
      'accept': this.isAcceptable,
      'greedy': true,
      'classes': {
        'ui-droppable-active': 'accordion-active',
        'ui-droppable-hover': 'accordion-hover',
      },
    })]);
    jqElt.callMethod('on', ['drop', this.onDrop]);
  }

  // From ACartBank ********************************************************* **

  bool get full => false;
  bool get empty => _carts.isEmpty;
  Html.Element get elt => _elt;

  void pop(ICart c)
  {
    Ft.log('CartBank', 'pop', [c]);
    final bool poped = _carts.remove(c);

    assert(poped, "CartBank.pop($c) not found");
    _elt.nodes = _carts.map((c) => c.elt);
  }

  void push(ICart c)
  {
    Ft.log('CartBank', 'push', [c]);
    assert(!_carts.contains(c), "DetachedCartBank.push($c) already in");
    _carts.forEach((c) => c.collapse());
    _carts.add(c);
    _elt.nodes = _carts.map((c) => c.elt);
    c.elt.style.left = '0px';
    c.elt.style.top = '0px';
    c.parent = this;
    c.setLocation(CartLocation.CartBank);
  }

  // ************************************************************************ **

  // Call at startup: Once for each cart/rom in indexedDB
  // Call at new `.rom` file.
  void add(Emufiledb.ProxyEntry prox) {
    final Cart c = new Cart(_cartHtml, _validator, prox);

    c.parent = this;
    _carts.add(c);
    _elt.nodes = _carts.map((c) => c.elt);
  }

}

class DetachedChipBank extends AChipBank {

  List<Chip> _chips = [];
  final Html.Element _elt = Html.querySelector('#detached-chip-bank');

  // Construction *********************************************************** **

  DetachedChipBank()
  {
    Ft.log('${this.runtimeType}', 'constructor');

    var jqElt = Js.context.callMethod(r'$', [
      new Js.JsObject.fromBrowserObject(_elt)]);

    jqElt.callMethod('droppable', [new Js.JsObject.jsify({
      'accept': this.isAcceptable,
      'greedy': true,
      'classes': {
        'ui-droppable-active': 'chipbank-active',
        'ui-droppable-hover': 'chipbank-hover',
      },
    })]);
    jqElt.callMethod('on', ['drop', this.onDrop]);
    // g_dbProxy.entryMoved
    //   .when((Emufiledb.ProxyEntry p) =>
    //       _chips.any((IChip c) => c.prox == p))
    //   .forEach((Emufiledb.ProxyEntry p) {
    //     this.pop(_chips.singleWhere((IChip c) => c.prox == p));
    //   });
  }

  // From ChipBank ********************************************************** **

  Location get loc => Location.DetachedChipBank;
  bool get full => false;
  bool get empty => _chips.isEmpty;
  bool get locked => false;
  Html.Element get elt => _elt;
  Ft.Option<Emufiledb.ProxyEntry> get cartProx => new Ft.Option.none();
  Ft.Option<int> get slot => new Ft.Option<int>.none();

  bool acceptType(ChipType t) => true;

  void pop(IChip toPop)
  {
    Ft.log('DetachedChipBank', 'pop', [toPop]);
    final bool poped = _chips.remove(toPop);

    assert(poped
        , "DetachedChipBank.pop($toPop) not found"
           );
    _elt.nodes = _chips.map((c) => c.elt);
  }

  void push(IChip toPush)
  {
    Ft.log('DetachedChipBank', 'push', [toPush]);
    assert(!_chips.contains(toPush)
        , "DetachedChipBank.push($toPush) already in"
           );
    _chips.add(toPush);
    _elt.nodes = _chips.map((c) => c.elt);
    toPush.elt.style.left = '0px';
    toPush.elt.style.top = '0px';
    toPush.parent = this;
  }

  // ************************************************************************ **

  Chip newRam(Emufiledb.ProxyEntry prox)
  {
    var c = new Chip.ram(prox);
    this.push(c);
    return c;
  }
  Chip newSs(Emufiledb.ProxyEntry prox)
  {
    var c = new Chip.ss(prox);
    this.push(c);
    return c;
  }

}
