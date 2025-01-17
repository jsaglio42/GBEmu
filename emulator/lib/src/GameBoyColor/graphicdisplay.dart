// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   graphicdisplay.dart                                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/31 18:55:32 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/enums.dart";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";

import "package:emulator/src/hardware/hardware.dart" as Hardware;

import "package:emulator/src/video/sprite.dart";
import "package:emulator/src/video/tile.dart";
import "package:emulator/src/video/tileinfo.dart";

abstract class GraphicDisplay
  implements Hardware.Hardware {

  /* API **********************************************************************/
  void updateDisplay() {
    if (this.lcd.shouldDrawLine)
      _drawLine();
    if (this.lcd.shouldRefreshScreen)
      this.lcd.refreshScreen();
    return ;
  }

  /* Drawing functions ********************************************************/
  void _drawLine() {
    Ft.fillBuffer(this.lcd.bgColorIDs, null);
    Ft.fillBuffer(this.lcd.spriteColors, null);

    final int y = this.memr.LY;
    for (int x = 0; x < LCD_WIDTH; ++x)
    {
      this.lcd.bgColorIDs[x] = _useWindowColorID(x, y)
        ? _getWindowColorID(x, y)
        : _getBackgroundColorID(x, y);
    }
    _setSpriteColors(y);
    _updateScreenBuffer(y);
    return ;
  }

  bool _useWindowColorID(int x, int y) {
    if (!this.memr.rLCDC.isWindowDisplayEnabled)
      return false;
    final int posY = y - this.memr.WY;
    if (posY < 0 || posY >= LCD_HEIGHT)
      return false;
    final int posX =  x - (this.memr.WX - 7);
    if (posX < 0 || posX >= LCD_WIDTH)
      return false;
    return true;
  }

  int _getBackgroundColorID(int x, int y) {
    if (!this.memr.rLCDC.isBackgroundDisplayEnabled)
      return (null);
    final int posY = (y + this.memr.SCY) & 0xFF;
    final int posX =  (x + this.memr.SCX) & 0xFF;
    return (_getMappedColorID(posX, posY, this.memr.rLCDC.tileMapID_BG));
  }

  int _getWindowColorID(int x, int y) {
    final int posY = y - this.memr.WY;
    final int posX =  x - (this.memr.WX - 7);
    return (_getMappedColorID(posX, posY, this.memr.rLCDC.tileMapID_WIN));
  }

  int _getMappedColorID(int mapX, int mapY, int tileMapID) {
    final int tileX = mapX ~/ 8;
    final int tileY = mapY ~/ 8;
    final int relativeX = mapX % 8;
    final int relativeY = mapY % 8;
    final int tileID = this.videoram.getTileID(tileX, tileY, tileMapID);
    final TileInfo tinfo = this.videoram.getTileInfo(tileX, tileY, tileMapID);
    final Tile tile = this.videoram.getTile(tileID, 0, this.memr.rLCDC.tileDataSelectID);
    return tile.getColorID(relativeX, relativeY, false, false);
  }

  void _setSpriteColors(int y) {
    if (!this.memr.rLCDC.isSpriteDisplayEnabled)
      return ;
    Ft.fillBuffer(this.lcd.zBuffer, -1);

    final int sizeY = this.memr.rLCDC.spriteSize;
    for (int spriteno = 0; spriteno < 40; ++spriteno)
    {
      Sprite s = this.oam[spriteno];
      final int unsafeY = y - (s.posY - 16);
      if (unsafeY < 0 || unsafeY >= sizeY)
        continue ;
      final int tileID = s.adjustedTileID(sizeY, unsafeY, s.info.flipY);
      final Tile tile = this.videoram.getTile(tileID, 0, 1);

      final int relativeY = unsafeY % 8;
      for (int relativeX = 0; relativeX < 8; ++relativeX)
      {
        int x = (s.posX - 8) + relativeX;
        if (x >= LCD_WIDTH)
          break ;
        else if (x < 0
          || this.lcd.zBuffer[x] >= 0
          /* To be changed using BG priority as well */
          || (s.info.priorityIsBG && this.lcd.bgColorIDs[x] != 0 && this.lcd.bgColorIDs[x] != null))
          continue ;
        final int colorID = tile.getColorID(relativeX, relativeY, s.info.flipX, s.info.flipY);
        if (colorID == 0)
          continue ;
        final int OBP = (s.info.OBP_DMG == 0) ? this.memr.OBP0 : this.memr.OBP1;
        final int mappedColorID = _mapColorID(colorID, OBP);
        this.lcd.spriteColors[x] = this.palette.getColor(1, mappedColorID);
        this.lcd.zBuffer[x] = spriteno;
      }
    }
  }

  void _updateScreenBuffer(int y) {
    assert(this.lcd.bgColorIDs.length == LCD_WIDTH, 'Failure');
    assert(this.lcd.spriteColors.length == LCD_WIDTH, 'Failure');
    final int BGP = this.memr.BGP;
    for (int x = 0; x < LCD_WIDTH; ++x)
    {
      if (this.lcd.spriteColors[x] != null)
        this.lcd.setPixel(x, y, this.lcd.spriteColors[x]);
      else
      {
        int mappedColorID = _mapColorID(this.lcd.bgColorIDs[x], BGP);
        this.lcd.setPixel(x, y, this.palette.getColor(2, mappedColorID));
      }
    }
    return ;
  }

  int _mapColorID(int colorID, int palette) {
    if (colorID == null)
      return 0x00;
    else
      return (palette >> (2 * colorID)) & 0x3;
  }

}
