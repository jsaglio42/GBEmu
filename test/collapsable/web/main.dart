// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   main.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/08 13:31:53 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/15 17:12:03 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;
import 'dart:indexed_db' as Idb;
import 'dart:typed_data';

import 'package:ft/ft.dart' as Ft;

// import 'package:emulator/constants.dart';
// import 'package:emulator/enums.dart';
import 'package:emulator/emulator.dart' as Emulator;
import 'package:emulator/filedb.dart' as Emufiledb;

import './component_system.dart';
import './component_system_dom.dart';
import './cart.dart';
import './chip.dart';
import './toplevel_banks.dart';

/*
 * Global Variable
 */

// String _cartHtml;
final Html.NodeValidatorBuilder _domCartValidator =
  new Html.NodeValidatorBuilder()
  ..allowHtml5()
  ..allowElement('button', attributes: ['href', 'data-parent', 'data-toggle'])
  ..allowElement('th', attributes: ['style'])
  ..allowElement('tr', attributes: ['style'])
  ;
final tetrisHead = new Uint8List.fromList(<int>[
  0xc3, 0x8b, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc3, 0x8b, 0x02, 0xff, 0xff, 0xff, 0xff, 0xff,
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x87, 0xe1, 0x5f, 0x16, 0x00, 0x19, 0x5e, 0x23,
  0x56, 0xd5, 0xe1, 0xe9, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
  0xc3, 0xfd, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc3, 0x12, 0x27, 0xff, 0xff, 0xff, 0xff, 0xff,
  0xc3, 0x12, 0x27, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc3, 0x7e, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff,
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,

  //Entry point:
  0x00, 0xc3, 0x50, 0x01, 0xce, 0xed, 0x66, 0x66, 0xcc, 0x0d, 0x00, 0x0b, 0x03, 0x73, 0x00, 0x83,
  0x00, 0x0c, 0x00, 0x0d, 0x00, 0x08, 0x11, 0x1f, 0x88, 0x89, 0x00, 0x0e, 0xdc, 0xcc, 0x6e, 0xe6,
  0xdd, 0xdd, 0xd9, 0x99, 0xbb, 0xbb, 0x67, 0x63, 0x6e, 0x0e, 0xec, 0xcc, 0xdd, 0xdc, 0x99, 0x9f,
  0xbb, 0xb9, 0x33, 0x3e, 0x54, 0x45, 0x54, 0x52, 0x49, 0x53, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x0b, 0x89, 0xb5,
  0xc3, 0x8b, 0x02, 0xcd, 0x2b, 0x2a, 0xf0, 0x41, 0xe6, 0x03, 0x20, 0xfa, 0x46, 0xf0, 0x41, 0xe6
]);

/*
 * Internal Methods
 */

/*
 * Exposed Methods
 */

Async.Future<Map<Emufiledb.IdbStore, Set<int>>> _detachedChips() async {

  final Set<int> rams = new Set.from(g_dbProxy.rams.keys);
  final Set<int> sss = new Set.from(g_dbProxy.sss.keys);

  final Iterable<Async.Future<Map<String, dynamic>>> futureCartsInfo =
    g_dbProxy.carts.values.map(
        (Emufiledb.ProxyEntry prox) => g_dbProxy.info(prox));

  (await Async.Future.wait(futureCartsInfo))
  .forEach(
      (Map<String, dynamic> cinfo) {
        rams.remove(cinfo['ram']);
        cinfo['ssList']?.forEach((int ssIdOpt) {
          sss.remove(ssIdOpt);
        });
      });
  return {
    Emufiledb.IdbStore.Ram: rams,
    Emufiledb.IdbStore.Ss: sss,
  };
}

Async.Future init(Emulator.Emulator emu) async {
  Ft.log('main', 'init', [emu]);

  final filedbFut = Emufiledb.make(Html.window.indexedDB);
  final cartHtmlFut = Html.HttpRequest.getString("cart_table.html");

  g_dbProxy = await filedbFut;
  final cartHtml = await cartHtmlFut;

  g_cartBank = new CartBank(cartHtml, _domCartValidator);
  g_dChipBank = new DetachedChipBank();
  g_gbSocket = new GameBoySocket();

  await g_dbProxy.addRom('tetris_head.rom', tetrisHead);
  await g_dbProxy.addRom('tetris_head.rom', tetrisHead);
  await g_dbProxy.addRam('pokemon.save', tetrisHead);
  await g_dbProxy.addRam('pokemon.save', tetrisHead);
  await g_dbProxy.addRam('pokemon.save', tetrisHead);
  print(g_dbProxy);

  final futureDetachedChips = _detachedChips();

  g_dbProxy.carts.forEach((int i, Emufiledb.ProxyEntry prox){
    g_cartBank.add(prox);
  });

  final detachedChips = await futureDetachedChips;
  detachedChips[Emufiledb.IdbStore.Ram].forEach((int id){
    g_dChipBank.newRam(g_dbProxy.rams[id]);
  });
  detachedChips[Emufiledb.IdbStore.Ss].forEach((int id){
    g_dChipBank.newSs(g_dbProxy.sss[id]);
  });

  return ;
}

main () {
  print('Hello World');

  init(null)
    ..catchError((e, st) {
          print(e);
          print(st);
  });
}
