// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   graphics.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/15 19:51:08 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/enums.dart";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";

import "package:emulator/src/hardware/hardware.dart" as Hardware;
import "package:emulator/src/hardware/data.dart" as Data;
import "package:emulator/src/mixins/interruptmanager.dart" as Interrupt;
import "package:emulator/src/mixins/tail_ram.dart" as Tailram;
import "package:emulator/src/mixins/mmu.dart" as Mmu;

enum GraphicMode {
  HBLANK,
  VBLANK,
  OAM_ACCESS,
  VRAM_ACCESS
}

enum Color {
  White,
  LightGrey,
  DarkGrey,
  Black
}

final Map<Color, List<int>> _colorMap = new Map.unmodifiable({
  Color.White : [0xFF, 0xFF, 0xFF, 0xFF],
  Color.LightGrey : [0xAA, 0xAA, 0xAA, 0xFF],
  Color.DarkGrey : [0x55, 0x55, 0x55, 0x55],
  Color.Black : [0x00, 0x00, 0x00, 0xFF]
});

/* Small classes used to save data/store info *********************************/
// class GRegisterCurrentInfo {

//   int LCDC;
//   int STAT;
//   int LYC;
//   int LY;
//   int SCY;
//   int SCX;
//   int WY;
//   int WX;
//   int BGP;
//   int OBP0;
//   int OBP1;

//   GRegisterCurrentInfo();

//   void init() {
//     this.LCDC = this.memr.LCDC;
//     this.STAT = this.memr.STAT;
//     this.LYC = this.memr.LYC;
//     this.LY = this.memr.LY;
//     this.SCY = this.memr.SCY;
//     this.SCX = this.memr.SCX;
//     this.WY = this.memr.WY;
//     this.WX = this.memr.WX - 7;
//     this.BGP = this.memr.BGP;
//     this.OBP0 = this.memr.OBP0;
//     this.OBP1 = this.memr.OBP1;
//     return ;
//   }

//   bool get isLCDEnabled => (this.LCDC >> 7) & 0x1 == 1;
//   bool get isWindowDisplayEnabled => (this.LCDC >> 5) & 0x1 == 1;
//   bool get isSpriteDisplayEnabled => (this.LCDC >> 1) & 0x1 == 1;
//   bool get isBackgroundDisplayEnabled => (this.LCDC >> 1) & 0x1 == 1;
//   int  get tileMapAddress_BG => (this.LCDC >> 3) & 0x1 == 1 ? 0x9C00 : 0x9800;
//   int  get tileMapAddress_WIN => (this.LCDC >> 6) & 0x1 == 1 ? 0x9C00 : 0x9800;

//   GraphicMode get mode => GraphicMode.values[this.STAT & 0x3];

//   bool isInterruptMonitored(GraphicMode g) {
//     return (this.STAT >> (g.index + 3)) & 0x1 == 1;
//   }

//   int getTileAddress(int tileID) {
//     assert(tileID & ~0xFF == 0, 'Invalid tileID');
//     if ((this.LCDC >> 4) & 0x1 == 1)
//       return 0x8000 + tileID * 16;
//     else
//       return 0x9000 + tileID.toSigned(8) * 16;
//   }

//   int getColor(int colorID, int palette) {
//     if (colorID == null)
//       return 0;
//     else
//       return (palette >> (2 * colorID)) & 0x3;
//   }

// }

/* Small classes used to save updated info ************************************/
class GRegisterUpdatedInfo {

    bool drawLine = false;
    bool updateScreen = false;

    int LY = null;
    GraphicMode mode = null;
    int STAT = null;

    GRegisterUpdatedInfo();

    void reset() {
      this.drawLine = false;
      this.updateScreen = false;
      this.mode = null;
      this.STAT = null;
      this.LY = null;
      return ;
    }

}

/* Mixins that handle graphics ************************************************/
abstract class TrapAccessors {

  void resetLYRegister();
  void execDMA(int v);

}

