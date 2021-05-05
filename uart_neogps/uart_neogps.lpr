program uart_neogps;
{
  This file is part of pico-fpcsamples
  Copyright (c) 2021 -  Michael Ring

  This program is free software: you can redistribute it and/or modify it under the terms of the FPC modified GNU
  Library General Public License for more

  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the FPC modified GNU Library General Public
  License for more details.
}

{$MODE OBJFPC}
{$H+}
{$MEMORY 10000,10000}

uses
  pico_c,
  pico_gpio_c,
  pico_uart_c,
  neogps;
const
  BAUDRATE=115200;
  GPS_BAUDRATE=9600;
var
  gps : TNeoGPS;

begin
  gpio_init(TPicoPin.LED);
  gpio_set_dir(TPicoPin.LED,TGPIODirection.GPIO_OUT);
  uart_init(uart0, BAUDRATE);
  gpio_set_function(TPicoPin.UART_TX, TGPIOFunction.GPIO_FUNC_UART);
  gpio_set_function(TPicoPin.UART_RX, TGPIOFunction.GPIO_FUNC_UART);
  uart_init(uart1, GPS_BAUDRATE);
  gpio_set_function(TPicoPin.GP4_UART1_TX, TGPIOFunction.GPIO_FUNC_UART);
  gpio_set_function(TPicoPin.GP5_UART1_RX, TGPIOFunction.GPIO_FUNC_UART);

  gps.init(uart1);

  repeat
    gpio_put(TPicoPin.LED,false);
    gps.poll;
    gpio_put(TPicoPin.LED,true);
    if (gps.status = TGPSStatusCode.INITIALIZING) then
      uart_puts(uart0,'Initializing connection to GPS'+#13#10);
    if (gps.status = TGPSStatusCode.SERIALDETECTED) then
      uart_puts(uart0,'Found Serial Device'+#13#10);
    if (gps.status = TGPSStatusCode.GPSDETECTED) then
      uart_puts(uart0,'Found GPS Device, waiting for position fix'+#13#10);
    if (gps.status = TGPSStatusCode.POSITIONFIX) then
    begin
      uart_puts(uart0,'Time: '+gps.GPRMC[TGPSGPRMCField.UTCTime]+' Date: '+gps.GPRMC[TGPSGPRMCField.UTCDate]+' ');
      uart_puts(uart0,'Position: '+gps.GPRMC[TGPSGPRMCField.Lattitude]+gps.GPRMC[TGPSGPRMCField.LattitudeIndicator]+' ');
      uart_puts(uart0,gps.GPRMC[TGPSGPRMCField.Longgitude]+gps.GPRMC[TGPSGPRMCField.LongitudeIndicator]+' ');
      uart_puts(uart0,'Satellites: '+gps.GPGGA[TGPSGPGGAField.SatellitesUsed]+' Altitude: '+gps.GPGGA[TGPSGPGGAField.MSLAttitude]+' m ');
      uart_puts(uart0,'Speed: '+gps.GPRMC[TGPSGPRMCField.Speed]+' km/h Course: '+gps.GPRMC[TGPSGPRMCField.Course]+' Degrees'+#13#10);
    end;
  until 1=0;
end.
