// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   variants.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/24 12:12:05 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/06 15:30:21 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

abstract class Chip implements Component{}

abstract class Component {
  static const Iterable<Component> values =
    const <Component>[Rom.v, Ram.v, Ss.v];
}

class Rom implements Component {
  const Rom._();
  static const Rom v = const Rom._();
  String toString() => 'Rom';
}

class Ram implements Chip {
  const Ram._();
  static const Ram v = const Ram._();
  String toString() => 'Ram';
}

class Ss implements Chip {
  const Ss._();
  static const Ss v = const Ss._();
  String toString() => 'Ss';
}

// Locations **************************************************************** **
abstract class CartState {}
abstract class ChipState {}

class None implements CartState, ChipState {
  const None._();
  static const None v = const None._();
  String toString() => 'None';
}

class Closed implements CartState {
  const Closed._();
  static const Closed v = const Closed._();
  String toString() => 'Closed';
}

class Opened implements CartState {
  const Opened._();
  static const Opened v = const Opened._();
  String toString() => 'Opened';
}

class GameBoy implements CartState {
  const GameBoy._();
  static const GameBoy v = const GameBoy._();
  String toString() => 'GameBoy';
}

class Detached implements ChipState {
  const Detached._();
  static const Detached v = const Detached._();
  String toString() => 'Detached';
}

class Attached implements ChipState {
  const Attached._();
  static const Attached v = const Attached._();
  String toString() => 'Attached';
}

// Cart movements *********************************************************** **
enum _CartEvent {
  New, Open, Close, Load,
  UnloadOpened, UnloadClosed,
  DeleteOpened, DeleteClosed, DeleteGameBoy,
}

const _cartEventTargets = const <_CartEvent, List<CartState>>{
  _CartEvent.New: const <CartState>[None.v, Closed.v],
  _CartEvent.Open: const <CartState>[Closed.v, Opened.v],
  _CartEvent.Close: const <CartState>[Opened.v, Closed.v],
  _CartEvent.Load: const <CartState>[Opened.v, GameBoy.v],
  _CartEvent.UnloadOpened: const <CartState>[GameBoy.v, Opened.v],
  _CartEvent.UnloadClosed: const <CartState>[GameBoy.v, Closed.v],
  _CartEvent.DeleteOpened: const <CartState>[Opened.v, None.v],
  _CartEvent.DeleteClosed: const <CartState>[Closed.v, None.v],
  _CartEvent.DeleteGameBoy: const <CartState>[GameBoy.v, None.v],
};

class CartEvent<T> {

  final T cart;
  final _CartEvent _ev;

  CartEvent.New(this.cart) : _ev = _CartEvent.New;
  CartEvent.Open(this.cart) : _ev = _CartEvent.Open;
  CartEvent.Close(this.cart) : _ev = _CartEvent.Close;
  CartEvent.Load(this.cart) : _ev = _CartEvent.Load;
  CartEvent.UnloadOpened(this.cart) : _ev = _CartEvent.UnloadOpened;
  CartEvent.UnloadClosed(this.cart) : _ev = _CartEvent.UnloadClosed;
  CartEvent.DeleteOpened(this.cart) : _ev = _CartEvent.DeleteOpened;
  CartEvent.DeleteClosed(this.cart) : _ev = _CartEvent.DeleteClosed;
  CartEvent.DeleteGameBoy(this.cart) : _ev = _CartEvent.DeleteGameBoy;

  bool get isNew => _ev == _CartEvent.New;
  bool get isOpen => _ev == _CartEvent.Open;
  bool get isClose => _ev == _CartEvent.Close;
  bool get isLoad => _ev == _CartEvent.Load;
  bool get isUnloadOpened => _ev == _CartEvent.UnloadOpened;
  bool get isUnloadClosed => _ev == _CartEvent.UnloadClosed;
  bool get isDeleteOpened => _ev == _CartEvent.DeleteOpened;
  bool get isDeleteClosed => _ev == _CartEvent.DeleteClosed;
  bool get isDeleteGameBoy => _ev == _CartEvent.DeleteGameBoy;