abstract class Graphics
  implements Hardware.Hardware
  , Tailram.TailRam
  , Mmu.Mmu
  , Interrupt.InterruptManager
  , TrapAccessors {

  Uint8List _buffer = new Uint8List(LCD_DATA_SIZE);
  
  int _counterScanline = 0;
  GRegisterUpdatedInfo _updated = new GRegisterUpdatedInfo();

  List<int> _BGColorIDs = new List<int>(LCD_WIDTH);
  List<int> _SpriteColors = new List<int>(LCD_WIDTH);
  List<int> _zbuffer = new List<int>(LCD_WIDTH);

  /* API **********************************************************************/
  void updateGraphics(int nbClock) {
    // _current.init(this);
    _updated.reset();

    /* will need special routine when enabling */
    if (_current.isLCDEnabled)
    {
      _updateGraphicMode(nbClock);
      if (_updated.drawLine)
        _drawLine();
      if (_updated.updateScreen)
        _updateScreen();
      _updateGraphicRegisters();
    }
    return ;
  }

  // to be implemented
  // void enableScreen(int nbClock) {
  //   _updated.LY = 0;
  //   _counterScanline = 0;
  //   _updated.mode = GraphicMode.OAM_ACCESS;
  // }

  void resetLYRegister() {
    this.memr.LY = 0;
    return ;
  }

  void execDMA(int v) {
    final int addr = v << 8;

    for (int i = 0 ; i < 0xA0; i++)
      // TODO CHECK: `tr_push8` was `tailRam.push8_unsafe`
      this.tr_push8(0xFE00 + i, this.pull8(addr + i));
    this.memr.DMA = v;
    return ;
  }

  /* Private ******************************************************************/
  void _updateGraphicMode(int nbClock) {
    // print('$_counterScanline : ${_current.mode.toString()}');
    _counterScanline += nbClock;
    switch (_current.mode)
    {
      case (GraphicMode.OAM_ACCESS) : _OAM_routine(); break;
      case (GraphicMode.VRAM_ACCESS) : _VRAM_routine(); break;
      case (GraphicMode.HBLANK) : ; _HBLANK_routine(); break;
      case (GraphicMode.VBLANK) : ; _VBLANK_routine(); break;
      default: assert (false, 'GraphicMode: switch failure');
    }
    assert(_updated.LY != null, "LY: Condition Failure");
    assert(_updated.mode != null, "Mode: Condition Failure");
  }

  /* Switch to VRAM_ACCESS or remain as is */
  void _OAM_routine() {
    if (_counterScanline >= CLOCK_PER_OAM_ACCESS)
    {
      _counterScanline -= CLOCK_PER_OAM_ACCESS;
      _updated.LY = _current.LY;
      _updated.mode = GraphicMode.VRAM_ACCESS;
    }
    else
    {
      _updated.LY = _current.LY;
      _updated.mode = _current.mode;
    }
  }

  /* Switch to HBLANK or remain as is */
  void _VRAM_routine() {
    if (_counterScanline >= CLOCK_PER_VRAM_ACCESS)
    {
      _counterScanline -= CLOCK_PER_VRAM_ACCESS;
      _updated.LY = _current.LY;
      _updated.mode = GraphicMode.HBLANK;
      if (_current.isInterruptMonitored(_updated.mode))
        this.requestInterrupt(InterruptType.LCDStat);
    }
    else
    {
      _updated.LY = _current.LY;
      _updated.mode = _current.mode;
    }
  }

  /* Switch to OAM_ACCESS/VBLANK or remain as is */
  void _HBLANK_routine() {
    if (_counterScanline >= CLOCK_PER_HBLANK)
    {
      _counterScanline -= CLOCK_PER_HBLANK;
      _updated.drawLine = true;
      _updated.LY = _current.LY + 1;
      if (_updated.LY < VBLANK_THRESHOLD)
        _updated.mode = GraphicMode.OAM_ACCESS;
      else
      {
        _updated.mode = GraphicMode.VBLANK;
        this.requestInterrupt(InterruptType.VBlank);
      }
      if (_current.isInterruptMonitored(_updated.mode))
        this.requestInterrupt(InterruptType.LCDStat);
    }
    else
    {
      _updated.LY = _current.LY;
      _updated.mode = _current.mode;
    }
  }

  /* Switch to OAM_ACCESS or remain as is */
  void _VBLANK_routine() {
    if (_counterScanline >= CLOCK_PER_LINE)
    {
      _counterScanline -= CLOCK_PER_LINE;
      final int incLY = _current.LY + 1;
      if (incLY >= FRAME_THRESHOLD)
      {
        _updated.updateScreen = true;
        _updated.LY = 0;
        _updated.mode = GraphicMode.OAM_ACCESS;
        if (_current.isInterruptMonitored(_updated.mode))
          this.requestInterrupt(InterruptType.LCDStat);
      }
      else
      {
        _updated.LY = incLY;
        _updated.mode = _current.mode;
      }
    }
    else
    {
      _updated.LY = _current.LY;
      _updated.mode = _current.mode;
    }
  }

  /* MUST trigger LYC interrupt and push new STAT/LY register */
  void _updateGraphicRegisters() {
    final int interrupt_bits = _current.STAT & 0xF8;
    final int mode_bits = _updated.mode.index;
    if (_current.LYC != _updated.LY)
      _updated.STAT = mode_bits | interrupt_bits;
    else
    {
      _updated.STAT = mode_bits | interrupt_bits | 0x4;
      if ((_current.STAT >> 6) & 0x1 == 1)
        this.requestInterrupt(InterruptType.LCDStat);
    }
    this.memr.STAT = _updated.STAT;
    this.memr.LY = _updated.LY;
    return ;
  }

  /* Drawing functions ********************************************************/
  void _updateScreen() {
    Uint8List tmp;

    // print('UpdateScreen');
    tmp = _buffer;
    _buffer = this.lcdScreen;
    this.lcdScreen = tmp;
    return ;
  }

  void _drawLine() {
    _BGColorIDs.fillRange(0, _BGColorIDs.length, null);
    _SpriteColors.fillRange(0, _SpriteColors.length, null);

    // print('Draw Line');
    for (int x = 0; x < LCD_WIDTH; ++x)
    {
      _setBackgroundColorID(x);
      _setWindowColorID(x);
    }
    _setSpriteColor();
    _updateScreenBuffer();
    return ;
  }

  void _setBackgroundColorID(int x) {
    // print('Background');
    if (!_current.isBackgroundDisplayEnabled)
      return ;
    final int posY = (_current.LY + _current.SCY) & 0xFF;
    final int posX =  (x + _current.SCX) & 0xFF;
    final int tileY = posY ~/ 8;
    final int tileX = posX ~/ 8;
    final int tileID = this.videoRam.pull8_unsafe(_current.tileMapAddress_BG + tileY * 32 + tileX);

    final int tileAddress = _current.getTileAddress(tileID);

    final int relativeY = posY % 8;
    final int relativeX = posX % 8;
    final int tileRow_l = this.videoRam.pull8_unsafe(tileAddress + relativeY * 2);
    final int tileRow_h = this.videoRam.pull8_unsafe(tileAddress + relativeY * 2 + 1);
    final int colorId_l = (tileRow_l >> (7 - relativeX)) & 0x1 == 1 ? 0x1 : 0x0;
    final int colorId_h = (tileRow_h >> (7 - relativeX)) & 0x1 == 1 ? 0x2 : 0x0;
    _BGColorIDs[x] = colorId_l | colorId_h;
    return ;
  }

  void _setWindowColorID(int x) {
    // print('Window');
    if (!_current.isWindowDisplayEnabled)
      return ;
    final int posY = _current.LY - _current.WY;
    if (posY < 0 || posY >= LCD_HEIGHT)
      return ;
    final int posX =  x - _current.WX;
    if (posX < 0 || posX >= LCD_WIDTH)
      return ;
    final int tileY = posY ~/ 8;
    final int tileX = posX ~/ 8;
    final int tileID = this.videoRam.pull8_unsafe(_current.tileMapAddress_WIN + tileY * 32 + tileX);

    final int tileAddress = _current.getTileAddress(tileID);

    final int relativeY = posY % 8;
    final int relativeX = posX % 8;
    final int tileRow_l = this.videoRam.pull8_unsafe(tileAddress + relativeY * 2);
    final int tileRow_h = this.videoRam.pull8_unsafe(tileAddress + relativeY * 2 + 1);
    final int colorId_l = (tileRow_l >> (7 - relativeX)) & 0x1 == 1 ? 0x1 : 0x0;
    final int colorId_h = (tileRow_h >> (7 - relativeX)) & 0x1 == 1 ? 0x2 : 0x0;
    _BGColorIDs[x] = colorId_l | colorId_h;
    return ;
  }

  void _setSpriteColor() {
    if (!_current.isSpriteDisplayEnabled)
      return ;
    _zbuffer.fillRange(0, _zbuffer.length, -1);

    final int sizeY = ((_current.LCDC >> 2) & 0x1 == 1) ? 16 : 8;

    for (int spriteno = 0; spriteno < 40; ++spriteno) {
      int spriteOffset = 0xFE00 + spriteno * 4;
      int posY = this.tr_pull8(spriteOffset) - 16;
      int relativeY = _current.LY - posY;
      if (relativeY < 0 || relativeY >= sizeY)
        continue ;

      int info = this.tr_pull8(spriteOffset + 3);
      bool priorityIsBG = (info >> 7) & 0x1 == 1;
      bool flipY = (info >> 6) & 0x1 == 1;
      bool flipX = (info >> 5) & 0x1 == 1;
      int OBP = ((info >> 4) & 0x1 == 0) ? _current.OBP0 : _current.OBP1;

      if (flipY)
        relativeY = sizeY - 1 - relativeY;

      int tileID = this.tr_pull8(spriteOffset + 2);
      /* tile address should use sizeY ? TO BE CHECKED */
      int tileAddress = 0x8000 + tileID * 16;
      int tileRow_l = this.videoRam.pull8_unsafe(tileAddress + relativeY * 2);
      int tileRow_h = this.videoRam.pull8_unsafe(tileAddress + relativeY * 2 + 1);
      int posX = this.tr_pull8(spriteOffset + 1) - 8;

      for (int relativeX = 0; relativeX < 8; ++relativeX) {
        int x = posX + relativeX;
        if (x < 0)
          continue ;
        if (x >= LCD_WIDTH)
          break ;

        /* Not sure about BG transparency here; TO BE CHECKED */
        if (priorityIsBG && _BGColorIDs[x] != 0 && BGColorIDs[x] != null)
          continue ;

        if (zbuffer[x] >= 0)
          continue ;

        int colorId_l;
        int colorId_h;
        if (flipX)
        {
          colorId_l = (tileRow_l >> relativeX) & 0x1 == 1 ? 0x1 : 0x0;
          colorId_h = (tileRow_h >> relativeX) & 0x1 == 1 ? 0x2 : 0x0;
        }
        else
        {
          colorId_l = (tileRow_l >> (7 - relativeX)) & 0x1 == 1 ? 0x1 : 0x0;
          colorId_h = (tileRow_h >> (7 - relativeX)) & 0x1 == 1 ? 0x2 : 0x0;
        }

        int colorID = colorId_l | colorId_h;
        if (colorID == 0)
          continue;
        _SpriteColors[x] = _current.getColor(colorID, OBP);
        _zbuffer[x] = spriteno;
      }
    }
  }

  void _updateScreenBuffer() {
    assert(_BGColorIDs.length == LCD_WIDTH, 'Failure');
    assert(_SpriteColors.length == LCD_WIDTH, 'Failure');
    int BGP = _current.BGP;
    for (int x = 0; x < LCD_WIDTH; ++x)
    {
      Color c;
      int pixelOffset = (_current.LY * LCD_WIDTH + x) * 4;
      if (_SpriteColors[x] != null)
        c = Color.values[_SpriteColors[x]];
      else
        c = Color.values[_current.getColor(_BGColorIDs[x], BGP)];
      List cList = _colorMap[c];
      _buffer[pixelOffset + 0] = cList[0];
      _buffer[pixelOffset + 1] = cList[1];
      _buffer[pixelOffset + 2] = cList[2];
      _buffer[pixelOffset + 3] = cList[3];
    }
    return ;
  }

}
