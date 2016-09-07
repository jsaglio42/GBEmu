// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   cart_system.dart                                   :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/07 14:48:13 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/07 16:53:21 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;

import 'package:ft/ft.dart' as Ft;

import './component_system.dart';
import './chip_system.dart';

class ChipSocket extends IChipBank {

  final Html.Element _elt;
  final ChipType chipType;

  CartLocation _cartLoc = CartLocation.CartBank;
  bool _locked = true;

  CartLocation get cartLoc => _cartLoc;
  // Html.Element get elt => _elt;

  Ft.Option<Chip> _chip = new Ft.Option<Chip>.none();

  // Construction *********************************************************** **

  ChipSocket(this._elt, this.chipType);

  // From ChipBank ********************************************************** **

  Location get loc =>
    _cartLoc == CartLocation.GameBoy ? Location.GameBoy : Location.CartBank;
  bool get full => _chip.isSome;
  bool get empty => _chip.isNone;
  bool get locked => _locked;

  bool acceptType(ChipType t) => t == this.chipType;

  void pop(Chip c)
  {
    Ft.log('ChipSocket', 'pop', c);
    assert(_chip.isSome && _chip.v == c
        , "ChipSocket.pop($c) with `_chip.v = ${_chip.v}`"
           );
    _chip = new Ft.Option<Chip>.none();
    _elt.nodes = [];
  }

  void push(Chip c)
  {
    Ft.log('ChipSocket', 'push', c);
    assert(_chip.isNone
        , "ChipSocket.push($c) with `_chip.v = ${_chip.v}`"
           );
    _chip = new Ft.Option<Chip>.some(c);
    _elt.nodes = [_chip.v.elt];
  }

  // ************************************************************************ **

  void lock()
  {
    assert(_locked == false, "ChipSocket.lock() while locked");
    this._locked = true;
    if (_chip.isSome)
      _chip.v.lock();
  }

  void unlock()
  {
    assert(_locked == true, "ChipSocket.unlock() while unlocked");
    this._locked = false;
    if (_chip.isSome)
      _chip.v.lock();
  }

}

class Cart {

  static int _ids = 0;

  final Html.Element _elt;
  final Html.ButtonElement _btn;
  final Js.JsObject _jqBtn;
  final int _id;
  final String _bodyId;
  final ChipSocket _ramSocket;
  final List<ChipSocket> _ssSockets;

  bool _locked = false;
  bool _collapsed = false;
  CartLocation _loc = CartLocation.CartBank;

  ChipSocket get ramSocket => _ramSocket;
  List<ChipSocket> get ssSockets => _ssSockets;
  bool get locked => _locked;
  int get id => _id;
  CartLocation get loc => _loc;
  Html.Element get elt => _elt;

  // Construction *********************************************************** **

  static _ramSocketOfElt(elt)
  {
    final ramElt = elt.querySelector('.cart-ram-socket');

    return new ChipSocket(ramElt, ChipType.Ram);
  }

  static _ssSocketsOfElt(elt)
  {
    final ssElts = elt.querySelectorAll('.cart-ss-socket');
    var l = [];

    for (int i = 0; i < 4; i++) {
      l.add(new ChipSocket(ssElts[i], ChipType.Ss));
    }
    return new List<ChipSocket>.unmodifiable(l);
  }

  Cart.elements(elt, btn)
    : _elt = elt
    , _btn = btn
    , _jqBtn = Js.context.callMethod(r'$', [
      new Js.JsObject.fromBrowserObject(btn)])
    , _id = _ids++
    , _bodyId = 'cart${_ids - 1}Param-body'
    , _ramSocket = _ramSocketOfElt(elt)
    , _ssSockets = _ssSocketsOfElt(elt)
  {
    var body = elt.querySelector('.panel-collapse');
    var jqBody = Js.context.callMethod(r'$', [
      new Js.JsObject.fromBrowserObject(body)]);

    _btn.setAttribute('href', '#$_bodyId');
    jqBody.callMethod('on', ['shown.bs.collapse', _onOpenned]);
    jqBody.callMethod('on', ['hide.bs.collapse', _onCollapsed]);

    _makeCollapsable();
  }
  Cart.element(elt): this.elements(elt, elt.querySelector('.bg-head-btn'));

  Cart(String cartHtml, Html.NodeValidator v) : this.element(
      new Html.Element.html(cartHtml, validator: v));

  // ************************************************************************ **

  void setLocation(CartLocation loc)
  {
    assert(loc != _loc, "Cart.setLocation($loc)");
    _loc = loc;
    if (_loc == CartLocation.CartBank) {
      _makeCollapsable();
      _unlock();
    }
    else {
      _unmakeCollapsable();
      _lock();
    }
  }

  void _onCollapsed(_)
  {
    _collapsed = true;
    _lock();
  }

  void _onOpenned(_)
  {
    _collapsed = false;
    _unlock();
  }

  // ************************************************************************ **

  void _makeCollapsable()
  {
    _elt.querySelector('.panel-collapse')
      .id = _bodyId;
    _btn.disabled = false;
  }

  void _unmakeCollapsable()
  {
    _elt.querySelector('.panel-collapse')
      .id = null;
    _btn.disabled = true;
  }

  void _lock()
  {
    // assert(_locked == false, "Cart.lock() while locked");
    _locked = true;
    _ramSocket.lock();
    _ssSockets.forEach((p) => p.lock());
  }

  void _unlock()
  {
    // assert(_locked == true, "Cart.unlock() while unlocked");
    _locked = false;
    _ramSocket.unlock();
    _ssSockets.forEach((p) => p.unlock());
  }

}

class CartBank {

  List<Cart> _carts = [];
  List<Cart> get carts => _carts;

  final Html.DivElement _elt = Html.querySelector('#accordion');

  final String _cartHtml;
  final Html.NodeValidator _validator;

  static bool _instanciated = false;
  CartBank(this._cartHtml, this._validator)
  {
    assert(_instanciated == false, "CartBank()");
    _instanciated = true;
    assert(_elt != null, "CartBank._elt");

  }

  testAdd() {
    _carts.add(new Cart(_cartHtml, _validator));
    _elt.nodes = _carts.map((c) => c.elt);

  }

}