  bool get isUnload => isUnloadOpened || isUnloadClosed;
  bool get isMove => isLoad || isUnload;
  bool get isDelete => isDeleteGameBoy || isDeleteOpened || isDeleteClosed;

  CartState get src => _cartEventTargets[_ev][0];
  CartState get dst => _cartEventTargets[_ev][1];

  bool get isOpenedChange => src is Opened || dst is Opened;
  bool get isGbChange => src is GameBoy || dst is GameBoy;

}
// Chip events ************************************************************** **
enum _ChipEvent {
  New, Attach, Detach, DeleteAttached, DeleteDetached,
}

const _chipEventTargets = const <_ChipEvent, List<ChipState>>{
  _ChipEvent.New: const <ChipState>[None.v, Detached.v],
  _ChipEvent.Attach: const <ChipState>[Detached.v, Attached.v],
  _ChipEvent.Detach: const <ChipState>[Attached.v, Detached.v],
  _ChipEvent.DeleteAttached: const <ChipState>[Attached.v, None.v],
  _ChipEvent.DeleteDetached: const <ChipState>[Detached.v, None.v],
};

class ChipEvent<T, C> {

  final T chip;
  final _ChipEvent _ev;

  ChipEvent.New(this.chip) : _ev = _ChipEvent.New;
  ChipEvent.DeleteDetached(this.chip) : _ev = _ChipEvent.DeleteDetached;
  factory ChipEvent.Attach(chip, cart) =>
    new ChipEventCart<T, C>(chip, cart, _ChipEvent.Attach);
  factory ChipEvent.Detach(chip, cart) =>
    new ChipEventCart<T, C>(chip, cart, _ChipEvent.Detach);
  factory ChipEvent.DeleteAttached(chip, cart) =>
    new ChipEventCart<T, C>(chip, cart, _ChipEvent.DeleteAttached);

  ChipEvent._detail(this.chip, this._ev);

  bool get isNew => _ev = _ChipEvent.New;
  bool get isAttach => _ev = _ChipEvent.Attach;
  bool get isDetach => _ev = _ChipEvent.Detach;
  bool get isDeleteAttached => _ev = _ChipEvent.DeleteAttached;
  bool get isDeleteDetached => _ev = _ChipEvent.DeleteDetached;
  bool get isMove => isAttach || isDetach;
  bool get isDelete => isDeleteDetached || isDeleteAttached;

}

class ChipEventCart<T, C> extends ChipEvent<T> {

  final C cart;

  ChipEventCart._detail(chip, this.cart, ev) : super._detail(chip, ev);
  ChipEventCart.Detach(chip, this.cart, ev) : super._detail(chip, ev);
  ChipEventCart.DeleteAttached(chip, this.cart, ev) : super._detail(chip, ev);

}

// Life ********************************************************************* **
class Alive implements Life {
  const Alive._();
  static const Alive v = const Alive._();
  String toString() => 'Alive';
}

class Dead implements Life {
  const Dead._();
  static const Dead v = const Dead._();
  String toString() => 'Dead';
}

abstract class Life {
  factory Life.ofString(String s) {
    switch (s) {
      case ('Alive'): return Alive.v;
      case ('Dead'): return Dead.v;
      default: throw new Exception('Life.ofString($s)');
    }
  }
}

// SlotAction event ********************************************************* **
enum _SlotEvent {
  Arrival, Dismissal,
}

class SlotEvent<T> {
  final T value;
  final _SlotEvent _ev;

  SlotEvent.Arrival(this.value) : _ev = _SlotEvent.Arrival;
  SlotEvent.Dismissal(this.value) : _ev = _SlotEvent.Dismissal;

  bool get isArrival => _ev == _SlotEvent.Arrival;
  bool get isDismissal => _ev == _SlotEvent.Dismissal;

}

// Update event ************************************************************* **
class Update<T> {
  final T newValue;
  final T oldValue;
  Update({T oldValue, T newValue})
    : oldValue = oldValue
    , newValue = newValue;
}
